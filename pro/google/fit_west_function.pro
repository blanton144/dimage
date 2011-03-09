;+
; NAME:
;   fit_west_function
; PURPOSE:
;   Fit functional form from West et al 2010
; CALLING SEQUENCE:
;   fit_west_function
; REVISION HISTORY:
;   2-Aug-2010 MRB, NYU
;-
pro fit_west_function, model=model


ufake= mrdfits(getenv('DIMAGE_DIR')+'/data/fake/fake_lsb_v5.6.3_u_000.fits',1)
gfake= mrdfits(getenv('DIMAGE_DIR')+'/data/fake/fake_lsb_v5.6.3_g_000.fits',1)
rfake= mrdfits(getenv('DIMAGE_DIR')+'/data/fake/fake_lsb_v5.6.3_r_000.fits',1)
ifake= mrdfits(getenv('DIMAGE_DIR')+'/data/fake/fake_lsb_v5.6.3_i_000.fits',1)
zfake= mrdfits(getenv('DIMAGE_DIR')+'/data/fake/fake_lsb_v5.6.3_z_000.fits',1)
stamps= mrdfits(getenv('DIMAGE_DIR')+'/data/fake/fake_stamps_info_003.fits',1)
stamp_measure= mrdfits(getenv('DIMAGE_DIR')+'/data/fake/fake_stamps_measure_003.fits',1)
pobj= mrdfits(getenv('DIMAGE_DIR')+'/data/fake/fake_photo_003.fits',1)
pobjv56= mrdfits(getenv('DIMAGE_DIR')+'/data/skytest/pobj_fake_lsb_v5.6.3.fits',1)
fmeas= mrdfits('/global/data/scr/mb144/skyfake/fake-004/fake-004-measure.fits',1)

if(keyword_set(model)) then begin
   pobj.petroflux= pobj.cmodelflux
   pobjv56.petroflux= pobjv56.cmodelflux
   
   stamp_measure.petroflux= stamps.flux

endif

ii= where(pobjv56.petroth90[2] gt 6. and pobjv56.petroflux[2] gt 1. and $
          pobj.petroth90[2] gt 6. and pobj.petroflux[2] gt 1. and $
          pobj.petroflux[2] lt stamp_measure.petroflux and $
          pobjv56.petroflux[2] lt stamp_measure.petroflux and $
          rfake.r50 gt 0., nii)

lmag= alog10(22.5-2.5*alog10(pobj[ii].petroflux[2]))
lr90= alog10(pobj[ii].petroth90[2])
lba= alog10(stamps[ii].axisratio)
flact= alog10(stamp_measure[ii].petroflux-pobj[ii].petroflux[2])

aa= dblarr(4, nii)
aa[0,*]=1.
aa[1,*]=lmag
aa[2,*]=lr90
aa[3,*]=lba

hogg_iter_linfit, aa, flact, replicate(1., nii), coeffs, nsigma=5.
yy= coeffs#aa
sig=djsig(flact-yy, sigrej=5)
coeffs_v5_4= coeffs

postfix=''
if(keyword_set(model)) then $
  postfix='.model'
openw, unit, getenv('DIMAGE_DIR')+'/tex/west_params'+postfix+'.tex', /get_lun

if(keyword_set(model)) then $
  str='cModel & ' $
else $
  str='Petrosian & '
str= str+'{\tt v5\_4} '
for i=0L, n_elements(coeffs)-1L do $
  str= str+' & '+ strtrim(string(f='(f40.3)', coeffs[i]),2)
str= str+' & '+ strtrim(string(f='(f40.3)', sig),2)
str= str+' \cr'
printf, unit, str

lmag= alog10(22.5-2.5*alog10(pobjv56[ii].petroflux[2]))
lr90= alog10(pobjv56[ii].petroth90[2])
lba= alog10(stamps[ii].axisratio)
flact= alog10(stamp_measure[ii].petroflux-pobjv56[ii].petroflux[2])

aa= dblarr(4, nii)
aa[0,*]=1.
aa[1,*]=lmag
aa[2,*]=lr90
aa[3,*]=lba

hogg_iter_linfit, aa, flact, replicate(1., nii), coeffs, nsigma=5.
yy= coeffs#aa
sig=djsig(flact-yy, sigrej=5)
coeffs_v5_6= coeffs

str= ' & {\tt v5\_6} '
for i=0L, n_elements(coeffs)-1L do $
  str= str+' & '+ strtrim(string(f='(f40.3)', coeffs[i]),2)
str= str+' & '+ strtrim(string(f='(f40.3)', sig),2)
str= str+' \cr'
printf, unit, str

free_lun, unit

west= mrdfits(getenv('DIMAGE_DIR')+'/data/sstest/west-sample.fits', 1)
west_pobj= mrdfits(getenv('DIMAGE_DIR')+'/data/sstest/west-sample-pobj.fits', 1)

k_print, filename=getenv('DIMAGE_DIR')+'/tex/sky_offsets_vs_west'+postfix+'.ps'

!Y.MARGIN=0
!X.MARGIN=0

mag= 22.5-2.5*alog10(pobjv56.petroflux[2])
flwestorig= 9.87 - 9.28*alog10(mag[ii])+2.56*alog10(pobjv56[ii].petroth90[2])+ $
  1.34*alog10(stamps[ii].axisratio)
