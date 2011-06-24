;+
; NAME:
;   atlas_version_info
; PURPOSE:
;   return information about version
; CALLING SEQUENCE:
;   info= atlas_version_info(version)
; REVISION HISTORY:
;   23-Jun-2011  MRB, NYU
;-
;------------------------------------------------------------------------------
function atlas_version_info, version

all= yanny_readone(getenv('DIMAGE_DIR')+'/data/atlas/atlas_versions.par')
iv= where(all.version eq version, nv)
if(nv gt 1) then $
  message, 'Error in versions files, multiple instances of '+version
if(nv eq 0) then begin
    splog, 'No version '+version
    return, 0
endif

return, all[iv[0]]
  
end
