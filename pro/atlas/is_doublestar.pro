;+
; NAME:
;   is_doublestar
; PURPOSE:
;   For a given SDSS object, ask whether it is a double star
; CALLING SEQUENCE:
;   double= is_doublestar(run, camcol, field, id, rerun= [, /plot])
; OUTPUTS:
;   double - structure with :
;        ISDOUBLE - 0 if not double, 1 if it is
;        DOUBLEFLUX - flux in double-star fit
;        SINGLEFLUX - flux in single-star fit
;        PSFFLUX - PSF flux from PHOTO
;        MODELFLUX - model flux from PHOTO
;        CHI2DOUBLE - chi^2 of double star fit
;        CHI2SINGLE - chi^2 of single star fit
; REVISION HISTORY:
;   11-Aug-2010  MRB, NYU
;-
;------------------------------------------------------------------------------
function is_doublestar, run, camcol, field, id, rerun=rerun, plot=plot

if(n_elements(run) gt 1) then begin
    for i=0L, n_elements(run)-1L do begin
        tmp_double= is_doublestar(run[i], camcol[i], field[i], $
                                  id[i], rerun=rerun[i])
        if(n_tags(double) eq 0) then $
          double=replicate(tmp_double, n_elements(run))
        double[i]=tmp_double[0]
    endfor
    return, double
endif

filter=2L
double={isdouble:byte(0), $
        doubleflux:0., $
        singleflux:0., $
        psfflux:0., $
        modelflux:0., $
        chi2double:0., $
        chi2single:0.}

pobjfile= sdss_name('photoObj', run, camcol, field, rerun=rerun)

pobj= mrdfits(pobjfile, 1, row=id-1L)

if(pobj.petroth90[2] eq -9999.) then $
  imsize=51L $
else $
  imsize=(long(8.*pobj.petroth90[2]/0.396)/2L+3L) > 51L

;; get image
image=fpbin_to_frame(obj=pobj[0],filter=filter,cutout=imsize, $
                     /register, /calibrate,/center, $
                     seed=seed, invvar=invvar, hdr=hdr, /pad)
adxy, hdr, pobj.ra, pobj.dec, x, y

;; get psf
psfieldfile=sdss_name('psField',run, camcol, field, rerun=rerun)
kl=mrdfits(psfieldfile,filter+1)
klpsf=sdss_psf_recon(kl, pobj.objc_colc, pobj.objc_rowc, $
                     klpsf, normalize=1.)
psf=klpsf[10:40,10:40]

;; fit the double psf model
multi_psf_fit, image, invvar, psf, npsf=2, x=x, y=y, flux=flux, $
  model=model, chi2=chi2, /silent
if(n_elements(flux) gt 0) then begin
    double.doubleflux=total(flux)
    double.chi2double=chi2
    multi_psf_fit, image, invvar, psf, npsf=1, x=x, y=y, flux=flux, $
      model=model, chi2=chi2, /silent
    double.singleflux=total(flux)
    double.chi2single=chi2
    double.psfflux=pobj.psfflux[2]
    double.modelflux=pobj.modelflux[2]
    
    if(double.modelflux/double.psfflux lt 2. and $
       double.chi2double/double.chi2single lt 0.2) then $
      double.isdouble=1
endif

if(keyword_set(plot)) then $
  atv, image

return, double

end
