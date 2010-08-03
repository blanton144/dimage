;+
; NAME:
;   plot_fake
; PURPOSE:
;   Plot results of fake tests
; CALLING SEQUENCE:
;   plot_fake
; REVISION HISTORY:
;   2-Aug-2010 MRB, NYU
;-
pro plot_fake

rfake= mrdfits(getenv('DIMAGE_DIR')+'/data/fake/fake_r_003.fits',1)
stamps= mrdfits(getenv('DIMAGE_DIR')+'/data/fake/fake_stamps_003.fits',1)
pobj= mrdfits(getenv('DIMAGE_DIR')+'/data/fake/fake_photo_003.fits',1)

roffset= -2.5*alog10((rfake.flux95_fake-rfake.flux95_real)/rfake.flux95_stamp)
proffset= -2.5*alog10((pobj.cmodelflux[2]>0.001)/(rfake.flux95_stamp/0.95))

k_print, filename=getenv('DIMAGE_DIR')+'/tex/r_offsets.ps'

hogg_usersym, 10, /fill

djs_plot, rfake.r50*0.396, roffset, psym=8, symsize=0.4, $
  xtitle='!8r_{50}!6 (arcsec)!6', $
  ytitle='!6Offset within !8r_{95}!6 (mag)!6', $
  yra=[-0.79,1.49], xra=[-5., 260.] 

hogg_usersym, 10

djs_oplot, rfake.r50*0.396, proffset, psym=8, symsize=0.35, color='red'

r_curve= findgen(1000)+1.
hyde_curve= -0.024+r_curve/71.17+(r_curve/26.5)^2
djs_oplot, r_curve, hyde_curve, th=3, color='red'

djs_oplot, [126., 252., 252., 126., 126.], $
  [-0.72, -0.72, -0.34, -0.34, -0.72]
hogg_usersym, 10, /fill
djs_oplot, [137.], [-0.42], psym=8, symsize=0.4*1.4
djs_xyouts, 150., -0.45, '!8New sky-subtraction!6'
hogg_usersym, 10
djs_oplot, [137.], [-0.52], psym=8, symsize=0.35*1.4, color='red'
djs_xyouts, 150., -0.55, '!8SDSS photo v5.4!6', color='red'
djs_oplot, [130., 145.], [-0.62, -0.62], th=3, color='red'
djs_xyouts, 150., -0.65, '!8Hyde & Bernardi (2009)!6', color='red'

k_end_print

end

