;+
; NAME:
;   run_sky_patches
; PURPOSE:
;   driver to make FITS images for Google sky process
; CALLING SEQUENCE:
;   run_sky_patches
; COMMENTS:
;   Requires that the sky patch database be properly set up
;     on hercules
;   This routine requests an entry that isn't done or running
;     from the database (the database function automatically 
;     says that that entry is now "running")
;   Then it starts the build of the patch.
;   When the build completes, it tells the database the patch is "done".
; REVISION HISTORY:
;   3-Feb-2009 MRB, NYU
;-
;------------------------------------------------------------------------------
pro get_patch, idstr, ra, dec, size

common com_run_sky_patches, psqlstr

spawn, psqlstr+'"select get_sky_to_process();"', outsql
outsql=strmid(strtrim(outsql[0],2),1,strlen(outsql[0])-2)
outwords= strsplit(outsql, ',', /extr)
idstr= outwords[0]
ra=double(outwords[1])
dec=double(outwords[2])
size=double(outwords[3])

end
;
pro run_sky_patches

common com_run_sky_patches

psqlstr='psql -t -q -h hercules -U postgres sky -c '

patchfile= getenv('GOOGLE_DIR')+'/sky-patches.fits'
rerun=[137, 161]

;; randomly pick an id
processid= long(randomu(seed)*1000000.)

keepgoing=1
get_patch, idstr, ra, dec, size
while(idstr ne '-1') do begin

    ;; make the output dir and go there
    subdir= image_subdir(ra, dec, root=getenv('GOOGLE_DIR'), $
                         subname='fits', prefix=prefix)
    spawn, 'mkdir -p '+subdir
    cd, subdir

    ;; perform the smosaicking
    smosaic_make, ra, dec, size, size, $
      /global, rerun=rerun, /dropweights, /dontcrash, prefix=prefix, $
      minscore=0.5, /ignoreframesstatus, /processed
    
    spawn, psqlstr+'"select completed_sky('+idstr+')"'

    get_patch, idstr, ra, dec, size
endwhile

end
;------------------------------------------------------------------------------
