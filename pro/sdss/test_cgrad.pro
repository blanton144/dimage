.com dcgrad
gmeas= mrdfits(getenv('VAGC_REDUX')+'/lowz/lowz_measure_g.dr6.fits',1)
rmeas= mrdfits(getenv('VAGC_REDUX')+'/lowz/lowz_measure_r.dr6.fits',1)
imeas= mrdfits(getenv('VAGC_REDUX')+'/lowz/lowz_measure_i.dr6.fits',1)
gmeas= gmeas[0:7999]
rmeas= rmeas[0:7999]
imeas= imeas[0:7999]
lowz=lowz_read(sample='dr6')
lowz= lowz[0:7999]

cgrad=dcgrad(gmeas, imeas)
ii=where(cgrad eq cgrad and abs(cgrad) lt 1000.)
umr= lowz[ii].absmag[0]-lowz[ii].absmag[2]
 splot,umr, cgrad[ii], psym=3
