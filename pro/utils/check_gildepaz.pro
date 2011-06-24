;+
; NAME:
;   check_gildepaz
; PURPOSE:
;   Checks atlas against Gil de Paz results
; CALLING SEQUENCE:
;   check_munoz
; REVISION HISTORY:
;   22-Jun-2011  Written by Mike Blanton, NYU
;-
;------------------------------------------------------------------------------
pro check_gildepaz

gdp= mrdfits(getenv('DIMAGE_DIR')+'/data/sstest/gildepaz07.fits',1)
atlas= read_atlas(measure=measure, /galex)

spherematch, gdp._raj2000, gdp._dej2000, measure.racen, measure.deccen, $
             3./3600., m1, m2

atlas=atlas[m2]
measure=measure[m2]
gdp=gdp[m1]

fmag= 22.5-2.5*alog10(measure.sersicflux[6]>0.001)
nmag= 22.5-2.5*alog10(measure.sersicflux[5]>0.001)
rmag= 22.5-2.5*alog10(measure.sersicflux[2]>0.001)
gmag= 22.5-2.5*alog10(measure.sersicflux[1]>0.001)

fmagp= 22.5-2.5*alog10(measure.petroflux[6]>0.001)
nmagp= 22.5-2.5*alog10(measure.petroflux[5]>0.001)
rmagp= 22.5-2.5*alog10(measure.petroflux[2]>0.001)

anmag= 22.5-2.5*alog10(measure.sersicflux[5]>0.001)
agmag= 22.5-2.5*alog10(measure.sersicflux[1]>0.001)


end
;------------------------------------------------------------------------------
