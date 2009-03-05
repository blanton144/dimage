;+
; NAME:
;   montage_recal
; PURPOSE:
;   Recalibrate montage images (subtract median and convert to nmgy)
; CALLING SEQUENCE:
;   montage_recal, prefix
; INPUTS:
;   prefix - prefix to files
; COMMENTS:
;   Alters files:
;     [prefix]-[ugriz].fits.gz
; REVISION HISTORY:
;   4-Mar-2009 MRB, NYU
;-
;------------------------------------------------------------------------------
pro montage_recal, prefix

bands=['u', 'g', 'r', 'i', 'z']

for iband=0L, n_elements(bands)-1L do begin
    filename= prefix+'-'+bands[iband]+'.fits'
    img= mrdfits(filename+'.gz', 0, hdr)
    magzp= float(sxpar(hdr, 'MAGZP'))
    img=img*10.^(0.4*(22.5-magzp))
    img= img-median(img)
    mwrfits, img, filename, hdr, /create
    spawn, 'gzip -vf '+filename
endfor

end
;------------------------------------------------------------------------------
