;+
; NAME:
;   skydb_set
; PURPOSE:
;   Set the sky database based on the sky-patches.fits file
; CALLING SEQUENCE:
;   skydb_set
; COMMENTS:
;   We are doing this so that we can transfer results from
;     sky-patches.fits to the "sky" database on hercules
; REVISION HISTORY:
;   25-Feb-2009 MRB, NYU
;-
;------------------------------------------------------------------------------
pro skydb_set

;; read in sky-patches settings
patchfile= getenv('GOOGLE_DIR')+'/sky-patches.fits'
patch=mrdfits(patchfile,1)

;; open sql file
sqlfile=getenv('GOOGLE_DIR')+'/tmp-sky-load.sql'
openw, unit, sqlfile, /get_lun

;; delete all current data
printf,unit, 'delete from sky;'

;; put in current date if no other
spawn, 'date "+%Y-%m-%d %H:%M:%S"', nowdate
treq="'"+nowdate[0]+"'"
tcomp=treq

for i=0L, n_elements(patch)-1L do begin
    rastr= strtrim(string(f='(f40.20)', patch[i].ra),2)
    decstr= strtrim(string(f='(f40.20)', patch[i].dec),2)
    szstr= strtrim(string(f='(f40.20)', patch[i].size),2)
    processed= '-1'
    if(patch[i].done gt 0) then begin
        done= 'true' 
        pgcmd='insert into sky '+ $
          '(ra, dec, size, processed, done, '+ $
          'timestamp_completed, timestamp_requested) '+ $
          'values ('+rastr+','+decstr+','+szstr+','+processed+','+ $
          done+','+tcomp+','+treq+');'
    endif else begin
        done= 'false' 
        pgcmd='insert into sky '+ $
          '(ra, dec, size, processed, done) '+ $
          'values ('+rastr+','+decstr+','+szstr+','+processed+','+ $
          done+');'
    endelse
    printf,unit, pgcmd
endfor

free_lun, unit

spawn,'psql -q -h hercules -U postgres sky -f '+sqlfile


end 
;------------------------------------------------------------------------------
