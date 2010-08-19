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
;   /cenonly - only output parent image for central object
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
              noclobber=noclobber, puse=puse, seed=seed0, $
              cenonly=cenonly, pbuffer=pbuffer

if(NOT keyword_set(plim)) then plim=5.
if(NOT keyword_set(pbuffer)) then pbuffer=0.1
if(NOT keyword_set(ref)) then ref=0
if(NOT keyword_set(puse)) then puse=replicate(1, n_elements(imfiles))
if(NOT keyword_set(seed0)) then seed0=108L
seed=seed0

;; check for all files, if we have them and we aren't supposed to
;; clobber them, then return
nim=n_elements(imfiles)
if(keyword_set(noclobber)) then begin
    gotall=1
    for k=0L, nim-1L do begin
        if(gz_file_test(base+'-'+strtrim(string(k),2)+'-pimage.fits') eq 0) $
          then gotall=0
    endfor
    if(gz_file_test(base+'-pcat.fits') eq 0) then $
      gotall=0
    if(gotall gt 0) then begin
        pcat=gz_mrdfits(base+'-pcat.fits',1)
        ist=0L
        ind= n_elements(pcat)-1L
        if(keyword_set(cenonly)) then begin
            tmp_pimage=gz_mrdfits(base+'-pimage.fits')
            tmp_nx=(size(tmp_pimage, /dim))[0]
            tmp_ny=(size(tmp_pimage, /dim))[0]
            tmp_icen= tmp_pimage[tmp_nx/2L, tmp_ny/2L]
            ist= tmp_icen
            ind= tmp_icen
        endif
        for i=ist, ind do $
          if(gz_file_test('parents/'+base+'-parent-'+ $
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
    hdr=gz_headfits(imfiles[k],ext=0)
    nx[k]=sxpar(hdr, 'NAXIS1')
    ny[k]=sxpar(hdr, 'NAXIS2')
    hdrs[k]=ptr_new(hdr)
    images[k]=ptr_new(fltarr(nx[k],ny[k]))
    ivars[k]=ptr_new(fltarr(nx[k],ny[k]))
endfor

;; read in images and ivars
sigma=fltarr(nim)
pixscale=fltarr(nim)
allzero=bytarr(nim)
for k=0L, nim-1L do begin
    ;; read in image
    *images[k]=gz_mrdfits(imfiles[k],0,hdr)

    inot= where(*images[k] ne 0., nnot)
    if(nnot eq 0) then $
      allzero[k]=1

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
    if(sigma[k] le 0.) then begin
        scale=8L
        newnx= nx[k]/scale 
        newny= ny[k]/scale 
        newim= rebin((*images[k])[0:newnx*scale-1, $
                                  0:newny*scale-1], newnx, newny)* $
          scale^2
        sigma[k]=dsigma(newim, sp=10)/float(scale)
        if(sigma[k] eq 0.) then sigma[k]=1.
    endif

    ivar=gz_mrdfits(imfiles[k],1) 
    if(NOT keyword_set(ivar)) then begin
        if(allzero[k] eq 0) then $
          *ivars[k]=fltarr(nx[k], ny[k])+1./sigma[k]^2 $
        else $
          *ivars[k]=fltarr(nx[k], ny[k])
    endif  else begin
        *ivars[k]=ivar
    endelse
endfor

;; do general object detection
dobjects, images, object=oimage, plim=plim, puse=puse, fobject=fobject, $
  seed=seed
mwrfits, fobject, base+'-pimage.fits', /create
for k=0L, nim-1L do begin
    mwrfits, *oimage[k], base+'-'+strtrim(string(k),2)+'-pimage.fits', $
      *hdrs[k], /create
endfor

if(max(fobject) eq -1) then return

nfx= (size(fobject,/dim))[0]
nfy= (size(fobject,/dim))[1]
fcen= fobject[nfx/2L, nfy/2L]

pcat=replicate({xst:lonarr(nim), yst:lonarr(nim), $
                xnd:lonarr(nim), ynd:lonarr(nim), $
                xc:fltarr(nim), yc:fltarr(nim), $
                cra:0.D, cdec:0.D},max(fobject)+1L)
spawn, 'mkdir -p parents'

obj_st=0L
obj_nd= max(fobject)
if(keyword_set(cenonly)) then begin
    if(fcen eq -1) then return
    obj_st=fcen
    obj_nd=fcen
endif

buffer=30L
for iobj=obj_st, obj_nd do begin
    for k=0L, nim-1L do begin
        io=where(*oimage[k] eq iobj)
        ixo=io mod nx[k]
        iyo=io / nx[k]

        ;; add standard buffer
        xstart=(min(ixo)-buffer)>0
        xend=(max(ixo)+buffer)<(nx[k]-1L)
        ystart=(min(iyo)-buffer)>0
        yend=(max(iyo)+buffer)<(ny[k]-1L)
        nxtmp=xend-xstart+1L
        nytmp=yend-ystart+1L

        ;; add extra buffer
        xbuffer= long(pbuffer*float(nxtmp))
        ybuffer= long(pbuffer*float(nytmp))
        xstart=(xstart-xbuffer)>0
        xend=(xend+xbuffer)<(nx[k]-1L)
        ystart=(ystart-ybuffer)>0
        yend=(yend+ybuffer)<(ny[k]-1L)
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
        
        if(allzero[k] eq 0) then $
          iimage=randomn(seed, nxnew, nynew)*sigma[k] $
        else $
          iimage=fltarr(nxnew, nynew)
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
