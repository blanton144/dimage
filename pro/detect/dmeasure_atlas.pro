;+
; NAME:
;   dmeasure_atlas
; PURPOSE:
;   Run measurements on atlas results
; CALLING SEQUENCE:
;   dmeasure_atlas, subdir
; COMMENTS:
;   Assumes dimage-style detection outputs
; REVISION HISTORY:
;   31-July-2010
;-
;------------------------------------------------------------------------------
function clip_ivar, ivar, xcen, ycen, radius

out= ivar
nx=(size(out,/dim))[0]
ny=(size(out,/dim))[1]

xx= findgen(nx)#replicate(1., ny)-xcen
yy= replicate(1.,nx)#findgen(ny)-ycen
rr2= xx^2+yy^2
iclip= where(rr2 gt radius^2, nclip)
if(nclip gt 0) then $
  out[iclip]=0.

return, out

end
;
pro dmeasure_atlas, noclobber=noclobber

nmax_sersic= 3000L
sub='atlases'
postfix=''

spawn, /nosh, 'pwd', subdir
subdir=subdir[0]

if(keyword_set(noclobber) ne 0) then begin
   dreadcen, measure=measure
   if(n_tags(measure) gt 0) then begin
      splog, 'Already found measurements, skipping.'
      return
   endif
endif

prefix= file_basename(subdir)

pset= gz_mrdfits(subdir+'/'+prefix+'-pset.fits',1)
ref= (pset.ref)[0]
nbands= n_elements(pset.imfiles)

;; hack to find pixel scale
pixscales= fltarr(nbands)
for i=0L, nbands-1L do begin
    hdr= headfits(strtrim(pset.imfiles[i],2))
    nx= long(sxpar(hdr, 'NAXIS1'))
    ny= long(sxpar(hdr, 'NAXIS2'))
    ntest=10L
    xyad, hdr, nx/2L, ny/2L, ra1, dec1
    xyad, hdr, nx/2L+ntest, ny/2L, ra2, dec2
    cirrange,ra1
    cirrange,ra2
    spherematch, ra1, dec1, ra2,dec2, 360., m1, m2, d12
    pixscales[i]=d12/float(ntest)
endfor
scales= pixscales[ref]/pixscales

;; psf file names
psffiles= strarr(nbands)
for i=0L, nbands-1L do begin
    imfile= strtrim(string(pset.imfiles[i]),2)
    psffiles[i]=(strmid(imfile, 0, strlen(imfile)-8)+'-bpsf.fits')
endfor

phdr= gz_headfits(subdir+'/'+prefix+'-r.fits')
pim= gz_mrdfits(subdir+'/'+prefix+'-pimage.fits',0)
if(keyword_set(pim)) then begin
    nx=(size(pim,/dim))[0]
    ny=(size(pim,/dim))[1]
    xyad, phdr, float(nx/2L), float(ny/2L), racen, deccen
    cirrange, racen
    pid=pim[nx/2L, ny/2L]
    pstr=strtrim(string(pid),2)
    
    mfile=subdir+'/'+sub+'/'+pstr+'/'+prefix+'-'+pstr+ $
      '-measure'+postfix+'.fits'
    sfile=subdir+'/'+sub+'/'+pstr+'/'+prefix+'-'+pstr+ $
      '-sersic'+postfix+'.fits'
    if(keyword_set(noclobber) eq 0 OR $
       gz_file_test(mfile) eq 0) then begin
        
        acat=gz_mrdfits(subdir+'/'+sub+'/'+pstr+'/'+prefix+'-acat-'+ $
                        pstr+'.fits',1)
        nkeep=0

        if(n_tags(acat) gt 0) then $
          ikeep=where(acat.good gt 0 and acat.type eq 0, nkeep)
        
        if(tag_exist(acat, 'RACEN') gt 0 AND $
           nkeep gt 0) then begin
            acat=acat[ikeep]
            spherematch, racen, deccen, acat.racen, $
              acat.deccen, 3., m1, m2
            if (m1[0] eq -1) then $
              message, 'no match?'
            aid=acat[m2].aid
            astr=strtrim(string(aid),2)
            
            rimage=gz_mrdfits(subdir+'/'+sub+'/'+pstr+'/'+prefix+'-'+ $
                              pstr+'-atlas-'+astr+'.fits', ref, hdr)
            rinvvar=gz_mrdfits(subdir+'/'+sub+'/'+pstr+'/'+prefix+'-'+ $
                               'ivar-'+pstr+'.fits', ref)
            rinvvar=rinvvar>0.
            
            if((keyword_set(noclobber) eq 0 OR $
                gz_file_test(mfile) eq 0) AND $
               keyword_set(nomeasure) eq 0) then begin
                
                rnx= (size(rimage, /dim))[0]
                rny= (size(rimage, /dim))[1]

                adxy, hdr, acat[m2].racen, acat[m2].deccen, xcen, ycen

                psf= gz_mrdfits(psffiles[ref])
                
                dmeasure, rimage, rinvvar, xcen=xcen, ycen=ycen, $
                  measure=r_measure
                r_sersic=0
                model=0
