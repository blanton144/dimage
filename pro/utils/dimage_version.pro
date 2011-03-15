;+
; NAME:
;   dimage_version
; PURPOSE:
;   Return the version name for the dimage product 
; CALLING SEQUENCE:
;   vers = dimage_version()
; OUTPUTS:
;   vers       - Version name for the product dimage 
; COMMENTS:
;   Depends on shell script in $DIMAGE_DIR/bin
;-
;------------------------------------------------------------------------------
function dimage_version
   spawn, 'dimage_version', stdout, /noshell
   return, stdout[0]
end
;------------------------------------------------------------------------------
