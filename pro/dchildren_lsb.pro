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
pro dchildren_lsb, base, iparent, psfs=psfs, plim=plim, gsmooth=gsmooth, $
                     glim=glim, xstars=xstars, ystars=ystars, xgals=xgals, $
                     ygals=ygals, hand=hand, saddle=saddle, ref=ref, $
                     nstars=nstars, ngals=ngals, sersic=in_sersic, $
                     aset=in_aset, sgset=in_sgset, starlimit=starlimit, $
                     sizelimit=sizelimit, sdss=sdss
                     

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

maxnstar=2000L

;; read in images and psfs
hdr=headfits('parents/'+base+'-parent-'+ $
             strtrim(string(iparent),2)+'.fits',ext=0)
nim=long(sxpar(hdr, 'NIM'))
nx=long(sxpar(hdr, 'NAXIS1'))
ny=long(sxpar(hdr, 'NAXIS2'))
images=fltarr(nx,ny, nim)
nimages=fltarr(nx,ny, nim)
ivars=fltarr(nx,ny, nim)

if(keyword_set(sizelimit)) then begin
    if(nx lt sizelimit OR ny lt sizelimit) then return
endif

asetfile=subdir+'/'+strtrim(string(iparent),2)+'/'+base+'-aset.fits'
if(keyword_set(in_aset) eq 0 OR file_test(asetfile) eq 0) then begin
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
if(keyword_set(in_sgset) eq 0 OR file_test(sgsetfile) eq 0) then begin
    sgset={base:base, $
           ref:ref, $
           iparent:iparent, $
           nstars:0L, $
           xstars:fltarr(maxnstar), $
           ystars:fltarr(maxnstar), $
           ngals:0L, $
           xgals:fltarr(maxnstar), $
           ygals:fltarr(maxnstar) }
endif else begin
    newsg=0
    sgset=mrdfits(sgsetfile, 1)
endelse

maxnpeaks=1000L

for k=0L, nim-1L do begin
    images[*,*,k]=mrdfits('parents/'+base+'-parent-'+ $
                          strtrim(string(iparent),2)+'.fits',0+k*2L)
    ivars[*,*,k]=mrdfits('parents/'+base+'-parent-'+ $
                         strtrim(string(iparent),2)+'.fits',1+k*2L)
endfor

if(n_tags(sdss) gt 0) then begin
    sdss.filter=filtername(ref)
    bpsf=dvpsf(nx/2L, ny/2L, sdss=sdss) 
endif else begin
    bpsf=dvpsf(nx/2L, ny/2L, psf=psfs[ref])
endelse
pnx=(size(bpsf,/dim))[0]
pny=(size(bpsf,/dim))[1]
dfit_mult_gauss, bpsf, 1, amp, psfsig, model=model, /quiet ; jm07may01nyu

;; quick check for a bright star
if(keyword_set(starlimit)) then begin
    simage=dsmooth(images[*,*,ref],psfsig)
    ssigma=dsigma(simage, sp=psfsig*5.)
    dpeaks, simage, xc=tmp_xc, yc=tmp_yc, sigma=ssigma, $
      minpeak=30.*ssigma, /refine, npeaks=nc, maxnpeaks=50
    if(nc gt 0) then begin
        tmp_xc=tmp_xc[0:nc-1L]
        tmp_yc=tmp_yc[0:nc-1L]
        if(n_tags(sdss) gt 0) then begin
            sdss.filter=filtername(ref)
            ispsf=dpsfcheck(images[*,*,ref], ivars[*,*,ref], tmp_xc, tmp_yc, $
                            flux=flux, amp=amp, sdss=sdss) 
        endif else begin
            ispsf=dpsfcheck(images[*,*,ref], ivars[*,*,ref], tmp_xc, tmp_yc, $
                            vpsf=psfs[ref], flux=flux, amp=amp) 
        endelse
        if(max(flux) gt starlimit) then return
    endif
endif

