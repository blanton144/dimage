;+
; NAME: 
;   wise_nearby_select
; PURPOSE: 
;   Select nearby galaxies appropriate to WISE+SDSS analysis
; CALLING SEQUENCE: 
;   wise_nearby_select
; COMMENTS:
;   Writes into current directory:
;     atlas_wise_nearby.fits
; REVISION HISTORY:
;   11-Apr-2011 MRB NYU
;-
pro wise_nearby_select

atlas= mrdfits(getenv('DIMAGE_DIR')+'/data/atlas/atlas.fits',1)
measure= mrdfits(getenv('DIMAGE_DIR')+'/data/atlas/atlas_measure.fits',1)
radec= struct_trimtags(atlas, select=['ra', 'dec'])
measure= struct_addtags(measure, radec)

th50= measure.sersic_r50*0.396
rmag= 22.5-2.5*alog10(measure.sersicflux[2]>0.01)

ibig= where(rmag gt 10. and rmag lt 14. and th50 gt 3., nbig)

wiseinfo=replicate({nsaid:-1L, zdist:0., ra:0.D, dec:0.D, absmag:fltarr(5), $
                    n:0., th50:0., rmag:0., inside:0, sersicflux:fltarr(5), $
                    sersicflux_ivar:fltarr(5), isdss:-1l, ined:-1L}, nbig)

wiseinfo.ra= measure[ibig].racen
wiseinfo.dec= measure[ibig].deccen
wiseinfo.th50= th50[ibig]
wiseinfo.rmag= rmag[ibig]
wiseinfo.n= measure[ibig].sersic_n
wiseinfo.nsaid= ibig
wiseinfo.isdss= atlas[ibig].isdss
wiseinfo.ined= atlas[ibig].ined

euler, wiseinfo.ra, wiseinfo.dec, elon, elat, 3
wiseinfo.inside= (elon gt 27.8 and elon lt 133.4) OR $
  (elon gt 201.9 and elon lt 309.6)

kc= sdss_kcorrect(wiseinfo.zdist, cal=wiseinfo, flux='sersic',absmag=absmag)
wiseinfo.absmag=absmag

mwrfits, wiseinfo, 'atlas_wise_nearby.fits', /create

END 
