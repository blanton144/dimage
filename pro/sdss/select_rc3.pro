pro select_rc3

rc3=mrdfits(getenv('RC3_DIR')+'/rc3_catalog.fits',1)

im= sdss_findimage(rc3.ra, rc3.dec, /best)

ii=where(im.run ne 0)
rc3=rc3[ii]

mbmin=9.
mbmax=15.
nbin=4L
nper=4L
for i=0L, nbin-1L do begin
    binmin=mbmin+(mbmax-mbmin)/float(nbin)*float(i)
    binmax=mbmin+(mbmax-mbmin)/float(nbin)*float(i+1)
    ii=where(rc3.mb gt binmin AND rc3.mb lt binmax, nii)
    if(nii gt nper) then $
      ii=ii[shuffle_indx(nii, num_sub=nper)]
    if(n_elements(ikeep) gt 0) then $
      ikeep=[ikeep, ii] else ikeep=ii
endfor

rc3=rc3[ikeep]

mwrfits, rc3, getenv('DIMAGE_DIR')+'/data/sstest/sstest-rc3.fits', /create

end
