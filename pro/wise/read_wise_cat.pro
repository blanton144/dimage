;+
; NAME: 
;   read_wise_cat
; PURPOSE: 
;   Read a standard WISE catalog from GATOR
; CALLING SEQUENCE: 
;   cat= read_wise_cat(filename)
; INPUTS:
;   filename - name of file
; OUTPUTS:
;   cat - [N] catalog structure
; COMMENTS:
;   Assumes TBL-style outputs
; REVISION HISTORY:
;   14-Apr-2011 MRB NYU
;-
function create_tag, name, type

if(type eq 'int') then $
  tag= create_struct(name, 0L)
if(type eq 'double') then $
  tag= create_struct(name, 0.D)
if(type eq 'char') then $
  tag= create_struct(name, ' ')

return, tag[0]

end
;
function read_wise_cat, filename

openr, unit, filename, /get_lun

line=' '
readf, unit, line
while(strmid(line,0,1) eq '\') do $
  readf, unit, line

names= strtrim(strsplit(line,'|', /extr),2)
readf, unit, line
types= strtrim(strsplit(line,'|', /extr),2)
readf, unit, line
units= strtrim(strsplit(line,'|', /extr, /preserve_null),2)
readf, unit, line
nulls= strtrim(strsplit(line,'|', /extr),2)

cat0= create_tag(names[0],types[0])
for i=1L, n_elements(names)-1L do $
  cat0= create_struct(cat0, create_tag(names[i],types[i]))

cat= replicate(cat0, numlines(filename))
j=0L
while(NOT eof(unit)) do begin
    if((j mod 500) eq 0) then $
      splog, j
    readf, unit, line
    words= strsplit(line, /extr)
    struct_assign, {junk:0}, cat0
    for i=0L, n_elements(names)-1L do begin
        if(words[i] ne 'null') then begin
            if(types[i] eq 'int') then $
              cat0.(i)= long(words[i]) $
            else if(types[i] eq 'double') then $
              cat0.(i)= double(words[i]) $
            else if(types[i] eq 'char') then $
              cat0.(i)= (words[i]) $
            else $
              message, 'Fail.'
        endif
    endfor
    cat[j]=cat0 
    j=j+1
endwhile

free_lun, unit

cat=cat[0:j-1]

return, cat

END 
