;+
; NAME: 
;   kcorrect_wise_cat
; PURPOSE: 
;   Run kcorrect on the wise catalog
; CALLING SEQUENCE: 
;   convert_wise_cat
; COMMENTS:
;   Reads in:
;    wise_prelim.wise_prelim_p3as_psd9504.fits
;   (created using read_wise_cat.pro) and also
;    wise_atlas_search.txt
;   to create:
;     atlas_wise_cat.fits
;   in parallel with the atlas.fits file
;   Has SOUGHT, which indicates whether each point
;   was originally sought
; REVISION HISTORY:
;   14-Apr-2011 MRB NYU
;-
pro convert_wise_cat, version=version

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

filterlist= ['sdss_'+['u','g','r','i','z']+'0.par', $
             'wise_w'+['1','2','3','4']+'.par']

kcorrect, mgy, ivar, atlas.zdist, kc, absmag=absmag, rmaggies=rmgy, $
  filterlist=filterlist

END 
