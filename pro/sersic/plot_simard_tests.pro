;+
; NAME:
;   plot_simard_tests
; PURPOSE:
;   Make plots associated with Simard catalog tests
; CALLING SEQUENCE:
;   plot_simard_tests, filebase
; INPUTS:
;   filebase  - filebase name
; REVISION HISTORY:
;   20-May-2014  Written by Mike Blanton, NYU
;-
;------------------------------------------------------------------------------
pro plot_simard_tests, tversion=tversion

if(NOT keyword_set(tversion)) then $
  tversion='vA'
outdir= getenv('DIMAGE_DIR')+'/tex'

all= mrdfits(tversion+'-test.fits',1)

iall= where(all.rhlr/all.scale/0.396 gt 2.)
all=all[iall]

mp= 22.5-2.5*alog10(all.petroflux_p)
mpc= 22.5-2.5*alog10(all.petroflux)
;;ms= 22.5-2.5*alog10(all.sersicflux)

;; Make Petro flux comparisons
filebase=outdir+'/test-simard-petro-flux'+'-'+tversion
k_print, filename=filebase+'.ps'
!P.MULTI=[3,1,3]
!Y.MARGIN=5
!X.OMARGIN=[20, 0]
!Y.OMARGIN=[4, 0]
yra=[-0.3, 0.3]
charsize=2.5
diff= mp-all.rg2d
hogg_scatterplot, all.rg2d, diff, /cond, $
  quantiles=quantiles, exp=0.25, xra=[13.8, 16.7], yra=yra, $
  xtitle=textoidl('m_r (True)'), ytitle=textoidl('m_r :: Petro - True'), $
  xcharsize=charsize, ycharsize=charsize, xnpix=30, ynpix=20
djs_oplot, !X.CRANGE, [0., 0.], th=4, color='red', linestyle=1
hogg_scatterplot, alog10(all.rhlr/all.scale), diff, /cond, $
  quantiles=quantiles, exp=0.25, xra=[-0.1, 1.5], yra=yra, $
  xtitle=textoidl('log_{10}(r_{50}) (True)'), $
  ytitle=textoidl('m_r :: Petro - True'), $
  xcharsize=charsize, ycharsize=charsize, xnpix=30, ynpix=20
djs_oplot, !X.CRANGE, [0., 0.], th=4, color='red', linestyle=1
hogg_scatterplot, all.__b_t_r, diff, /cond, $
  quantiles=quantiles, exp=0.25, xra=[-0.05, 1.05], yra=yra, $
  xtitle='B/T (True)', ytitle=textoidl('m_r :: Petro - True'), $
  xcharsize=charsize, ycharsize=charsize, xnpix=30, ynpix=20
djs_oplot, !X.CRANGE, [0., 0.], th=4, color='red', linestyle=1
k_end_print
spawn, /nosh, ['convert', filebase+'.ps', filebase+'.png']

;; Make Petro size comparisons
filebase=outdir+'/test-simard-petro-r50'+'-'+tversion
k_print, filename=filebase+'.ps'
!P.MULTI=[3,1,3]
!Y.MARGIN=5
!X.OMARGIN=[20, 0]
!Y.OMARGIN=[4, 0]
yra=[-0.6, 0.6]
charsize=2.2
diff= alog(all.petror50_p*0.396/(all.rhlr/all.scale))
ytitle=textoidl('ln(r_{50}) :: Petro - True') 
hogg_scatterplot, all.rg2d, diff, /cond, $
  quantiles=quantiles, exp=0.25, xra=[13.8, 16.7], yra=yra, $
  xtitle=textoidl('m_r (True)'), ytitle=ytitle, $
  xcharsize=charsize, ycharsize=charsize, xnpix=30, ynpix=20
djs_oplot, !X.CRANGE, [0., 0.], th=4, color='red', linestyle=1
hogg_scatterplot, alog10(all.rhlr/all.scale), diff, /cond, $
  quantiles=quantiles, exp=0.25, xra=[-0.1, 1.5], yra=yra, $
  xtitle=textoidl('log_{10}(r_{50}) (True)'), ytitle=ytitle, $
  xcharsize=charsize, ycharsize=charsize, xnpix=30, ynpix=20
djs_oplot, !X.CRANGE, [0., 0.], th=4, color='red', linestyle=1
hogg_scatterplot, all.__b_t_r, diff, /cond, $
  quantiles=quantiles, exp=0.25, xra=[-0.05, 1.05], yra=yra, $
  xtitle='B/T (True)', ytitle=ytitle, $
  xcharsize=charsize, ycharsize=charsize, xnpix=30, ynpix=20
