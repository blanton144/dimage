;+
; NAME:
;   dgals
; PURPOSE:
;   find galaxies in multi-band, multi-res images (called by dchildren)
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro dgals, nimages, psfs, hdrs, gsmooth=gsmooth, glim=glim, $
           ra_gals=out_ra_gals, dec_gals=out_dec_gals, ngals=ngals, $
           puse=puse

nim=n_elements(nimages)
nx=lonarr(nim)
ny=lonarr(nim)

for k=0L, nim-1L do begin
    if(keyword_set(puse[k])) then begin
    nx[k]=(size(*nimages[k],/dim))[0]
    ny[k]=(size(*nimages[k],/dim))[1]
endif
endfor

for k=0L, nim-1L do begin
if(keyword_set(puse[k])) then begin
    ntest=10L
    xyad, *hdrs[k], nx[k]/2L, ny[k]/2L, ra1, dec1
    xyad, *hdrs[k], nx[k]/2L+ntest, ny[k]/2L, ra2, dec2
    spherematch, ra1, dec1, ra2,dec2, 360., m1, m2, d12
    pixscale=(d12/float(ntest)*3600.)[0]

    subpix=(long(gsmooth/pixscale/3.) > 1L)[0]
    nxsub=nx[k]/subpix
    nysub=ny[k]/subpix
    simage=rebin((*nimages[k])[0:nxsub*subpix-1, 0:nysub*subpix-1], $
                 nxsub, nysub)
    simage=dsmooth(simage, gsmooth/pixscale/float(subpix))
    ssig=dsigma(simage, sp=10)
    sivar=fltarr(nxsub, nysub)+1./ssig^2
    dpeaks, simage, xc=xc, yc=yc, sigma=ssig, minpeak=glim*ssig, $
      /refine, npeaks=ngals, saddle=saddle, /check
    if(ngals eq 0) then begin
        while(ngals eq 0 AND gsmooth gt 1.) do begin
            gsmooth=(gsmooth*0.7)>1.
            subpix=(long(gsmooth/3.) > 1L)[0]
            nxsub=nx[k]/subpix
            nysub=ny[k]/subpix
            simage=rebin((*nimages[k])[0:nxsub*subpix-1, 0:nysub*subpix-1], $
                         nxsub, nysub)
            simage=dsmooth(simage, gsmooth/float(subpix))
            ssig=dsigma(simage, sp=10)
            sivar=fltarr(nxsub, nysub)+1./ssig^2
            dpeaks, simage, xc=xc, yc=yc, sigma=ssig, minpeak=glim*ssig, $
              /refine, npeaks=ngals, saddle=saddle, /check
        endwhile
    endif
    
    if(ngals gt 0) then begin
        tmp_xgals=(float(xc)+0.5)*float(subpix)
        tmp_ygals=(float(yc)+0.5)*float(subpix)
        
        ;; refine the centers
        drefine, *nimages[k], tmp_xgals, tmp_ygals, smooth=2., $
          xr=r_xgals, yr=r_ygals, box=long(5.*subpix)

        xyad, *hdrs[k], r_xgals, r_ygals, $
          tmp_ra_gals, tmp_dec_gals
        
        if(n_elements(ra_gals) eq 0) then begin
            ra_gals=tmp_ra_gals
            dec_gals=tmp_dec_gals
        endif else begin
            ra_gals=[ra_gals, tmp_ra_gals]
            dec_gals=[dec_gals, tmp_dec_gals]
        endelse
    endif
endif
endfor 
ngals=n_elements(ra_gals)

;; reduce to unique peaks
if(ngals gt 0) then begin
    ing=spheregroup(ra_gals, dec_gals, 2.*gsmooth/3600., $
                    firstg=firstg)
    ngals=max(ing)+1L
    out_ra_gals=ra_gals[firstg[0:ngals-1]]
    out_dec_gals=dec_gals[firstg[0:ngals-1]]
endif

end
;------------------------------------------------------------------------------
