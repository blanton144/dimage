;+
; NAME:
;   dparents
; PURPOSE:
;   take a fits file, detect objects, and create parents file
; CALLING SEQUENCE:
;   dparents, imfile [, plim= ]
; INPUTS:
;   imfile - FITS image file 
; OPTIONAL INPUTS:
;   plim - significance to detect (default 5.)
; COMMENTS:
;   If you input 'myimage.fits' it outputs:
;    myimage-pimage.fits (object image)
;    myimage-pcat.fits (parent catalog)
;    myimage-parents.fits (parents)
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro dparents_multi, base, imfiles, plim=plim

if(NOT keyword_set(plim)) then plim=5.

nim=n_elements(imfiles)
hdr=headfits(imfiles[0],ext=0)
nx=sxpar(hdr, 'NAXIS1')
ny=sxpar(hdr, 'NAXIS2')

images=fltarr(nx,ny,nim)
ivars=fltarr(nx,ny,nim)

sigma=fltarr(nim)
for k=0L, nim-1L do begin
    images[*,*,k]=mrdfits(imfiles[k],0)
    sigma[k]=dsigma(images[*,*,k], sp=10)
    ivar=mrdfits(imfiles[k],1)
    if(NOT keyword_set(ivar)) then $
      ivars[*,*,k]=fltarr(nx, ny)+1./sigma[k]^2 $
    else $
      ivars[*,*,k]=ivar
endfor

;; do general object detection
dobjects_multi, images, object=oimage, plim=plim
mwrfits, oimage, base+'-pimage.fits', /create

pcat=replicate({xst:0L, yst:0L, xnd:0L, ynd:0L},max(oimage)+1L)
spawn, 'mkdir -p parents'
for iobj=0L, max(oimage) do begin
    io=where(oimage eq iobj)
    ixo=io mod nx
    iyo=io / nx
    xstart=(min(ixo)-30L)>0
    xend=(max(ixo)+30L)<(nx-1L)
    ystart=(min(iyo)-30L)>0
    yend=(max(iyo)+30L)<(ny-1L)
    nxnew=xend-xstart+1L
    nynew=yend-ystart+1L

    hdr=['']
    sxaddpar, hdr, 'XST', xstart
    sxaddpar, hdr, 'YST', ystart
    sxaddpar, hdr, 'XND', xend
    sxaddpar, hdr, 'YND', yend
    pcat[iobj].xst=xstart
    pcat[iobj].xnd=xend
    pcat[iobj].yst=ystart
    pcat[iobj].ynd=yend
    
    for k=0L, nim-1L do begin
        timage=images[xstart:xend, ystart:yend, k]
        nimage=oimage[xstart:xend, ystart:yend]
        iivar=ivars[xstart:xend, ystart:yend, k]
        
        io=where(nimage eq iobj OR nimage eq -1L)
        
        iimage=randomn(seed, nxnew, nynew)*sigma[k]
        ii=where(iivar gt 0., nii)
        if(nii gt 0) then $
          iimage[ii]=randomn(seed, nii)/sqrt(iivar[ii])
        iimage[io]=timage[io]
        
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
