;+
; NAME:
;   plot_for_dr8_paper
; PURPOSE:
;   Plot results of fake tests
; CALLING SEQUENCE:
;   plot_fake
; REVISION HISTORY:
;   2-Aug-2010 MRB, NYU
;-
pro plot_running_median, x, y, xra, xsize, nbin, color=color

xpos= (findgen(nbin)+0.5)/float(nbin)*(xra[1]-xra[0])+xra[0]
ypos= fltarr(nbin)

for i=0L, nbin-1L do begin
   iin= where(x gt xpos[i]-0.5*xsize and $
              x le xpos[i]+0.5*xsize, nin)
   if(nin gt 0) then begin
      ypos[i]= djs_median(y[iin])
   endif
endfor

djs_oplot, xpos, ypos, th=6, color=color

end
;
pro plot_band, stamps, name, pobj, pobjv56, rfake, cfake, num, topaxis=topaxis, bottomaxis=bottomaxis, $
               diff=diff, nomu=nomu, nomag=nomag, nor50=nor50, yra=yra

common com_compare_reruns, atlas, im, m1, m2

if(n_elements(yra) eq 0) then begin
   yra=[-0.79,1.79]
   if(keyword_set(diff)) then yra=[-1.64, 0.69]
endif

csize=0.2

irkeep= where(atlas[m1].petroth50[2] gt 0.8 AND $
              im[m2].petror50[2] gt 1. AND $
              atlas[m1].petroflux[2] gt 0. AND $
              atlas[m1].petroflux[num] gt 0. AND $
              im[m2].petroflux[num] gt 0., nrkeep)

real_r50= atlas[m1[irkeep]].petroth50[2]
real_rmag= 22.5-2.5*alog10(atlas[m1[irkeep]].petroflux[2])
real_rmu50= 22.5-2.5*alog10(0.5*atlas[m1[irkeep]].petroflux[2]/(!DPI*real_r50^2))
real_rflux_v5_6= atlas[m1[irkeep]].petroflux[num]
real_rflux_v5_4= im[m2[irkeep]].petroflux[num]
real_offset= -2.5*alog10(real_rflux_v5_6/real_rflux_v5_4)

iok= where(pobj.petroflux[num] gt 0. and pobjv56.petroflux[num] gt 0. and $
          cfake.flux95_stamp gt 0)
roffset= -2.5*alog10((cfake[iok].flux95_fake-cfake[iok].flux95_real)/cfake[iok].flux95_stamp)
proffset= -2.5*alog10((pobj[iok].petroflux[num])/(cfake[iok].flux95_stamp/0.95))
p56roffset= -2.5*alog10((pobjv56[iok].petroflux[num])/(cfake[iok].flux95_stamp/0.95))
pvroffset= -2.5*alog10((pobjv56[iok].petroflux[num])/(pobj[iok].petroflux[num]))

help, rfake, stamps
rr50= stamps[iok].r50*0.396*sqrt(stamps[iok].axisratio)
pr50= pobjv56[iok].petroth50[2]
rmag= 22.5-2.5*alog10(rfake[iok].flux95_stamp/0.95)
pmag= 22.5-2.5*alog10(pobjv56[iok].petroflux[2])
rmu50= 22.5-2.5*alog10(rfake[iok].flux50_stamp/(!DPI*(rfake[iok].r50*0.396)^2))
pmu50= pmag+2.5*alog10(2.0*!DPI*pr50^2)

