;+
; NAME:
;   detect_fakes
; PURPOSE:
;   Run detect on fakes
; CALLING SEQUENCE:
;   detect_fakes, name
; COMMENTS:
;   Takes smosaics from indir and reorganizes into directory under:
;      /global/data/scr/mb144/skyfake/[name]
; REVISION HISTORY:
;   2-Aug-2010 MRB, NYU
;-
pro detect_fakes, name

dirs= file_search('/global/data/scr/mb144/skyfake/'+name+'/*', /test_dir)

for i=208L, n_elements(dirs)-1L do begin
    cd, dirs[i]
    if(dirs[i] ne '/global/data/scr/mb144/skyfake/fake-004/fake-004-1184') then begin
        detect_atlas 
        dmeasure_atlas
    endif
endfor

end
