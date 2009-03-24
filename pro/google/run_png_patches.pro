;+
; NAME:
;   run_png_patches
; PURPOSE:
;   driver to make PNGs from FITS for Google Sky
; CALLING SEQUENCE:
;   run_png_patches
; COMMENTS:
;   Requires that the sky patch database be properly set up
;     on hercules
;   This routine requests an entry that isn't done or running
;     from the database (the database function automatically 
;     says that that entry is now "running")
;   Then it starts the build of the patch.
;   When the build completes, it tells the database the png is "done".
; REVISION HISTORY:
;   3-Feb-2009 MRB, NYU
;-
;------------------------------------------------------------------------------
pro get_png_patch, idstr, ra, dec, size

common com_run_png_patches, psqlstr

spawn, psqlstr+'"select * from sky s, get_png_to_process() n where s.id = n.sky_id;"', outsql

if(NOT keyword_set(outsql)) then begin
    idstr= '-1'
    return
endif

outsql= outsql[0]
outwords= strsplit(outsql, '|', /extr)
idstr= outwords[0]
ra=double(outwords[1])
dec=double(outwords[2])
size=double(outwords[3])

end
;
pro run_png_patches

common com_run_png_patches

psqlstr='psql -t -q -h hercules -U postgres sky -c '

get_png_patch, idstr, ra, dec, size
while(idstr ne '-1') do begin

    ;; get paths
    patchpath= image_subdir(ra, dec, root=getenv('GOOGLE_DIR'), $
                            subname='fits', prefix=prefix)
    if(file_test(patchpath) eq 0) then $
      message, 'FITS directory not made (should be even if no files)'

    pngpath= image_subdir(ra, dec, root=getenv('GOOGLE_DIR'), $
                          subname='png', prefix=prefix)
    spawn, 'mkdir -p '+pngpath

    ;; make the PNG
    patch_png, prefix, patchpath=patchpath, pngpath=pngpath, /clobber
    
    spawn, psqlstr+'"select completed_png('+idstr+')"'

    ;; now get next patch
    get_png_patch, idstr, ra, dec, size
endwhile

end
;------------------------------------------------------------------------------
