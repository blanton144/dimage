;+
; NAME:
;   gather_ned_galaxies
; PURPOSE:
;   Gather NED galaxies into a single FITS file
; CALLING SEQUENCE:
;   gather_ned_galaxies
; COMMENTS:
;   Reads NED outputs from $DIMAGE_DIR/data/atlas/blanton_atlas_???.txt.gz
;   Writes output file $DIMAGE_DIR/data/atlas/ned_atlas.fits
; REVISION HISTORY:
;   2-May-2008  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro gather_ned_galaxies

outdir= getenv('DIMAGE_DIR')+'/data/atlas/ned'
indir= getenv('DIMAGE_DIR')+'/data/atlas/'
filebase= 'blanton_atlas_'
tmpfile= indir+'/ned.tmp'

for i=0L, 359L do begin
    numstr= string(i, f='(i3.3)')
    filename=indir+'/'+filebase+numstr+'.txt.gz'
    spawn, 'gzip -dvc '+filename+' > '+tmpfile
    tmp_gals= read_ned_galaxies(tmpfile)
    if(i eq 0) then gals=tmp_gals else gals=[gals, tmp_gals]
    spawn, 'rm -f '+tmpfile
endfor

mwrfits, gals, outdir+'/ned_atlas.fits', /create

end
;------------------------------------------------------------------------------
