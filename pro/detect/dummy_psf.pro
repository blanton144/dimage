;+
; NAME:
;   dummy_psf
; PURPOSE:
;   return a dummy psf for cases where it is unknown
; CALLING SEQUENCE:
;   psfstr =dummy_psf(natlas, nx, ny)
; OUTPUTS:
;   psfstr - structure with:
;             NX
;             NY
;             COEFFS[NP, NC]
;             PSFT[NATLAS, NATLAS, NC]
; COMMENTS:
;   returns output like that of dpsfread()
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
function dummy_psf, natlas, nx, ny

xst=0L
yst=0L
nc=3L
np=1L
softbias=0.

psfstr={XST:xst, $
        YST:yst, $
        NX:nx, $
        NY:ny, $
        NP:np, $
        NC:nc, $
        NATLAS:natlas, $
        SOFTBIAS:softbias, $
        BPSF:fltarr(natlas,natlas), $
        COEFFS:fltarr(200L,nc), $
        PSFT:fltarr(natlas, natlas, nc)}

psfstr.bpsf= psf_gaussian(npix=natlas, st_dev=1.5, /normalize)

return, psfstr

end
;------------------------------------------------------------------------------
