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
pro dchildren_multi, base, iparent, psf=psf, plim=plim, gsmooth=gsmooth, $
                     glim=glim, xstars=xstars, ystars=ystars, xgals=xgals, $
                     ygals=ygals, hand=hand, saddle=saddle

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
image=fltarr(nx,ny, nim)
ivar=fltarr(nx,ny, nim)

for k=0L, nim-1L do begin
    image[*,*,k]=mrdfits('parents/'+base+'-parent-'+ $
                  strtrim(string(iparent),2)+'.fits',0+k*2L)
    ivar[*,*,k]=mrdfits('parents/'+base+'-parent-'+ $
                        strtrim(string(iparent),2)+'.fits',1+k*2L)
endfor


    
pnx=(size(psf,/dim))[0]
pny=(size(psf,/dim))[1]
fit_mult_gauss, psf, 1, amp, psfsig, model=model

;; find all peaks 
if(NOT keyword_set(xstars)) then begin
    simage=dsmooth(image,psfsig)
    ssigma=dsigma(simage, sp=psfsig*5.)
    dpeaks, simage, xc=xc, yc=yc, sigma=ssigma, minpeak=plim*ssigma, $
      /refine, npeaks=nc, maxnpeaks=maxnpeaks, /check
endif    

if(keyword_set(nc) gt 0 or $
   keyword_set(xstars) gt 0 or $
   keyword_set(xgals) gt 0 or $
   keyword_set(hand) gt 0) then begin
    
    if(keyword_set(xstars) eq 0 AND $
       keyword_set(xgals) eq 0) then begin 

        ;; try and guess which peaks are PSFlike
        ispsf=dpsfcheck(image, ivar, xc, yc, amp=amp, psf=psf)
        istars=where(ispsf gt 0, nstars)
        if(nstars gt 0) then begin
            xstars=xc[istars]
            ystars=yc[istars]
            ispsf=ispsf[istars]
            amp=amp[istars]
        
            ;; subtract off PSFs, we don't care about them
            model=fltarr(nx,ny)
            for i=0L, nstars-1L do $ 
              embed_stamp, model, amp[i]*psf/max(psf), $
              xstars[i]-float(pnx/2L), ystars[i]-float(pny/2L)
            nimage= image-model
        endif else begin
            nimage= image
        endelse
    endif

    if(keyword_set(xgals) eq 0) then begin
        ngals=0
        while(ngals eq 0 and gsmooth gt 1.) do begin
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
            
            if(ngals eq 0) then $
              gsmooth=gsmooth*0.8 > 1.
        endwhile
        
        if(ngals gt 0) then begin
            xgals=(float(xc)+0.5)*float(subpix)
            ygals=(float(yc)+0.5)*float(subpix)
            
            ;; refine the centers
            drefine, nimage, xc, yc, smooth=2., xr=xgals, yr=ygals, $
              box=long(5.*subpix)
            
            if(keyword_set(nstars)) then begin
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
        endif
    endif
    
    if(keyword_set(hand)) then $
      dhand, image, xstars=xstars, ystars=ystars, nstars=nstars, $
      xgals=xgals, ygals=ygals, ngals=ngals

;; deblend on those peaks
    if(nstars gt 0 OR ngals gt 0) then begin

        ;; make stellar templates
        psfd=psf
        if(nstars gt 0) then begin
            psfd=fltarr(pnx, pny, n_elements(xstars))
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
endif

end
;------------------------------------------------------------------------------
