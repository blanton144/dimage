pro compare_lowz_sdss

lowz= lowz_read(sample='dr6')
measure= mrdfits(getenv('VAGC_REDUX')+'/lowz/lowz_measure.dr6.fits',1)
measure=measure[0:n_elements(lowz)-1L]
gmr gt 0.75 and gmr lt 0.9 and conc gt 2.6)

gmr=-2.5*alog10(measure.petroflux[1]/measure.petroflux[2])
conc= measure.petror90/ measure.petror50

ii=where(gmr gt 0.75 and gmr lt 0.9 and conc gt 2.6)
measure=measure[ii]
lowz=lowz[ii]

xx=findgen(100)

k_print, filename=getenv('DIMAGE_DIR')+'/tex/compare_petroflux.ps'
!P.MULTI=[0,2,3]
!X.MARGIN= 6
!y.MARGIN= 3
band=['u', 'g', 'r', 'i', 'z']
for i=0L, 4L do $
  hogg_scatterplot, measure.petror50, $
  lowz.petroflux[i]/measure.petroflux[i], xnpix=30, ynpix=25, $
  /cond, exp=0.3, xra=[0.1, 75.], yra=[0.1, 1.6], $
  xtitle=textoidl('!8r_{50}!6 (pixels)'), $
  ytitle=textoidl('!8f_{SDSS}/f_{mine} !6(!8'+band[i]+'!6 band)')
rmag= 22.5-2.5*alog10(measure.petroflux[2])
hogg_scatterplot, rmag, measure.petror50, $
  xnpix=20, ynpix=20, $
  /cond, exp=0.3, yra=[0.1, 75.], xra=[9.9, 18.6], $
  ytitle=textoidl('!8r_{50}!6 (pixels)'), $
  xtitle=textoidl('!8m_r!6')
k_end_print

aperflux= fltarr(5, n_elements(measure))
for i=0L, n_elements(measure)-1L do begin
    for b=0L, 4L do begin
        interp_profmean, measure[i].nprof[b], $
          transpose(measure[i].profmean[b,*]), $
          2.*lowz[i].petrotheta[2]/0.396, tmp_flux
        aperflux[b,i]=tmp_flux[0]
    endfor
endfor

k_print, filename=getenv('DIMAGE_DIR')+'/tex/compare_aperflux.ps'
!P.MULTI=[0,2,3]
!X.MARGIN= 6
!y.MARGIN= 3
band=['u', 'g', 'r', 'i', 'z']
for i=0L, 4L do begin
    hogg_scatterplot, measure.petror50, $
      lowz.petroflux[i]/aperflux[i,*], xnpix=30, ynpix=25, $
      /cond, exp=0.3, xra=[0.1, 55.], yra=[0.1, 1.6], $
      xtitle=textoidl('!8r_{50}!6 (pixels)'), $
      ytitle=textoidl('!8f_{SDSS}/f_{aper} !6(!8'+band[i]+'!6 band)')
endfor
k_end_print

umr= ((-2.5*alog10(measure.petroflux[0]/measure.petroflux[2])) > (-3.))<5.
k_print, filename=getenv('DIMAGE_DIR')+'/tex/umr-asymmetry.ps'

hogg_scatterplot, umr, measure.asymmetry[2], $
  xnpix=40, ynpix=40, xra=[0.9, 3.1], yra=[-0.05, 0.34], $
  /outliers, exp=0.8, xtitle='!8u-r!6', ytitle='!6asyymetry', $
  /internal_weight, levels=[0.05, 0.1, 0.3, 0.5, 0.7, 0.9, 0.95]

k_end_print

stop


end