if(NOT keyword_set(nor50)) then begin
   if(NOT keyword_set(diff)) then begin
      djs_plot, alog10(rr50), roffset, psym=8, symsize=0.4, $
        xtitle=textoidl('!6log_{10}!8[r_{50}!6 (b/a)^{1/2}]!6 (arcsec)'), $
        ytitle='!6\Deltam_'+name+' (mag)!6', $
        yra=yra, xra=alog10([3.5, 119.] ), /nodata, /left, topaxis=topaxis, $
        bottomaxis=bottomaxis
      djs_oplot, alog10(rr50), proffset, psym=8, symsize=csize, color='red'
      djs_oplot, alog10(rr50), p56roffset, psym=8, symsize=csize, color='blue'
      plot_running_median,  alog10(rr50), proffset, !X.CRANGE, 0.3, 100, color='red'
      plot_running_median,  alog10(rr50), p56roffset, !X.CRANGE, 0.3, 100, color='blue'
   endif else begin
      xtitle=textoidl('!6log_{10} !8r_{50}!6 (arcsec)!6')
      ytitle=textoidl('!6\Deltam_'+name+' (mag)!6')
      hogg_scatterplot, alog10(real_r50), real_offset, $
                        yra=yra, xra=alog10([3.5, 119.] ), /left, $
                        /internal, exp=0.3, xnpix=40, $
                        ynpix=40, xcharsize=0.001, ytitle=ytitle
      if(keyword_set(topaxis)) then $
         axis, !X.CRANGE[0], !Y.CRANGE[1], xaxis=1, $
               xtitle=xtitle
      if(keyword_set(bottomaxis)) then $
         axis, !X.CRANGE[0], !Y.CRANGE[0], xaxis=0, $
               xtitle=xtitle
      djs_oplot, alog10(pr50), pvroffset, psym=8, symsize=csize, color='red'
      plot_running_median,  alog10(real_r50), real_offset, !X.CRANGE, 0.3, 100, color='black'
      plot_running_median,  alog10(pr50), pvroffset, !X.CRANGE+[0.,-0.5], 0.3, 100, color='red'
   endelse
endif

;;if(num eq 2 and keyword_set(diff) eq 0) then begin
   ;;r_curve= findgen(1000)+1.
   ;;hyde_curve= -0.024+r_curve/71.17+(r_curve/26.5)^2
   ;;djs_oplot, alog10(r_curve), hyde_curve, th=5, color='magenta'
;;endif

xch=!X.CHARSIZE
ych=!Y.CHARSIZE
if(keyword_set(topaxis) eq 0 and keyword_set(bottomaxis) eq 0) then begin
   xch=0.0001
   ych=0.0001
endif

if(NOT keyword_set(nomag)) then begin
   if(NOT keyword_set(diff)) then begin
      djs_plot, rmag, roffset, psym=8, symsize=0.4, $
                xtitle='!8m_r !6(mag)!6', $
                ytitle='!6\Deltam_'+name+'(mag)!6', $
                yra=yra, xra=[9.7, 17.9] , /nodata, topaxis=topaxis, $
                bottomaxis=bottomaxis, xcharsize=xch, ycharsize=ych
      djs_oplot, rmag, proffset, psym=8, symsize=csize, color='red'
      djs_oplot, rmag, p56roffset, psym=8, symsize=csize, color='blue'
      plot_running_median,  rmag, proffset, !X.CRANGE, 0.6, 100, color='red'
      plot_running_median,  rmag, p56roffset, !X.CRANGE, 0.6, 100, color='blue'
   endif else begin
      xtitle=textoidl('!8m_r !6(mag)!6')
      ytitle=textoidl('!6\Deltam_'+name+' (mag)!6')
      hogg_scatterplot, real_rmag, real_offset, $
                        yra=yra, xra=[9.7, 17.9], $
                        /internal, exp=0.3, xnpix=40, $
                        ynpix=40, xcharsize=0.001, ycharsize=0.001
      if(keyword_set(topaxis)) then $
         axis, !X.CRANGE[0], !Y.CRANGE[1], xaxis=1, $
               xtitle=xtitle
      if(keyword_set(bottomaxis)) then $
         axis, !X.CRANGE[0], !Y.CRANGE[0], xaxis=0, $
               xtitle=xtitle
      djs_oplot, pmag, pvroffset, psym=8, symsize=csize, color='red'
      plot_running_median,  real_rmag, real_offset, !X.CRANGE+[0.7, 0.], 0.3, 100, color='black'
      plot_running_median,  pmag, pvroffset, !X.CRANGE+[0.7, 0.], 0.6, 100, color='red'
   endelse
endif
   
