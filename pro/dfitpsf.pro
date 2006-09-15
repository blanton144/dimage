;+
; NAME:
;   dfitpsf
; PURPOSE:
;   fit a PSF model to an image
; CALLING SEQUENCE:
;   dfitpsf, imfile
; INPUTS:
;   imfile - input FITS file
; COMMENTS:
;   Currently always uses Nc=1 (no varying PSFs allowed)
;   Seems to work OK but many arbitrary parameters.
;   Ouputs (imfile is base.fits or base.fits.gz):
;     base-bpsf.fits - basic (single-fit) PSF
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro dfitpsf, imfile

base=(stregex(imfile, '(.*)\.fits.*', /sub, /extr))[1]
image=mrdfits(imfile)
nx=(size(image,/dim))[0]
ny=(size(image,/dim))[1]

;; set a bunch of parameters
plim=20.
box=60
small=30
minbatlas=1.e-6
natlas=61
nc=1L
np=1L
natlas=61
stardiff=20.
maxnstar=60

; Set source object name
soname=filepath('libdimage.'+idlutils_so_ext(), $
                root_dir=getenv('DIMAGE_DIR'), subdirectory='lib')

;; if there are zeros at the edges, excise 'em
xst=0L
yst=0L
sigma=dsigma(image)
if(sigma eq 0) then begin
    ii=where(image gt 0., nii)
    xst=min(ii mod nx)
    yst=min(ii / nx)
    xnd=max(ii mod nx)
    ynd=max(ii / nx)
    image=image[xst:xnd, yst:ynd]
    sigma=dsigma(image)
    nx=(size(image,/dim))[0]
    ny=(size(image,/dim))[1]
endif
invvar=fltarr(nx,ny)+1./sigma^2

;; median smooth the image and find and extract objects
msimage=dmedsmooth(image, invvar, box=box)
simage=image-msimage
dobjects, simage, objects=obj, plim=plim
dextract, simage, invvar, object=obj, extract=extract, small=small
if(n_tags(extract) eq 0) then begin
    splog, 'no small enough objects in image'
    return
endif

; do initial fit
atlas=extract.atlas
atlas_ivar=extract.atlas_ivar
batlas=(atlas) 
batlas=batlas>minbatlas
psf=fltarr(natlas,natlas)
psfc=fltarr(nc, n_elements(extract))
psft=fltarr(natlas,natlas,nc)
xpsf=fltarr(np,nc)
ypsf=fltarr(np,nc)
retval=call_external(soname, 'idl_dfitpsf', float(batlas), $
                     float(atlas_ivar), long(natlas), long(natlas), $
                     long(n_elements(extract)), float(psfc), float(psft), $
                     float(xpsf), float(ypsf), long(nc), long(np))

; clip non-stars
diff=fltarr(n_elements(extract))
for i=0L, n_elements(extract)-1L do begin 
    model=reform(reform(psft, natlas*natlas, nc)#psfc[*,i], natlas, natlas) 
    scale=max(model) 
    diff[i]=total((atlas[*,*,i]-model)^2/scale^2) 
endfor
isort=sort(diff)
istar=isort[where(diff[isort] lt stardiff and $
                  lindgen(n_elements(isort)) lt maxnstar)]
extract=extract[istar]

; find basic PSF
atlas=extract.atlas
atlas_ivar=extract.atlas_ivar
batlas=(atlas) 
batlas=batlas>minbatlas
psf=fltarr(natlas,natlas)
psfc=fltarr(nc, n_elements(extract))
psft=fltarr(natlas,natlas,nc)
xpsf=fltarr(np,nc)
ypsf=fltarr(np,nc)
retval=call_external(soname, 'idl_dfitpsf', float(batlas), $
                     float(atlas_ivar), long(natlas), long(natlas), $
                     long(n_elements(extract)), float(psfc), float(psft), $
                     float(xpsf), float(ypsf), long(nc), long(np))

; output basic PSF
psft=psft-median(psft)
mwrfits, reform(psft, natlas, natlas), base+'-bpsf.fits', /create


end
;------------------------------------------------------------------------------
