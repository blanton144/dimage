;+
; NAME:
;   compare_petro_colors
; PURPOSE:
;   Compare Petrosian colors to Sersic
; CALLING SEQUENCE:
;   compare_petro_colors
; REVISION HISTORY:
;   10-Jun-2014  Written by Mike Blanton, NYU
;-
;------------------------------------------------------------------------------
pro plot_aperture_corrections

common com_plot_aperture_corrections, nsa, petro

outdir=getenv('DIMAGE_DIR')+'/tex'

if(n_tags(nsa) eq 0) then begin
    petro= mrdfits(getenv('ATLAS_DATA')+'/test/petro/petro_v1_0_0_a1.fits',1)
endif

igd= where(petro.petroflux[1] gt 1.d-20 AND $
           petro.petroflux[5] gt 1.d-20 AND $
           petro.petroth50[2] gt 1.d-20 AND $
           petro.petroth50[4] gt 1.d-20 AND $
           petro.petroflux[4] gt 250., ngd)

mpr= 22.5-2.5*alog10(petro[igd].petroflux[4])
lth50= alog10(petro[igd].petroth50_r)
ltheta= alog10(petro[igd].petrotheta_r)
lth50_ratio= alog(petro[igd].petroth50[2]/petro[igd].petroth50[4])
apn= -2.5*alog10(petro[igd].apcorr[1])

filebase=outdir+'/petro-aperture-a1'
k_print, filename=filebase+'.ps', xsize=8., ysize=11.
!P.MULTI=[4,1,4]
!Y.MARGIN=[10,0]
!X.OMARGIN=[15, 0]
!Y.OMARGIN=[0, 0]
yra=[-0.9, 0.2]
charsize=2.51
hogg_scatterplot, mpr, apn, /cond, $
  quantiles=quantiles, exp=0.25, xra=[12.5, 16.7], yra=yra, $
  xtitle=textoidl('m_r (Petro)'), $
  ytitle=textoidl('\Delta m)'), $
  xcharsize=charsize, ycharsize=charsize, xnpix=50, ynpix=50
djs_oplot, !X.CRANGE, [0., 0.], th=4, color='red', linestyle=1
hogg_scatterplot, lth50, apn, /cond, $
  quantiles=quantiles, exp=0.25, xra=[-0.1, 1.99], yra=yra, $
  xtitle=textoidl('log_{10} r_{50} (Petro)'), $
  ytitle=textoidl('\Delta m)'), $
  xcharsize=charsize, ycharsize=charsize, xnpix=50, ynpix=50
djs_oplot, !X.CRANGE, [0., 0.], th=4, color='red', linestyle=1
hogg_scatterplot, ltheta, apn, /cond, $
  quantiles=quantiles, exp=0.25, xra=[-0.1, 1.99], yra=yra, $
  xtitle=textoidl('log_{10} r_{P}'), $
  ytitle=textoidl('\Delta m)'), $
  xcharsize=charsize, ycharsize=charsize, xnpix=50, ynpix=50
djs_oplot, !X.CRANGE, [0., 0.], th=4, color='red', linestyle=1
hogg_scatterplot, lth50_ratio, apn, /cond, $
  quantiles=quantiles, exp=0.25, xra=[-1.1, 1.1], yra=yra, $
  xtitle=textoidl('ln r_{50,u} / r_{50,r}'), $
  ytitle=textoidl('\Delta m)'), $
  xcharsize=charsize, ycharsize=charsize, xnpix=50, ynpix=50
djs_oplot, !X.CRANGE, [0., 0.], th=4, color='red', linestyle=1
k_end_print
spawn, /nosh, ['convert', filebase+'.ps', filebase+'.png']

end
