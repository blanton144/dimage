pro plot_wise_mir_umr

atlas= read_nsa()
rootdir=atlas_rootdir(cdir=cdir)
absmag= mrdfits(rootdir+'/misc/wise-cat/atlas_wise_absmag.fits',1)
absmag= absmag[atlas.nsaid]

indx= mrdfits(cdir+'/atlas_indx.fits')
twomass= mrdfits(cdir+'/atlas_2mass_xsc.fits',1)
twomass= twomass[indx[atlas.nsaid]]

kabs= twomass.k_m_ext- lf_distmod(atlas.zdist)

igd= where(atlas.amivar[1] gt 0., ngd)

nmr= atlas[igd].absmag[1]- atlas[igd].absmag[4]
rmk= atlas[igd].absmag[4]- kabs[igd]

mir= absmag[igd].absmag[5]-absmag[igd].absmag[7]

okmir= mir ne 0. and $
       absmag[igd].absmag[5] lt 0. and absmag[igd].absmag[7]  lt 0. and $
       atlas[igd].absmag[4] gt -23. and atlas[igd].absmag[4] lt -17.5

save

ff= fltarr(4)
ired= where(abs(nmr-5.8) lt 0.4 and abs(mir+1.9) lt 0.4 and okmir ne 0)
ff[0]= 10.^(-0.4*median(nmr[ired]))  ;; near
ff[1]= 1. ;; r
ff[2]= 10.^(-0.4*median(absmag[igd[ired]].absmag[5]-atlas[igd[ired]].absmag[4])) ;; 3.4
ff[3]= 10.^(-0.4*median(absmag[igd[ired]].absmag[7]-atlas[igd[ired]].absmag[4])) ;; 12
iv= fltarr(4)+1.
iv[0]=1000.
iv[2]=0.1
iv[3]=0.1

kcorrect, ff, iv, 0.001, kc, filterlist=['galex_NUV.par', 'sdss_r0.par', $
                                         'wise_w1.par', 'wise_w4.par'], $
          coeffs=coeffs, vmatrix=vmatrix, lambda=lambda, rmaggies=rff

ii= where(okmir)

k_print, filename='wise_mir_nmr.ps', xsize=13., ysize=13.

hogg_usersym, 10, /fill
djs_plot, xra=[-2.8, 2.8], yra=[0.7, 8.7], xtitle='!8[12]-[3.4]!6', $
  ytitle='!8N-r!6', -mir[ii], nmr[ii], psym=8, symsize=0.5, $
  xcharsize=2.3, ycharsize=2.3

djs_xyouts, -2., 1.0, '!8star-forming!6', color='blue', charsize=3.0, th=2
djs_xyouts, 1., 8.3, '!8quiescent!6', color='red', charsize=3.0, th=2

k_end_print

end
