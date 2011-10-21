;+
; NAME:
;   atlas_check_host
; PURPOSE:
;   Make a small HTML file with a list of links for checking atlas
; CALLING SEQUENCE:
;   atlas_check_host, filename, nsaid[, description=]
; INPUTS:
;   filename - file name of HTML file to use
;   nsaid - [N] list of NSAID numbers
; OPTIONAL INPUTS:
;   description - string with short description to put at top
; COMMENTS:
;   Makes a very barebones HTML file usable to make a large
;   set of atlas images to check.
; REVISION HISTORY:
;   21-Oct-2011  MRB, NYU
;-
;------------------------------------------------------------------------------
pro atlas_check_html, filename, nsaid, description=description

openw, unit, filename, /get_lun

printf, unit, '<html>'
printf, unit, '<body>'

if(n_elements(description) gt 0) then $
  printf, unit,  '<p>'+description+'</p>'

printf, unit, '<ol>'

url= atlas_check_url(nsaid)
for i=0L, n_elements(url)-1L do $
  printf, unit, '<li> <a href="'+url[i]+'">Batch #'+strtrim(string(i+1),2)+'</a></li>'

printf, unit, '</ol>'
printf, unit, '</body>'
printf, unit, '</html>'

free_lun, unit

end
