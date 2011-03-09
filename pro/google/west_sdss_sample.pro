;+
; NAME:
;   west_sdss_sample
; PURPOSE:
;   Match West sample to SDSS photometry
; CALLING SEQUENCE:
;   west_sdss_sample
; REVISION HISTORY:
;   2-Aug-2010 MRB, NYU
;-
pro west_sdss_sample

readcol, comment='#', getenv('DIMAGE_DIR')+'/data/sstest/west-sample.txt', $
  f='(a,a,d,d,f,f,f,f,f,f,f,f,f,f,f,f,f,f)', $
  name, flag, ra,dec, $
  umag, umag_err, $
  gmag, gmag_err, $
  rmag, rmag_err, $
  imag, imag_err, $
  zmag, zmag_err, $
  r50, r50_err, $
  r90, r90_err

outstr= replicate({name:' ', $
                   flag: ' ', $
                   ra:0.D, $
                   dec:0.D, $
                   umag:0., $
                   umag_err:0., $
                   gmag:0., $
                   gmag_err:0., $
                   rmag:0., $
                   rmag_err:0., $
                   imag:0., $
                   imag_err:0., $
                   zmag:0., $
                   zmag_err:0., $
                   r50:0., $
                   r50_err:0., $
                   r90:0., $
                   r90_err:0.}, n_elements(ra))

outstr.name=name
outstr.flag=flag
outstr.ra=ra
outstr.dec=dec
outstr.umag=umag
outstr.umag_err=umag_err
outstr.gmag=gmag
outstr.gmag_err=gmag_err
outstr.rmag=rmag
outstr.rmag_err=rmag_err
outstr.imag=imag
outstr.imag_err=imag_err
outstr.zmag=zmag
outstr.zmag_err=zmag_err
outstr.r50=r50
outstr.r50_err=r50_err
outstr.r90=r90
outstr.r90_err=r90_err

mwrfits, outstr, getenv('DIMAGE_DIR')+'/data/sstest/west-sample.fits', /create

obj= sdss_findobj(ra, dec, rerun=137)
pobj= sdss_readobjlist(inlist=obj)

mwrfits, pobj, getenv('DIMAGE_DIR')+'/data/sstest/west-sample-pobj.fits', /create

end
