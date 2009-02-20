;+
; NAME:
;   all_patch_png
; PURPOSE:
;   Loop over all tiles and make PNG for each
; CALLING SEQUENCE:
;   all_patch_png [, start=, /clobber ]
; OPTIONAL INPUTS:
;   start - index number to start on (default 0)
; OPTIONAL KEYWORDS:
;   /clobber - clobber already-created PNGs
; COMMENTS:
;    Reads FITS files from:
;      $GOOGLE_DIR/fits/[..]/JNAME/JNAME-[ugriz].fits.gz
;    Write PNG files to:
;      $GOOGLE_DIR/png/[..]/JNAME/JNAME_mask.tif.gz - 0/1 mask
;                                 JNAME_wcs.fits - WCS header (empty FITS)
;                                 JNAME.png - PNG file
; REVISION HISTORY:
;   25-Oct-2007 MRB, NYU
;-
pro all_patch_png, start=start, clobber=clobber

patch= mrdfits(getenv('GOOGLE_DIR')+'/sky-patches.fits',1)

if(NOT keyword_set(start)) then start=0L
for i=start, n_elements(patch)-1L do begin
    patchdir= image_subdir(patch[i].ra, patch[i].dec, $
                           root=getenv('GOOGLE_DIR'), subname='fits', $
                           prefix=prefix)
    pngdir= image_subdir(patch[i].ra, patch[i].dec, $
                         root=getenv('GOOGLE_DIR'), subname='png')
    spawn, 'mkdir -p '+pngdir
    patch_png, prefix, patchpath=patchdir, pngpath=pngdir, clobber=clobber
endfor

end

