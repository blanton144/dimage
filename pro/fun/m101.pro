pro m101

ra=210.802458D
dec=54.349094D

zerolist={run:0, rerun:'', camcol:0, field:0, id:0}

smosaic_make, ra, dec, 0.5, 0.5, rerun=137, /global, $
  /dropweights, prefix='m101'


photo=fpbin_to_frame(3712, 3, 187, rerun=137, /calibrate, $
                     filter='r', /allid)
mwrfits, photo, 'm101-photo.fits', /create

ours=fpbin_to_frame(3712, 3, 187, rerun=137, /calibrate, $
                    filter='r', /allid, /addsky)
sdss_skyfield, 3712, 3, 187, $
  rerun=137, sky=sky, filter=2
calib = sdss_calib(3712, 3, 187, rerun=137)
sky=sky*(calib.nmgypercount[2])[0]
ours=ours-sky
mwrfits, ours, 'm101-ours.fits', /create

;smosaic_make, ra, dec, 0.5, 0.5, rerun=137, /global, $
  ;/dropweights, prefix='m101sky', /fpbin, objlist=zerolist
  

end
