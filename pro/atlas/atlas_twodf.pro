;+
; NAME:
;   atlas_twodf
; PURPOSE:
;   Convert the 2dF file into an atlas-appropriate file
; CALLING SEQUENCE:
;   twodf_atlas
; REVISION HISTORY:
;   31-Jul-2010  MRB, NYU
;-
;------------------------------------------------------------------------------
pro atlas_twodf, version=version

rootdir=atlas_rootdir(sample=sample, version=version)

two= mrdfits(rootdir+'/catalogs/twodf/twodf_catalog.fits.gz', 1)

ikeep= where(two.z_helio lt 0.055)
two=two[ikeep]

mwrfits, two, rootdir+'/catalogs/twodf_atlas.fits', /create

end

