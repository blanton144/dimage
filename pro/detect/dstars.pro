;+
; NAME:
;   dstars
; PURPOSE:
;   find stars in multi-band, multi-res images (called by dchildren)
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro dstars, images, ivars, psfs, hdrs, sdss=sdss, slim=slim, ref=ref, $
            nimages=nimages, ra_stars=out_ra_stars, dec_stars=out_dec_stars, $
            nstars=nstars, puse=puse, maxnstar=maxnstar

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

;;  find stellar peaks in all images
for k=0, nim-1L do begin
    if(keyword_set(puse[k])) then begin
        simage=dsmooth(*images[k],psfsig)
        ssigma=dsigma(simage, sp=psfsig*5.)
        dpeaks, simage, xc=tmp_xc, yc=tmp_yc, sigma=ssigma, $
          minpeak=slim*ssigma, /refine, npeaks=nc, maxnpeaks=maxnpeaks, /check
        
        nstars=0
        if(nc gt 0) then begin
            tmp_xc=tmp_xc[0:nc-1]
            tmp_yc=tmp_yc[0:nc-1]
            
            ;; try and guess which peaks are PSFlike
            ispsf=dpsfcheck(*images[k], *ivars[k], tmp_xc, tmp_yc, $
                            vpsf=psfs[k])
        
            istars=where(ispsf gt 0, nstars)
            help,k
            help, nstars
            if(nstars gt 0) then begin
                tmp_xstars=tmp_xc[istars]
                tmp_ystars=tmp_yc[istars]
                fluxes=fltarr(nstars)
                
                ;; refine center and subtract off best fit 
                ;; psf for each star in this band
                msimage=dmedsmooth(*images[k], box=long(psfsig*30L))
                fimage=*images[k]-msimage
                fivar=*ivars[k]
                model=fltarr(nx[k],ny[k])
                xx=findgen(nx[k])#replicate(1.,ny[k])
                yy=replicate(1.,nx[k])#findgen(ny[k])
                drefine, fimage, tmp_xstars, tmp_ystars, xr=xr, yr=yr, smooth=1
                for i=0L, n_elements(tmp_xstars)-1L do begin 
                    psf=dvpsf(xr[i], yr[i], psf=psfs[k])
                    sigpsf=dsigma(psf, sp=3)
                    tmp_model=fltarr(nx[k],ny[k])
                    embed_stamp, tmp_model, psf, $
                      xr[i]-float(pnx/2L), $
                      yr[i]-float(pny/2L)
                    r2away=(xx-xr[i])^2+(yy-yr[i])^2
                    ifit=where(tmp_model gt (-max(tmp_model)*1.e-2) AND $
                               r2away lt (psfsig[0]*5.)^2 AND $
                               tmp_model ne 0.)
                    tmp_flux= total(fimage[ifit]* $
                                    tmp_model[ifit]*fivar[ifit])/ $
                      total(tmp_model[ifit]*tmp_model[ifit]*fivar[ifit])
                    sigpsf=sigpsf*tmp_flux
                    ivar=1./((1./fivar[ifit])+sigpsf^2)
                    fluxes[i]= total(fimage[ifit]* $
                                     tmp_model[ifit]*ivar)/ $
                      total(tmp_model[ifit]*tmp_model[ifit]*ivar)
                    model=model+tmp_model*fluxes[i]
                endfor
                
                ;; in this pass don't let noise spikes come in 
                nimages[k]=ptr_new(((*images[k])-model) < (*images[k]))
                
                ;; now convert to RA and Dec
                xyad, *hdrs[k], tmp_xstars, tmp_ystars, $
                  tmp_ra_stars, tmp_dec_stars
                cirrange, tmp_ra_stars
                
                if(n_elements(ra_stars) eq 0) then begin
                    ra_stars=tmp_ra_stars
                    dec_stars=tmp_dec_stars
                endif else begin
                    ra_stars=[ra_stars, tmp_ra_stars]
                    dec_stars=[dec_stars, tmp_dec_stars]
                endelse
            endif else begin
                nimages[k]=ptr_new(*images[k])
            endelse
        endif else begin
            nimages[k]=ptr_new(*images[k])
        endelse
    endif
endfor
nstars=n_elements(ra_stars)

;; reduce to unique peaks
if(nstars gt 0) then begin
    ing=spheregroup(ra_stars, dec_stars, 2.*psfsig*pixscale_ref, $
                    firstg=firstg)
    nstars=(max(ing)+1L)
    out_ra_stars=ra_stars[firstg[0:nstars-1]]
    out_dec_stars=dec_stars[firstg[0:nstars-1]]
    adxy, *hdrs[ref], out_ra_stars, out_dec_stars, out_x, out_y
    out_fluxes= (*nimages[ref])[out_x, out_y] 
    isort= reverse(sort(out_fluxes))
    isort= isort[0:(n_elements(isort)-1)<(maxnstar-1)]
    out_ra_stars=out_ra_stars[isort]
    out_dec_stars=out_dec_stars[isort]
    nstars= n_elements(out_ra_stars)
endif

end
;------------------------------------------------------------------------------
