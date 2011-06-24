;+
; NAME:
;   read_munoz
; PURPOSE:
;   Reads in Munoz-Mateos et al (2009) catalog
; CALLING SEQUENCE:
;   munoz= read_munoz()
; COMMENTS:
;   Data stored in $DIMAGE_DIR/data/sstest/munozmateos.txt
; REVISION HISTORY:
;   22-Jun-2011  Written by Mike Blanton, NYU
;-
;------------------------------------------------------------------------------
function read_munoz, reset=reset

fitsfile= getenv('DIMAGE_DIR')+'/data/sstest/munozmateos.fits'

if(file_test(fitsfile) eq 0 or keyword_set(reset) gt 0) then begin
    txtfile= getenv('DIMAGE_DIR')+'/data/sstest/munozmateos.txt'
    
    munoz0= {name:' ', $
             fmag:0., $
             fmag_err:0., $
             nmag:0., $
             nmag_err:0., $
             umag:0., $
             umag_err:0., $
             gmag:0., $
             gmag_err:0., $
             rmag:0., $
             rmag_err:0., $
             imag:0., $
             imag_err:0., $
             zmag:0., $
             zmag_err:0., $
             jmag:0., $
             jmag_err:0., $
             hmag:0., $
             hmag_err:0., $
             kmag:0., $
             kmag_err:0., $
             ra:0.D, $
             dec:0.D}
    
    openr, unit, txtfile, /get_lun
    line= ' '
    while(NOT eof(unit)) do begin
        readf, unit, line
        line= strtrim(line, 2)
        if(keyword_set(line)) then begin
            if(strmid(line, 0, 1) ne '#') then begin
                words = strsplit(line, /extr)
                
                munoz0.name= words[0]+' '+words[1]
                munoz0.fmag= float(words[2])
                munoz0.fmag_err= float(words[4])
                munoz0.nmag= float(words[5])
                munoz0.nmag_err= float(words[5])
                munoz0.umag= float(words[8])
                munoz0.umag_err= float(words[10])
                munoz0.gmag= float(words[11])
                munoz0.gmag_err= float(words[13])
                munoz0.rmag= float(words[14])
                munoz0.rmag_err= float(words[16])
                munoz0.imag= float(words[17])
                munoz0.imag_err= float(words[19])
                munoz0.zmag= float(words[20])
                munoz0.zmag_err= float(words[22])
                munoz0.jmag= float(words[23])
                munoz0.jmag_err= float(words[25])
                munoz0.hmag= float(words[26])
                munoz0.hmag_err= float(words[28])
                munoz0.kmag= float(words[29])
                munoz0.kmag_err= float(words[31])
                
                if(n_tags(munoz) eq 0) then $
                   munoz= munoz0 $
                else $
                   munoz= [munoz, munoz0]
            endif
        endif
    endwhile
    free_lun, unit

    for i=0L, n_elements(munoz)-1L do begin
        hogg_ned_name2radec, munoz[i].name, ra, dec
        munoz[i].ra= ra
        munoz[i].dec= dec
    endfor

    mwrfits, munoz, fitsfile, /create
    
endif

munoz= mrdfits(fitsfile, 1)
    
return, munoz

end
;------------------------------------------------------------------------------