spawn, 'mkdir -p '+subdir+'/'+strtrim(string(iparent),2)

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
            if(n_tags(sdss) gt 0) then begin
                sdss.filter=filtername(k)
                ispsf=dpsfcheck(images[*,*,k], ivars[*,*,k], tmp_xc, tmp_yc, $
                                sdss=sdss) 
            endif else begin
                ispsf=dpsfcheck(images[*,*,k], ivars[*,*,k], tmp_xc, tmp_yc, $
                                vpsf=psfs[k])
            endelse

            istars=where(ispsf gt 0, nstars)
            help,k
            help, nstars
            if(nstars gt 0) then begin
                tmp_xstars=tmp_xc[istars]
                tmp_ystars=tmp_yc[istars]
                fluxes=fltarr(nstars)
                
                ;; refine center and subtract off best fit psf for each star
                ;; IN THIS BAND!!
                msimage=dmedsmooth(images[*,*,k], box=long(psfsig*30L))
                fimage=images[*,*,k]-msimage
                fivar=ivars[*,*,k]
                model=fltarr(nx,ny)
                drefine, fimage, tmp_xstars, tmp_ystars, xr=xr, yr=yr, smooth=1
                for i=0L, n_elements(tmp_xstars)-1L do begin 
                    if(n_tags(sdss) gt 0) then begin
                        sdss.filter=filtername(k)
                        psf=dvpsf(xr[i], yr[i], sdss=sdss)
                    endif else begin
                        psf=dvpsf(xr[i], yr[i], psf=psfs[k])
                    endelse
                    tmp_model=fltarr(nx,ny)
                    embed_stamp, tmp_model, psf, $
                      xr[i]-float(pnx/2L), $
                      yr[i]-float(pny/2L)
                    ifit=where(tmp_model gt (-max(tmp_model)*1.e-2))
                    fluxes[i]= total(fimage[ifit]* $
                                 tmp_model[ifit]*fivar[ifit])/ $
                      total(tmp_model[ifit]*tmp_model[ifit]*fivar[ifit])
                    model=model+tmp_model*fluxes[i]
                endfor
                
                ;; in this pass don't let noise spikes come in 
                nimages[*,*,k]=(images[*,*,k]-model) < images[*,*,k]

                if(n_elements(xstars) eq 0) then begin
                    xstars=tmp_xstars
                    ystars=tmp_ystars
                endif else begin
                    xstars=[xstars, tmp_xstars]
                    ystars=[ystars, tmp_ystars]
                endelse
            endif else begin
                nimages[*,*,k]=images[*,*,k]
            endelse
        endif else begin
            nimages[*,*,k]=images[*,*,k]
        endelse
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
        if(ngals eq 0) then begin
            while(ngals eq 0 AND gsmooth gt 1.) do begin
                gsmooth=(gsmooth*0.7)>1.
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
            endwhile
        endif
        
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
        ing= groupnd(xx, 2.*gsmooth, firstg=firstg, nd=2)
        ngals=max(ing)+1L
        xgals=xgals[firstg[0:ngals-1]]
        ygals=ygals[firstg[0:ngals-1]]
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
        sgset.xstars[0:(nstars-1)<maxnstar]= xstars
        sgset.ystars[0:(nstars-1)<maxnstar]= ystars
    endif
    sgset.ngals= ngals
    if(ngals gt 0) then begin
        sgset.xgals[0:ngals-1]= xgals
        sgset.ygals[0:ngals-1]= ygals
    endif
