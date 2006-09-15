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
pro dparents, imfile, plim=plim

common atv_point, markcoord

if(NOT keyword_set(plim)) then plim=5.

base=(stregex(imfile, '(.*)\.fits.*', /sub, /extr))[1]

image=mrdfits(imfile)
ivar=mrdfits(imfile,2)

nx=(size(image,/dim))[0]
ny=(size(image,/dim))[1]

sigma=dsigma(image, sp=10)
if(NOT keyword_set(ivar)) then $
  ivar=fltarr(nx, ny)+1./sigma^2

;; do general object detection
dobjects, image, object=oimage, plim=plim
mwrfits, oimage, base+'-pimage.fits', /create

pcat=replicate({xst:0L, yst:0L, xnd:0L, ynd:0L, msig:0.},max(oimage)+1L)
mwrfits, 0, base+'-parents.fits', /create
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

    timage=image[xstart:xend, ystart:yend]
    nimage=oimage[xstart:xend, ystart:yend]
    iivar=ivar[xstart:xend, ystart:yend]
    
;; now choose the object that includes the center
    io=where(nimage eq iobj OR nimage eq -1L)
    
    iimage=randomn(seed, nxnew, nynew)*sigma
    ii=where(iivar gt 0., nii)
    if(nii gt 0) then $
      iimage[ii]=randomn(seed, nii)/sqrt(iivar[ii])
    iimage[io]=timage[io]

    hdr=['']
    sxaddpar, hdr, 'XST', xstart
    sxaddpar, hdr, 'YST', ystart
    sxaddpar, hdr, 'XND', xend
    sxaddpar, hdr, 'YND', yend
    pcat[iobj].xst=xstart
    pcat[iobj].xnd=xend
    pcat[iobj].yst=ystart
    pcat[iobj].ynd=yend
    pcat[iobj].msig=max(iimage)/sigma
    
    mwrfits, iimage, base+'-parents.fits', hdr
    mwrfits, iivar, base+'-parents.fits', hdr
endfor

mwrfits, pcat, base+'-pcat.fits', /create
    
end
;------------------------------------------------------------------------------
