;+
; NAME:
;   dmeasure_multi
; PURPOSE:
;   Measure multiple bands simultaneously
; CALLING SEQUENCE:
;   dmeasure_multi, subdir
; COMMENTS:
;   Assumes dimage-style detection outputs
; REVISION HISTORY:
;   31-July-2010
;-
;------------------------------------------------------------------------------
pro dmeasure_multi, subdir, noclobber=noclobber, hand=hand, ref=ref, $
                    scales=scales, nbands=nbands, check=check

if(n_elements(ref) eq 0) then ref=2L
if(NOT keyword_set(nbands)) then nbands=5L
if(n_elements(scales) eq 0) then $
  scales= fltarr(nbands)+1.

prefix= file_basename(subdir)

phdr= gz_headfits(subdir+'/'+prefix+'-r.fits')
pim= gz_mrdfits(subdir+'/'+prefix+'-pimage.fits',0)
if(keyword_set(pim)) then begin
    nx=(size(pim,/dim))[0]
    ny=(size(pim,/dim))[1]
    xyad, phdr, float(nx/2L), float(ny/2L), racen, deccen
    pid=pim[nx/2L, ny/2L]
    pstr=strtrim(string(pid),2)
    
    sub='atlases'
    postfix=''
    if(gz_file_test('hand/'+pstr) gt 0 AND $
       keyword_set(hand) gt 0) then begin
        sub='hand'
        postfix='-hand'
    endif
    
    mfile=subdir+'/'+sub+'/'+pstr+'/'+prefix+'-'+pstr+ $
      '-measure'+postfix+'.fits'
    if(keyword_set(noclobber) eq 0 OR $
       gz_file_test(mfile) eq 0 OR $
       keyword_set(check) gt 0 OR $
       keyword_set(gather) gt 0) then begin
        
        acat=gz_mrdfits(subdir+'/'+sub+'/'+pstr+'/'+prefix+'-'+pstr+ $
                        '-acat.fits',1)
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
            rinvvar=gz_mrdfits(subdir+'/parents/'+prefix+'-parent-'+ $
                               pstr+'.fits', ref*2L+1L, hdr)
            rinvvar=rinvvar>0.

            if((keyword_set(noclobber) eq 0 OR $
                gz_file_test(mfile) eq 0) AND $
               keyword_set(nomeasure) eq 0) then begin
                
                adxy, hdr, acat[m2].racen, acat[m2].deccen, xcen, ycen
                
                dmeasure, rimage, rinvvar, xcen=xcen, ycen=ycen, $
                  measure=r_measure

                xyad, hdr, r_measure.xcen, r_measure.ycen, racen, deccen
                
                help,/st,r_measure
                
                mall= {racen:racen, $
                       deccen:deccen, $
                       xcen:r_measure.xcen, $
                       ycen:r_measure.ycen, $
                       nprof:fltarr(nbands), $
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
                       asymmetry:fltarr(nbands), $
                       clumpy:fltarr(nbands), $
                       dflags:lonarr(nbands), $
                       aid:aid}

                for iband=0L, nbands-1L do begin
                    image=gz_mrdfits(subdir+'/'+sub+'/'+pstr+'/'+ $
                                     prefix+'-'+pstr+'-atlas-'+ $
                                     astr+'.fits', iband, hdr)
                    invvar=gz_mrdfits(subdir+'/parents/'+prefix+ $
                                      '-parent-'+pstr+'.fits', $
                                      iband*2L+1L, hdr)
                    invvar=invvar>0.

                    adxy, hdr, racen, deccen, xcen, ycen
                    dmeasure, image, invvar, xcen=xcen, $
                      ycen=ycen, /fixcen, measure=tmp_measure, $
                      cpetrorad= mall.petrorad*scales[iband], $
                      faper= 7.57576*scales[iband]
                    
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
                    mall.asymmetry[iband]= tmp_measure.asymmetry
                    mall.clumpy[iband]= tmp_measure.clumpy
                    mall.dflags[iband]= tmp_measure.dflags
                endfor
                
                mwrfits, mall, mfile, /create
                spawn, 'gzip -vf '+mfile
            endif

            if(keyword_set(check)) then begin
                mall= gz_mrdfits(mfile,1)
                dmeasure_check, rimage, rinvvar, measure=mall
            endif

        endif 
    endif
endif

end
