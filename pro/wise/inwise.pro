;+
; NAME: 
;   inwise
; PURPOSE: 
;   Query the WISE tile locator to see whether something is in WISE
; CALLING SEQUENCE: 
;   yup= inwise(ra,dec [, best=, all=all] )
; INPUTS:
;   ra, dec - J2000 deg
; OUTPUTS:
;   yup - 0 if outside WISE, 1 if inside
;   best - Tile Id (string) of best tile
;   all - [N] list of all tiles, with .INDEX, .TILEID, .RACEN, .DECCEN
; REVISION HISTORY:
;   11-Apr-2011 MRB NYU
;-
function inwise, ra, dec, verbose=verbose, best=best, all=all

compile_opt idl2

if N_params() LT 2 then begin
    print,'Syntax - yup= inwise(ra,dec)'
    return,-1
endif	

sign='+'
if(dec lt 0.) then $
  sign='-'
QueryURL=strcompress("http://irsa.ipac.caltech.edu/wise/cgi-bin/WISETiles/nph-wisetile?locstr="+ $
                     strtrim(string(f='(f40.12)', ra),2)+sign+$
                     strtrim(string(f='(f40.12)', dec),2)+'&proxy=%2Fwise',/remove)

if keyword_set(verbose) then message,/INF, QueryURL
result = webget(QueryURL)
text= result.text

best=''
all=0
intable=0L
inrow=0L
id=-1L
found=0L
ntiles=-1L
for i=0L, n_elements(text)-1L do begin
    ;; first search for Best Tile listing
    if(strmatch(text[i], '*Best Tile*')) then begin
        words=stregex(text[i],'.*<td align="right">(.*)</td></tr>$',/sub,/extr)
        best=words[1]
        if(keyword_set(best)) then found=1
    endif

    ;; next retrieve all tiles
    if(inrow gt 0 and strmatch(text[i], '*<td*')) then begin
        if(id eq 0) then $
          tile0= {index:0L, tileid:'', racen:0.D, deccen:0.D}
        words= stregex(text[i], '.*<td.*>(.*)</td>$', /sub, /extr)
        if(id eq 0) then $
          tile0.index= long(words[1])
        if(id eq 1) then $
          tile0.tileid= (words[1])
        if(id eq 2) then $
          tile0.racen= double(words[1])
        if(id eq 3) then $
          tile0.deccen= double(words[1])
        if(id eq 3) then begin
            if(n_tags(all) eq 0) then $
              all= tile0 $
            else $
              all= [all, tile0]
        endif
        id=id+1L
    endif
    if(intable gt 0 and strmatch(text[i], '*</tr>*')) then begin
        inrow=0L
        ntiles=ntiles+1L
    endif
    if(intable gt 0 and strmatch(text[i], '*<tr>*')) then begin
        inrow=1L
        id=0L
    endif
    if(intable eq 0 and found gt 0 and $
       strmatch(text[i], '*Tile ID*') ne 0) then $
      intable=1L
endfor

return, found

END 
