;+
; NAME:
;   dgetxy
; PURPOSE:
;   get basic X an
; CALLING SEQUENCE:
;   dimage, image
; INPUTS:
;   image - [nx, ny] input image
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro dimage, image

nx=(size(image,/dim))[0]
ny=(size(image,/dim))[1]

;; Preprocess: 
;;   * try to guess whether it is background subtracted
;;   * try to guess saturation
;;   * try to guess PSF size
;;   - set noise level (and test, roughly)
;;   * try to find bad (low) pixels
invvar=dinvvar(image, hdr=hdr, satur=satur)

;; Do first pass: 
;;   * eliminate cosmics
;;   - find small objects and their crude centers
;;   * find better centers
;;   * measure simple flux
msmooth=dmedsmooth(image, invvar, box=40L)
simage=image-msmooth
dobjects, simage, invvar, object=oimage, smooth=smooth
dextract, smooth, invvar, object=oimage, extract=extract, small=31L

stop

end
;------------------------------------------------------------------------------
