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

hdr=gz_headfits(psffile, ext=0)

if(n_elements(hdr) eq 1) then return,0

nx=long(sxpar(hdr, 'NX'))
ny=long(sxpar(hdr, 'NY'))
xst=long(sxpar(hdr, 'XST'))
yst=long(sxpar(hdr, 'YST'))
nc=long(sxpar(hdr, 'NC'))
np=long(sxpar(hdr, 'NP'))
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
        COEFFS:fltarr(200L,nc), $
        PSFT:fltarr(natlas, natlas, nc)}

psfstr.bpsf=gz_mrdfits(psffile, 0)
psfstr.psft=gz_mrdfits(psffile, 1)
psfstr.coeffs[0:np*np-1]=(gz_mrdfits(psffile, 2))[0:np*np-1]

return, psfstr

end
;------------------------------------------------------------------------------
