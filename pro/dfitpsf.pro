;+
; NAME:
;   dfitpsf
; PURPOSE:
;   fit a PSF model to an image
; CALLING SEQUENCE:
;   dfitpsf, imfile
; INPUTS:
;   imfile - input FITS file
; OPTIONAL INPUTS:
;   natlas   - size of the PSF postage stamp (default 41)
;   maxnstar - maximum number of stars to use when constructing the
;              PSF (default 200)
;   
; KEYWORD PARAMETERS:
;   noclobber - if the PSF files already exist, do nothing and return 
; COMMENTS:
;   Currently always uses Nc=1 (no varying PSFs allowed)
;   Seems to work OK but many arbitrary parameters.
;   Ouputs (imfile is base.fits or base.fits.gz):
;     base-bpsf.fits - basic (single-fit) PSF
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro dfitpsf, imfile, natlas=natlas, maxnstar=maxnstar, noclobber=noclobber

if(NOT keyword_set(natlas)) then natlas=41L

base=(stregex(imfile, '(.*)\.fits.*', /sub, /extr))[1]

if(keyword_set(noclobber)) then begin
    if(file_test(base+'-bpsf.fits') gt 0 AND $
       file_test(base+'-vpsf.fits') gt 0) then return
endif

splog, 'Reading image '+imfile
image=mrdfits(imfile,/silent)
fits_info, imfile, n_ext=next, /silent
if (next ge 1L) then begin
   splog, 'Reading inverse variance map'
   invvar = mrdfits(imfile,1,/silent)
endif
nx=(size(image,/dim))[0]
ny=(size(image,/dim))[1]

;; set a bunch of parameters
plim=10.
box=natlas
small=(natlas-1L)/2L
;nc=1L
;np=1L
stardiff=100.
if (n_elements(maxnstar) eq 0L) then maxnstar=200L

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
    if (n_elements(invvar) ne 0L) then invvar = invvar[xst:xnd,yst:ynd]
    sigma=dsigma(image)
    nx=(size(image,/dim))[0]
    ny=(size(image,/dim))[1]
endif
if (n_elements(invvar) eq 0L) then invvar=fltarr(nx,ny)+1./sigma^2

;; median smooth the image and find and extract objects
msimage=dmedsmooth(image, invvar, box=box)
simage=image-msimage
dobjects, simage, objects=obj, plim=plim
dextract, simage, invvar, object=obj, extract=extract, small=small
if(n_tags(extract) eq 0) then begin
    splog, 'no small enough objects in image'
    return
endif

extract1 = extract
splog, 'Identified ', n_elements(extract), ' objects.'

rejsigma = [3.0,2.5,1.0]
for iter = 0L, n_elements(rejsigma)-1L do begin

; do initial fit

   bpsf= reform(total(reform(extract.atlas,natlas*natlas,n_elements(extract)),2),natlas,natlas)
   bpsf=bpsf/total(bpsf)

; clip non-stars

   diff=fltarr(n_elements(extract))
   model=reform(bpsf, natlas*natlas)
   for i=0L, n_elements(extract)-1L do begin 
      scale=total(model*reform(extract[i].atlas,natlas*natlas))/ $
        total(model*model)
      diff[i]=total((extract[i].atlas/scale-model)^2*extract[i].atlas_ivar) ; jm07may07nyu
   endfor

; reject REJSIGMA outliers
   
   keep = where(diff lt mpchilim(rejsigma[iter],1.0,/sigma),nkeep)
   splog, 'REJSIGMA = ', rejsigma[iter], '; keeping ', nkeep, ' stars'
   if (nkeep eq 0L) then begin
      splog, 'No good stars found.'
      return
   endif

   extract = extract[keep]
   
endfor
   
;plotimage, logscl(image,exp=0.5,min=-1,max=5), /preserve, xrange=[400,700], yrange=[400,700]
;for jj = 0L, n_elements(extract1)-1L do tvcircle, 10.0, extract1[jj].xcen, extract1[jj].ycen, color=djs_icolor('red'), /data
;for kk = 0L, n_elements(extract)-1L do tvcircle, 10.0, extract[kk].xcen, extract[kk].ycen, thick=2.0, color=djs_icolor('yellow'), /data

;isort=sort(diff)
;
;istarsort=where(diff[isort] lt stardiff and $
;                lindgen(n_elements(isort)) lt maxnstar, $
;                nstarsort)
;if(nstarsort eq 0) then begin
;    istar=isort[0]
;endif else begin
;    istar=isort[where(diff[isort] lt stardiff and $
;                      lindgen(n_elements(isort)) lt maxnstar)]
;endelse
;extract=extract[istar]

; find basic PSF
atlas=extract.atlas
bpsf= reform(total(reform(atlas, natlas*natlas, n_elements(extract)),2), $
             natlas,natlas)
bpsf=bpsf/total(bpsf)