endif else begin
    nstars=sgset.nstars
    if(nstars gt 0) then begin
        xstars=sgset.xstars[0:(nstars-1)<maxnstar]
        ystars=sgset.ystars[0:(nstars-1)<maxnstar]
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

    ;; refine galaxy peaks again
    model=fltarr(nx,ny)
    if(nstars gt 0) then begin
        msimage=dmedsmooth(images[*,*,ref], box=long(psfsig*30L))
        fimage=images[*,*,ref]-msimage
        fivar=ivars[*,*,ref]
        drefine, fimage, xstars, ystars, xr=xr, yr=yr, smooth=2
        for i=0L, nstars-1L do begin 
            if(n_tags(sdss) gt 0) then begin
                sdss.filter=filtername(ref)
                psf=dvpsf(xr[i], yr[i], sdss=sdss)
            endif else begin
                psf=dvpsf(xr[i], yr[i], psf=psfs[ref])
            endelse
            tmp_model=fltarr(nx,ny)
            embed_stamp, tmp_model, psf, $
              xr[i]-float(pnx/2L), $
              yr[i]-float(pny/2L)
            ifit=where(tmp_model ne 0.)
            scale= total(fimage[ifit]*tmp_model[ifit]*fivar[ifit])/ $
              total(tmp_model[ifit]*tmp_model[ifit]*fivar[ifit])
            model=model+tmp_model*scale
        endfor
    endif
    rimage=images[*,*,ref]-model
    if(ngals gt 0) then begin
        ;; refine the centers
        drefine, rimage, xgals, ygals, smooth=2., $
          xr=r_xgals, yr=r_ygals, box=long(5.*subpix)
        xgals=r_xgals
        ygals=r_ygals
    endif 

    for k=0L, nim-1L do begin
        if(k eq 0) then first=1 else first=0
        
        spawn, 'mkdir -p '+subdir+'/'+strtrim(string(iparent),2)
            
        model=fltarr(nx,ny)
        if(nstars gt 0) then begin
            stimages=fltarr(nx,ny,nstars)
            msimage=dmedsmooth(images[*,*,k], box=long(psfsig*30L))
            fimage=images[*,*,k]-msimage
            fivar=ivars[*,*,k]
            for i=0L, nstars-1L do begin 
                if(n_tags(sdss) gt 0) then begin
                    sdss.filter=filtername(k)
                    psf=dvpsf(xstars[i], ystars[i], sdss=sdss)
                endif else begin
                    psf=dvpsf(xstars[i], ystars[i], psf=psfs[k])
                endelse
                dprefine, fimage, psf, xstars[i], ystars[i], xr=xr, yr=yr
                tmp_model=fltarr(nx,ny)
                embed_stamp, tmp_model, psf, $
                  xr-float(pnx/2L), $
                  yr-float(pny/2L)
                ifit=where(tmp_model ne 0.)
                scale= total(fimage[ifit]*tmp_model[ifit]*fivar[ifit])/ $
                  total(tmp_model[ifit]*tmp_model[ifit]*fivar[ifit])
                stimages[*,*,i]=tmp_model
                model=model+stimages[*,*,i]*scale
            endfor
        endif
        nimages[*,*,k]=(images[*,*,k]-model) > 0.
        
        if(ngals gt 0) then begin
            ;; make galaxy templates
            dtemplates, nimages[*,*,k], xgals, ygals, templates=gtemplates, $
              sersic=sersic, ikept=ikept
            sig=dsigma(nimages[*,*,k],sp=5)
            nchild=n_elements(gtemplates)/nx/ny
            stemplates=fltarr(nx,ny,nchild)
            stemplates2=fltarr(nx,ny,nchild)
            for i=0L, nchild-1L do begin
                stemplates[*,*,i]= dsmooth(gtemplates[*,*,i], 2.5)
                stemplates2[*,*,i]= dsmooth(gtemplates[*,*,i], 7.5)
                tmp_stemplates=reform(stemplates[*,*,i],nx*ny)
                tmp_stemplates2=reform(stemplates2[*,*,i],nx*ny)
                tmp_templates=reform(gtemplates[*,*,i],nx*ny)
                ii=where(tmp_stemplates lt 2.*sig, nii)
                if(nii gt 0) then $
                  tmp_templates[ii]= tmp_stemplates[ii]
                ii=where(tmp_stemplates lt 0.2*sig, nii)
                if(nii gt 0) then $
                  tmp_templates[ii]=tmp_stemplates2[ii]
                gtemplates[*,*,i]=reform(tmp_templates, nx, ny)
            endfor
        endif
        
        ;; add stars as templates
        nkept=n_elements(ikept)
        nchild=nkept+nstars
        templates=fltarr(nx,ny, nchild)
        if(nkept gt 0) then $
          templates[*,*,0:nkept-1L]=gtemplates
        if(nstars gt 0) then $
          templates[*,*,nkept:nchild-1L]=stimages
        
        ;; find weights
        if(ngals gt 0 and nstars gt 0) then begin
            xcen=[xgals[ikept], xstars]
            ycen=[ygals[ikept], ystars]
        endif else begin
            if(ngals gt 0) then begin
                xcen=[xgals[ikept]]
                ycen=[ygals[ikept]]
            endif
            if(nstars gt 0) then begin
                xcen=xstars
                ycen=ystars
            endif
        endelse 

        dweights, images[*,*,k], ivars[*,*,k], templates, $
          weights=weights, /nonneg
        help,templates
        dfluxes, images[*,*,k], templates, weights, xcen, ycen, $
          children=children
        help,children

        for i=0L, nchild-1L do begin
            iuse=i
            if(i lt nkept) then iuse=ikept[i]
            if(i lt nkept) then begin
                acat[ikept[i]].xcen=xgals[ikept[i]]
                acat[ikept[i]].ycen=ygals[ikept[i]]
                acat[iuse].type=0L
            endif else begin
                acat[i].xcen=xstars[i-nkept]
                acat[i].ycen=ystars[i-nkept]
                acat[iuse].type=1L
            endelse
            if(total(children[*,*,i]) gt 0) then begin
                acat[iuse].good=1
                acat[iuse].bgood[k]=1
            endif
            aid=acat[iuse].aid
            mwrfits, children[*,*,i], subdir+'/'+ $
              strtrim(string(iparent),2)+ $
              '/'+base+'-'+strtrim(string(iparent),2)+ $
              '-atlas-'+strtrim(string(aid),2)+'.fits', hdr, create=first
            mwrfits, templates[*,*,i], subdir+'/'+ $
              strtrim(string(iparent),2)+ $
              '/'+base+'-'+strtrim(string(iparent),2)+ $
              '-templates-'+strtrim(string(aid),2)+'.fits', hdr, $
              create=first
        endfor
        
        if(ngals gt 0) then begin
            notkept=bytarr(ngals)+1
            notkept[ikept]=0
            inot=where(notkept, nnot)
            if(nnot gt 0) then begin
                for i=0L, nnot-1L do begin
                    aid=acat[inot[i]].aid
                    acat[inot[i]].type=0L
                    mwrfits, fltarr(nx,ny), $
                      subdir+'/'+strtrim(string(iparent),2)+ $
                      '/'+base+'-'+strtrim(string(iparent),2)+ $
                      '-atlas-'+strtrim(string(aid),2)+'.fits', hdr, $
                      create=first
                    mwrfits, fltarr(nx,ny), $
                      subdir+'/'+strtrim(string(iparent),2)+ $
                      '/'+base+'-'+strtrim(string(iparent),2)+ $
                      '-templates-'+strtrim(string(aid),2)+'.fits', hdr, $
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
