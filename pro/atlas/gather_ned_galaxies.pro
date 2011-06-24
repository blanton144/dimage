;+
; NAME:
;   gather_ned_galaxies
; PURPOSE:
;   Gather NED galaxies into a single FITS file
; CALLING SEQUENCE:
;   gather_ned_galaxies
; COMMENTS:
;   Reads NED outputs from atlas_rootdir/catalogs/blanton_atlas_???.txt.gz
;   Writes output file atlas_rootdir/catalogs/ned_atlas.fits
; REVISION HISTORY:
;   2-May-2008  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro gather_ned_galaxies, version=version

rootdir=atlas_rootdir(sample=sample, version=version)

outdir= rootdir+'/catalogs/ned'
indir= rootdir+'/catalogs/'
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
