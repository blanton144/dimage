pro test_dpsf, base

maxnpeaks=1000L

image=mrdfits(base+'.fits')
sigma=dsigma(image, sp=4L)
nx=(size(image,/dim))[0]
ny=(size(image,/dim))[1]
ivar=fltarr(nx,ny)+1./sigma^2

dfitpsf, base+'.fits', natlas=41

vpsf=dpsfread(base+'-vpsf.fits')

psfsig=2.
plim=10.
image=image-median(image)
simage=dsmooth(image,psfsig)
ssigma=dsigma(simage, sp=psfsig*5.)

dpeaks, simage, xc=xc, yc=yc, sigma=ssigma, minpeak=plim*ssigma, $
  /refine, npeaks=nc, maxnpeaks=maxnpeaks, /check

ispsf=dpsfcheck(image, ivar, xc, yc, amp=amp, vpsf=vpsf)

istars=where(ispsf gt 0, nstars)
xstars=xc[istars]
ystars=yc[istars]
ispsf=ispsf[istars]
amp=amp[istars]

;; subtract off PSFs, we don't care about them
model=fltarr(nx,ny)
for i=0L, nstars-1L do begin & $
    currpsf=dvpsf(xstars[i], ystars[i], psfsrc=vpsf) & $
    embed_stamp, model, amp[i]*currpsf/max(currpsf), $
      xstars[i]-float(vpsf.natlas/2L), ystars[i]-float(vpsf.natlas/2L) & $
endfor
nimage= image-model

save, filename='data_dpsf.sav'

end
