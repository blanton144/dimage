;+
; NAME:
;   atlas_sixdf
; PURPOSE:
;   Convert the 6dF file into an atlas-appropriate file
; CALLING SEQUENCE:
;   sixdf_atlas
; REVISION HISTORY:
;   31-Jul-2010  MRB, NYU
;-
;------------------------------------------------------------------------------
pro atlas_sixdf

rootdir=atlas_rootdir(sample=sample, version=version)

six= mrdfits(rootdir+'/catalogs/sixdf/sixdf.fits', 1)

z=six.cz/299792.
ikeep= where(z lt 0.055)
six=six[ikeep]

mwrfits, six, rootdir+'/catalogs/sixdf_atlas.fits', /create

end

