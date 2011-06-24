;+
; NAME: 
;   absmag_wise_cat
; PURPOSE: 
;   Calculate absolute magnitudes
; CALLING SEQUENCE: 
;   absmag_wise_cat
; REVISION HISTORY:
;   14-Apr-2011 MRB NYU
;-
pro absmag_wise_cat, version=version

rootdir=atlas_rootdir(version=version)

wise=mrdfits('atlas_wise_cat.fits',1)
measure=mrdfits(rootdir+'/catalogs/atlas_measure.fits',1)
atlas=mrdfits(rootdir+'/catalogs/atlas.fits',1)
radec= struct_trimtags(atlas, select=['ra', 'dec'])
measure= struct_addtags(measure, radec)

sdss_to_maggies, smgy, sivar, cal=measure, flux='sersic'
wise_to_maggies, wise, wmgy, wivar

mgy=fltarr(9, n_elements(wise))
ivar=fltarr(9, n_elements(wise))
mgy[0:4,*]= smgy
ivar[0:4,*]= sivar
mgy[5:8,*]= wmgy
ivar[5:8,*]= wivar

absmag= replicate({mag:fltarr(9), mgy:fltarr(9), ivar:fltarr(9), $
                   absmag:fltarr(9)}, n_elements(wise))
absmag.mgy=mgy
absmag.ivar=ivar
dm= transpose(lf_distmod(atlas.zdist))
for i=0L, 8L do begin
    iok= where(ivar[i,*] gt 0 and mgy[i,*] gt 0 and $
               finite(mgy[i,*]) gt 0 and atlas.zdist gt 0., nok)
    if(nok gt 0) then begin
        absmag[iok].mag[i]= -2.5*alog10(transpose(mgy[i,iok]))
        absmag[iok].absmag[i]= -2.5*alog10(transpose(mgy[i,iok]))-dm[iok]
    endif
endfor

mwrfits, absmag, 'atlas_wise_absmag.fits', /create


END 