djs_oplot, !X.CRANGE, [0., 0.], th=4, color='red', linestyle=1
k_end_print
spawn, /nosh, ['convert', filebase+'.ps', filebase+'.png']

;; Make Petro size comparisons
filebase=outdir+'/test-simard-petro-r50-big'+'-'+tversion
k_print, filename=filebase+'.ps'
!P.MULTI=[3,1,3]
!Y.MARGIN=5
!X.OMARGIN=[20, 0]
!Y.OMARGIN=[4, 0]
yra=[-0.6, 0.6]
charsize=2.2
diff= alog(all.petror50_b*0.396/(all.rhlr/all.scale))
ytitle=textoidl('ln(r_{50}) :: Petro - True') 
hogg_scatterplot, all.rg2d, diff, /cond, $
  quantiles=quantiles, exp=0.25, xra=[13.8, 16.7], yra=yra, $
  xtitle=textoidl('m_r (True)'), ytitle=ytitle, $
  xcharsize=charsize, ycharsize=charsize, xnpix=30, ynpix=20
djs_oplot, !X.CRANGE, [0., 0.], th=4, color='red', linestyle=1
hogg_scatterplot, alog10(all.rhlr/all.scale), diff, /cond, $
  quantiles=quantiles, exp=0.25, xra=[-0.1, 1.5], yra=yra, $
  xtitle=textoidl('log_{10}(r_{50}) (True)'), ytitle=ytitle, $
  xcharsize=charsize, ycharsize=charsize, xnpix=30, ynpix=20
djs_oplot, !X.CRANGE, [0., 0.], th=4, color='red', linestyle=1
hogg_scatterplot, all.__b_t_r, diff, /cond, $
  quantiles=quantiles, exp=0.25, xra=[-0.05, 1.05], yra=yra, $
  xtitle='B/T (True)', ytitle=ytitle, $
  xcharsize=charsize, ycharsize=charsize, xnpix=30, ynpix=20
djs_oplot, !X.CRANGE, [0., 0.], th=4, color='red', linestyle=1
k_end_print
spawn, /nosh, ['convert', filebase+'.ps', filebase+'.png']

;; Make Petro size comparisons
filebase=outdir+'/test-simard-petrocirc-r50'+'-'+tversion
k_print, filename=filebase+'.ps'
!P.MULTI=[3,1,3]
!Y.MARGIN=5
!X.OMARGIN=[20, 0]
!Y.OMARGIN=[4, 0]
yra=[-0.6, 0.6]
charsize=2.2
diff= alog(all.petror50*0.396/(all.rhlr/all.scale))
ytitle=textoidl('ln(r_{50}) :: PetroC - True') 
hogg_scatterplot, all.rg2d, diff, /cond, $
  quantiles=quantiles, exp=0.25, xra=[13.8, 16.7], yra=yra, $
  xtitle=textoidl('m_r (True)'), ytitle=ytitle, $
  xcharsize=charsize, ycharsize=charsize, xnpix=30, ynpix=20
djs_oplot, !X.CRANGE, [0., 0.], th=4, color='red', linestyle=1
hogg_scatterplot, alog10(all.rhlr/all.scale), diff, /cond, $
  quantiles=quantiles, exp=0.25, xra=[-0.1, 1.5], yra=yra, $
  xtitle=textoidl('log_{10}(r_{50}) (True)'), ytitle=ytitle, $
  xcharsize=charsize, ycharsize=charsize, xnpix=30, ynpix=20
djs_oplot, !X.CRANGE, [0., 0.], th=4, color='red', linestyle=1
hogg_scatterplot, all.__b_t_r, diff, /cond, $
  quantiles=quantiles, exp=0.25, xra=[-0.05, 1.05], yra=yra, $
  xtitle='B/T (True)', ytitle=ytitle, $
  xcharsize=charsize, ycharsize=charsize, xnpix=30, ynpix=20
djs_oplot, !X.CRANGE, [0., 0.], th=4, color='red', linestyle=1
k_end_print
spawn, /nosh, ['convert', filebase+'.ps', filebase+'.png']

;; Make Petro size comparisons
filebase=outdir+'/test-simard-petrocirccirc-r50'+'-'+tversion
k_print, filename=filebase+'.ps'
!P.MULTI=[3,1,3]
!Y.MARGIN=5
!X.OMARGIN=[20, 0]
!Y.OMARGIN=[4, 0]
yra=[-0.6, 0.6]
charsize=2.2
diff= alog(all.petror50*0.396/(all.rchl_r/all.scale))
ytitle=textoidl('ln(r_{50}) :: PetroC - TrueC') 
hogg_scatterplot, all.rg2d, diff, /cond, $
  quantiles=quantiles, exp=0.25, xra=[13.8, 16.7], yra=yra, $
  xtitle=textoidl('m_r (True)'), ytitle=ytitle, $
  xcharsize=charsize, ycharsize=charsize, xnpix=30, ynpix=20
