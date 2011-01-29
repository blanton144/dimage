;+
; NAME:
;   in_sdss_footprint
; PURPOSE:
;   Test whether RA/Dec values are in the SDSS window
; CALLING SEQUENCE:
;   window= in_sdss_footprint(ra, dec)
; REVISION HISTORY:
;   15-Aug-2010  MRB, NYU
;-
;------------------------------------------------------------------------------
function in_sdss_footprint, ra, dec

common com_in_sdss_footprint, flist, unif, ura, udec

if(n_tags(unif) eq 0) then begin
   window_read, flist=flist
   read_fits_polygons, getenv('PHOTO_RESOLVE')+'/window_unified.fits', unif
   xx= vmid(unif)
   x_to_angles, xx, phi, th
   ura= phi
   udec= (90.D)-th
endif

spherematch, ra, dec, ura, udec, 0.16, m1, m2, max=0

window0= create_struct(flist[0], 'iunified', -1L)
struct_assign, {junk:0}, window0
window0.iunified=-1L
window= replicate(window0, n_elements(ra))

isort= sort(m2)
iuniq= uniq(m2[isort])
ist=0L
for i=0L, n_elements(iuniq)-1L do begin
   ind= iuniq[i]
   icurr= isort[ist:ind]
   racurr= ra[m1[icurr]]
   deccurr= dec[m1[icurr]]
   ucurr= unif[m2[icurr[0]]]
   is_in= is_in_polygon(ra=racurr, dec=deccurr, ucurr)
   iin= where(is_in, nin)
   if(nin gt 0) then begin
      struct_assign, flist[ucurr.ifield], window0
      window0.iunified= m2[icurr[0]]
      window[m1[icurr[iin]]]= replicate(window0, nin)
   endif
   ist= ind+1L
endfor

return, window

end
