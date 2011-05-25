;+
; NAME:
;   dtrim_atlas
; PURPOSE:
;   trim an atlas directory of bulky files
; CALLING SEQUENCE:
;   dtrim_atlas
; REVISION HISTORY:
;   24-May-2011  MRB, NYU
;-
;------------------------------------------------------------------------------
pro dtrim_atlas

spawn, /nosh, ['find', 'atlases', '-name', '*-templates-*.fits.gz', '-exec', 'rm', '-f', '{}', ';']
spawn, /nosh, ['find', 'atlases', '-name', '*-nimage-*.fits.gz', '-exec', 'rm', '-f', '{}', ';']
spawn, /nosh, ['find', 'parents', '-name', '*-parent-*.fits.gz', '-exec', 'rm', '-f', '{}', ';']

end