djs_oplot, !X.CRANGE, [0., 0.], th=4, color='red', linestyle=1
hogg_scatterplot, alog10(all.rhlr/all.scale), diff, /cond, $
  quantiles=quantiles, exp=0.25, xra=[-0.1, 1.5], yra=yra, $
  xtitle=textoidl('log_{10}(r_{50}) (True)'), ytitle=ytitle, $
  xcharsize=charsize, ycharsize=charsize, xnpix=30, ynpix=20
djs_oplot, !X.CRANGE, [0., 0.], th=4, color='red', linestyle=1
hogg_scatterplot, all.__b_t_r, diff, /cond, $
  quantiles=quantiles, exp=0.25, xra=[-0.05, 1.05], yra=yra, $
  xtitle='B/T (True)', ytitle=ytitle, $
  xcharsize=charsize, ycharsize=charsize, xnpix=30, ynpix=20
djs_oplot, !X.CRANGE, [0., 0.], th=4, color='red', linestyle=1
k_end_print
spawn, /nosh, ['convert', filebase+'.ps', filebase+'.png']

;; Make Petro flux comparisons
filebase=outdir+'/test-simard-petrocirc-flux'+'-'+tversion
k_print, filename=filebase+'.ps'
!P.MULTI=[3,1,3]
!Y.MARGIN=5
!X.OMARGIN=[20, 0]
!Y.OMARGIN=[4, 0]
yra=[-0.3, 0.3]
charsize=2.2
diff= mpc-all.rg2d
ytitle=textoidl('m_r :: PetroC - True') 
hogg_scatterplot, all.rg2d, diff, /cond, $
  quantiles=quantiles, exp=0.25, xra=[13.8, 16.7], yra=yra, $
  xtitle=textoidl('m_r (True)'), ytitle=ytitle, $
  xcharsize=charsize, ycharsize=charsize, xnpix=30, ynpix=20
djs_oplot, !X.CRANGE, [0., 0.], th=4, color='red', linestyle=1
hogg_scatterplot, alog10(all.rhlr/all.scale), diff, /cond, $
  quantiles=quantiles, exp=0.25, xra=[-0.1, 1.5], yra=yra, $
  xtitle=textoidl('log_{10}(r_{50}) (True)'), ytitle=ytitle, $
  xcharsize=charsize, ycharsize=charsize, xnpix=30, ynpix=20
djs_oplot, !X.CRANGE, [0., 0.], th=4, color='red', linestyle=1
hogg_scatterplot, all.__b_t_r, diff, /cond, $
  quantiles=quantiles, exp=0.25, xra=[-0.05, 1.05], yra=yra, $
  xtitle='B/T (True)', ytitle=ytitle, $
  xcharsize=charsize, ycharsize=charsize, xnpix=30, ynpix=20
djs_oplot, !X.CRANGE, [0., 0.], th=4, color='red', linestyle=1
k_end_print
spawn, /nosh, ['convert', filebase+'.ps', filebase+'.png']

;; Make Petro size comparisons
filebase=outdir+'/test-simard-petro-rad'+'-'+tversion
k_print, filename=filebase+'.ps'
!P.MULTI=[3,1,3]
!Y.MARGIN=5
!X.OMARGIN=[20, 0]
!Y.OMARGIN=[4, 0]
yra=[-0.6, 0.6]
charsize=2.2
diff= alog(all.petrorad_p*0.396/(all.rhlr/all.scale))
ytitle=textoidl('ln(r_{P}/r_{50,true}')
hogg_scatterplot, all.rg2d, diff, /cond, $
  quantiles=quantiles, exp=0.25, xra=[13.8, 16.7], yra=yra, $
  xtitle=textoidl('m_r (True)'), ytitle=ytitle, $
  xcharsize=charsize, ycharsize=charsize, xnpix=30, ynpix=20
djs_oplot, !X.CRANGE, [0., 0.], th=4, color='red', linestyle=1
hogg_scatterplot, alog10(all.rhlr/all.scale), diff, /cond, $
  quantiles=quantiles, exp=0.25, xra=[-0.1, 1.5], yra=yra, $
  xtitle=textoidl('log_{10}(r_{50}) (True)'), ytitle=ytitle, $
  xcharsize=charsize, ycharsize=charsize, xnpix=30, ynpix=20
