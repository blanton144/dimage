;+
; NAME:
;   dchildren
; PURPOSE:
;   deblend children of a parent
; CALLING SEQUENCE:
;   dchildren, base, iparent [, psf=psf, plim=, gsmooth=, glim=, 
;      saddle=, xstars=, ystars=, xgals=, ygals=, clippsf=, /hand ]
; INPUTS:
;   base - FITS image base name
;   iparent - parent to process 
; OPTIONAL KEYWORDS:
;   /hand - brings up ATV so user can pick galaxy and star centers
; OPTIONAL INPUTS:
;   psf - [npx, npy] PSF to assume (if none, doesn't search for stars)
;   plim - nsigma limit for point source detection (default 5.)
;   glim - nsigma limit for galaxy detection (default 5.)
;   gsmooth - smoothing for galaxy detection (default 2.)
;   saddle - saddle point for galaxy peak checking (default 100.)
;   xstars, ystars - [N] input where you want stars assumed
;   xgals, ygals - [N] input where you want galaxies assumed
;   clippsf - if set, limits psf to gaussian approximation at
;             clippsf*sigma and further from center
; COMMENTS:
;   Assumes that dparents.pro has been run, so it looks for parent
;   image in:
;    myimage-parents.fits
;   If you input 'myimage.fits' it outputs:
;    myimage-iparent-cat.fits (catalog)
;    myimage-iparent-atlas.fits (atlases)
; TODO:
;   Include PSFs in final deblending.
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro dchildren_multi, base, iparent, psfs=psfs, plim=plim, gsmooth=gsmooth, $
                     glim=glim, xstars=xstars, ystars=ystars, xgals=xgals, $
                     ygals=ygals, hand=hand, saddle=saddle, ref=ref, $
                     nstars=nstars, ngals=ngals

common atv_point, markcoord

if(NOT keyword_set(plim)) then plim=5.
if(NOT keyword_set(glim)) then glim=5.
if(NOT keyword_set(gsmooth)) then gsmooth=2.
if(NOT keyword_set(saddle)) then saddle=5.
if(keyword_set(xstars)) then nstars=n_elements(xstars)
if(keyword_set(xgals)) then ngals=n_elements(xgals)

maxnpeaks=1000L

;; read in images and psfs
hdr=headfits('parents/'+base+'-parent-'+ $
             strtrim(string(iparent),2)+'.fits',ext=0)
nim=long(sxpar(hdr, 'NIM'))
nx=long(sxpar(hdr, 'NAXIS1'))
ny=long(sxpar(hdr, 'NAXIS2'))
images=fltarr(nx,ny, nim)
ivars=fltarr(nx,ny, nim)

for k=0L, nim-1L do begin
    images[*,*,k]=mrdfits('parents/'+base+'-parent-'+ $
                          strtrim(string(iparent),2)+'.fits',0+k*2L)
    ivars[*,*,k]=mrdfits('parents/'+base+'-parent-'+ $
                         strtrim(string(iparent),2)+'.fits',1+k*2L)
endfor

bpsf=dvpsf(nx/2L, ny/2L, psf=psfs[ref])
pnx=(size(bpsf,/dim))[0]
pny=(size(bpsf,/dim))[1]
fit_mult_gauss, bpsf, 1, amp, psfsig, model=model


;;  find stellar peaks in all images
for k=0, nim-1L do begin
    simage=dsmooth(images[*,*,k],psfsig)
    ssigma=dsigma(simage, sp=psfsig*5.)
    dpeaks, simage, xc=tmp_xc, yc=tmp_yc, sigma=ssigma, $
      minpeak=plim*ssigma, /refine, npeaks=nc, maxnpeaks=maxnpeaks, /check
    
    ;; try and guess which peaks are PSFlike
    ispsf=dpsfcheck(images[*,*,k], ivars[*,*,k], tmp_xc, tmp_yc, $
                    vpsf=psfs[k])
    istars=where(ispsf gt 0, nstars)
    if(nstars gt 0) then begin
        tmp_xstars=tmp_xc[istars]
        tmp_ystars=tmp_yc[istars]
        if(n_elements(xstars) eq 0) then begin
            xstars=tmp_xstars
            ystars=tmp_ystars
        endif else begin
            xstars=[xstars, tmp_xstars]
            ystars=[ystars, tmp_ystars]
        endelse
    endif
endfor
nstars=n_elements(xstars)

;; reduce to unique peaks
if(nstars gt 0) then begin
    xx=fltarr(2,n_elements(xstars))
    xx[0, *]= xstars
    xx[1, *]= ystars
    ing= groupnd(xx, psfsig, firstg=firstg, nd=2)
    xstars=xstars[firstg]
    ystars=ystars[firstg]
    nstars=n_elements(xstars)
endif
    
;;  find galaxy peaks in all images
for k=0L, nim-1L do begin

    msimage=dmedsmooth(images[*,*,k], box=long(psfsig*30L))
    fimage=images[*,*,k]-msimage
    fivar=ivars[*,*,k]

    ;; refine center and subtract off best fit psf for each star
    model=fltarr(nx,ny)
    if(nstars gt 0) then begin
        drefine, fimage, xstars, ystars, xr=xr, yr=yr
        for i=0L, nstars-1L do begin 
            psf=dvpsf(xstars[i], ystars[i], psf=psfs[k])
            tmp_model=fltarr(nx,ny)
            embed_stamp, tmp_model, psf, $
              xstars[i]-float(pnx/2L), $
              ystars[i]-float(pny/2L)
            ifit=where(tmp_model ne 0.)
            scale= total(fimage[ifit]*tmp_model[ifit]*fivar[ifit])/ $
              total(tmp_model[ifit]*tmp_model[ifit]*fivar[ifit])
            tmp_model=tmp_model*scale
            model=model+tmp_model
        endfor
    endif
    nimage=images[*,*,k]-model

    subpix=long(gsmooth/3.) > 1L
    nxsub=nx/subpix
    nysub=ny/subpix
    simage=rebin(nimage[0:nxsub*subpix-1, 0:nysub*subpix-1], $
                 nxsub, nysub)
    simage=dsmooth(simage, gsmooth/float(subpix))
    ssig=dsigma(simage, sp=10)
    sivar=fltarr(nxsub, nysub)+1./ssig^2
    dpeaks, simage, xc=xc, yc=yc, sigma=ssig, minpeak=glim*ssig, $
      /refine, npeaks=ngals, saddle=saddle, /check
    
    if(ngals gt 0) then begin
        tmp_xgals=(float(xc)+0.5)*float(subpix)
        tmp_ygals=(float(yc)+0.5)*float(subpix)
        
        ;; refine the centers
        drefine, nimage, tmp_xgals, tmp_ygals, smooth=2., xr=r_xgals, $
          yr=r_ygals, box=long(5.*subpix)
        
        if(n_elements(xgals) eq 0) then begin
            xgals=r_xgals
            ygals=r_ygals
        endif else begin
            xgals=[xgals, r_xgals]
            ygals=[ygals, r_ygals]
        endelse
    endif
endfor 
ngals=n_elements(xgals)

;; reduce to unique peaks
if(ngals gt 0) then begin
    xx=fltarr(2,ngals)
    xx[0, *]= xgals
    xx[1, *]= ygals
    ing= groupnd(xx, subpix, firstg=firstg, nd=2)
    xgals=xgals[firstg]
    ygals=ygals[firstg]
    ngals=n_elements(xgals)
endif

if(keyword_set(nstars) gt 0 AND $
   keyword_set(ngals) gt 0) then begin
    x1=fltarr(2,n_elements(xstars))
    x1[0,*]=xstars
    x1[1,*]=ystars
    x2=fltarr(2,n_elements(xgals))
    x2[0,*]=xgals
    x2[1,*]=ygals
    matchnd, x1, x2, 10., m1=m1, m2=m2, nmatch=nm, nd=2
    if(nm gt 0) then begin
        kpsf=lonarr(n_elements(xstars))+1L 
        kpsf[m1]=0 
        istars=where(kpsf gt 0, nstars) 
        if(nstars gt 0) then begin
            xstars=xstars[istars] 
            ystars=ystars[istars] 
        endif
    endif
endif
    
if(keyword_set(hand)) then $
  dhand, images[*,*,ref], xstars=xstars, ystars=ystars, nstars=nstars, $
  xgals=xgals, ygals=ygals, ngals=ngals

for k=0L, nim-1L do begin
    if(nstars gt 0 OR ngals gt 0) then begin
        
        ;; make stellar templates
        psfd=psf
        if(nstars gt 0) then begin
            psfd=fltarr(pnx, pny, n_elements(xstars))
            psf=dvpsf(xstars[i], ystars[i], psf=psfs[k])
            for i=0L, n_elements(xstars)-1L do begin
                psfd[*,*,i]=sshift2d(psf, [xstars[i]-long(xstars[i]), $
                                           ystars[i]-long(ystars[i])])
            endfor
        endif

        ;; make galaxy templates
        dtemplates, nimage, xgals, ygals, templates=templates, /sersic

        ;; combine the two

        ;; find weights
        dweights, nimage, ivar, templates, weights=weights, /nonneg
        dfluxes, nimage, templates, weights, xgals, ygals, children=children
        
        nchild=n_elements(children)/nx/ny

        mwrfits, children[*,*,0], base+'-'+strtrim(string(iparent),2)+ $
          '-atlas.fits', hdr, /create
        for i=1L, nchild-1L do $
          mwrfits, children[*,*,i], base+'-'+strtrim(string(iparent),2)+ $
          '-atlas.fits', hdr
    endif 

end
;------------------------------------------------------------------------------
