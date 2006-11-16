;+
; NAME:
;   dvpsf
; PURPOSE:
;   given a PSF structure, return the PSF at a particular point
; CALLING SEQUENCE:
;   psf=dvpsf(x, y [, psfsrc=psfsrc)
; INPUTS:
;   psfsrc - filename, or structure with:
;             NX
;             NY
;             NP
;             NC
;             NATLAS
;             COEFFS[NP*(NP+1)/2, NC]
;             PSFT[NATLAS, NATLAS, NC]
;   x, y - location to evaluate psf at
; COMMENTS:
;   NATLAS is size of PSF image
;   NP is number of polynomial terms in variable fit
;   NC is number of components in fit
;   Returns an NX by NY image of PSF at given location
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
function dvpsf, x, y, psfsrc=psfsrc

if(n_tags(psfsrc) eq 0) then psfsrc=dpsfread(psfsrc)

xx=(x/float(psfsrc.nx))-0.5
yy=(y/float(psfsrc.ny))-0.5

cmap=fltarr(psfsrc.nc)
for c=0L, psfsrc.nc-1L do begin
    k=0L 
    for i=0L, psfsrc.np-1L do begin 
        for j=i, psfsrc.np-1L do begin 
            cmap[c]=cmap[c]+psfsrc.coeffs[k,c]*xx^(float(i))*yy^(float(j)) 
            k=k+1L 
        endfor 
    endfor 
endfor 

psf=reform(reform(psfsrc.psft, psfsrc.natlas*psfsrc.natlas, psfsrc.nc)#cmap, $
           psfsrc.natlas, psfsrc.natlas)-psfsrc.softbias

return, psf

end
;------------------------------------------------------------------------------