djs_oplot, !X.CRANGE, [0., 0.], th=4, color='red', linestyle=1
hogg_scatterplot, all.__b_t_r, diff, /cond, $
  quantiles=quantiles, exp=0.25, xra=[-0.05, 1.05], yra=yra, $
  xtitle='B/T (True)', ytitle=ytitle, $
  xcharsize=charsize, ycharsize=charsize, xnpix=30, ynpix=20
djs_oplot, !X.CRANGE, [0., 0.], th=4, color='red', linestyle=1
k_end_print
spawn, /nosh, ['convert', filebase+'.ps', filebase+'.png']

return

;; Make Sersic flux comparisons
filebase=outdir+'/test-simard-sersic-flux'+'-'+tversion
k_print, filename=filebase+'.ps'
!P.MULTI=[3,1,3]
!Y.MARGIN=5
!X.OMARGIN=[20, 0]
!Y.OMARGIN=[4, 0]
yra=[-0.3, 0.3]
charsize=2.5
diff= ms-all.rg2d
hogg_scatterplot, all.rg2d, diff, /cond, $
  quantiles=quantiles, exp=0.25, xra=[13.8, 16.7], yra=yra, $
  xtitle=textoidl('m_r (True)'), ytitle=textoidl('m_r :: Sersic - True'), $
  xcharsize=charsize, ycharsize=charsize, xnpix=30, ynpix=20
djs_oplot, !X.CRANGE, [0., 0.], th=4, color='red', linestyle=1
hogg_scatterplot, alog10(all.rhlr/all.scale), diff, /cond, $
  quantiles=quantiles, exp=0.25, xra=[-0.1, 1.5], yra=yra, $
  xtitle=textoidl('log_{10}(r_{50}) (True)'), $
  ytitle=textoidl('m_r :: Sersic - True'), $
  xcharsize=charsize, ycharsize=charsize, xnpix=30, ynpix=20
djs_oplot, !X.CRANGE, [0., 0.], th=4, color='red', linestyle=1
hogg_scatterplot, all.__b_t_r, diff, /cond, $
  quantiles=quantiles, exp=0.25, xra=[-0.05, 1.05], yra=yra, $
  xtitle='B/T (True)', ytitle=textoidl('m_r :: Sersic - True'), $
  xcharsize=charsize, ycharsize=charsize, xnpix=30, ynpix=20
djs_oplot, !X.CRANGE, [0., 0.], th=4, color='red', linestyle=1
k_end_print
spawn, /nosh, ['convert', filebase+'.ps', filebase+'.png']

;; Make Sersic size comparisons
filebase=outdir+'/test-simard-sersic-r50'+'-'+tversion
k_print, filename=filebase+'.ps'
!P.MULTI=[3,1,3]
!Y.MARGIN=5
!X.OMARGIN=[20, 0]
!Y.OMARGIN=[4, 0]
yra=[-0.6, 0.6]
charsize=2.2
diff= alog(all.sersicr50*0.396/(all.rhlr/all.scale))
ytitle=textoidl('ln(r_{50}) :: Sersic - True') 
hogg_scatterplot, all.rg2d, diff, /cond, $
  quantiles=quantiles, exp=0.25, xra=[13.8, 16.7], yra=yra, $
  xtitle=textoidl('m_r (True)'), ytitle=ytitle, $
  xcharsize=charsize, ycharsize=charsize, xnpix=30, ynpix=20
djs_oplot, !X.CRANGE, [0., 0.], th=4, color='red', linestyle=1
hogg_scatterplot, alog10(all.rhlr/all.scale), diff, /cond, $
  quantiles=quantiles, exp=0.25, xra=[-0.1, 1.5], yra=yra, $
  xtitle=textoidl('log_{10}(r_{50}) (True)'), ytitle=ytitle, $
  xcharsize=charsize, ycharsize=charsize, xnpix=30, ynpix=20
djs_oplot, !X.CRANGE, [0., 0.], th=4, color='red', linestyle=1
hogg_scatterplot, all.__b_t_r, diff, /cond, $
  quantiles=quantiles, exp=0.25, xra=[-0.05, 1.05], yra=yra, $
  xtitle='B/T (True)', ytitle=ytitle, $
  xcharsize=charsize, ycharsize=charsize, xnpix=30, ynpix=20
djs_oplot, !X.CRANGE, [0., 0.], th=4, color='red', linestyle=1
k_end_print
spawn, /nosh, ['convert', filebase+'.ps', filebase+'.png']

end
