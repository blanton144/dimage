;+
; NAME:
;   check_munoz
; PURPOSE:
;   Checks atlas against Munoz-Mateos numbers
; CALLING SEQUENCE:
;   check_munoz
; REVISION HISTORY:
;   22-Jun-2011  Written by Mike Blanton, NYU
;-
;------------------------------------------------------------------------------
pro check_munoz

munoz= read_munoz()
atlas= read_atlas(measure=measure, kcorrect=kcorrect, /galex)

spherematch, munoz.ra, munoz.dec, measure.racen, measure.deccen, 3./3600., m1, m2

atlas=atlas[m2]
measure=measure[m2]
munoz=munoz[m1]

glactc, atlas.ra, atlas.dec, 2000., gl, gb, 1, /deg
ebv=dust_getval(gl,gb,/interp,/noloop)
extvoebv=3.10
nuv_extoextv=8.18/extvoebv
fuv_extoextv=8.29/extvoebv
nuv_extinction=ebv*nuv_extoextv*extvoebv
fuv_extinction=ebv*fuv_extoextv*extvoebv
u_extinction=ebv*5.155
g_extinction=ebv*3.793
r_extinction=ebv*2.751
i_extinction=ebv*2.086
z_extinction=ebv*1.479

fmag= 22.5-2.5*alog10(measure.sersicflux[6])-fuv_extinction
nmag= 22.5-2.5*alog10(measure.sersicflux[5])-nuv_extinction
umag= 22.5-2.5*alog10(measure.sersicflux[0])-u_extinction
gmag= 22.5-2.5*alog10(measure.sersicflux[1])-g_extinction
rmag= 22.5-2.5*alog10(measure.sersicflux[2])-r_extinction
imag= 22.5-2.5*alog10(measure.sersicflux[3])-i_extinction
zmag= 22.5-2.5*alog10(measure.sersicflux[4])-z_extinction

fmagp= 22.5-2.5*alog10(measure.petroflux[6])-fuv_extinction
nmagp= 22.5-2.5*alog10(measure.petroflux[5])-nuv_extinction
umagp= 22.5-2.5*alog10(measure.petroflux[0])-u_extinction
gmagp= 22.5-2.5*alog10(measure.petroflux[1])-g_extinction
rmagp= 22.5-2.5*alog10(measure.petroflux[2])-r_extinction
imagp= 22.5-2.5*alog10(measure.petroflux[3])-i_extinction
zmagp= 22.5-2.5*alog10(measure.petroflux[4])-z_extinction

end
;------------------------------------------------------------------------------
