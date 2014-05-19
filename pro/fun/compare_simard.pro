;; Code to plot comparisons with Simard et al. 2011 results.
pro compare_simard

nsa=read_nsa() 
sim= mrdfits(getenv('DIMAGE_DIR')+'/data/cats/simard-sdss-sn4.fits',1)

nsagd= (nsa.isdss ge 0 and $
        nsa.plate lt 3000 and $
        nsa.petroflux[4] gt 250. and $
        nsa.petroth50 gt 0. and $
        nsa.sersic_th50 gt 0.)
insagd= where(nsagd, nnsagd)
rpetro_nsa= 22.5-2.5*alog10(nsa[insagd].petroflux[4])
rsersic_nsa= 22.5-2.5*alog10(nsa[insagd].sersicflux[4])
r50s_nsa= nsa[insagd].sersic_th50
r50p_nsa= nsa[insagd].petroth50
n_nsa= nsa[insagd].sersic_n

simgd= (sim.rhlr gt 0. and $
        sim.rg2d gt 0. and $
        sim.scale gt 0.)
isimgd= where(simgd, nsimgd)
r_sim= sim[isimgd].rg2d
r50_sim= sim[isimgd].rhlr/sim[isimgd].scale

spherematch, nsa[insagd].ra, nsa[insagd].dec, $
  sim[isimgd]._ra, sim[isimgd]._de, 2./3600., m1, m2

;; Make completeness as a function of magnitude plot
binsize=0.1
minmag=10.
maxmag=16.8
nsahist= histogram(rpetro_nsa, min=minmag, max=maxmag, binsize=binsize)
simhist= histogram(rpetro_nsa[m1], min=minmag, max=maxmag, binsize=binsize)
maghist= minmag+binsize*(findgen(n_elements(nsahist))+0.5)
filebase=getenv('DIMAGE_DIR')+'/tex/simard-completeness'
k_print, filename=filebase+'.ps'
djs_plot, maghist, alog10(nsahist), psym=10, th=4, xra=[minmag, maxmag], $
  yra=alog10(minmax(nsahist>1.))+[-0.05, 0.15], xtitle='m_r (Petro, NSA)', $
  ytitle='log_{10} N'
djs_oplot, maghist, alog10(simhist), psym=10, th=4, color='red'
djs_xyouts, 10.2, 4.0, 'NSA galaxies, m_r<16.5 ('+strtrim(string(nnsagd),2)+')'
djs_xyouts, 10.2, 3.85, 'NSA matches to Simard galaxies ('+ $
  strtrim(string(n_elements(m1)),2)+')', color='red'
k_end_print
spawn, /nosh, ['convert', filebase+'.ps', filebase+'.png']

;; Make Sersic flux comparisons
filebase=getenv('DIMAGE_DIR')+'/tex/simard-sersic-flux'
k_print, filename=filebase+'.ps'
!P.MULTI=[3,1,3]
!Y.MARGIN=5
!X.OMARGIN=[20, 0]
!Y.OMARGIN=[4, 0]
yra=[-0.6, 0.4]
charsize=2.5
hogg_scatterplot, r_sim[m2], rsersic_nsa[m1]-r_sim[m2], /cond, $
  quantiles=quantiles, exp=0.25, xra=[13.8, 16.7], yra=yra, $
  xtitle=textoidl('m_r (GIM2D)'), ytitle=textoidl('m_r :: Sersic - GIM2D'), $
  xcharsize=charsize, ycharsize=charsize
hogg_scatterplot, alog10(r50_sim[m2]), rsersic_nsa[m1]-r_sim[m2], /cond, $
  quantiles=quantiles, exp=0.25, xra=[0.1, 1.5], yra=yra, $
  xtitle=textoidl('log_{10}(r_{50}) (GIM2D)'), $
  ytitle=textoidl('m_r :: Sersic - GIM2D'), $
  xcharsize=charsize, ycharsize=charsize
