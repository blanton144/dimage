;+
; NAME:
;   read_nsa
; PURPOSE:
;   Read in the final NSA file for a particular version
; CALLING SEQUENCE:
;   nsa= read_nsa([version=, mrdfits options])
; OPTIONAL INPUTS:
;   version - version
; REVISION HISTORY:
;   15-Jul-2011  MRB, NYU
;-
;------------------------------------------------------------------------------
function read_nsa, version=version, _EXTRA=extra_for_mrdfits

if(not keyword_set(version)) then $
  version= atlas_default_version()

rootdir= atlas_rootdir(version=version)
nsafile= rootdir+'/nsa_'+version+'.fits'
nsa= mrdfits(nsafile,1, _EXTRA=extra_for_mrdfits)

return, nsa

end

