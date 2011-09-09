;+
; NAME:
;   velmod_atlas
; PURPOSE:
;   Get "real" distances to galaxies for atlas
; CALLING SEQUENCE:
;   velmod_atlas
; COMMENTS:
;   Uses read_atlas() to get measure and atlas heliocentric redshift
;   Outputs the file:
;      atlas_rootdir/derived/[version]/atlas_velmod.fits
;   For v0_1_0 and earlier, this value was derived before the
;    measurements of the images; however, now we match to the SDSS
;    spectra afterwards to ensure quality.
; REVISION HISTORY:
;   15-Aug-2010  MRB, NYU
;-
;------------------------------------------------------------------------------
pro velmod_atlas, version=version

if(NOT keyword_set(sigv)) then sigv=150.
if(n_elements(beta) eq 0) then beta=0.5

rootdir=atlas_rootdir(version=version, ddir=ddir)

atlas=read_atlas(measure=measure, finalz=finalz, /notrim)

vmod1={zdist:-1., $
       zdist_err:-1., $
       zlg:-1., $
       zhelio:-1., $
       ra:0.D, $
       dec:0.D}
vmod=replicate(vmod1, n_elements(atlas))
vmod.ra= atlas.ra
vmod.dec= atlas.dec
vmod.zhelio= finalz.z
vmod.zlg=vhelio_to_vlg(vmod.zhelio*2.99792e+5, vmod.ra, vmod.dec)/2.99792e+5
vmod.zdist=vmod.zlg
vmod.zdist_err=sigv/2.99792e+5

ilow=where(vmod.zlg lt 6400./299792. and vmod.zlg gt -1., nlow)
help,nlow
if(nlow gt 0) then begin
   ldist=velmod_distance(vmod[ilow].zhelio, vmod[ilow].ra, vmod[ilow].dec, $
                         sigv=sigv, beta=beta, version=version)
   vmod[ilow].zdist=ldist.distance/2.99792e+5
   vmod[ilow].zdist_err=ldist.distance_err/2.99792e+5
endif

mwrfits, vmod, ddir+'/atlas_velmod.fits', /create

end
