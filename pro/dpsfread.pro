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
nc=long(sxpar(hdr, 'NP'))
np=long(sxpar(hdr, 'NC'))
natlas=long(sxpar(hdr, 'NATLAS'))

psfstr={NX:nx, $
        NY:ny, $
        NP:np, $
        NC:nc, $
        NATLAS:natlas, $
        COEFFS:fltarr(np*(np+1L)/2L,nc), $
        PSFT:fltarr(natlas, natlas, nc)}

psfstr.psft=mrdfits(psffile, 0)
psfstr.coeffs=mrdfits(psffile, 1)

return, psfstr

end
;------------------------------------------------------------------------------
