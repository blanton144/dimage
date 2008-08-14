;+
; NAME:
;   dmeasure_check
; PURPOSE:
;   visual check of measurements of deblended image
; CALLING SEQUENCE:
;   dmeasure_check, image, ivar, measure=measure
; INPUTS:
;   image - [nx,ny] input image
;   measure - parameters of measurements
; OPTIONAL INPUTS:
;   invvar - [nx,ny] input inverse variance [default to unity everywhere]
; REVISION HISTORY:
;   10-Aug-2008  Written by Mike Blanton, NYU
;-
;------------------------------------------------------------------------------
pro dmeasure_check, image, ivar, measure=measure

common com_dmeasure, cache

help,/st,measure

profradius=[0.564190, 1.692569, 2.585442, 4.406462, $
            7.506054, 11.576202, 18.584032, 28.551561, $
            45.503910, 70.510155, 110.530769, 172.493530, $
            269.519104, 420.510529, 652.500061]

nx=(size(image,/dim))[0]
ny=(size(image,/dim))[0]

if(NOT keyword_set(ivar)) then $
  ivar= fltarr(nx, ny)+1.

xx= findgen(nx)#replicate(1., ny)
yy= replicate(1., nx)#findgen(ny)
rr= sqrt((xx-measure.xcen)^2+(yy-measure.ycen)^2)
rinterp=findgen(long(max(rr)))
bprofradius= [0., profradius]
profrmean= 0.5*(bprofradius[0:n_elements(bprofradius)-2]+ $
                bprofradius[1:n_elements(bprofradius)-1])
profinterp= interpol(measure.profmean, profrmean, rinterp)

splot, rr, image, psym=3
soplot, rinterp, profinterp, th=2, color='red'
soplot, [measure.petrorad, measure.petrorad], [-1.,3.]*max(profinterp), th=2, $
  color='green', linest=1

atv, image
atvplot, measure.xcen, measure.ycen, psym=6

;; plot petrosian radius
nth=100L
th= findgen(nth)/float(nth-1L)*360.
xc= measure.xcen+2.*measure.petrorad*cos(!DPI*th/180.)
yc= measure.ycen+2.*measure.petrorad*sin(!DPI*th/180.)
atvplot, xc, yc, color='yellow', th=2
xc= measure.xcen+measure.petror50*cos(!DPI*th/180.)
yc= measure.ycen+measure.petror50*sin(!DPI*th/180.)
atvplot, xc, yc, color='green', th=2
xc= measure.xcen+measure.petror90*cos(!DPI*th/180.)
yc= measure.ycen+measure.petror90*sin(!DPI*th/180.)
atvplot, xc, yc, color='green', th=2

xc= measure.petror90*cos(!DPI*(th)/180.)
yc= measure.ba90*measure.petror90*sin(!DPI*(th)/180.)
xcr= measure.xcen+xc*cos(!DPI*measure.phi90/180.)-yc*sin(!DPI*measure.phi90/180.)
ycr= measure.ycen+xc*sin(!DPI*measure.phi90/180.)+yc*cos(!DPI*measure.phi90/180.)
atvplot, xcr, ycr, color='green'

xc= measure.petror50*cos(!DPI*(th)/180.)
yc= measure.ba50*measure.petror50*sin(!DPI*(th)/180.)
xcr= measure.xcen+xc*cos(!DPI*measure.phi50/180.)-yc*sin(!DPI*measure.phi50/180.)
ycr= measure.ycen+xc*sin(!DPI*measure.phi50/180.)+yc*cos(!DPI*measure.phi50/180.)
atvplot, xcr, ycr, color='green'

end
