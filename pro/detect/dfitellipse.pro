;+
; NAME:
;   dfitellipse
; PURPOSE:
;   Fit an ellipse to a mask image
; CALLING SEQUENCE:
;   dfitellipse, mask, xcen, ycen, ellipse=ellipse
; INPUTS:
;   mask - [nx,ny] input mask image (0 or 1)
;   xcen, ycen - x,y center
; OUTPUTS:
;   iso - structure with results
; COMMENTS:
;   Smoothes (mask gt 0) with a 1 pixel Gaussian; then subtracts
;   -0.5. Then fits for an ellipse by maximizing the sum of the
;   pixels within it.
; REVISION HISTORY:
;   10-Aug-2008  Written by Mike Blanton, NYU
;-
;------------------------------------------------------------------------------
function dfitellipse_func, params

common com_dfe, dimage, xx, yy

nx=(size(dimage, /dim))[0]
ny=(size(dimage, /dim))[1]

xcen= params[0]
ycen= params[1]
ba= params[2]
phi= params[3]
rr= params[4]

rrround= sqrt((xx-xcen)^2+(yy-ycen)^2)
rrsquash= sqrt((xx-xcen)^2+((yy-ycen)/ba)^2)
rrrot= polywarp_rotate(rrsquash, phi, center=[xcen, ycen])

irr= where(rrrot lt rr and rrround lt rr, nrr)


tot= 0. 
if(nrr gt 0) then begin
    tot= -total(dimage[irr])
new= fltarr(nx, ny)
new[irr]=1.
atv, dimage
atv2, new
endif

help, tot

return,tot

end
;
pro dfitellipse, image, limit, xcen, ycen, ellipse=ellipse

common com_dfe

nx=(size(image, /dim))[0]
ny=(size(image, /dim))[1]

xx= findgen(nx)#replicate(1., ny)
yy= replicate(1., nx)#findgen(ny)

;; get initial guess
if(n_elements(xcen) eq 0 OR n_elements(ycen) eq 0) then $
  dpeaks, image, xcen=xcen, ycen=ycen, maxnpeaks=1L

;; flood fill 
simage= dsmooth(image, 1.)
mimage= long(image gt limit)
fimage= dfloodfill(mimage, long(xcen), long(ycen), 2L)
eimage= fltarr(nx, ny)
ifill= where(fimage eq 2L, nfill)
if(nfill) eq 0 then return
eimage[ifill]= 1.

extract_profmean, image, long([xcen, ycen]), profmean, $
  profmean_ivar, nprof=nprof, profradius=profradius, cache=cache, $
  qstokes=qstokes, ustokes=ustokes
dpetro, nprof, profmean, petrorad=petrorad, $
  petror50= petror50, petror90= petror90, petroflux= petroflux
qu_to_baphi, qstokes, ustokes, bastokes, phistokes
ba= interpol(bastokes, profradius, petror50)
phi= interpol(phistokes, profradius, petror50)

dimage=dsmooth(eimage,1)-0.5

parinfo0= {value:0., limited:[0, 0], limits:fltarr(2)}
parinfo= replicate(parinfo0, 5)
parinfo[0].value= xcen
parinfo[0].limited= 1
parinfo[0].limits= [0.5, float(nx)-0.5]
parinfo[1].value= ycen
parinfo[1].limited= 1
parinfo[1].limits= [0.5, float(ny)-0.5]
parinfo[2].value= 0.5
parinfo[2].limited= 1
parinfo[2].limits= [0.1, 1.]
parinfo[3].value= phi
parinfo[3].limited= 0
parinfo[3].limits= [0., 0.]
parinfo[4].value= 10.
parinfo[4].limited= 1
parinfo[4].limits= [1., float(min([nx, ny]))/4.]

pars= tnmin('dfitellipse_func', parinfo=parinfo, /auto)


end