hogg_scatterplot, n_nsa[m1], rsersic_nsa[m1]-r_sim[m2], /cond, $
  quantiles=quantiles, exp=0.25, xra=[0.3, 6.1], yra=yra, $
  xtitle='n (Sersic)', ytitle=textoidl('m_r :: Sersic - GIM2D'), $
  xcharsize=charsize, ycharsize=charsize
k_end_print
spawn, /nosh, ['convert', filebase+'.ps', filebase+'.png']

;; Make Petro flux comparisons
filebase=getenv('DIMAGE_DIR')+'/tex/simard-petro-flux'
k_print, filename=filebase+'.ps'
!P.MULTI=[3,1,3]
!Y.MARGIN=5
!X.OMARGIN=[20, 0]
!Y.OMARGIN=[4, 0]
yra=[-0.6, 0.4]
charsize=2.5
hogg_scatterplot, r_sim[m2], rpetro_nsa[m1]-r_sim[m2], /cond, $
  quantiles=quantiles, exp=0.25, xra=[13.8, 16.7], yra=yra, $
  xtitle=textoidl('m_r (GIM2D)'), ytitle=textoidl('m_r :: Petro - GIM2D'), $
  xcharsize=charsize, ycharsize=charsize
hogg_scatterplot, alog10(r50_sim[m2]), rpetro_nsa[m1]-r_sim[m2], /cond, $
  quantiles=quantiles, exp=0.25, xra=[0.1, 1.5], yra=yra, $
  xtitle=textoidl('log_{10}(r_{50}) (GIM2D)'), $
  ytitle=textoidl('m_r :: Petro - GIM2D'), $
  xcharsize=charsize, ycharsize=charsize
hogg_scatterplot, n_nsa[m1], rpetro_nsa[m1]-r_sim[m2], /cond, $
  quantiles=quantiles, exp=0.25, xra=[0.3, 6.1], yra=yra, $
  xtitle='n (Sersic)', ytitle=textoidl('m_r :: Petro - GIM2D'), $
  xcharsize=charsize, ycharsize=charsize
k_end_print
spawn, /nosh, ['convert', filebase+'.ps', filebase+'.png']

;; Make Sersic size comparisons
filebase=getenv('DIMAGE_DIR')+'/tex/simard-sersic-r50'
k_print, filename=filebase+'.ps'
!P.MULTI=[3,1,3]
!Y.MARGIN=5
!X.OMARGIN=[20, 0]
!Y.OMARGIN=[4, 0]
yra=[-1.2, 1.2]
charsize=2.5
hogg_scatterplot, r_sim[m2], alog(r50s_nsa[m1]/r50_sim[m2]), /cond, $
  quantiles=quantiles, exp=0.25, xra=[13.8, 16.7], yra=yra, $
  xtitle=textoidl('m_r (GIM2D)'), $
  ytitle=textoidl('r_{50} :: ln(Sersic/GIM2D)'), $
  xcharsize=charsize, ycharsize=charsize
hogg_scatterplot, alog10(r50_sim[m2]), alog(r50s_nsa[m1]/r50_sim[m2]), /cond, $
  quantiles=quantiles, exp=0.25, xra=[0.1, 1.5], yra=yra, $
  xtitle=textoidl('log_{10}(r_{50}) (GIM2D)'), $
  ytitle=textoidl('r_{50} :: ln(Sersic/GIM2D)'), $
  xcharsize=charsize, ycharsize=charsize
hogg_scatterplot, n_nsa[m1], alog(r50s_nsa[m1]/r50_sim[m2]), /cond, $
  quantiles=quantiles, exp=0.25, xra=[0.3, 6.1], yra=yra, $
  xtitle='n (Sersic)', $
  ytitle=textoidl('r_{50} :: ln(Sersic/GIM2D)'), $
  xcharsize=charsize, ycharsize=charsize
k_end_print
spawn, /nosh, ['convert', filebase+'.ps', filebase+'.png']

