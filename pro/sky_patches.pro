;+
; NAME:
;   sky_patches
; PURPOSE:
;   create 
; CALLING SEQUENCE:
;   invvar=dinvvar(image, hdr=)
; INPUTS:
;   image - [nx, ny] input image
;   hdr - [N] header of FITS file 
; OUTPUTS:
;   invvar - [nx,ny] output invverse variance
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
function dinvvar, image, hdr=hdr, satur=satur

invvar=1./float(image)

ii=where(image le 0. and image ne image, nii)
if(nii gt 0) then $
  invvar[ii]=0.

return, invvar

end
;------------------------------------------------------------------------------
