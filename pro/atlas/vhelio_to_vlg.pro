;+
; NAME:
;   vhelio_to_vlg
; PURPOSE:
;   convert from heliocentric to local group barycentric redshifts
; CALLING SEQUENCE:
;   cz_lg= vhelio_to_vlg(cz, ra, dec)
; INPUTS:
;   cz - [N] heliocentric redshift in km/s
;   ra - [N] right ascension (J2000 deg)
;   dec - [N] declination (J2000 deg)
; OUTPUTS:
;   cz_lg - [N] local group barycentric redshift
; COMMENTS
;   According to Yahil 1977, ApJ 217, 903, the Sun is moving at 308
;   km/s in the direction l=105., b=-7. in Galactic coordinates. This
;   means that something at rest wrt the barycenter and is in that
;   direction looks like it is coming towards us and we have to ADD
;   308 km/s to its velocity.
; REVISION HISTORY:
;   7-Apr-2004  Converted from Michael Strauss's Fortran by Mike Blanton, NYU
;-
;------------------------------------------------------------------------------
function vhelio_to_vlg, cz, ra, dec

d2r=!DPI/180.

; set bary_l, bary_b, bary_v
bary_b = -7.
bary_l = 105.
bary_v = 308.

; convert ra/dec to ll/bb
glactc, ra, dec, 2000, ll, bb, 1, /deg

ctheta = cos((ll - bary_l)*d2r)*cos(bb*d2r)*cos(bary_b*d2r) + $
  sin(bb*d2r)*sin(bary_b*d2r)
cz_lg = cz + bary_v*ctheta      ; correction to lg barycenter.

return, cz_lg

end
