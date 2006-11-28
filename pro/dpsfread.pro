;+
; NAME:
;   dpsfread
; PURPOSE:
;   read a PSF structure from a file
; CALLING SEQUENCE:
;   psfstr= dpsfread(psffile)
; INPUTS:
;   psffile - input FITS file output by dpsffit
; OUTPUTS:
;   psfstr - structure with:
;             NX
;             NY
;             COEFFS[NP, NC]
;             PSFT[NATLAS, NATLAS, NC]
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
function dpsfread, psffile

hdr=headfits(psffile, ext=0)
nx=long(sxpar(hdr, 'NX'))
ny=long(sxpar(hdr, 'NY'))
xst=long(sxpar(hdr, 'XST'))
yst=long(sxpar(hdr, 'YST'))
nc=long(sxpar(hdr, 'NP'))
np=long(sxpar(hdr, 'NC'))
softbias=float(sxpar(hdr, 'SOFTBIAS'))
natlas=long(sxpar(hdr, 'NATLAS'))

psfstr={XST:xst, $
        YST:yst, $
        NX:nx, $
        NY:ny, $
        NP:np, $
        NC:nc, $
        NATLAS:natlas, $
        SOFTBIAS:softbias, $
        BPSF:fltarr(natlas,natlas), $
        COEFFS:fltarr(np*(np+1L)/2L,nc), $
        PSFT:fltarr(natlas, natlas, nc)}

psfstr.bpsf=mrdfits(psffile, 0)
psfstr.psft=mrdfits(psffile, 1)
psfstr.coeffs=mrdfits(psffile, 2)

return, psfstr

end
;------------------------------------------------------------------------------