if(NOT keyword_set(nomu)) then begin
   if(NOT keyword_set(diff)) then begin
      djs_plot, rmu50, roffset, psym=8, symsize=0.4, $
                xtitle='\mu_{50}!6 (mag arcsec^{-2})', $
                ytitle='!6\Deltam_'+name+'(mag)!6', $
                yra=yra, xra=[18.5, 25.] , /nodata, /right, $
                topaxis=topaxis, bottomaxis=bottomaxis
      djs_oplot, rmu50, proffset, psym=8, symsize=csize, color='red'
      djs_oplot, rmu50, p56roffset, psym=8, symsize=csize, color='blue'
      plot_running_median,  rmu50, proffset, !X.CRANGE, 0.6, 100, color='red'
      plot_running_median,  rmu50, p56roffset, !X.CRANGE, 0.6, 100, color='blue'
   endif else begin
      xtitle=textoidl('\mu_{50}!6 (mag arcsec^{-2})')
      ytitle=textoidl('!6\Deltam_'+name+' (mag)!6')
      hogg_scatterplot, real_rmu50, real_offset, $
                        yra=yra, xra=[18.5, 25.], $
                        /internal, exp=0.3, xnpix=40, $
                        ynpix=40, xcharsize=0.001, ycharsize=0.001
      axis, !X.CRANGE[1], !Y.CRANGE[0], yaxis=1, $
            ytitle=ytitle
      if(keyword_set(topaxis)) then $
         axis, !X.CRANGE[0], !Y.CRANGE[1], xaxis=1, $
               xtitle=xtitle
      if(keyword_set(bottomaxis)) then $
         axis, !X.CRANGE[0], !Y.CRANGE[0], xaxis=0, $
               xtitle=xtitle
      djs_oplot, pmu50, pvroffset, psym=8, symsize=csize, color='red'
      plot_running_median,  real_rmu50, real_offset, !X.CRANGE+[0.,-1.], 0.3, 100, color='black'
      plot_running_median,  pmu50, pvroffset, !X.CRANGE+[0., -2.6], 0.6, 100, color='red'
   endelse
endif
   
end
;;
pro plot_for_dr8_paper, model=model

common com_compare_reruns

postfix=''
if(keyword_set(model)) then $
   postfix='.model'

if(n_tags(im) eq 0) then begin
    imfile= '/global/data/vagc-dr7/vagc2/object_sdss_imaging.fits'
    im= hogg_mrdfits(imfile, 1, nrow=28800, $
                     columns=['ra', 'dec', 'petroflux', 'petroflux_ivar', $
                              'petror50', 'petror90', 'modelflux', $
                              'modelflux_ivar', 'theta_dev', 'theta_exp'])
endif

if(n_tags(atlas) eq 0) then $
  atlas= mrdfits(getenv('DIMAGE_DIR')+'/data/atlas/sdss_atlas.fits',1)
    
spherematch, atlas.ra, atlas.dec, im.ra, im.dec, 2./3600., m1, m2

ufake= mrdfits(getenv('DIMAGE_DIR')+'/data/fake/fake_lsb_v5.6.3_u_000.fits',1)
gfake= mrdfits(getenv('DIMAGE_DIR')+'/data/fake/fake_lsb_v5.6.3_g_000.fits',1)
rfake= mrdfits(getenv('DIMAGE_DIR')+'/data/fake/fake_lsb_v5.6.3_r_000.fits',1)
ifake= mrdfits(getenv('DIMAGE_DIR')+'/data/fake/fake_lsb_v5.6.3_i_000.fits',1)
zfake= mrdfits(getenv('DIMAGE_DIR')+'/data/fake/fake_lsb_v5.6.3_z_000.fits',1)
stamps= mrdfits(getenv('DIMAGE_DIR')+'/data/fake/fake_stamps_info_003.fits',1)
pobj= mrdfits(getenv('DIMAGE_DIR')+'/data/fake/fake_photo_003.fits',1)
pobjv56= mrdfits(getenv('DIMAGE_DIR')+'/data/skytest/pobj_fake_lsb_v5.6.3.fits',1)

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

k_print, filename=getenv('DIMAGE_DIR')+'/tex/dr8_offsets_fakedist'+postfix+'.ps'

