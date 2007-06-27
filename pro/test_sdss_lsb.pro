pro test_sdss_lsb

sz=0.5 
runs=[4335, 4388]
rerun=9137

sdss_sky_patches, sz, runs=runs, rerun=rerun, ra=ra, dec=dec 

;; 12 too small a patch
for i=13L, n_elements(ra)-1L do begin
    sdss_lsb, ra[i], dec[i], sz, rerun=rerun, runs=runs, /all, /nocl
endfor

end
