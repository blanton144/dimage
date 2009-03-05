;+
; NAME:
;   montage_image
; PURPOSE:
;   Retrieve Montage test images for particular patch(es)
; CALLING SEQUENCE:
;   montage_image, indx
; INPUTS:
;   indx - [N] indices in sky-patches.fits 
; COMMENTS:
;   Requires the sky patch file $GOOGLE_DIR/sky-patches.fits
;   Puts outputs in: 
;     $GOOGLE_DIR/montage/[subdir]/[prefix]-[ugriz].fits.gz
;   where "subdur" and "prefix" are built from RA and Dec
;   in the usual way.
; REVISION HISTORY:
;   4-Mar-2009 MRB, NYU
;-
;------------------------------------------------------------------------------
pro montage_image, indx

patchfile= getenv('GOOGLE_DIR')+'/sky-patches.fits'
patches= mrdfits(patchfile,1)

bands=['u', 'g', 'r', 'i', 'z']

for i=0L, n_elements(indx)-1L do begin
    dopatch= patch[indx[i]]

    ;; make the output dir and go there
    subdir= image_subdir(dopatch[i].ra, dopatch[i].dec, $
                         root=getenv('GOOGLE_DIR'), $
                         subname='montage', prefix=prefix)
    spawn, 'mkdir -p '+subdir
    cd, subdir

    rastr= strtrim(string(f='(f40.20)', dopatch[i].ra),2)
    decstr= strtrim(string(f='(f40.20)', dopatch[i].dec),2)
    sizestr= strtrim(string(f='(f40.5)', dopatch[i].size),2)
    
    for iband=0L, n_elements(bands)-1L do begin
        filename= prefix+'-'+bands[iband]+'.fits'
        spawn, 'getMontage '+filename+' '+bands[iband]+' '+ $
               rastr+' '+decstr+' '+sizestr
        spawn, 'gzip -v '+filename
     endfor
endfor

end
;------------------------------------------------------------------------------
