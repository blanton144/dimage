pro smosaic_dimage, ra, dec, sz, prefix=prefix, _EXTRA=extra_for_smosaic

if(NOT keyword_set(prefix)) then $
  prefix=(hogg_iau_name(ra,dec,''))[0]
smosaic_make, ra, dec, sz, sz, /fpbin, /global, rerun=[137, 161], $
  /dropweights, /ivarout, /sheldon, prefix=prefix, $
  _EXTRA=extra_for_smosaic

djs_rgb_make, prefix[0]+'-i.fits.gz', $
  prefix[0]+'-r.fits.gz', $
  prefix[0]+'-g.fits.gz', $
  name=prefix+'.jpg', $
  scales=[10.,10.,10.], $
  nonlinearity=3., satvalue=100., $
  quality=100.

end
