;+
; NAME:
;   dtrim_atlas_all
; PURPOSE:
;   re-trim all atlas detections
; CALLING SEQUENCE:
;   dtrim_atlas_all [, subname= ]
; REVISION HISTORY:
;   3-Aug-2004  MRB, NYU
;-
;------------------------------------------------------------------------------
pro dtrim_atlas_all, subname=subname

atlas= read_atlas(/notrim)

for i=0L, n_elements(atlas)-1L do begin
    if((i mod 1000) eq 0) then $
      help, i
    atcd, i, subname=subname
    dtrim_atlas
endfor
 
end
