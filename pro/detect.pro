;+
; NAME:
;   detect
; PURPOSE:
;   detect objects 
; CALLING SEQUENCE:
;   detect, imfile [, psf= ]
; INPUTS:
;   imfile - FITS image file 
; OPTIONAL INPUTS:
;   psf - guess sigma for gaussian PSF (default 2.)
; COMMENTS:
;   If you input 'myimage.fits' it outputs:
;    myimage-cat.fits (catalog)
;    myimage-parents.fits (atlases)
;    myimage-atlas.fits (atlases)
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro detect, imfile, guess=guess, plim=plim, msub=msub

common atv_point, markcoord

if(NOT keyword_set(guess)) then guess=1.5
if(NOT keyword_set(plim)) then plim=20.

base=(stregex(imfile, '(.*)\.fits.*', /sub, /extr))[1]

image=mrdfits(imfile)
if(keyword_set(msub)) then image=image-median(image)

nx=(size(image,/dim))[0]
ny=(size(image,/dim))[1]

;; do general object detection
sigma=dsigma(image)
invvar=fltarr(nx,ny)+1./sigma^2
dobjects, image, invvar, object=oimage, plim=plim
mwrfits, oimage, base+'-pimage.fits', /create

cat0={x:0., y:0.}

mwrfits, 0, base+'-atlas.fits', /create
mwrfits, 0, base+'-parents.fits', /create
for iobj=0L, max(oimage) do begin
    io=where(oimage eq iobj)
    ixo=io mod nx
    iyo=io / nx
    xstart=(min(ixo)-30L)>0
    xend=(max(ixo)+30L)<(nx-1L)
    ystart=(min(iyo)-30L)>0
    yend=(max(iyo)+30L)<(ny-1L)
    nxnew=xend-xstart+1L
    nynew=yend-ystart+1L

    timage=image[xstart:xend, ystart:yend]
    nimage=oimage[xstart:xend, ystart:yend]
    
;; now choose the object that includes the center
    io=where(nimage eq iobj OR nimage eq -1L)
    
    iimage=randomn(seed, nxnew, nynew)*sigma
    iimage[io]=timage[io]
    iivar=fltarr(nxnew,nynew)+1./sigma^2

    hdr=['']
    sxaddpar, hdr, 'XOFF', xstart
    sxaddpar, hdr, 'YOFF', ystart
    mwrfits, iimage, base+'-parents.fits', hdr
    
;; find all peaks 
    dpeaks, iimage, xc=xc, yc=yc, sigma=sigma, minpeak=5.*sigma/(4.*!DPI), $
      /refine, npeaks=nc, /smooth

    if(nc gt 0) then begin
        
;; try and guess which peaks are PSFlike
        psf=dpsfcheck(iimage, iivar, xc, yc, amp=amp, guess=guess)
        ipsf=where(psf gt 0., npsf)
        xstars=-1
        ystars=-1
        if(npsf gt 0) then begin
            xstars=xc[ipsf]
            ystars=yc[ipsf]
            psf=psf[ipsf]
            amp=amp[ipsf]
        endif
        
        nxi=(size(iimage,/dim))[0]
        nyi=(size(iimage,/dim))[1]
        
        nimage=iimage
        for i=0L, npsf-1L do begin 
            xst=long(xstars[i]-psf[i]*8)>0L  
            xnd=long(xstars[i]+psf[i]*8)<(nxi-1L)  
            xs=xnd-xst+1L  
            yst=long(ystars[i]-psf[i]*8)>0L  
            ynd=long(ystars[i]+psf[i]*8)<(nyi-1L)  
            ys=ynd-yst+1L  
            xx=(xst+findgen(xs))#replicate(1., ys)  
            yy=replicate(1., xs)#(yst+findgen(ys))  
            model=amp[i]*exp(-0.5*((xx-xstars[i])^2+ $
                                   (yy-ystars[i])^2)/psf[i]^2)  
            nimage[xst:xnd, yst:ynd]= nimage[xst:xnd, yst:ynd]- model 
        endfor
        
        psmooth=15.
        subpix=long(psmooth/3.) > 1L
        nxsub=nxi/subpix
        nysub=nyi/subpix
        simage=rebin(nimage[0:nxsub*subpix-1, 0:nysub*subpix-1], nxsub, nysub)
        simage=dsmooth(simage, psmooth/float(subpix))
        ssig=dsigma(simage)
        sivar=fltarr(nxsub, nysub)+1./ssig^2
        dpeaks, simage, xc=xc, yc=yc, sigma=ssig, minpeak=5.*ssig, $
          /refine, npeaks=nc
        xgals=-1
        ygals=-1
        if(nc gt 0) then begin
            xgals=(float(xc)+0.5)*float(subpix)
            ygals=(float(yc)+0.5)*float(subpix)
        endif
        
        x1=fltarr(2,n_elements(xstars))
        x1[0,*]=xstars
        x1[1,*]=ystars
        x2=fltarr(2,n_elements(xgals))
        x2[0,*]=xgals
        x2[1,*]=ygals
        matchnd, x1, x2, 5., m1=m1, m2=m2, nmatch=nm, nd=2
        if(nm gt 0) then begin
            kpsf=lonarr(n_elements(xstars))+1L 
            kpsf[m1]=0 
            ik=where(kpsf gt 0, nk) 
            if(nk gt 0) then begin
                xstars=xstars[ik] 
                ystars=ystars[ik] 
            endif else begin
                xstars=-1
                ystars=-1
            endelse
        endif

;; deblend on those peaks
        if(xstars[0] ge 0 OR xgals[0] gt 0) then begin
            deblend, iimage, iivar, nchild=nchild, xcen=xcen, ycen=ycen, $
              children=children, templates=templates, xgals=xgals, $
              ygals=ygals, xstars=xstars, ystars=ystars
    
            for i=0L, nchild-1L do begin
                cat0.x=xcen[i]+xstart
                cat0.y=ycen[i]+ystart
                if(n_tags(cat) eq 0) then $
                  cat=cat0 $ 
                else $
                  cat=[cat, cat0]
                mwrfits, children[*,*,i], base+'-atlas.fits', hdr
            endfor
        endif 
    endif

endfor
mwrfits, cat, base+'-cat.fits', /create

atv,image
atvplot, cat.x, cat.y, psym=4
atvxyouts, cat.x, cat.y, strtrim(string(lindgen(n_elements(cat))),2), chars=2.

end
;------------------------------------------------------------------------------
