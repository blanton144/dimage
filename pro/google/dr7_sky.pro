;+
; NAME:
;   dr7_sky
; PURPOSE:
;   driver to make FITS images for Google sky process
; CALLING SEQUENCE:
;   dr7_sky
; COMMENTS:
;   Requires that the following file have been produced:
;     $GOOGLE_DIR/sky-patches.fits
;   This routine reads that list of patches in, and asks 
;     for the first entry that isn't "done" AND doesn't have 
;     "processid" set (indicating that it is not running or 
;     crashed in some way).
;   It writes its own processid into the file and writes it 
;     back to disk. 
;   Then it starts the build of the patch.
;   When the build completes, it marks the patch as "done".
;   Then it reads in the latest version of the file and repeats.
; REVISION HISTORY:
;   3-Feb-2009 MRB, NYU
;-
;------------------------------------------------------------------------------
function get_patch

common com_dr7_sky, processid, patchfile 

dopatch=0
keepchecking=1

while(n_tags(dopatch) eq 0 and keepchecking eq 1) do begin
    ;; read in patch file
    patch=0
    while(n_tags(patch) eq 0) do begin
        wait, 0.5
        patch= mrdfits(patchfile,1)
    endwhile
    ipatch= where(patch.done eq 0 and $
                  patch.processid eq -1L, npatch)
    if(npatch gt 0) then begin
        ipatch=ipatch[0]
        patch[ipatch].processid= processid
        mwrfits, patch, patchfile, /create
        dopatch= patch[ipatch]
        
        ;; now check patch list to make sure we're
        ;; still the one (nobody else has interfered)
        wait, 2
        patch=0
        while(n_tags(patch) eq 0) do begin
            wait, 0.5
            patch= mrdfits(patchfile,1)
        endwhile
        if(patch[ipatch].processid ne processid) then begin
            dopatch=0
        endif
    endif else begin
        keepchecking=0
    endelse
endwhile

return, dopatch

end
;
pro dr7_sky

common com_dr7_sky

patchfile= getenv('GOOGLE_DIR')+'/sky-patches.fits'
rerun=[137, 161]

;; randomly pick an id
processid= long(randomu(seed)*1000000.)

keepgoing=1
dopatch= get_patch()
while(n_tags(dopatch) gt 0) do begin

    ;; make the output dir and go there
    subdir= image_subdir(dopatch.ra, dopatch.dec, root=getenv('GOOGLE_DIR'), $
                         subname='fits', prefix=prefix)
    spawn, 'mkdir -p '+subdir
    cd, subdir

    ;; perform the smosaicking
    smosaic_make, dopatch.ra, dopatch.dec, dopatch.size, dopatch.size, $
      /global, rerun=rerun, /dropweights, /dontcrash, prefix=prefix

    ;; report to patch file that we are done
    patch=0
    while(n_tags(patch) eq 0) do begin
        wait, 0.5
        patch= mrdfits(patchfile,1)
    endwhile
    spherematch, patch.ra, patch.dec, dopatch.ra, dopatch.dec, 1./3600., $
      m1, m2
    patch[m1].done=1
    mwrfits, patch, patchfile, /create

    dopatch= get_patch()
endwhile

end
;------------------------------------------------------------------------------
