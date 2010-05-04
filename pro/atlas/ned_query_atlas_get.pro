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
pro ned_query_atlas_get, st=st

if(NOT keyword_set(st)) then st=0L

outdir=getenv('DIMAGE_DIR')+'/data/atlas/ned'

cd, outdir

for id=st, 359L do begin

    filename='blanton_atlas_'+string(id,f='(i3.3)')+'.txt.gz'

    spawn, 'wget --no-clobber '+ $
      '--level 2 http://nedftp.ipac.caltech.edu/batch/'+ $
      filename
endfor
    

end