; jm13jul19siena - bug fix                
                if(rnx lt nmax_sersic and rny lt nmax_sersic) then $
                   dsersic, rimage, rinvvar, xcen=r_measure.xcen, $
                            ycen=r_measure.ycen, sersic=r_sersic, $
                            /fixcen, /fixsky, model=model, psf=psf

                outhdr= hdr
                sxdelpar, outhdr, 'XTENSION'
                sxdelpar, outhdr, 'PCOUNT'
                sxdelpar, outhdr, 'GCOUNT'
                mwrfits, float(model), sfile, outhdr, /create

                xyad, hdr, r_measure.xcen, r_measure.ycen, racen, deccen
                cirrange, racen
                
                mall= {racen:racen, $
                       deccen:deccen, $
                       xcen:r_measure.xcen, $
                       ycen:r_measure.ycen, $
                       nprof:bytarr(nbands), $
                       profmean:fltarr(nbands, 15), $
                       profmean_ivar:fltarr(nbands, 15), $
                       profradius:r_measure.profradius, $
                       qstokes:fltarr(nbands, 15), $
                       ustokes:fltarr(nbands, 15), $
                       bastokes:fltarr(nbands, 15), $
                       phistokes:fltarr(nbands, 15), $
                       petroflux:fltarr(nbands), $
                       petroflux_ivar:fltarr(nbands), $
                       fiberflux:fltarr(nbands), $
                       fiberflux_ivar:fltarr(nbands), $
                       petrorad:r_measure.petrorad, $
                       petror50:r_measure.petror50, $
                       petror90:r_measure.petror90, $
                       ba50:r_measure.ba50, $
                       phi50:r_measure.phi50, $
                       ba90:r_measure.ba90, $
                       phi90:r_measure.phi90, $
                       sersicflux:fltarr(nbands), $
                       sersicflux_ivar:fltarr(nbands), $
                       sersic_r50:1., $
                       sersic_n:1., $
                       sersic_ba:1., $
                       sersic_phi:0., $
                       asymmetry:fltarr(nbands), $
                       clumpy:fltarr(nbands), $
                       dflags:lonarr(nbands), $
                       aid:aid}

                if(n_tags(r_sersic) gt 0) then begin
                   sersic_r50=r_sersic.sersicr50
                   sersic_n=r_sersic.sersicn
                   sersic_ba=r_sersic.axisratio
                   sersic_phi=r_sersic.orientation
                endif
                   
                for iband=0L, nbands-1L do begin
                    image=gz_mrdfits(subdir+'/'+sub+'/'+pstr+'/'+prefix+'-'+ $
                                      pstr+'-atlas-'+astr+'.fits', iband, hdr)
                    invvar=gz_mrdfits(subdir+'/'+sub+'/'+pstr+'/'+prefix+'-'+ $
                                      'ivar-'+pstr+'.fits', iband)
                    invvar=invvar>0.

                    psf= gz_mrdfits(psffiles[iband], /silent)

                    adxy, hdr, racen, deccen, xcen, ycen
                    dmeasure, image, invvar, xcen=xcen, $
                      ycen=ycen, /fixcen, measure=tmp_measure, $
                      cpetrorad= mall.petrorad*scales[iband], $
                      faper= 7.57576*scales[iband]
                    if(rnx lt nmax_sersic and rny lt nmax_sersic) then begin
                       curr_sersic= r_sersic
                       curr_sersic.xcen= xcen
                       curr_sersic.ycen= ycen
                       curr_sersic.sersicr50= r_sersic.sersicr50*scales[iband]
                       dsersic, image, invvar, xcen=xcen, ycen=ycen, $
                                sersic=curr_sersic, /onlyflux, /fixcen, $
                                /fixsky, psf=psf, model=model
                    endif else begin
                       curr_sersic=0
                    endelse
                    
                    mall.nprof[iband]= tmp_measure.nprof
                    mall.profmean[iband,*]= $
                      tmp_measure.profmean
                    mall.profmean_ivar[iband,*]= $
                      tmp_measure.profmean_ivar
                    mall.qstokes[iband,*]= tmp_measure.qstokes
                    mall.ustokes[iband,*]= tmp_measure.ustokes
                    mall.bastokes[iband,*]= tmp_measure.bastokes
                    mall.phistokes[iband,*]= tmp_measure.phistokes
                    mall.petroflux[iband]= tmp_measure.petroflux
                    mall.petroflux_ivar[iband]= $
                      tmp_measure.petroflux_ivar
                    mall.fiberflux[iband]= tmp_measure.fiberflux
                    mall.fiberflux_ivar[iband]= $
                      tmp_measure.fiberflux_ivar
                    if(n_tags(curr_sersic) gt 0) then begin
                       mall.sersicflux[iband]= curr_sersic.sersicflux
                       mall.sersicflux_ivar[iband]= curr_sersic.sersicflux_ivar
                    endif
                    mall.asymmetry[iband]= tmp_measure.asymmetry
                    mall.clumpy[iband]= tmp_measure.clumpy
                    mall.dflags[iband]= tmp_measure.dflags
                endfor
                
                dhdr= dimage_hdr()
                mwrfits, mall, mfile, dhdr, /create
                spawn, 'gzip -vf '+mfile
            endif

        endif 
    endif
endif

end
