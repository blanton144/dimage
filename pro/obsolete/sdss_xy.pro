pro sdss_xy, run, camcol, field

fname=sdss_name('idR', run, camcol, field)
sdss_readimage, fname, image

simplexy, image, x, y, flux

outstr=replicate({x:0., y:0., flux:0.}, n_elements(x))
outstr.x=x
outstr.y=y
outstr.flux=flux
mwrfits, outstr, 'sdss-xy-'+string(f='(i6.6)', run)+'-r'+ $
  strtrim(string(camcol),2)+'-'+string(f='(i4.4)', field)+'.fits', /create

end