pnx=(size(bpsf,/dim))[0]
pny=(size(bpsf,/dim))[1]
dfit_mult_gauss, bpsf, 1, amp, psfsig, model=model ; jm07may01nyu
mm=max(model)
gpsf=(model/mm) > 0.001

; output basic PSF
mwrfits, reform(bpsf, natlas, natlas), base+'-bpsf.fits', /create
mwrfits, reform(model, natlas, natlas), base+'-bpsf.fits' ; jm07may01nyu

np=2L
nc=4L
nchunk=2L
niter=3L

vatlas=fltarr(natlas*natlas, np^2*nchunk^2)
nb=lonarr(np^2*nchunk^2)
xx=fltarr(np^2*nchunk^2)
yy=fltarr(np^2*nchunk^2)
model=reform(bpsf, natlas*natlas)
for i=0L, np*nchunk-1L do begin
    for j=0L, np*nchunk-1L do begin
        ii=where(extract.xcen gt nx*(i)/(np*nchunk) AND $
                 extract.xcen le nx*(i+1)/(np*nchunk) AND $
                 extract.ycen gt ny*(j)/(np*nchunk) AND $
                 extract.ycen le ny*(j+1)/(np*nchunk), nii)
        if(nii gt 0) then begin
            nb[i+(np*nchunk)*j]=nii	
            vatlas[*,i+(np*nchunk)*j]= $
              total(reform(extract[ii].atlas, natlas*natlas, nii), 2)
            scale=total(model*vatlas[*,i+(np*nchunk)*j])/ total(model*model)
            vatlas[*,i+(np*nchunk)*j]= (vatlas[*,i+(np*nchunk)*j]/scale - model)
            vatlas[*,i+(np*nchunk)*j]= vatlas[*,i+(np*nchunk)*j]*gpsf
            xx[i+(np*nchunk)*j]=mean(extract[ii].xcen)/float(nx)-0.5
            yy[i+(np*nchunk)*j]=mean(extract[ii].ycen)/float(ny)-0.5
        endif
    endfor
endfor

clipped=lonarr(np^2*nchunk^2)

for iter=0L, niter-1L do begin
    iv=where(nb gt 0L and clipped eq 0, nv)
    if(nv gt np^2L) then begin

        em_pca, vatlas[*, iv], nc, eatlas, ecoeffs
        
        aa=dblarr(np*np, nv)
        k=0L
        for i=0L, np-1L do begin 
            for j=0, np-1L do begin 
                aa[k,*]=xx[iv]^(float(i))*yy[iv]^(float(j)) 
                k=k+1L 
            endfor 
        endfor
        
        xarr=(findgen(nx)#replicate(1.,ny))/float(nx)-0.5
        yarr=(replicate(1.,nx)#findgen(ny))/float(ny)-0.5
        
        cmap=fltarr(nx,ny,nc)
        coeffs=fltarr(np*np, nc)
        for c=0L, nc-1L do begin 
            sig=djsig(ecoeffs[c,*])
            weights=replicate(1., nv) /sig^2
            hogg_iter_linfit,aa, transpose(ecoeffs[c,*]), weights, $
              tmp_coeffs, nsigma=3., /true
            clipped[iv]=clipped[iv] OR (weights eq 0.)
            k=0L 
            for i=0L, np-1L do begin 
                for j=0, np-1L do begin 
                    cmap[*,*,c]=cmap[*,*,c]+ $
                      tmp_coeffs[k]*xarr^(float(i))*yarr^(float(j)) 
                    k=k+1L 
                endfor 
            endfor 
            coeffs[*,c]=tmp_coeffs
        endfor
    endif else begin
        eatlas=fltarr(natlas, natlas, nc)
        coeffs=fltarr(np*np, nc)
        cmap=fltarr(nx,ny,nc)
    endelse
endfor

hdr=['']
sxaddpar, hdr, 'NP', np, 'number of polynomial terms'
sxaddpar, hdr, 'NC', nc, 'number of components in NMF'
sxaddpar, hdr, 'NATLAS', natlas, 'size of PSF image'
sxaddpar, hdr, 'XST', xst, 'start of source image used'
sxaddpar, hdr, 'YST', yst, 'start of source image used'
sxaddpar, hdr, 'NX', nx, 'dimension of source image (as used)'
sxaddpar, hdr, 'NY', ny, 'dimension of source image (as used)'
sxaddpar, hdr, 'SOFTBIAS', softbias, 'dimension of source image'
mwrfits, bpsf, base+'-vpsf.fits', hdr, /create
outatlas=reform(eatlas, natlas, natlas, nc)
for i=0L, nc-1L do $
  outatlas[*,*,i]=outatlas[*,*,i]/gpsf
mwrfits, outatlas, base+'-vpsf.fits'
mwrfits, coeffs, base+'-vpsf.fits'
mwrfits, cmap, base+'-vpsf.fits'

stop

end
;------------------------------------------------------------------------------
