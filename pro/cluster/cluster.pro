pro cluster, ra, dec

prefix='mBCG-'+hogg_iau_name(ra,dec,'')
smosaic_make, ra, dec, 0.3, 0.3, rerun=[137,161], /fpbin, $
  /global, /maskobj, objlist={run:0, camcol:0, field:0, id:0, rerun:''}, $
  /noran, /ivarout, prefix=prefix, pixscale=4.*0.396/3600.

prefix='obj-'+prefix
smosaic_make, ra, dec, 0.3, 0.3, rerun=[137,161], /fpbin, $
  /global, /noran, /ivarout, prefix=prefix, pixscale=4.*0.396/3600.

end
