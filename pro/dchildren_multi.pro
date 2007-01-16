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
                     nstars=nstars, ngals=ngals, sersic=in_sersic, $
                     aset=aset, sgset=sgset
                     

common atv_point, markcoord

if(NOT keyword_set(plim)) then plim=5.
if(NOT keyword_set(glim)) then glim=5.
if(NOT keyword_set(gsmooth)) then gsmooth=2.
if(NOT keyword_set(saddle)) then saddle=5.
if(keyword_set(xstars)) then nstars=n_elements(xstars)
if(keyword_set(xgals)) then ngals=n_elements(xgals)
if(keyword_set(in_sersic)) then sersic=in_sersic else sersic=0
subdir='atlases'
if(keyword_set(hand)) then subdir='hand'

spawn, 'mkdir -p '+subdir+'/'+strtrim(string(iparent),2)
asetfile=subdir+'/'+strtrim(string(iparent),2)+'/'+base+'-aset.fits'
if(keyword_set(aset) eq 0 OR file_test(asetfile) eq 0) then begin
    aset={base:base, $
          ref:ref, $
          iparent:iparent, $
          sersic:sersic, $
          gsmooth:gsmooth, $
          glim:glim}
endif else begin
    aset=mrdfits(asetfile, 1)
    gsmooth=aset.gsmooth
    glim=aset.glim
    sersic=aset.sersic
endelse

sgsetfile=subdir+'/'+strtrim(string(iparent),2)+'/'+base+'-sgset.fits'
newsg=1
if(keyword_set(sgset) eq 0 OR file_test(sgsetfile) eq 0) then begin
    sgset={base:base, $
           ref:ref, $
           iparent:iparent, $
           nstars:0L, $
           xstars:fltarr(200), $
           ystars:fltarr(200), $
           ngals:0L, $
           xgals:fltarr(200), $
           ygals:fltarr(200) }
endif else begin
    newsg=0
    sgset=mrdfits(sgsetfile, 1)
endelse

maxnpeaks=1000L

;; read in images and psfs
hdr=headfits('parents/'+base+'-parent-'+ $
             strtrim(string(iparent),2)+'.fits',ext=0)
nim=long(sxpar(hdr, 'NIM'))
nx=long(sxpar(hdr, 'NAXIS1'))
ny=long(sxpar(hdr, 'NAXIS2'))
images=fltarr(nx,ny, nim)
nimages=fltarr(nx,ny, nim)
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
fit_mult_gauss, bpsf, 1, amp, psfsig, model=model, /quiet

if(keyword_set(newsg)) then begin

    
;;  find stellar peaks in all images
    for k=0, nim-1L do begin
        simage=dsmooth(images[*,*,k],psfsig)
        ssigma=dsigma(simage, sp=psfsig*5.)
        dpeaks, simage, xc=tmp_xc, yc=tmp_yc, sigma=ssigma, $
          minpeak=plim*ssigma, /refine, npeaks=nc, maxnpeaks=maxnpeaks, /check
        
        nstars=0
        if(nc gt 0) then begin
            tmp_xc=tmp_xc[0:nc-1]
            tmp_yc=tmp_yc[0:nc-1]
            
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
        endif
    endfor
    nstars=n_elements(xstars)
    
;; reduce to unique peaks
    if(nstars gt 0) then begin
        xx=fltarr(2,n_elements(xstars))
        xx[0, *]= xstars
        xx[1, *]= ystars
        ing= groupnd(xx, psfsig, firstg=firstg, nd=2)
        nstars=max(ing)+1L
        xstars=xstars[firstg[0:nstars-1]]
        ystars=ystars[firstg[0:nstars-1]]
    endif
    
