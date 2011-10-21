;+
; NAME:
;   atlas_check_url
; PURPOSE:
;   Generate a URL to look at a set of atlases
; CALLING SEQUENCE:
;   url= atlas_check_url(nsaid)
; INPUTS:
;   nsaid - [N] list of NSAID numbers
; OUTPUTS:
;   url - URL(s) to check these with
; COMMENTS:
;   If more than 50 NSAID values, 'url' is returned 
;   as an array (since nsatlas.org only allows 50 at a time)
; REVISION HISTORY:
;   21-Oct-2011  MRB, NYU
;-
;------------------------------------------------------------------------------
function atlas_check_url, nsaid

nper=50L
baseurl= 'http://www.nsatlas.org/getAtlas.html?search=nsaid&cutoutType=deblend&submit_form=Submit&nsaID='

if(n_elements(nsaid) lt nper) then begin
    nurl=1L
    url='' 
endif else begin
    nurl= n_elements(nsaid)/nper+1L
    url= strarr(nurl)
endelse

for i=0L, nurl-1L do begin
    jst= i*nper
    jnd= ((i+1L)*nper-1L)<(n_elements(nsaid)-1L)
    url[i]= baseurl+strjoin(strtrim(string(nsaid[jst:jnd]),2), '%2C')
endfor

return, url

end
