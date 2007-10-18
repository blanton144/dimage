;+
; NAME:
;   dparents
; PURPOSE:
;   find parent objects in multi-band, multi-res images
; CALLING SEQUENCE:
;   dparents, base, imfiles, [plim=, ref=, sky=, /noclobber ]
; INPUTS:
;   base - base name for output
;   imfiles - [Nband] array of FITS files with images in HDU 0
; OPTIONAL INPUTS:
;   plim - significance to detect (default 5.)
;   ref - integer indicating which imfile is the "reference"
;   sky - if set, subtracts a median smoothed sky with this box size
;         (in arcsec)
; OPTIONAL KEYWORDS:
;   /noclobber - do not overwrite previously created files
; COMMENTS:
;   Creates files:
;      base-#-pimage.fits - image with parent number in each pixel
;      base-#-pcat.fits - image with parent number in each pixel
;      parents/base-parent-[parent].fits - multi-HDU file with
;                                          individual parents
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro dparents, base, imfiles, plim=plim, ref=ref, sky=sky, $
              noclobber=noclobber, puse=puse

if(NOT keyword_set(plim)) then plim=5.
if(NOT keyword_set(ref)) then ref=0
if(NOT keyword_set(puse)) then puse=replicate(1, n_elements(imfiles))

;; check for all files, if we have them and we aren't supposed to
;; clobber them, then return
nim=n_elements(imfiles)
if(keyword_set(noclobber)) then begin
    gotall=1
    for k=0L, nim-1L do begin
        if(file_test(base+'-'+strtrim(string(k),2)+'-pimage.fits') eq 0) then $
          gotall=0
    endfor
    if(file_test(base+'-pcat.fits') eq 0) then $
      gotall=0
    if(gotall gt 0) then begin
        pcat=mrdfits(base+'-pcat.fits',1)
        for i=0L, n_elements(pcat)-1L do $
          if(file_test('parents/'+base+'-parent-'+ $
                       strtrim(string(i),2)+'.fits') eq 0) then $
          gotall=0
    endif
    if(gotall) then return
endif

;; create image arrays for each band
images=ptrarr(nim)
ivars=ptrarr(nim)
nx=lonarr(nim)
ny=lonarr(nim)
hdrs=ptrarr(nim)
for k=0L, nim-1L do begin
    hdr=headfits(imfiles[k],ext=0)
    nx[k]=sxpar(hdr, 'NAXIS1')
    ny[k]=sxpar(hdr, 'NAXIS2')
    hdrs[k]=ptr_new(hdr)
    images[k]=ptr_new(fltarr(nx[k],ny[k]))
    ivars[k]=ptr_new(fltarr(nx[k],ny[k]))
endfor

;; read in images and ivars
sigma=fltarr(nim)
pixscale=fltarr(nim)
for k=0L, nim-1L do begin
    ;; read in image
    *images[k]=mrdfits(imfiles[k],0,hdr)

    ;; hack to find pixel scale
    ntest=10L
    xyad, hdr, nx[k]/2L, ny[k]/2L, ra1, dec1
    xyad, hdr, nx[k]/2L+ntest, ny[k]/2L, ra2, dec2
    spherematch, ra1, dec1, ra2,dec2, 360., m1, m2, d12
    pixscale[k]=d12/float(ntest)
    
    ;; sky subtract if desired
    if(keyword_set(sky)) then begin
        skypix=sky/(pixscale*3600.)
        msimage=dmedsmooth(*images[k], box=skypix)
        *image[k]= *images[k]-msimage
    endif

    ;; set ivars (defaulting to sigma estimate)
    sigma[k]=dsigma(*images[k], sp=10)
    ivar=mrdfits(imfiles[k],1) 
    if(NOT keyword_set(ivar)) then $
      *ivars[k]=fltarr(nx[k], ny[k])+1./sigma[k]^2 $
    else $
      *ivars[k]=ivar
endfor

;; do general object detection
dobjects, images, object=oimage, plim=plim, puse=puse, fobject=fobject
mwrfits, fobject, base+'-pimage.fits', /create
for k=0L, nim-1L do begin
    mwrfits, *oimage[k], base+'-'+strtrim(string(k),2)+'-pimage.fits', $
      *hdrs[k], /create
endfor

pcat=replicate({xst:lonarr(nim), yst:lonarr(nim), $
                xnd:lonarr(nim), ynd:lonarr(nim), $
                xc:fltarr(nim), yc:fltarr(nim), $
                cra:0.D, cdec:0.D},max(fobject)+1L)
spawn, 'mkdir -p parents'
for iobj=0L, max(fobject) do begin
    for k=0L, nim-1L do begin
        io=where(*oimage[k] eq iobj)
        ixo=io mod nx[k]
        iyo=io / nx[k]
        xstart=(min(ixo)-30L)>0
        xend=(max(ixo)+30L)<(nx[k]-1L)
        ystart=(min(iyo)-30L)>0
        yend=(max(iyo)+30L)<(ny[k]-1L)
        nxnew=xend-xstart+1L
        nynew=yend-ystart+1L
        
        hdr=*hdrs[k]
        sxaddpar, hdr, 'XST', xstart
        sxaddpar, hdr, 'YST', ystart
        sxaddpar, hdr, 'XND', xend
        sxaddpar, hdr, 'YND', yend
        sxaddpar, hdr, 'NIM', nim
        crpix1=float(sxpar(hdr, 'CRPIX1'))-xstart
        crpix2=float(sxpar(hdr, 'CRPIX2'))-ystart
        sxaddpar, hdr, 'CRPIX1', crpix1
        sxaddpar, hdr, 'CRPIX2', crpix2
        pcat[iobj].xst[k]=xstart
        pcat[iobj].xnd[k]=xend
        pcat[iobj].yst[k]=ystart
        pcat[iobj].ynd[k]=yend
        
        timage=(*images[k])[xstart:xend, ystart:yend]
        nimage=(*oimage[k])[xstart:xend, ystart:yend]
        iivar=(*ivars[k])[xstart:xend, ystart:yend]
        
        io=where(nimage eq iobj OR nimage eq -1L)
        
        iimage=randomn(seed, nxnew, nynew)*sigma[k]
        ii=where(iivar gt 0., nii)
        if(nii gt 0) then $
          iimage[ii]=randomn(seed, nii)/sqrt(iivar[ii])
        iimage[io]=timage[io]

        if(k eq ref) then begin
            dpeaks, iimage, xc=xc, yc=yc, npeaks=1
            isort=reverse(sort(iimage[xc,yc]))
            xyad, *hdrs[k], xc[isort[0]], yc[isort[0]], cra, cdec
            pcat[iobj].cra=cra
            pcat[iobj].cdec=cdec
            for kk=0L, nim-1L do begin
                if(kk ne ref) then begin
                    adxy, *hdrs[kk], cra, cdec, xc, yc
                    pcat[iobj].xc[kk]=xc
                    pcat[iobj].yc[kk]=yc
                endif
            endfor
        endif
        
        if(k eq 0) then $
          first=1 $
        else $
          first=0
        mwrfits, iimage, 'parents/'+base+'-parent-'+ $
          strtrim(string(iobj),2)+'.fits', hdr, create=first
        mwrfits, iivar, 'parents/'+base+'-parent-'+ $
          strtrim(string(iobj),2)+'.fits', hdr
    endfor
endfor

mwrfits, pcat, base+'-pcat.fits', /create

end
;------------------------------------------------------------------------------
