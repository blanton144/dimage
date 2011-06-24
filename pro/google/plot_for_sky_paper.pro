;+
; NAME:
;   plot_for_sky_paper
; PURPOSE:
;   Plot results of fake tests
; CALLING SEQUENCE:
;   plot_fake
; REVISION HISTORY:
;   2-Aug-2010 MRB, NYU
;-
pro calc_running_median, x, y, xra, xsize, nbin, xpos, ypos, npos

xpos= (findgen(nbin)+0.5)/float(nbin)*(xra[1]-xra[0])+xra[0]
ypos= fltarr(nbin)

npos= lonarr(nbin)
for i=0L, nbin-1L do begin
   iin= where(x gt xpos[i]-0.5*xsize and $
              x le xpos[i]+0.5*xsize, nin)
   npos[i]=nin
   if(nin gt 0) then begin
      ypos[i]= djs_median(y[iin])
   endif
endfor

end
;
pro plot_running_median, x, y, xra, xsize, nbin, color=color

calc_running_median, x, y, xra, xsize, nbin, xpos, ypos, npos

djs_oplot, xpos, ypos, th=6, color=color

end
;
function fit_running_median_model, xpos, pars

model= pars[0]*replicate(1., n_elements(xpos))
for i=1L, n_elements(pars)-1L do begin
   model+= pars[i]*(xpos-1.)^float(i)
endfor

return, (model)
  
end
;
;
function fit_running_median_deviates, pars

common com_fit_running_median, fit_xpos, fit_ypos, fit_weight

model= fit_running_median_model(fit_xpos, pars)

return, (model-fit_ypos)*fit_weight
  
end
;
pro fit_running_median, xpos, ypos, npos, pars, sigma

common com_fit_running_median

fit_xpos= [xpos]
fit_ypos= [ypos]
fit_weight= [float(npos gt 0)]

;; parameters are:
pst= [0.D, 0.D, 0.D]
parinfo0={value:0., fixed:0L, limited:bytarr(2), limits:fltarr(2), step:0.}
parinfo= replicate(parinfo0, n_elements(pst))
parinfo.step=1.e-2

;; run minimization
pmin= mpfit('fit_running_median_deviates', pst, auto=1, parinfo=parinfo, $
            status=status, /quiet, ftol=1.d-6)

pars= pmin

end
;
pro sigma_running_median, x, y, xpos, pars, sigma

model= fit_running_median_model(xpos, pars)
ymodel= interpol(model, xpos, x)
sigma= djsig(y-ymodel)

end
;
pro plot_band, stamps, name, pobj, pobjv56, rfake, cfake, num, topaxis=topaxis, bottomaxis=bottomaxis, $
               yra=yra, leftaxis=leftaxis, rightaxis=rightaxis, xcharsize=xcharsize, $
               ycharsize=ycharsize, fmeas=fmeas, vsmeas=vsmeas, xmeas=xmeas, xra=xra, unit=unit

if(n_elements(yra) eq 0) then begin
   yra=[-0.99,1.99]
endif

if(n_elements(xra) eq 0) then begin
   xra=alog10([3.5, 119])
endif

csize=0.45

if(n_elements(num) eq 1) then begin
   iok= where(pobj.petroflux[num] gt 0. and pobjv56.petroflux[num] gt 0. and $
              pobjv56.petroth50[2] gt 0. and $
              cfake.flux95_stamp gt 0)
   roffset= -2.5*alog10((cfake[iok].flux95_fake-cfake[iok].flux95_real)/cfake[iok].flux95_stamp)
   proffset= -2.5*alog10((pobj[iok].petroflux[num])/(cfake[iok].flux95_stamp/0.95))
   p56roffset= -2.5*alog10((pobjv56[iok].petroflux[num])/(cfake[iok].flux95_stamp/0.95))
   pvroffset= -2.5*alog10((pobjv56[iok].petroflux[num])/(pobj[iok].petroflux[num]))
   if(n_tags(fmeas) gt 0) then $
      fmroffset= -2.5*alog10((fmeas.sersicflux[num]>0.001)/ $
                             (cfake[long(fmeas.num)].flux95_stamp/0.95))
