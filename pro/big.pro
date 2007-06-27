ra= 161.95667d
dec=12.581639d
sz=0.3
rerun=[137, 161]

smosaic_make, ra, dec, sz, sz, /global, seed=seed, $
  /fpbin, rerun=rerun, prefix='big', /ivarout, $
  noclobber=noclobber, /dropweights, /sheldon

