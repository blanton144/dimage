nx=600
ny=600

num=150L

x=nx*randomu(seed,num)
y=ny*randomu(seed,num)
amp=10.+randomu(seed,num)*100.

sigma=1.5+(x/float(nx)+y/float(ny))*0.2

image=fltarr(nx,ny)

xarr=(findgen(nx)#replicate(1.,ny))
yarr=(replicate(1.,nx)#findgen(ny))

for i=0L, num-1L do $
  image=image+amp[i]*exp(-0.5*((xarr-x[i])^2+(yarr-y[i])^2)/sigma[i]^2)

image=image+randomn(seed,nx,ny)

mwrfits, image, 'tst.fits', /create

test_dpsf, 'tst'
