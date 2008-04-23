pro select_mergers

mrg=mrdfits(getenv('DIMAGE_DIR')+'/data/sstest/merg_flux.fits',1)
iz=where(mrg.zdist gt 0.)
mrg=mrg[iz]

lflux= alog10(mrg.petroflux[2])

lfmin=2.5
lfmax=max(lflux)
nbin=4L
nper=4L
for i=0L, nbin-1L do begin
    binmin=lfmin+(lfmax-lfmin)/float(nbin)*float(i)
    binmax=lfmin+(lfmax-lfmin)/float(nbin)*float(i+1)
    ii=where(lflux gt binmin AND lflux lt binmax, nii)
    if(nii gt nper) then $
      ii=ii[shuffle_indx(nii, num_sub=nper)]
    if(n_elements(ikeep) gt 0) then $
      ikeep=[ikeep, ii] else ikeep=ii
endfor

mrg=mrg[ikeep]

mwrfits, mrg, getenv('DIMAGE_DIR')+'/data/sstest/sstest-mergers.fits', /create

end
