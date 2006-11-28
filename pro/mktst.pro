nx=1000
ny=1000

x=nx*randomu(seed,300)
y=ny*randomu(seed,300)
amp=10.+randomu(seed,300)*100.

sigma=1.5+(x/float(nx)+y/float(ny))*0.2

image=fltarr(nx,ny)

xarr=(findgen(nx)#replicate(1.,ny))
yarr=(replicate(1.,nx)#findgen(ny))

for i=0L, 299L do $
  image=image+amp[i]*exp(-0.5*((xarr-x[i])^2+(yarr-y[i])^2)/sigma[i]^2)

image=image+randomn(seed,nx,ny)

mwrfits, image, 'tst.fits', /create

test_dpsf, 'tst'