flwest= coeffs_v5_6[0] $
  +coeffs_v5_6[1]*alog10(mag[ii]) $
  +coeffs_v5_6[2]*alog10(pobjv56[ii].petroth90[2])+ $
  coeffs_v5_6[3]*alog10(stamps[ii].axisratio)
flact= alog10((stamp_measure[ii].petroflux-pobjv56[ii].petroflux[2]) > 0.00001)

hogg_usersym, 10, /fill
djs_plot, flwest, flact, psym=8, symsize=0.4, xra=[-0.1, 5.1], yra=[-0.1, 5.1], $
          xtit='!6log_{10} !8f_{!6lost}!6 (predicted, nanomaggies)', $
          ytit='!6log_{10} !8f_{!6lost}!6 (actual, nanomaggies)'

mag= 22.5-2.5*alog10(pobj.petroflux[2])
flwestorig= 9.87 - 9.28*alog10(mag[ii])+2.56*alog10(pobj[ii].petroth90[2])+ $
  1.34*alog10(stamps[ii].axisratio)
flwest= coeffs_v5_4[0] $
  +coeffs_v5_4[1]*alog10(mag[ii]) $
  +coeffs_v5_4[2]*alog10(pobj[ii].petroth90[2])+ $
  coeffs_v5_4[3]*alog10(stamps[ii].axisratio)
flact= alog10((stamp_measure[ii].petroflux-pobj[ii].petroflux[2]) > 0.00001)

hogg_usersym, 10
djs_oplot, flwest, flact, psym=8, symsize=0.4, xra=[-0.1, 5.1], yra=[-0.1, 5.1], $
           color='red'

;;ii= where(west_pobj.petroflux[2] gt 4. and west_pobj.petror90[2]*0.396 gt 6. and $
          ;;west_pobj.iso_a[2] gt 1. and west_pobj.iso_b[2] gt 1.)
;;mag= 22.5-2.5*alog10(west_pobj.petroflux[2])
;;ax= west_pobj.iso_b[2]/west_pobj.iso_a[2]
;;flwestorig= 9.87 - 9.28*alog10(mag[ii])+2.56*alog10(west_pobj[ii].petror90[2]*0.396)+ $
  ;;1.34*alog10(ax[ii])
;;flact= alog10((10.^(-0.4*(west[ii].rmag-22.5))-west_pobj[ii].petroflux[2]) > 0.00001)
;;
;;hogg_usersym, 10, /fill
;;djs_oplot, flwest, flact, psym=8, symsize=0.7, xra=[-0.1, 5.1], $
  ;;yra=[-0.1, 5.1], color='blue'

;;dr2= mrdfits(getenv('DIMAGE_DIR')+'/data/sstest/west-dr2.fits',1)
;;spherematch, dr2.ra, dr2.dec, west_pobj.ra, west_pobj.dec, 4./3600., m1, m2
;;ii= where(dr2[m1].r90 gt 6. and $
;;west_pobj[m2].iso_a[2] gt 1. and west_pobj[m2].iso_b[2] gt 1.)
;;mag= dr2[m2].rmag
;;ax= west_pobj[m1].iso_b/west_pobj[m1].iso_a
;;flwestorig= 9.87 - 9.28*alog10(mag[ii])+2.56*alog10(dr2[m1[ii]].r90)+ $
;;1.34*alog10(ax[ii])
;;flact= alog10((10.^(-0.4*(west[m2[ii]].rmag-22.5))- $
;;10.^(-0.4*(dr2[m1[ii]].rmag-22.5))) > 0.00001)

;;hogg_usersym, 10, /fill
;;djs_oplot, flwestorig, flact, psym=8, symsize=0.7, xra=[-0.1, 5.1], yra=[-0.1, 5.1], $
;;color='green'

;;readcol, getenv('DIMAGE_DIR')+'/data/sstest/west-data-direct.txt', $
  ;;f='(f,f,f,f,f,f)', rmagc, rext, pr90, ba, fluxsdss, fluxwest
;;flwestorig= 9.87 - 9.28*alog10(rmagc+rext)+ $
  ;;2.56*alog10(pr90)+ $
  ;;1.34*alog10(ba)
;;flact= alog10(((fluxwest-fluxsdss)*10.^(-0.4*rext))>0.0001)
;;
;;hogg_usersym, 10, /fill
;;djs_oplot, flwestorig, flact, psym=8, symsize=0.7, xra=[-0.1, 5.1], $
  ;;yra=[-0.1, 5.1], color='magenta'

djs_oplot, [-2., 6.], [-2., 6], th=4, color='grey'

hogg_usersym, 10
djs_oplot, [3.0], [1.05], psym=8, symsize=0.6, color='red'
xyouts, 3.2, 1., '!8DR7 version (v5_4)!6', color=djs_icolor('red')
hogg_usersym, 10, /fill
djs_oplot, [3.0], [0.75], psym=8, symsize=0.6
xyouts, 3.2, 0.7, '!8DR8 version (v5_6)!6'

djs_oplot, [2.85, 2.85, 4.8, 4.8, 2.85], $
          [0.6, 1.2, 1.2, 0.6, 0.6], th=2

k_end_print

end
