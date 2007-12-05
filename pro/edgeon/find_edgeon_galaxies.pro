pro find_edgeon_galaxies

if(NOT keyword_set(outbase)) then $
  outbase='edgeon'

im= hogg_mrdfits(vagc_name('object_sdss_imaging'),1,nrow=28800)
sp= hogg_mrdfits(vagc_name('object_sdss_spectro'),1,nrow=28800, $
                 columns=['z', 'zwarning'])

igal=where((im.vagc_select AND 4) gt 0 AND $
           sp.z gt 0.02 AND sp.z lt 0.1, ngal)

im=im[igal]
sp=sp[igal]

cal= retrieve_calibobj(im)

iflat=where(cal.ab_exp[2] lt 0.25, nflat)
cal=cal[iflat]
im=im[iflat]
sp=sp[iflat]

mwrfits, cal, $
  getenv('DATA')+'/'+outbase+'/'+outbase+'-cal.fits', /create
mwrfits, im, $
  getenv('DATA')+'/'+outbase+'/'+outbase+'-im.fits', /create
mwrfits, sp, $
  getenv('DATA')+'/'+outbase+'/'+outbase+'-sp.fits', /create

end
