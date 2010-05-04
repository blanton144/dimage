pro ned_to_fits, filebase=filebase, indx=indx

if(NOT keyword_set(filebase)) then filebase='test'

cat=mrdfits(vagc_name('object_catalog'), 1, rows=indx)

ned1={object_position:0L, $
;+
; NAME:
;   ned_query_atlas_get
; PURPOSE:
;   Get all the low redshift objects in NED
; CALLING SEQUENCE:
;   ned_query_atlas_get
; COMMENTS:
;   Gets batch results
; REVISION HISTORY:
;   31-Mar-2004  MRB, NYU
;-
;------------------------------------------------------------------------------
;+
; NAME:
;   ned_query_atlas_get
; PURPOSE:
;   Get all the low redshift objects in NED
; CALLING SEQUENCE:
;   ned_query_atlas_get
; COMMENTS:
;   Gets batch results
; REVISION HISTORY:
;   31-Mar-2004  MRB, NYU
;-
;------------------------------------------------------------------------------
      ra:0.D, $
      dec:0.D, $
      nmatch:0L, $
      nedname:' ', $
      nedra:' ', $
      neddec:' ', $
      nedcz:0., $
      nedcz_err:0., $
      nedcz_ref:' ' }
ned=replicate(ned1, n_elements(cat))
      

chunksize=2500L
nchunks=(n_elements(cat)/chunksize)+1L
help,nchunks
for j=0L, nchunks-1L do begin
    chunkstart=j*chunksize
    chunkend=((j+1L)*chunksize-1L) < (n_elements(cat)-1L)
    filename=filebase+'_'+strtrim(string(j),2)+'.txt'
    openr,unit,filename, /get_lun
    started=0
    ;; search for beginning of results
    line=' '
    while(NOT started) do begin
        readf,unit,line
        if(strmatch(line,'*SEARCH RESULTS*')) then started=1
    endwhile
    ;; now go through each object
    ipos=chunkstart
    while(ipos le chunkend) do begin
        ;;    -- find first line
        readf, unit, line
        while(NOT strmatch(line, 'NEARPOSN*')) do readf,unit,line
        ;; read how many objects there were
        readf, unit, line
        words=strsplit(line,/extr)
        ned[ipos].object_position=indx[ipos]
        ned[ipos].ra=cat[ipos].ra
        ned[ipos].dec=cat[ipos].dec
        if(words[0] ne 'No') then begin
            ;; if there are objects, take first one
            ned[ipos].nmatch=long(words[0])
            readf, unit, line
            readf, unit, line
            ned[ipos].nedname=strtrim(strmid(line,1,25),2)
            pos=strmid(line, 33, 26)
            ned[ipos].nedra=strtrim((strsplit(pos,/extr))[0],2)
            ned[ipos].neddec=strtrim((strsplit(pos,/extr))[1],2)
            readf, unit, line
            while(NOT strmatch(line, '#           Extinct*')) do $
              readf,unit,line
            readf,unit,line
            column5=strmid(line, 70, 100)
            words=strsplit(column5,/extr)
            if(n_elements(words) ge 5) then begin
                ned[ipos].nedcz=float(words[0])
                ned[ipos].nedcz_err=float(words[2])
                ned[ipos].nedcz_ref=strtrim(words[4],2)
            endif
        endif
        ipos=ipos+1L
    endwhile
    free_lun,unit
endfor

mwrfits, ned, 'ned_'+filebase+'.fits', /create

end
