;; code to run tests for MaNGA
pro manga_error_tests

nsa= read_nsa(version='v1b_0_0')

ispiral= where(nsa.sersic_n gt 0.8 and nsa.sersic_n lt 1.5 and $
               nsa.sersic_ba gt 0.45 and nsa.sersic_ba lt 0.55 and $
               nsa.sersic_th50 gt 3. and nsa.sersic_th50 lt 10. and $
               randomu(seed,n_elements(nsa)) lt 1.1*nsa.sersic_th50/10., nspiral)

;;ispiral=ispiral[shuffle_indx(nspiral, num_sub=10)]
;;nspiral=n_elements(ispiral)

iellip= where(nsa.sersic_n gt 3.0 and nsa.sersic_n lt 5.5 and $
              nsa.sersic_th50 gt 3. and nsa.sersic_th50 lt 10. and $
              randomu(seed,n_elements(nsa)) lt 0.2*nsa.sersic_th50/10., nellip)
;;iellip=iellip[shuffle_indx(nellip, num_sub=10)]
;;nellip=n_elements(iellip)

for i=0L, nspiral-1L do begin
    atcd, nsa[ispiral[i]].nsaid
    sersicfit=0
    dsersic_errors_atlas, sersicfit=sersicfit
    if(n_tags(sersicfit) gt 0) then begin
        if(n_tags(spiral_sersicfit) eq 0) then begin
            spiral_sersicfit0= sersicfit
            struct_assign, {junk:0}, spiral_sersicfit0
            spiral_sersicfit=replicate(spiral_sersicfit0, nspiral)
        endif
        spiral_sersicfit[i]=sersicfit
    endif
endfor

mwrfits, nsa[ispiral], '~/tmp/manga_spiral_errors.fits', /create
mwrfits, spiral_sersicfit, '~/tmp/manga_spiral_errors.fits'

for i=0L, nellip-1L do begin
    atcd, nsa[iellip[i]].nsaid
    sersicfit=0
    dsersic_errors_atlas, sersicfit=sersicfit
    if(n_tags(sersicfit) gt 0) then begin
        if(n_tags(ellip_sersicfit) eq 0) then begin
            ellip_sersicfit0= sersicfit
            struct_assign, {junk:0}, ellip_sersicfit0
            ellip_sersicfit=replicate(ellip_sersicfit0, nellip)
        endif
        ellip_sersicfit[i]=sersicfit
    endif
endfor

mwrfits, nsa[iellip], '~/tmp/manga_ellip_errors.fits', /create
mwrfits, ellip_sersicfit, '~/tmp/manga_ellip_errors.fits'

end
