;+
; NAME:
;   galex_sky_subtract
; PURPOSE:
;   Do a local sky subtraction for a GALEX image
; CALLING SEQUENCE:
;   galex_sky_subtract, image, sky=sky
; REVISION HISTORY:
;   07-Jul-2011  MRB, NYU
;-
;------------------------------------------------------------------------------
pro galex_sky_subtract, orig, cts, rr, image=image, sky=sky

atcd, 129415
orig= mrdfits('J*-fd.fits.gz',0)
fivar= mrdfits('J*-fd.fits.gz',1)
cts= mrdfits('J*-fd.fits.gz',2)
rr= mrdfits('J*-fd.fits.gz',3)

nx= (size(cts, /dim))[0]
ny= (size(cts, /dim))[1]
factor= 0.3
box= long(min([nx*factor, ny*factor, 100.]))>10L

;; detect objects for masking
dobjects, orig, plim=3., obj=obj

;; make image
image= fltarr(nx, ny)
inz= where(rr gt 0., nnz)
if(nnz gt 0) then $
  image[inz]=cts[inz]/rr[inz]

;; median smooth
ivar= fltarr(nx, ny)+1.
izero= where(obj ge 0 or rr le 0., nzero)
if(nzero gt 0) then $
  ivar[izero]=0.
sky= dmedsmooth(image, ivar, box=box)

;; subtract sky off image
image[inz]=image[inz]-sky[inz]

end
