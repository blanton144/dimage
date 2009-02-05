;+
; NAME:
;   all_patch_png
; PURPOSE:
;   Loop over all tiles and make PNG for each
; CALLING SEQUENCE:
;   all_patch_png
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
pro all_patch_png

patch= mrdfits(getenv('GOOGLE_DIR')+'/sky-patches.fits',1)

for i=0L, n_elements(patch)-1L do begin
    patchdir= image_subdir(patch[i].ra, patch[i].dec, $
                           root=getenv('GOOGLE_DIR'), subname='fits', $
                           prefix=prefix)
    pngdir= image_subdir(patch[i].ra, patch[i].dec, $
                         root=getenv('GOOGLE_DIR'), subname='png')
    patch_png, prefix, patchpath=patchdir, pngpath=pngdir
endfor

end

