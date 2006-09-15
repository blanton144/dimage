;+
; NAME:
;   dproc
; PURPOSE:
;   process a particular image
; CALLING SEQUENCE:
;   
; INPUTS:
;   image - [nx, ny] input image
; COMMENTS:
;   Assumes a sky-subtracted image
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro detect_bright, image, psmooth=psmooth

common atv_point, markcoord

 image=mrdfits('NGC_309_MCG_-2_3_50_IRAS_00542-1010-r.fits.gz')
 image=mrdfits('NGC_741_UGC_1413_3ZW_38-r.fits.gz')
 image=mrdfits('NGC_1129_UGC_2373-r.fits.gz')
 image=mrdfits('UGC_10041-r.fits.gz')

nx=(size(image,/dim))[0]
ny=(size(image,/dim))[1]

;; do general object detection
sigma=dsigma(image)
invvar=fltarr(nx,ny)+1./sigma^2
dobjects, image, invvar, object=oimage, plim=25., dpsf=1.

iobj=where(oimage eq oimage[nx/2L, ny/2L])
ixobj=iobj mod nx
iyobj=iobj / nx
xstart=(min(ixobj)-30L)>0
xend=(max(ixobj)+30L)<(nx-1L)
ystart=(min(iyobj)-30L)>0
yend=(max(iyobj)+30L)<(ny-1L)
nxnew=xend-xstart+1L
nynew=yend-ystart+1L

timage=image[xstart:xend, ystart:yend]
oimage=oimage[xstart:xend, ystart:yend]

;; now choose the object that includes the center
iobj=where(oimage eq oimage[nx/2L-xstart, ny/2L-ystart] OR oimage eq -1L)

iimage=randomn(seed, nxnew, nynew)*sigma
iimage[iobj]=timage[iobj]
iivar=fltarr(nxnew,nynew)+1./sigma^2

;; find all peaks 
dpeaks, iimage, xc=xc, yc=yc, sigma=sigma, minpeak=20.*sigma, /refine

;; try and guess which peaks are PSFlike
psf=dpsfcheck(iimage, iivar, xc, yc, amp=amp, guess=3.)
ipsf=where(psf gt 0., npsf)
xpsf=xc[ipsf]
ypsf=yc[ipsf]
psf=psf[ipsf]
amp=amp[ipsf]

nxi=(size(iimage,/dim))[0]
nyi=(size(iimage,/dim))[1]

nimage=iimage
for i=0L, npsf-1L do begin & $
  xst=long(xpsf[i]-psf[i]*8)>0L  & $
    xnd=long(xpsf[i]+psf[i]*8)<(nxi-1L)  & $
    xs=xnd-xst+1L  & $
    yst=long(ypsf[i]-psf[i]*8)>0L  & $
    ynd=long(ypsf[i]+psf[i]*8)<(nyi-1L)  & $
    ys=ynd-yst+1L  & $
    xx=(xst+findgen(xs))#replicate(1., ys)  & $
    yy=replicate(1., xs)#(yst+findgen(ys))  & $
    model=amp[i]*exp(-0.5*((xx-xpsf[i])^2+(yy-ypsf[i])^2)/psf[i]^2)  & $
    nimage[xst:xnd, yst:ynd]= nimage[xst:xnd, yst:ynd]- model & $
endfor

psmooth=15.
subpix=long(psmooth/3.) > 1L
nxsub=nxi/subpix
nysub=nyi/subpix
simage=rebin(nimage[0:nxsub*subpix-1, 0:nysub*subpix-1], nxsub, nysub)
simage=dsmooth(simage, psmooth/float(subpix))
ssig=dsigma(simage)
sivar=fltarr(nxsub, nysub)+1./ssig^2
dpeaks, simage, xc=xc, yc=yc, sigma=sigma, minpeak=10.*sigma, /refine
xpeaks=xc*float(subpix)
ypeaks=yc*float(subpix)

;;x1=fltarr(2,n_elements(xpsf))
;;x1[0,*]=xpsf
;;x1[1,*]=ypsf
;;x2=fltarr(2,n_elements(xpeaks))
;;x2[0,*]=xpeaks
;;x2[1,*]=ypeaks
;;matchnd, x1, x2, 5., m1=m1, m2=m2, nmatch=nm
;;if(nm gt 0) then begin & $
;;kpsf=lonarr(n_elements(xpsf))+1L & $
;;kpsf[m1]=0 & $
;;  ik=where(kpsf gt 0) & $
;;  xpsf=xpsf[ik] & $
;;  ypsf=ypsf[ik] & $
;;  endif

atv,iimage
atvplot, xpsf, ypsf, psym=4
atvplot, xpeaks, ypeaks, psym=4, color='green'


;; deblend on those peaks
deblend, iimage, iivar, nchild=nchild, xcen=xcen, ycen=ycen, $
  children=children, templates=templates, xgals=xpeaks, ygals=ypeaks, $
  xstars=xpsf, ystars=ypsf


;; measure colors of PSFlike peaks

;; 

;; smooth, resample, and find peaks at a reasonable scale 


deblend, simage, sivar, nchild=nchild, xcen=xcen, ycen=ycen, $
  children=children, templates=templates

dpeaks, simage, xc=xc, yc=yc, sigma=ssig, minpeak=25.*ssig
xpeaks=xc*float(subpix)
ypeaks=yc*float(subpix)

for i=0L, n_elements(xpeaks)-1L do begin
  xst=long(xpeaks[i]-1.5*subpix)>0L
  xnd=long(xpeaks[i]+1.5*subpix)<(nx-1L)
  yst=long(ypeaks[i]-1.5*subpix)>0L
  ynd=long(ypeaks[i]+1.5*subpix)<(ny-1L)
  subim=iimage[xst:xnd, yst:ynd]
  vmax=max(subim, imax)
  xpeaks[i]=(imax mod (xnd-xst+1L))+xst
  ypeaks[i]=(imax / (xnd-xst+1L))+yst
endfor
endif

splog, 'Mark stars and exit'
atv, iimage, /block

starcoord=markcoord

splog, 'Mark galaxies and exit'
atv, iimage, /block
galcoord=markcoord

xstars=transpose(starcoord[0,*])
ystars=transpose(starcoord[1,*])
xgals=transpose(galcoord[0,*])
ygals=transpose(galcoord[1,*])

stop


;; 
save


end
;------------------------------------------------------------------------------
