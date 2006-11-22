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
pro dfitpsf, imfile, natlas=natlas

if(NOT keyword_set(natlas)) then natlas=31

base=(stregex(imfile, '(.*)\.fits.*', /sub, /extr))[1]
image=mrdfits(imfile)
nx=(size(image,/dim))[0]
ny=(size(image,/dim))[1]

;; set a bunch of parameters
plim=10.
box=natlas/2L
small=(natlas-1L)/2L
minbatlas=1.e-6
nc=1L
np=1L
stardiff=20.
maxnstar=50

; Set source object name
soname=filepath('libdimage.'+idlutils_so_ext(), $
                root_dir=getenv('DIMAGE_DIR'), subdirectory='lib')

;; if there are zeros at the edges, excise 'em
xst=0L
yst=0L
sigma=dsigma(image)
softbias=0.
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
psf=psft

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
psft=psft-median(psft)

; output basic PSF
mwrfits, reform(psft, natlas, natlas), base+'-bpsf.fits', /create

; find variable PSF
;nc=3L
;np=1L
;atlas=extract.atlas
;atlas_ivar=extract.atlas_ivar
;batlas=(atlas) 
;batlas=batlas>minbatlas
;psf=fltarr(natlas,natlas)
;psfc=fltarr(nc, n_elements(extract))
;psft=fltarr(natlas,natlas,nc)
;xpsf=fltarr(np,nc)
;ypsf=fltarr(np,nc)
;retval=call_external(soname, 'idl_dfitpsf', float(batlas), $
                     ;float(atlas_ivar), long(natlas), long(natlas), $
                     ;long(n_elements(extract)), float(psfc), float(psft), $
                     ;float(xpsf), float(ypsf), long(nc), long(np))

; find variable PSF
nc=2L
np=2L

atlas=extract.atlas
atlas_ivar=extract.atlas_ivar
batlas_all=reform(atlas, natlas*natlas, n_elements(extract)) 
psft=reform(total(batlas_all, 2), natlas, natlas)
for i=0L, n_elements(extract)-1L do begin
    coeff=total(psft*batlas_all[*,i])/total(psft*psft)
    batlas_all[*,i]=batlas_all[*,i]/coeff-reform(psft, natlas*natlas)
endfor

batlas=reform(atlas, natlas*natlas, np^2*4L)
nb=fltarr(np^2*4L)
for i=0L, np*2L-1L do begin
    for j=0L, np*2L-1L do begin
        ii=where(extract.xcen gt nx*(i)/(np*2L) AND $
                 extract.xcen le nx*(i+1)/(np*2L) AND $
                 extract.ycen gt ny*(j)/(np*2L) AND $
                 extract.ycen le ny*(j+1)/(np*2L), nii)
        if(nii eq 0) then begin
            nb[i+(np*2L)*j]=nii	
            batlas[*,i+(np*2L)*j]= total(batlas_all[*,ii], 2)
        endif
    endfor
endfor

em_pca, batlas, nc, eatlas, ecoeffs

aa=dblarr(np*(np+1)/2L,n_elements(extract))
xx=(extract.xcen/float(nx))-0.5
yy=(extract.ycen/float(ny))-0.5
k=0L
for i=0L, np-1L do begin 
    for j=i, np-1L do begin 
        aa[k,*]=xx^(float(i))*yy^(float(j)) 
        k=k+1L 
    endfor 
endfor

xarr=(findgen(nx)#replicate(1.,ny))/float(nx)-0.5
yarr=(replicate(1.,nx)#findgen(ny))/float(ny)-0.5

cmap=fltarr(nx,ny,nc)
coeffs=fltarr(np*(np+1)/2L, nc)
for c=0L, nc-1L do begin 
    sig=djsig(ecoeffs[c,*])
    weights=replicate(1., n_elements(extract)) /sig^2
    hogg_iter_linfit,aa, transpose(ecoeffs[c,*]), weights, tmp_coeffs, $
      nsigma=3
    k=0L 
    for i=0L, np-1L do begin 
        for j=i, np-1L do begin 
            cmap[*,*,c]=cmap[*,*,c]+ $
              tmp_coeffs[k]*xarr^(float(i))*yarr^(float(j)) 
            k=k+1L 
        endfor 
    endfor 
    coeffs[*,c]=tmp_coeffs
endfor

hdr=['']
sxaddpar, hdr, 'NP', np, 'number of polynomial terms'
sxaddpar, hdr, 'NC', nc, 'number of components in NMF'
sxaddpar, hdr, 'NATLAS', natlas, 'size of PSF image'
sxaddpar, hdr, 'NX', nx, 'dimension of source image'
sxaddpar, hdr, 'NY', ny, 'dimension of source image'
sxaddpar, hdr, 'SOFTBIAS', softbias, 'dimension of source image'
mwrfits, psft, base+'-vpsf.fits', hdr, /create
mwrfits, reform(eatlas, natlas, natlas, nc), base+'-vpsf.fits'
mwrfits, coeffs, base+'-vpsf.fits'
mwrfits, cmap, base+'-vpsf.fits'

end
;------------------------------------------------------------------------------
