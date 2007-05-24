;+
; NAME:
;   sdss_sky_patches
; PURPOSE:
;   define sky patches of some size covering a given set of runs
; CALLING SEQUENCE:
;   sdss_sky_patches, sz, runs=, ra=, dec=, rerun=
; INPUTS:
;   sz - size of patch
;   runs - [nrun] list of runs to restrict to 
;   rerun - rerun (scalar or array of size [nrun])
; OUTPUTS:
;   ra, dec - center of each patch
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro sdss_sky_patches, sz, runs=runs, ra=ra, dec=dec, npatch=npatch, $
                      rerun=in_rerun

boundary=0.07

rerun=in_rerun
if(n_elements(rerun) ne n_elements(runs)) then $
  rerun=replicate(rerun[0], n_elements(runs))

for i=0L, n_elements(runs)-1L do begin
    runl=sdss_runlist(runs[i], rerun=rerun[i])
    fields=runl.startfield+lindgen(runl.endfield-runl.startfield+1L)
    for camcol=1L, 6L do begin
        sdss_run2radec, runs[i], camcol, fields, rerun=rerun[i], ra=run_ra, $
          dec=run_dec
        if(NOT keyword_set(all_ra)) then begin
            all_ra=run_ra 
            all_dec=run_dec
        endif else begin
            all_ra=[all_ra, run_ra ] 
            all_dec=[all_dec, run_dec] 
        endelse 
    endfor
endfor

min_ra=min(all_ra)
min_dec=min(all_dec)
max_ra=max(all_ra)
max_dec=max(all_dec)

ndec=long(floor((max_dec-min_dec)/(sz-boundary)))
dec_offset=0.5*((max_dec-min_dec)-(ndec-1)*(sz-boundary))
for idec=0L, ndec-1L do begin
    curr_dec=dec_offset+min_dec+float(idec)*(sz-boundary)
    rsz=(sz-boundary)/cos(!DPI/180.*curr_dec)
    nra= long(floor((max_ra-min_ra)/rsz))
    ra_offset=0.5*((max_ra-min_ra)-(nra-1)*rsz)
    for ira=0L, nra-1L do begin
        curr_ra=ra_offset+min_ra+float(ira)*rsz
        if(NOT keyword_set(out_ra)) then begin
            out_ra=curr_ra
            out_dec=curr_dec
        endif else begin
            out_ra=[out_ra, curr_ra]
            out_dec=[out_dec, curr_dec]
        endelse
    endfor
endfor

matchrad=0.15+0.5*sz*sqrt(2.)
spherematch, all_ra, all_dec, out_ra, out_dec, matchrad, m1, m2, d12, $
  max=0
keep=bytarr(n_elements(out_ra))
keep[m2]=1
ikeep=where(keep, npatch)

if(npatch gt 0) then begin
    ra=out_ra[ikeep]
    dec=out_dec[ikeep]
endif

end
;------------------------------------------------------------------------------
