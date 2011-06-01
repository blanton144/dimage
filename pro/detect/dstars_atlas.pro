;+
; NAME:
;   dstars_atlas
; PURPOSE:
;   find and subtract stars 
; COMMENTS:
;   Identifies detectable stars in r-band; assumes that
;     only those are relevant.
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro dstars_atlas, images, ivars, psfs, hdrs, sdss=sdss, slim=slim, ref=ref, $
                  nimages=nimages, ra_stars=ra_stars, dec_stars=dec_stars, $
                  nstars=nstars, maxnstar=maxnstar

if(NOT keyword_set(ref)) then $
   ref=2L
if(NOT keyword_set(maxnpeaks)) then $
   maxnpeaks=1000L
if(NOT keyword_set(maxnstar)) then $
   maxnstar=1000L

;; figure out sizes
nim=n_elements(images)
nx=lonarr(nim)
ny=lonarr(nim)
for k=0L, nim-1L do begin
    nx[k]=(size(*images[k],/dim))[0]
    ny[k]=(size(*images[k],/dim))[1]
endfor

;; read in basic PSFs and its get approximate size
bpsf=dvpsf(nx[ref]/2L, ny[ref]/2L, psf=psfs[ref])
pnx=(size(bpsf,/dim))[0]
pny=(size(bpsf,/dim))[1]
dfit_mult_gauss, bpsf, 1, amp, psfsig, model=model, /quiet 

;; hack to find pixel scale
ntest=10L
xyad, *hdrs[ref], nx[ref]/2L, ny[ref]/2L, ra1, dec1
xyad, *hdrs[ref], nx[ref]/2L+ntest, ny[ref]/2L, ra2, dec2
cirrange, ra1
cirrange, ra2
spherematch, ra1, dec1, ra2,dec2, 360., m1, m2, d12
pixscale_ref=d12/float(ntest)

;;  find stellar peaks in reference image
simage=dsmooth(*images[ref],psfsig)
ssigma=dsigma(simage, sp=psfsig*5.)
dpeaks, simage, xc=tmp_xc, yc=tmp_yc, sigma=ssigma, $
        minpeak=slim*ssigma, /refine, npeaks=nc, maxnpeaks=maxnpeaks, $
        /check

nstars=0
if(nc gt 0) then begin
   tmp_xc=tmp_xc[0:nc-1]
   tmp_yc=tmp_yc[0:nc-1]
   
   ;; try and guess which peaks are PSFlike
   chi2=dpsfid(*images[ref], *ivars[ref], tmp_xc, tmp_yc, vpsf=psfs[ref], $
               dof=dof, flux=flux)
   
   ispsf= chi2 lt dof+5.*sqrt(2.*dof) 
   istars=where(ispsf gt 0, nstars)
endif
   
if(nstars gt 0) then begin
   tmp_xstars=tmp_xc[istars]
   tmp_ystars=tmp_yc[istars]
   fluxes=fltarr(nstars)

   ;; now convert to RA and Dec
   xyad, *hdrs[ref], tmp_xstars, tmp_ystars, $
         ra_stars, dec_stars
   cirrange, ra_stars
   
   ;; refine center and subtract off best fit 
   ;; psf for each star in this band
   for k=0L, nim-1L do begin

      adxy, *hdrs[k], ra_stars, dec_stars, $
            tmp_xstars, tmp_ystars
      
      drefine, *images[k], tmp_xstars, tmp_ystars, smooth=1., $
               xr=xr, yr=yr
      chi2=dpsfid(*images[k], *ivars[k], xr, yr, vpsf=psfs[k], $
                  flux=flux, subimage=subimage)
      
      nimages[k]=ptr_new(subimage)
      
   endfor
endif else begin
   nimages[k]=ptr_new(*images[k])
endelse
nstars=n_elements(ra_stars)

end
;------------------------------------------------------------------------------