;;  find galaxy peaks in all images
    if(nstars gt 0) then begin
        stimages=fltarr(nx,ny,nstars)
    endif
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
                stimages[*,*,i]=tmp_model*scale
                model=model+stimages[*,*,i]
            endfor
        endif
        nimages[*,*,k]=images[*,*,k]-model
        
        subpix=long(gsmooth/3.) > 1L
        nxsub=nx/subpix
        nysub=ny/subpix
        simage=rebin(nimages[0:nxsub*subpix-1, 0:nysub*subpix-1, k], $
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
            drefine, nimages[*,*,k], tmp_xgals, tmp_ygals, smooth=2., $
              xr=r_xgals, yr=r_ygals, box=long(5.*subpix)
            
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
        ing= groupnd(xx, gsmooth, firstg=firstg, nd=2)
        xgals=xgals[firstg]
        ygals=ygals[firstg]
        ngals=n_elements(xgals)
    endif
    
;; then take out stars that are near galaxies
;; but give the center as the center of the star
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
            xgals[m2]=xstars[m1]
            ygals[m2]=ystars[m1]
            istars=where(kpsf gt 0, nstars) 
            if(nstars gt 0) then begin
                xstars=xstars[istars] 
                ystars=ystars[istars] 
            endif
        endif
    endif

    sgset.nstars= nstars
    if(nstars gt 0) then begin
        sgset.xstars[0:nstars-1]= xstars
        sgset.ystars[0:nstars-1]= ystars
    endif
    sgset.ngals= ngals
    if(ngals gt 0) then begin
        sgset.xgals[0:ngals-1]= xgals
        sgset.ygals[0:ngals-1]= ygals
    endif
endif else begin
    nstars=sgset.nstars
    if(nstars gt 0) then begin
        xstars=sgset.xstars[0:nstars-1]
        ystars=sgset.ystars[0:nstars-1]
    endif
    ngals=sgset.ngals
    if(ngals gt 0) then begin
        xgals=sgset.xgals[0:ngals-1]
        ygals=sgset.ygals[0:ngals-1]
    endif
    if(nstars gt 0) then begin
        stimages=fltarr(nx,ny,nstars)
    endif
endelse

mwrfits, aset, asetfile, /create
mwrfits, sgset, sgsetfile, /create

if(NOT keyword_set(nodeblend)) then begin
    if(ngals+nstars gt 0) then begin
        acat=replicate({pid:iparent, $
                        aid:-1L, $
                        xcen:0., $
                        ycen:0., $
                        bgood:lonarr(nim), $
                        type:0L, $
                        good:0L}, ngals+nstars)
        acat.aid=lindgen(ngals+nstars)
    endif
    for k=0L, nim-1L do begin
        if(k eq 0) then first=1 else first=0
        
        if(ngals gt 0) then begin
            spawn, 'mkdir -p '+subdir+'/'+strtrim(string(iparent),2)
            
            model=fltarr(nx,ny)
            if(nstars gt 0) then begin
                msimage=dmedsmooth(images[*,*,k], box=long(psfsig*30L))
                fimage=images[*,*,k]-msimage
                fivar=ivars[*,*,k]
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
                    stimages[*,*,i]=tmp_model*scale
                
                    acat[i].xcen=xstars[i]
                    acat[i].ycen=ystars[i]
                    acat[i].good=1
                    acat[i].type=1L
                    acat[i].bgood[k]=1
                    aid=acat[i].aid
                    mwrfits, stimages[*,*,i], $
                      subdir+'/'+strtrim(string(iparent),2)+ $
                      '/'+base+'-'+strtrim(string(iparent),2)+ $
                      '-atlas-'+strtrim(string(aid),2)+'.fits', hdr, $
                      create=first
                    model=model+stimages[*,*,i]
                endfor
            endif
            nimages[*,*,k]=images[*,*,k]-model

            ;; make galaxy templates
            dtemplates, nimages[*,*,k], xgals, ygals, templates=templates, $
              sersic=sersic, ikept=ikept
        
            ;; find weights
            dweights, nimages[*,*,k], ivars[*,*,k], templates, $
              weights=weights, /nonneg
            dfluxes, nimages[*,*,k], templates, weights, xgals, ygals, $
              children=children
            

            nchild=n_elements(children)/nx/ny
            
            for i=0L, nchild-1L do begin
                acat[nstars+ikept[i]].xcen=xgals[ikept[i]]
                acat[nstars+ikept[i]].ycen=ygals[ikept[i]]
                acat[nstars+ikept[i]].type=0L
                if(total(children[*,*,i]) gt 0) then begin
                    acat[nstars+ikept[i]].good=1
                    acat[nstars+ikept[i]].bgood[k]=1
                endif
                aid=acat[nstars+ikept[i]].aid
                mwrfits, children[*,*,i], subdir+'/'+ $
                  strtrim(string(iparent),2)+ $
                  '/'+base+'-'+strtrim(string(iparent),2)+ $
                  '-atlas-'+strtrim(string(aid),2)+'.fits', hdr, create=first
            endfor

            notkept=bytarr(ngals)+1
            notkept[ikept]=0
            inot=where(notkept, nnot)
            if(nnot gt 0) then begin
                for i=0L, nnot-1L do begin
                    aid=acat[nstars+inot[i]].aid
                    acat[nstars+inot[i]].type=0L
                    mwrfits, fltarr(nx,ny), $
                      subdir+'/'+strtrim(string(iparent),2)+ $
                      '/'+base+'-'+strtrim(string(iparent),2)+ $
                      '-atlas-'+strtrim(string(aid),2)+'.fits', hdr, $
                      create=first
                endfor
            endif
        endif 
    endfor
    
    if(n_tags(acat) gt 0) then begin
        mwrfits, acat, subdir+'/'+strtrim(string(iparent),2)+ $
          '/'+base+'-'+strtrim(string(iparent),2)+ $
          '-acat.fits', /create
    endif
endif

end
;------------------------------------------------------------------------------
