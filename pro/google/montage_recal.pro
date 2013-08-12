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
pro montage_recal, prefix, bands=bands, vega2ab=vega2ab, magzp=magzp

if(keyword_set(bands) eq 0) then $
   bands=['u', 'g', 'r', 'i', 'z']
if(keyword_set(vega2ab) eq 0) then $
   vega2ab= fltarr(n_elements(bands))

for iband=0L, n_elements(bands)-1L do begin
   filename= prefix+'-'+bands[iband]+'.fits'
   img= mrdfits(filename+'.gz', 0, hdr)
   if(keyword_set(img) gt 0) then begin
      if(NOT keyword_set(magzp)) then $
         curr_magzp= float(sxpar(hdr, 'MAGZP')) $
      else $
         curr_magzp= magzp[iband]
      curr_magzp= curr_magzp+vega2ab[iband]
      img=img*10.^(0.4*(22.5-curr_magzp))
      img= float(img-median(img))
      mwrfits, img, filename, hdr, /create
      spawn, 'gzip -vf '+filename
   endif
endfor

end
;------------------------------------------------------------------------------
