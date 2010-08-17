;+
; NAME:
;   atlas_alfalfa
; PURPOSE:
;   builds the ALFALFA catalog for atlas
; CALLING SEQUENCE:
;   atlas_alfalfa
; REVISION HISTORY:
;   15-Aug-2010  Fixed for atlas, MRB NYU
;-
;------------------------------------------------------------------------------
pro atlas_alfalfa

alfalfa=mrdfits(getenv('DIMAGE_DIR')+'/data/atlas/alfalfa/alfalfa3.fits',1)

ikeep= where(alfalfa.cz/299792. lt 0.055)
alfalfa=alfalfa[ikeep]

mwrfits, alfalfa, getenv('DIMAGE_DIR')+'/data/atlas/alfalfa_atlas.fits', $
         /create

end
