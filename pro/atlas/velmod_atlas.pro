;+
; NAME:
;   velmod_atlas
; PURPOSE:
;   Get "real" distances to galaxies for atlas
; CALLING SEQUENCE:
;   velmod_atlas
; COMMENTS:
;   Reads in the file:
;      atlas_rootdir/catalogs/atlas_combine.fits
;   Outputs the file:
;      atlas_rootdir/catalogs/atlas_velmod.fits
; REVISION HISTORY:
;   15-Aug-2010  MRB, NYU
;-
;------------------------------------------------------------------------------
pro velmod_atlas, version=version

if(NOT keyword_set(sigv)) then sigv=150.
if(n_elements(beta) eq 0) then beta=0.5

rootdir=atlas_rootdir(sample=sample, version=version)

atlas=mrdfits(rootdir+'/catalogs/atlas_combine.fits',1)

vmod1={zdist:-1., $
       zdist_err:-1., $
       zlg:-1., $
       zhelio:-1., $
       ra:0., $
       dec:0.}
vmod=replicate(vmod1, n_elements(atlas))
vmod.ra= atlas.ra
vmod.dec= atlas.dec
vmod.zhelio= atlas.z
vmod.zlg=vhelio_to_vlg(vmod.zhelio*2.99792e+5, vmod.ra, vmod.dec)/2.99792e+5
vmod.zdist=vmod.zlg
vmod.zdist_err=sigv/2.99792e+5

ilow=where(vmod.zlg lt 6400./299792. and vmod.zlg gt -1., nlow)
help,nlow
if(nlow gt 0) then begin
   ldist=velmod_distance(vmod[ilow].zhelio, vmod[ilow].ra, vmod[ilow].dec, $
                         sigv=sigv, beta=beta)
   vmod[ilow].zdist=ldist.distance/2.99792e+5
   vmod[ilow].zdist_err=ldist.distance_err/2.99792e+5
endif

mwrfits, vmod, rootdir+'/catalogs/atlas_velmod.fits', /create

end