endif else begin
   iok= where(pobj.petroflux[num[0]] gt 0. and pobjv56.petroflux[num[0]] gt 0. and $
              pobj.petroflux[num[1]] gt 0. and pobjv56.petroflux[num[1]] gt 0. and $
              pobjv56.petroth50[2] gt 0. and $
              cfake.flux95_stamp gt 0 and rfake.flux95_stamp gt 0.)
   if(num[0] eq 2) then begin
      fake0= rfake
      fake1= cfake
   endif else begin
      fake1= rfake
      fake0= cfake
   endelse
   roffset= -2.5*alog10((fake0[iok].flux95_fake-fake0[iok].flux95_real)/fake0[iok].flux95_stamp) $
            +2.5*alog10((fake1[iok].flux95_fake-fake1[iok].flux95_real)/fake1[iok].flux95_stamp)
   proffset= -2.5*alog10((pobj[iok].petroflux[num[0]])/(fake0[iok].flux95_stamp/0.95))  $
             +2.5*alog10((pobj[iok].petroflux[num[1]])/(fake1[iok].flux95_stamp/0.95))  
   p56roffset= -2.5*alog10((pobjv56[iok].petroflux[num[0]])/(fake0[iok].flux95_stamp/0.95)) $
               +2.5*alog10((pobjv56[iok].petroflux[num[1]])/(fake1[iok].flux95_stamp/0.95)) 
   pvroffset= -2.5*alog10((pobjv56[iok].petroflux[num[0]])/(pobj[iok].petroflux[num[0]])) $
              +2.5*alog10((pobjv56[iok].petroflux[num[1]])/(pobj[iok].petroflux[num[1]]))
   if(n_tags(fmeas) gt 0) then $
      fmroffset= -2.5*alog10((fmeas.sersicflux[num[0]]>0.001)/ $
                             (fake0[long(fmeas.num)].flux95_stamp/0.95)) $
                 +2.5*alog10((fmeas.sersicflux[num[1]]>0.001)/ $
                             (fake1[long(fmeas.num)].flux95_stamp/0.95)) 
endelse

rr50= rfake[iok].r50*0.396*sqrt(stamps[iok].axisratio)
pr50= pobjv56[iok].petroth50[2]
if(keyword_set(vsmeas)) then $
   rr50=pr50
rmag= 22.5-2.5*alog10(rfake[iok].flux95_stamp/0.95)
pmag= 22.5-2.5*alog10(pobjv56[iok].petroflux[2])
rmu50= 22.5-2.5*alog10(rfake[iok].flux50_stamp/(!DPI*(rfake[iok].r50*0.396)^2))
pmu50= pmag+2.5*alog10(2.0*!DPI*pr50^2)

left= 1 AND (keyword_set(rightaxis) eq 0)
right= 0 OR (keyword_set(rightaxis) ne 0)
hogg_usersym, 4
djs_plot, alog10(rr50), roffset, psym=8, symsize=0.6, $
          xtitle='!6log_{10} !8r_{50}!6 (arcsec)!6', $
          ytitle='!6\Delta'+name+' (mag)!6', $
          yra=yra, xra=xra, left=left, right=right, $
          topaxis=topaxis, bottomaxis=bottomaxis, xcharsize=xcharsize, ycharsize=ycharsize, $
          color='green', nodata=keyword_set(vsmeas)
;;if(keyword_set(vsmeas)) then $
   ;;djs_oplot, alog10(rr50), proffset, psym=8, symsize=csize, color='red'
hogg_usersym, 10
djs_oplot, alog10(rr50), p56roffset, psym=8, symsize=csize, color='blue'
if(NOT keyword_set(vsmeas)) then begin
   hogg_usersym, 3
   if(n_tags(fmeas) gt 0) then $
      djs_oplot, alog10(rr50), fmroffset, psym=8, symsize=csize, color='black'
   
   if(n_tags(fmeas) gt 0) then $
      plot_running_median,  alog10(rr50), fmroffset, !X.CRANGE, 0.3, 100, color='black'
endif