ii= where(atlas.petroth50[2] gt 1. and atlas.petroflux[2] gt 1., nii)
help,ii
hogg_scatterplot, alog10(atlas[ii].petroth50[2]), $
                  22.5-2.5*alog10(atlas[ii].petroflux[2]), $
  xtitle=textoidl('!6log_{10} !8r_{50}!6 (arcsec)!6'), $
  ytitle=textoidl('!8m_r!6'), xra=[0.1, 1.9], $
  yra=[10.1, 17.7], /internal, exp=0.5, xnpix=35, $
  ynpix=35, levels=[0.5, 0.75, 0.9, 0.95, 0.99]
ii= where(pobjv56.petroth50[2] gt 1. and pobjv56.petroflux[2] gt 1., nii)
hogg_usersym, 10, /fill
djs_oplot, alog10(pobjv56[ii].petroth50[2]), $
           22.5-2.5*alog10(pobjv56[ii].petroflux[2]), color='red', $
           symsize=0.3, psym=8

k_end_print

k_print, filename=getenv('DIMAGE_DIR')+'/tex/dr8_offsets_ronly'+postfix+'.ps'

!P.MULTI=[2,1,2]
!Y.MARGIN=0

hogg_usersym, 10, /fill

ii= where(pobj.petroth50[2] gt 1. and pobj.petroflux[2] gt 1. and $
          rfake.r50 gt 0., nii)
r50c= stamps[ii].r50*0.396*sqrt(stamps[ii].axisratio)
r50= rfake[ii].r50*0.396
delr= alog10(pobj[ii].petroth50[2]/r50)
djs_plot, alog10(r50c), delr, psym=8, color='red', xra=alog10([3.5, 119.]), $
          /left, symsize=0.2, ytitle='!6\Delta(log_{10}!8r_{50})!6', $
          yra=[-0.95, 0.1]

ii= where(pobjv56.petroth50[2] gt 1. and pobjv56.petroflux[2] gt 1. and $
          rfake.r50 gt 0., nii)
r50v56c= stamps[ii].r50*0.396*sqrt(stamps[ii].axisratio)
r50v56= rfake[ii].r50*0.396
delrv56= alog10(pobjv56[ii].petroth50[2]/r50v56)
djs_oplot, alog10(r50v56c), delrv56, psym=8, color='blue', symsize=0.2

plot_running_median, alog10(r50c),delr, !X.CRANGE, 0.3, 100, color='red'
plot_running_median, alog10(r50v56c),delrv56, !X.CRANGE, 0.3, 100, color='blue'

plot_band, stamps, 'r', pobj, pobjv56, rfake, rfake, 2, /bottom, /nomu, /nomag, $
           yra=[-0.29, 1.89]

k_end_print

k_print, filename=getenv('DIMAGE_DIR')+'/tex/dr8_offsets'+postfix+'.ps'

!P.MULTI=[15,3,5]
!X.MARGIN=0
!Y.MARGIN=0

hogg_usersym, 10, /fill

plot_band, stamps, 'u', pobj, pobjv56, rfake, ufake, 0, /top
plot_band, stamps, 'g', pobj, pobjv56, rfake, gfake, 1
plot_band, stamps, 'r', pobj, pobjv56, rfake, rfake, 2
plot_band, stamps, 'i', pobj, pobjv56, rfake, ifake, 3
plot_band, stamps, 'z', pobj, pobjv56, rfake, zfake, 4, /bottom

k_end_print

k_print, filename=getenv('DIMAGE_DIR')+'/tex/dr8_offsets_diff'+postfix+'.ps'

!P.MULTI=[15,3,5]
!X.MARGIN=0
!Y.MARGIN=0

hogg_usersym, 10, /fill

plot_band, stamps, 'u', pobj, pobjv56, rfake, ufake, 0, /top, /diff
plot_band, stamps, 'g', pobj, pobjv56, rfake, gfake, 1, /diff
plot_band, stamps, 'r', pobj, pobjv56, rfake, rfake, 2, /diff
plot_band, stamps, 'i', pobj, pobjv56, rfake, ifake, 3, /diff
plot_band, stamps, 'z', pobj, pobjv56, rfake, zfake, 4, /bottom, /diff

k_end_print

end