;; Make Sersic size with n=6 shown
filebase=getenv('DIMAGE_DIR')+'/tex/simard-sersic-r50-n6'
k_print, filename=filebase+'.ps'
!P.MULTI=[3,1,3]
!Y.MARGIN=5
!X.OMARGIN=[20, 0]
!Y.OMARGIN=[4, 0]
yra=[-1.2, 1.2]
charsize=2.5
hogg_scatterplot, r_sim[m2], alog(r50s_nsa[m1]/r50_sim[m2]), /cond, $
  quantiles=quantiles, exp=0.25, xra=[13.8, 16.7], yra=yra, $
  xtitle=textoidl('m_r (GIM2D)'), $
  ytitle=textoidl('r_{50} :: ln(Sersic/GIM2D)'), $
  xcharsize=charsize, ycharsize=charsize
in6=where(n_nsa[m1] gt 5.999)
djs_oplot, (r_sim[m2[in6]]), $
  alog(r50s_nsa[m1[in6]]/r50_sim[m2[in6]]), psym=3, $
  color='red'
hogg_scatterplot, alog10(r50_sim[m2]), alog(r50s_nsa[m1]/r50_sim[m2]), /cond, $
  quantiles=quantiles, exp=0.25, xra=[0.1, 1.5], yra=yra, $
  xtitle=textoidl('log_{10}(r_{50}) (GIM2D)'), $
  ytitle=textoidl('r_{50} :: ln(Sersic/GIM2D)'), $
  xcharsize=charsize, ycharsize=charsize
in6=where(n_nsa[m1] gt 5.999)
djs_oplot, alog10(r50_sim[m2[in6]]), $
  alog(r50s_nsa[m1[in6]]/r50_sim[m2[in6]]), psym=3, $
  color='red'
hogg_scatterplot, n_nsa[m1], alog(r50s_nsa[m1]/r50_sim[m2]), /cond, $
  quantiles=quantiles, exp=0.25, xra=[0.3, 6.1], yra=yra, $
  xtitle='n (Sersic)', $
  ytitle=textoidl('r_{50} :: ln(Sersic/GIM2D)'), $
  xcharsize=charsize, ycharsize=charsize
in6=where(n_nsa[m1] gt 5.999)
djs_oplot, (n_nsa[m1[in6]]), $
  alog(r50s_nsa[m1[in6]]/r50_sim[m2[in6]]), psym=3, $
  color='red'
k_end_print
spawn, /nosh, ['convert', filebase+'.ps', filebase+'.png']

;; Make Petro size comparisons
filebase=getenv('DIMAGE_DIR')+'/tex/simard-petro-r50'
k_print, filename=filebase+'.ps'
!P.MULTI=[3,1,3]
!Y.MARGIN=5
!X.OMARGIN=[20, 0]
!Y.OMARGIN=[4, 0]
yra=[-1.2, 1.2]
charsize=2.5
hogg_scatterplot, r_sim[m2], alog(r50p_nsa[m1]/r50_sim[m2]), /cond, $
  quantiles=quantiles, exp=0.25, xra=[13.8, 16.7], yra=yra, $
  xtitle=textoidl('m_r (GIM2D)'), $
  ytitle=textoidl('r_{50} :: ln(Petro/GIM2D)'), $
  xcharsize=charsize, ycharsize=charsize
hogg_scatterplot, alog10(r50_sim[m2]), alog(r50p_nsa[m1]/r50_sim[m2]), /cond, $
  quantiles=quantiles, exp=0.25, xra=[0.1, 1.5], yra=yra, $
  xtitle=textoidl('log_{10}(r_{50}) (GIM2D)'), $
  ytitle=textoidl('r_{50} :: ln(Petro/GIM2D)'), $
  xcharsize=charsize, ycharsize=charsize
hogg_scatterplot, n_nsa[m1], alog(r50p_nsa[m1]/r50_sim[m2]), /cond, $
  quantiles=quantiles, exp=0.25, xra=[0.3, 6.1], yra=yra, $
  xtitle='n (Sersic)', $
  ytitle=textoidl('r_{50} :: ln(Petro/GIM2D)'), $
  xcharsize=charsize, ycharsize=charsize
k_end_print
spawn, /nosh, ['convert', filebase+'.ps', filebase+'.png']


end