plot_running_median,  alog10(rr50), p56roffset, !X.CRANGE, 0.3, 100, color='blue'
if(keyword_set(vsmeas)) then begin
   ii=where(rfake[iok].sersic gt 3.5)
   hogg_usersym, 10, /fill
   djs_oplot, alog10(rr50[ii]), p56roffset[ii], psym=8, symsize=csize, color='blue'
;;   plot_running_median,  alog10(rr50[ii]), p56roffset[ii], !X.CRANGE, 0.3, 100, color='blue'
endif

;;if(keyword_set(vsmeas)) then $
   ;;plot_running_median,  alog10(rr50), proffset, !X.CRANGE, 0.3, 100, color='red'

calc_running_median,  alog10(rr50), proffset, !X.CRANGE, 0.3, 100, xpos, ypos, npos
calc_running_median,  alog10(rr50), p56roffset, !X.CRANGE, 0.3, 100, xpos56, ypos56, npos56
calc_running_median,  alog10(rr50), fmroffset, !X.CRANGE, 0.3, 100, xposmeas, yposmeas, nposmeas
fit_running_median, xpos, ypos, npos, pars
model= fit_running_median_model(xpos, pars)
sigma_running_median, alog10(rr50), proffset, xpos, pars, sigma
fit_running_median, xpos56, ypos56, npos56, pars56
model56= fit_running_median_model(xpos56, pars56)
sigma_running_median, alog10(rr50), p56roffset, xpos56, pars56, sigma56
fit_running_median, xposmeas, yposmeas, nposmeas, parsmeas
modelmeas= fit_running_median_model(xposmeas, parsmeas)
sigma_running_median, alog10(rr50), fmroffset > (-5.), xposmeas, parsmeas, sigmameas

note=''
if(keyword_set(vsmeas)) then $
   note=' (vs $r_{50}$ meas.)'

printf, unit, '$'+name+'$'+note+' & \texttt{v5\_4} & $'+strtrim(string(f='(f40.3)', pars[0]),2)+'$ & $'+ $
       strtrim(string(f='(f40.3)', pars[1]),2)+'$ & $'+ $
       strtrim(string(f='(f40.3)', pars[2]),2)+'$ & $'+ $
       strtrim(string(f='(f40.3)', sigma),2)+'$\cr'

printf, unit, ' & '+'\texttt{v5\_6} & $'+strtrim(string(f='(f40.3)', pars56[0]),2)+'$ & $'+ $
       strtrim(string(f='(f40.3)', pars56[1]),2)+'$ & $'+ $
       strtrim(string(f='(f40.3)', pars56[2]),2)+'$ & $'+ $
       strtrim(string(f='(f40.3)', sigma56),2)+'$\cr'

djs_oplot, xpos56, model56, color='blue'

printf, unit, ' & '+'global & $'+strtrim(string(f='(f40.3)', parsmeas[0]),2)+'$ & $'+ $
        strtrim(string(f='(f40.3)', parsmeas[1]),2)+'$ & $'+ $
        strtrim(string(f='(f40.3)', parsmeas[2]),2)+'$ & $'+ $
        strtrim(string(f='(f40.3)', sigmameas),2)+'$\cr'
djs_oplot, xposmeas, modelmeas, color='black'

xch=!X.CHARSIZE
ych=!Y.CHARSIZE
if(keyword_set(topaxis) eq 0 and keyword_set(bottomaxis) eq 0) then begin
   xch=0.0001
   ych=0.0001
endif

end
;;
pro plot_for_sky_paper, model=model, ax=ax, version=version

common com_compare_reruns, im, atlas

rootdir=atlas_rootdir(sample=sample, version=version)

postfix=''
if(keyword_set(model)) then $
   postfix=postfix+'.model'
if(keyword_set(ax)) then $
   postfix=postfix+'.ax'

if(n_tags(im) eq 0) then begin
    imfile= '/global/data/vagc-dr7/vagc2/object_sdss_imaging.fits'
    im= hogg_mrdfits(imfile, 1, nrow=28800, $
                     columns=['ra', 'dec', 'petroflux', 'petroflux_ivar', $
                              'petror50', 'petror90', 'modelflux', $
                              'modelflux_ivar', 'theta_dev', 'theta_exp'])
