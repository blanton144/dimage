;+
; NAME:
;   detect_bright
; PURPOSE:
;   detect objects in image of bright object
; CALLING SEQUENCE:
;   dimage, image
; INPUTS:
;   image - [nx, ny] input image
; COMMENTS:
;   Assumes a sky-subtracted image
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro test_deblend

nx=100
ny=100
image=fltarr(nx,ny)
xx=findgen(nx)#replicate(1.,ny)
yy=replicate(1.,nx)#findgen(ny)

xcen=[35., 55., 60.]
ycen=[30., 40., 45.]
sigx=[2.22, 10., 10.]
sigy=[2.22, 12., 10.]
rxy=[0., 0.8, 0.1]
flux=[70., 100., 50.]

i=0

invcovar=invert([[sigx[i]^2, sigx[i]*sigy[i]*rxy[i]], $
                 [sigx[i]*sigy[i]*rxy[i], sigy[i]^2]])
norm=1./(2.*!DPI*sqrt(sigx^2*sigy^2*(1.-rxy^2.)))
for j=0L, nx-1L do $
  for k=0L, ny-1L do $
  image[j,k]=image[j,k]+flux[i]* $
  exp(-0.5*([xx[j,k]-xcen[i], yy[j,k]-ycen[i]]#invcovar# $
            [xx[j,k]-xcen[i], yy[j,k]-ycen[i]]))*norm[i]
i=i+1

invcovar=invert([[sigx[i]^2, sigx[i]*sigy[i]*rxy[i]], $
                 [sigx[i]*sigy[i]*rxy[i], sigy[i]^2]])
norm=1./(2.*!DPI*sqrt(sigx^2*sigy^2*(1.-rxy^2.)))
for j=0L, nx-1L do $
  for k=0L, ny-1L do $
  image[j,k]=image[j,k]+flux[i]* $
  exp(-0.5*([xx[j,k]-xcen[i], yy[j,k]-ycen[i]]#invcovar# $
            [xx[j,k]-xcen[i], yy[j,k]-ycen[i]]))*norm[i]
i=i+1

invcovar=invert([[sigx[i]^2, sigx[i]*sigy[i]*rxy[i]], $
                 [sigx[i]*sigy[i]*rxy[i], sigy[i]^2]])
norm=1./(2.*!DPI*sqrt(sigx^2*sigy^2*(1.-rxy^2.)))
for j=0L, nx-1L do $
  for k=0L, ny-1L do $
  image[j,k]=image[j,k]+flux[i]* $
  exp(-0.5*([xx[j,k]-xcen[i], yy[j,k]-ycen[i]]#invcovar# $
            [xx[j,k]-xcen[i], yy[j,k]-ycen[i]]))*norm[i]
i=i+1

save
restore
sigma=0.0001
ivar=fltarr(nx,ny)+1./sigma^2

image=image+randomn(seed,nx,ny)*sigma

deblend, image, ivar, nchild=nchild, xcen=xcen, ycen=ycen, $
  children=children, templates=templates, xgals=xcen[1], $
  ygals=ycen[1], xstars=xcen[0], ystars=ycen[0]

save

end
;------------------------------------------------------------------------------
