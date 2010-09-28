;+
; NAME:
;   dfitpsf_atlas
; PURPOSE:
;   fit a PSF model to an image (special case for atlas images)
; CALLING SEQUENCE:
;   dfitpsf_atlas, imfile
; INPUTS:
;   imfile - input FITS file
; COMMENTS:
;   Ouputs (imfile is base.fits or base.fits.gz):
;     base-bpsf.fits - basic (single-fit) PSF
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro dfitpsf_cutouts, image, ivar, x, y, nx, ny, cutout_image, cutout_ivar

cutout_image=fltarr(nx,ny,n_elements(x)) 
cutout_ivar=fltarr(nx,ny,n_elements(x)) 

for i=0L, n_elements(x)-1L do begin
    tmp_cutout_image=fltarr(nx,ny) 
    tmp_cutout_ivar=fltarr(nx,ny) 
    
    embed_stamp, tmp_cutout_image, image, nx/2L-x[i], ny/2L-y[i] 
    embed_stamp, tmp_cutout_ivar, ivar, nx/2L-x[i], ny/2L-y[i] 
    tmp_cutout_ivar=tmp_cutout_ivar>0.
    
    cutout_image[*,*,i]=tmp_cutout_image
    cutout_ivar[*,*,i]=tmp_cutout_ivar
endfor

end
;;
pro dfitpsf_atlas, imfile, natlas=natlas, $
                   base=base, seed=seed0, check=check

if(NOT keyword_set(natlas)) then natlas=61L
if(NOT keyword_set(seed0)) then seed0=108L
if (n_elements(maxnstar) eq 0L) then maxnstar=10L
seed=seed0
box=natlas*2L

if(NOT keyword_set(base)) then $
  base=(stregex(imfile, '(.*)\.fits.*', /sub, /extr))[1]

splog, 'Reading image '+imfile
image=gz_mrdfits(imfile,/silent)
invvar = gz_mrdfits(imfile,1,/silent)
nx=(size(image,/dim))[0]
ny=(size(image,/dim))[1]

;; set a bunch of parameters
if(nx lt box OR ny lt box) then begin
    message, 'image too small!'
endif

;; find peaks and estimate flux in simple way
simage= dsmooth(image, 1.5)
simplexy, image, x, y
nfound=n_elements(x)
flux= simage[x,y]
isort= reverse(sort(flux))
x=x[isort]
y=y[isort]
flux=flux[isort]

keep= bytarr(nfound)
nstar= nfound < maxnstar
keep[0:nstar-1]=1

xx=replicate(1., natlas)#findgen(natlas)-float(natlas/2L)
yy=findgen(natlas)#replicate(1., natlas)-float(natlas/2L)
rr2=xx^2+yy^2

rejsigma = [10.0,5.0]
for iter = 0L, n_elements(rejsigma)-1L do begin

   ;; take mean of stars
   ikeep= where(keep, nkeep)
   dfitpsf_cutouts, image, invvar, x[ikeep], y[ikeep], natlas, natlas, $
                    cutout_image, cutout_ivar
   bpsf= reform(total(reform(cutout_image, natlas^2, nkeep),2), $
                natlas, natlas)
   bpsf=bpsf-median(bpsf)

   ;; taper
   dfit_mult_gauss, bpsf, 1, amp, psfsig, model=model, /quiet
   bpsf=bpsf*exp(-0.5*rr2/(psfsig[0]*8.)^2)
   bpsf=bpsf/total(bpsf)
   
   ;; find stars from full list
   ivaruse= invvar < 1./(abs(image)*0.1)^2
   chi2=dpsfselect_atlas(image, ivaruse, x, y, psf=bpsf, $
                         flux=flux, dof=dof, /noclip)
   istar = where(chi2 lt dof+rejsigma[iter]*sqrt(2.*dof),nstar)
   
   keep= bytarr(nfound)
   nstar= (nstar<(nfound<maxnstar))
   keep[istar[0L:nstar-1L]]=1

endfor

if(keyword_set(check)) then  begin
   atv, image
   ik= where(keep)
   atvplot, x[ik], y[ik], psym=4
endif

; output basic PSF
mkhdr, hdr, 4, [natlas,natlas], /extend
sxdelpar, hdr, 'COMMENT' 
sxdelpar, hdr, 'DATE'
sxaddpar, hdr, 'NPSFSTAR', long(nkeep), $
          ' number of stars used in the PSF'
mwrfits, float(reform(bpsf, natlas, natlas)), base+'-bpsf.fits', hdr, /create

if(keyword_set(check)) then  begin
   sub= dpsfsub_atlas(base)
   atv2, sub
   atv2plot, x, y, psym=4, color='green'
   atv2plot, x[ik], y[ik], psym=4
endif

end
;------------------------------------------------------------------------------
