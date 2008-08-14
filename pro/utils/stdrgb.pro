pro stdrgb, name, prefix

djs_rgb_make, prefix+'-i.fits.gz', $
  prefix+'-r.fits.gz', $
  prefix+'-g.fits.gz', $
  scales=[6.,7.,9.], nonlin=3., satv=30., name=name

end
