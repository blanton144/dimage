;+
; NAME:
;   smosaic_tiles_list
; PURPOSE:
;   make a list of tiles
; CALLING SEQUENCE:
;   smosaic_tiles_list
; REVISION HISTORY:
;   15-Jan-2015  MRB, NYU
;-
;------------------------------------------------------------------------------
pro smosaic_tiles_list

ra0= 145.51339
dec0= 0.33645
size=0.5

ntiles= 210

list0={itile:0L, $
       ra:0.D, $
       dec:0.D, $
       size:0.}

list= replicate(list0, ntiles)
list.itile= lindgen(ntiles)
list.ra= ra0+dindgen(ntiles)
list.dec= dblarr(ntiles)+dec0
list.size= size

mwrfits, list, 'equatorial-tiles.fits', /create

end
