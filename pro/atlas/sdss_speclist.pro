;+
; NAME:
;   sdss_speclist
; PURPOSE:
;   Create a small specList-dr8.fits file
; CALLING SEQUENCE:
;   sdss_speclist
; COMMENTS:
;   Reprocesses the files:
;      $SPECTRO_REDUX/photoPlate-dr8.fits
;      $SPECTRO_REDUX/specObj-dr8.fits
;   into a managable file:
;      $DIMAGE_DIR/data/atlas/sdss/specList-dr8.fits
; REVISION HISTORY:
;   31-Mar-2004  MRB, NYU
;-
;------------------------------------------------------------------------------
pro sdss_speclist

ph_columns= ['run', 'camcol', 'field', 'id', 'rerun', $
             'objc_type', 'objc_prob_psf', 'objc_flags', 'objc_flags2', $
             'objc_rowc', 'objc_colc', 'objc_rowcerr', 'objc_colcerr', $
             'petrotheta', 'petrothetaerr', 'petroth50', 'petroth50err', $
             'petroth90', 'petroth90err', 'fracdev', $
             'psp_status', 'ra', 'dec', 'psf_fwhm', $
             'extinction', $
             'psfflux', 'psfflux_ivar', $
             'fiberflux', 'fiberflux_ivar', $
             'modelflux', 'modelflux_ivar', $
             'cmodelflux', 'cmodelflux_ivar', $
             'petroflux', 'petroflux_ivar', $
             'cloudcam', 'calib_status', $
             'resolve_status', 'thing_id', $
             'ifield', 'balkan_id', $
             'score']

sp_columns= ['survey', 'chunk', 'programname', 'platerun', 'platequality', $
             'platesn2', 'specprimary', 'speclegacy', $
             'run2d', 'run1d', 'plate', 'fiberid', $
             'mjd', 'tile', 'plug_ra', 'plug_dec', 'class', 'subclass', $
             'z', 'z_err', 'vdisp', 'vdisp_err', 'zwarning', 'sn_median']

ph= hogg_mrdfits(getenv('SPECTRO_REDUX')+'/photoPlate-dr8.fits',1, $
                 nrow=28800, columns= ph_columns)
sp= hogg_mrdfits(getenv('SPECTRO_REDUX')+'/specObj-dr8.fits',1, $
                 nrow=28800, columns= sp_columns)

new0= create_struct(ph[0], sp[0])

new= replicate(new0, n_elements(ph))
struct_assign, ph, new
struct_assign, sp, new,/nozero

mwrfits, new, getenv('DIMAGE_DIR')+'/data/atlas/sdss/specList-dr8.fits', $
  /create


end