endif

if(n_tags(atlas) eq 0) then $
  atlas= mrdfits(rootdir+'/catalogs/sdss_atlas.fits',1)
    
ufake= mrdfits(getenv('DIMAGE_DIR')+'/data/fake/fake_lsb_v5.6.3_u_000.fits',1)
gfake= mrdfits(getenv('DIMAGE_DIR')+'/data/fake/fake_lsb_v5.6.3_g_000.fits',1)
rfake= mrdfits(getenv('DIMAGE_DIR')+'/data/fake/fake_lsb_v5.6.3_r_000.fits',1)
ifake= mrdfits(getenv('DIMAGE_DIR')+'/data/fake/fake_lsb_v5.6.3_i_000.fits',1)
zfake= mrdfits(getenv('DIMAGE_DIR')+'/data/fake/fake_lsb_v5.6.3_z_000.fits',1)
stamps= mrdfits(getenv('DIMAGE_DIR')+'/data/fake/fake_stamps_info_003.fits',1)
if(NOT keyword_set(ax)) then $
   stamps.axisratio=1.
stamp_measure= mrdfits(getenv('DIMAGE_DIR')+'/data/fake/fake_stamps_measure_003.fits',1)
pobj= mrdfits(getenv('DIMAGE_DIR')+'/data/fake/fake_photo_003.fits',1)
pobjv56= mrdfits(getenv('DIMAGE_DIR')+'/data/skytest/pobj_fake_lsb_v5.6.3.fits',1)
fmeas= mrdfits('/global/data/scr/mb144/skyfake/fake-004/fake-004-measure.fits',1)

openw, unit, getenv('DIMAGE_DIR')+'/tex/sky_offsets_tablebody'+postfix+'.tex', /get_lun

if(keyword_set(model)) then begin
   pobj.petroflux= pobj.cmodelflux
   pobjv56.petroflux= pobjv56.cmodelflux

   pobjv56.petroth50= pobjv56.theta_exp
   idev= where(pobjv56.fracdev[2] gt 0.5)
   pobjv56[idev].petroth50= pobjv56[idev].theta_exp

   pobj.petroth50= pobj.theta_exp
   idev= where(pobj.fracdev[2] gt 0.5)
   pobj[idev].petroth50= pobj[idev].theta_exp
endif

k_print, filename=getenv('DIMAGE_DIR')+'/tex/sky_offsets_fakedist'+postfix+'.ps'

ii= where(atlas.petroth50[2] gt 1. and atlas.petroflux[2] gt 1., nii)
help,ii
hogg_scatterplot, alog10(atlas[ii].petroth50[2]), $
                  22.5-2.5*alog10(atlas[ii].petroflux[2]), $
                  xtitle=textoidl('!6log_{10} !8r_{50}!6 (arcsec)'), $
                  ytitle=textoidl('!8m_r!6'), xra=[0.1, 1.9], $
                  yra=[10.1, 17.7], /internal, exp=0.5, xnpix=35, $
                  ynpix=35, levels=[0.5, 0.75, 0.9, 0.95, 0.99]
ii= where(pobjv56.petroth50[2] gt 1. and pobjv56.petroflux[2] gt 1., nii)
hogg_usersym, 10, /fill
djs_oplot, alog10(pobjv56[ii].petroth50[2]), $
           22.5-2.5*alog10(pobjv56[ii].petroflux[2]), color='red', $
           symsize=0.3, psym=8

k_end_print

k_print, filename=getenv('DIMAGE_DIR')+'/tex/sky_offsets_ronly'+postfix+'.ps'

!P.MULTI=[2,1,2]
!Y.MARGIN=0

ii= where(pobj.petroth50[2] gt 1. and pobj.petroflux[2] gt 1. and $
          rfake.r50 gt 0., nii)
r50c= rfake[ii].r50*0.396*sqrt(stamps[ii].axisratio)
r50= rfake[ii].r50*0.396
delr= alog10(pobj[ii].petroth50[2]/r50)

ii= where(pobjv56.petroth50[2] gt 1. and pobjv56.petroflux[2] gt 1. and $
          rfake.r50 gt 0., nii)
