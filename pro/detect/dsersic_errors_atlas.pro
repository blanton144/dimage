;+
; NAME:
;   dsersic_errors_atlas
; PURPOSE:
;   Run Sersic error measurements on atlas results
; CALLING SEQUENCE:
;   dsersic_errors_atlas, subdir
; COMMENTS:
;   Assumes dimage-style detection outputs
; REVISION HISTORY:
;   31-July-2010
;-
;------------------------------------------------------------------------------
pro dsersic_errors_atlas, sersicfit=sersicfit

nmax_sersic= 3000L
sub='atlases'
postfix=''

spawn, /nosh, 'pwd', subdir
subdir=subdir[0]

dreadcen, measure=measure

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
        
        rnx= (size(rimage, /dim))[0]
        rny= (size(rimage, /dim))[1]
        
        adxy, hdr, acat[m2].racen, acat[m2].deccen, xcen, ycen
        
        psf= gz_mrdfits(psffiles[ref])
        
        measure=gz_mrdfits(mfile,1)
        dsersic_errors, rimage, rinvvar, xcen=measure.xcen, ycen=measure.ycen, $
          psf=psf, r50=measure.sersic_r50, sersicn=measure.sersic_n, axisratio=measure.sersic_ba, $
          orientation= measure.sersic_phi, sersicfit=sersicfit, /fixcen, /fixsky
            
    endif 
endif

end
