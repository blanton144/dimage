;+
; NAME:
;   dpetro
; PURPOSE:
;   Measure Petrosian properties of a profile
; CALLING SEQUENCE:
;   dpetro, nprof, profmean [, petrorad=, petroflux=, petror50=, $
;     petror90=, petroratiolimit=, npetrorad= ]
; INPUTS:
;   nprof - number of usable elements in profmean
;   profmean - [nprof] profmean values
; OPTIONAL INPUTS:
;   petroratiolimit - limit for Petrosian Ratio (default 0.2)
;   npetrorad - number of Petrosian Radii out (default 2)
;   cpetrorad - fixed petrosian radius to assume
; OUTPUTS:
;   petrorad - Petrosian Radius (where Petrosian Ratio equals 
;              petroratiolimit)
;   petroflux - total Petrosian flux (within npetrorad*petrorad)
;   petror90 - 90% light radius 
;   petror50 - 50% light radius 
; REVISION HISTORY:
;   28-Mar-2002  Written by Mike Blanton, NYU
;   10-Aug-2008  Revised for new interp_profmean
;-
;------------------------------------------------------------------------------
function sb_annulus, nprof, profmean, radius

interp_profmean,nprof,profmean,radius*1.25,maggies_out
interp_profmean,nprof,profmean,radius*0.8,maggies_in
val=(maggies_out-maggies_in)/(!DPI*radius^2*(1.25^2-0.8^2))
return,val

end
;
pro dpetro,nprof,profmean,petrorad=petrorad,petroflux=petroflux, $
           petror50=petror50,petror90=petror90, $
           petroratiolimit=petroratiolimit, $
           npetrorad=npetrorad, cpetrorad=cpetrorad

if(NOT keyword_set(petroratiolimit)) then petroratiolimit=0.2
if(NOT keyword_set(npetrorad)) then npetrorad=2.
if(NOT keyword_set(profradius)) then $
  profradius=[0., 0.564190, 1.692569, 2.585442, 4.406462, $
              7.506054, 11.576202, 18.584032, 28.551561, $
              45.503910, 70.510155, 110.530769, 172.493530, $
              269.519104, 420.510529, 652.500061]

; set petrorad
nradii=1000L
radii=exp(alog(profradius[1])+(alog(profradius[nprof]) $
                               -alog(profradius[1]))* $
          dindgen(nradii)/double(nradii))

sb=sb_annulus(nprof, profmean, radii)
interp_profmean,nprof, profmean, radii,maggies_cum
avgsb=maggies_cum/(!DPI*radii^2)

if(NOT keyword_set(cpetrorad)) then begin
    indx=where(sb[0:nradii-2] gt petroratiolimit*avgsb[0:nradii-2] and $
               sb[1:nradii-1] lt petroratiolimit*avgsb[1:nradii-1], count)
    if(count eq 0) then indx=nradii-2
    petrorad=radii[indx[0]]
    petrorad=(petrorad > 1.)
endif else begin
    petrorad= cpetrorad
endelse

interp_profmean,nprof,profmean,petrorad*npetrorad,petroflux
petroflux=petroflux[0]

indx=where(maggies_cum[0:nradii-2] le 0.5*petroflux and $
           maggies_cum[1:nradii-1] gt 0.5*petroflux,count)
if(count eq 0) then $
  petror50=radii[0] $
else $
  petror50=radii[indx[0]]

indx=where(maggies_cum[0:nradii-2] le 0.9*petroflux and $
           maggies_cum[1:nradii-1] gt 0.9*petroflux,count)
if(count eq 0) then $
  petror90=radii[0] $
else $
  petror90=radii[indx[0]]

end