r50v56c= rfake[ii].r50*0.396*sqrt(stamps[ii].axisratio)
r50v56= rfake[ii].r50*0.396
delrv56= alog10(pobjv56[ii].petroth50[2]/r50v56)

r50measc=(rfake[fmeas.num].r50*0.396*sqrt(stamps[ii].axisratio))
r50meas=(rfake[fmeas.num].r50*0.396)
delrmeas= alog10(((fmeas.sersic_r50*0.396)>0.001)/r50meas)

hogg_usersym, 10
djs_plot, alog10(r50v56c), delrv56, psym=8, color='blue', xra=alog10([3.5, 119.]), $
          /left, symsize=0.45, ytitle='!6\Delta(log_{10}!8r_{50})!6', $
          yra=[-0.99, 0.17]

hogg_usersym, 3
djs_oplot, alog10(r50measc), delrmeas, psym=8, color='black', symsize=0.45

;;plot_running_median, alog10(r50),delr, !X.CRANGE, 0.3, 100, color='red'
plot_running_median, alog10(r50v56c),delrv56, !X.CRANGE, 0.3, 100, color='blue'
plot_running_median, alog10(r50measc),delrmeas, !X.CRANGE, 0.3, 100, color='black'

calc_running_median, alog10(r50c),delr, !X.CRANGE, 0.3, 100, xpos, ypos, npos
calc_running_median, alog10(r50v56c),delrv56, !X.CRANGE, 0.3, 100, xpos56, ypos56, npos56
calc_running_median, alog10(r50measc),delrmeas, !X.CRANGE, 0.3, 100, xposmeas, yposmeas, nposmeas

fit_running_median, xpos, ypos, npos, pars
fit_running_median, xpos56, ypos56, npos56, pars56
fit_running_median, xposmeas, yposmeas, nposmeas, parsmeas

model= fit_running_median_model(xpos, pars)
sigma_running_median, alog10(r50c), delr, xpos, pars, sigma
printf, unit, '$r_{50}$ & \texttt{v5\_4} & $'+strtrim(string(f='(f40.3)', pars[0]),2)+'$ & $'+ $
       strtrim(string(f='(f40.3)', pars[1]),2)+'$ & $'+ $
       strtrim(string(f='(f40.3)', pars[2]),2)+'$ & $'+ $
       strtrim(string(f='(f40.3)', sigma),2)+'$\cr'

model56= fit_running_median_model(xpos56, pars56)
djs_oplot, xpos56, model56, color='blue'
sigma_running_median, alog10(r50v56c), delrv56, xpos56, pars56, sigma56
printf, unit, ' & \texttt{v5\_6} & $'+strtrim(string(f='(f40.3)', pars56[0]),2)+'$ & $'+ $
       strtrim(string(f='(f40.3)', pars56[1]),2)+'$ & $'+ $
       strtrim(string(f='(f40.3)', pars56[2]),2)+'$ & $'+ $
       strtrim(string(f='(f40.3)', sigma56),2)+'$\cr'

modelmeas= fit_running_median_model(xposmeas, parsmeas)
djs_oplot, xposmeas, modelmeas, color='black'
sigma_running_median, alog10(r50measc), delrmeas, xposmeas, parsmeas, sigmameas
printf, unit, ' & global & $'+strtrim(string(f='(f40.3)', parsmeas[0]),2)+'$ & $'+ $
       strtrim(string(f='(f40.3)', parsmeas[1]),2)+'$ & $'+ $
       strtrim(string(f='(f40.3)', parsmeas[2]),2)+'$ & $'+ $
       strtrim(string(f='(f40.3)', sigmameas),2)+'$\cr'

plot_band, stamps, 'm_r', pobj, pobjv56, rfake, rfake, 2, /bottom, yra=[-0.59, 2.29], $
           fmeas=fmeas, unit=unit

!P.MULTI=0
!P.POSITION=[0.1487, 0.864, 0.8513, 1.]
djs_plot, [0], [0], /nodata, /noerase, xticklen=0.00001, yticklen=0.00001, $
          xcharsize=0.001, ycharsize=0.001

