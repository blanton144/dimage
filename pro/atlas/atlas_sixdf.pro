;+
; NAME:
;   sixdf_atlas
; PURPOSE:
;   Convert the 6dF file into an atlas-appropriate file
; CALLING SEQUENCE:
;   sixdf_atlas
; REVISION HISTORY:
;   31-Jul-2010  MRB, NYU
;-
;------------------------------------------------------------------------------
pro sixdf_atlas

six= mrdfits(getenv('DIMAGE_DIR')+'/data/atlas/sixdf/sixdf.fits', 1)

z=six.cz/299792.
ikeep= where(z lt 0.055)
six=six[ikeep]

mwrfits, six, getenv('DIMAGE_DIR')+'/data/atlas/sixdf_atlas.fits', /create

end

