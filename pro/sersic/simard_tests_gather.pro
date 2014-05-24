;+
; NAME:
;   simard_tests_gather
; PURPOSE:
;   Gather measurements for Simard tests
; CALLING SEQUENCE:
;   simard_tests_gather, filebase
; INPUTS:
;   filebase - basename for each file
; REVISION HISTORY:
;   20-May-2014  Written by Mike Blanton, NYU
;-
;------------------------------------------------------------------------------
pro simard_tests_gather, include_sersic=include_sersic

filebase='vA'
sim= mrdfits('sim-test.fits', 1)

for i=0L, n_elements(sim)-1L do begin
    measure= mrdfits(filebase+'-nsa-'+strtrim(string(i),2)+'.fits',1)
    if(keyword_set(include_sersic)) then $
      sersic= mrdfits(filebase+'-nsa-'+strtrim(string(i),2)+'.fits',2)
    petro= mrdfits(filebase+'-petro-'+strtrim(string(i),2)+'.fits',1)
    if(n_tags(all) eq 0) then begin
        petro0= struct_trimtags(petro[0], except=['xcen', 'ycen'])
        measure0= struct_trimtags(measure[0], except=['xcen', 'ycen'])
        all0= create_struct(sim[0], measure[0], petro0)
        if(n_tags(sersic) gt 0) then begin
            sersic0= struct_trimtags(sersic[0], except=['xcen', 'ycen'])
            all0= create_struct(all0, sersic0)
        endif 
        all= replicate(all0, n_elements(sim))
    endif
    struct_assign, sim[i], all0
    struct_assign, measure, all0, /nozero
    struct_assign, petro, all0, /nozero
    if(n_tags(sersic) gt 0) then $
      struct_assign, sersic, all0, /nozero
    all[i]=all0
endfor

mwrfits, all, filebase+'-test.fits', /create

end