hogg_usersym, 10
djs_oplot, [0.05], [0.8], psym=8, symsize=0.8, color='blue'
djs_xyouts, [0.08], [0.76], '!8Standard DR8 pipeline!6', color='blue'
hogg_usersym, 3
djs_oplot, [0.05], [0.5], psym=8, symsize=0.8, color='black'
djs_xyouts, [0.08], [0.46], '!8This paper (real deblending)!6', color='black'
hogg_usersym, 4
djs_oplot, [0.05], [0.2], psym=8, symsize=0.8, color='green'
djs_xyouts, [0.08], [0.16], '!8This paper (perfect deblending)!6', color='green'

djs_oplot, [0.58, 0.65], [0.8, 0.8], th=6
djs_xyouts, [0.68], [0.76], '!8running median!6'
djs_oplot, [0.58, 0.65], [0.5, 0.5], th=1
djs_xyouts, [0.68], [0.46], '!8best fit to median!6'

k_end_print

k_print, filename=getenv('DIMAGE_DIR')+'/tex/sky_offsets_ugiz'+postfix+'.ps'

!P.MULTI=[4,2,2]
!Y.MARGIN=0
!X.MARGIN=0

hogg_usersym, 3

plot_band, stamps, '(u-r)', pobj, pobjv56, rfake, ufake, [0,2], /left, $
           xch=1.2, ych=1.2, fmeas=fmeas, yra=[-0.69, 0.69], unit=unit
plot_band, stamps, '(g-r)', pobj, pobjv56, rfake, gfake, [1,2], /right, $
           xch=1.2, ych=1.2, fmeas=fmeas, yra=[-0.69, 0.69], unit=unit
plot_band, stamps, '(r-i)', pobj, pobjv56, rfake, ifake, [2,3], /bottom, /left, $
           xch=1.2, ych=1.2, fmeas=fmeas, yra=[-0.69, 0.69], unit=unit
plot_band, stamps, '(r-z)', pobj, pobjv56, rfake, zfake, [2,4], /bottom, /right, $
           xch=1.2, ych=1.2, fmeas=fmeas, yra=[-0.69, 0.69], unit=unit

!P.MULTI=0
!P.POSITION=[0.143, 0.864, 0.857, 1.]
djs_plot, [0], [0], /nodata, /noerase, xticklen=0.00001, yticklen=0.00001, $
          xcharsize=0.001, ycharsize=0.001

hogg_usersym, 10
djs_oplot, [0.05], [0.8], psym=8, symsize=0.8, color='blue'
djs_xyouts, [0.08], [0.76], '!8Standard DR8 pipeline!6', color='blue'
hogg_usersym, 3
djs_oplot, [0.05], [0.5], psym=8, symsize=0.8, color='black'
djs_xyouts, [0.08], [0.46], '!8This paper (real deblending)!6', color='black'
hogg_usersym, 4
djs_oplot, [0.05], [0.2], psym=8, symsize=0.8, color='green'
djs_xyouts, [0.08], [0.16], '!8This paper (perfect deblending)!6', color='green'

djs_oplot, [0.58, 0.65], [0.8, 0.8], th=6
djs_xyouts, [0.68], [0.76], '!8running median!6'
djs_oplot, [0.58, 0.65], [0.5, 0.5], th=1
djs_xyouts, [0.68], [0.46], '!8best fit to median!6'

k_end_print

k_print, filename=getenv('DIMAGE_DIR')+'/tex/sky_offsets_vs_r50meas'+postfix+'.ps'

!Y.MARGIN=0
!X.MARGIN=0

hogg_usersym, 3

plot_band, stamps, 'm_r', pobj, pobjv56, rfake, rfake, 2, /bottom, /left, $
           xch=1.2, ych=1.2, fmeas=fmeas, /vsmeas, $
           xra=alog10([3.5, 40.]), unit=unit, yra=[-0.59, 2.29]

r_curve= findgen(1000)+1.
hyde_curve= -0.024+r_curve/71.17+(r_curve/26.5)^2
djs_oplot, alog10(r_curve), hyde_curve, th=6, color='red', linest=1

k_end_print

free_lun, unit



end
