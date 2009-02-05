;+
; NAME:
;   reset_sky_patches
; PURPOSE:
;   reset patch list, setting processid to zero for each patch not done
; CALLING SEQUENCE:
;   reset_sky_patches
; COMMENTS:
;   Changes the file:
;    $GOOGLE_DIR/sky-patches.fits
;   For each entry, if it is not "DONE" then "PROCESSID" is set to -1
; REVISION HISTORY:
;   25-Oct-2007 MRB, NYU
;-
;------------------------------------------------------------------------------
pro reset_sky_patches

patchfile= getenv('GOOGLE_DIR')+'/sky-patches.fits'

patch=mrdfits(patchfile,1)

inotdone= where(patch.done eq 0, nnotdone)

if(nnotdone gt 0) then $
  patch[inotdone].processid=-1

mwrfits, patch, patchfile, /create

end
;------------------------------------------------------------------------------
