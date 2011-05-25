pro plot_wise_mir_umr

atlas= read_atlas()
rootdir=atlas_rootdir(sample=sample)
absmag= mrdfits(rootdir+'/wise-cat/atlas_wise_absmag.fits',1)
absmag= absmag[atlas.nsaid]

indx= mrdfits('~/dimage/data/atlas/atlas_indx.fits')
twomass= mrdfits('~/dimage/data/atlas/atlas_2mass_xsc.fits',1)
twomass= twomass[indx[atlas.nsaid]]

kabs= twomass.k_m_ext- lf_distmod(atlas.zdist)

galex=mrdfits('~ioannis/home/research/data/vagc-dr7/vagc2/object_galex_gr6.fits.gz',1)
spherematch, galex.ra, galex.dec, atlas.ra, atlas.dec, 3./3600., m1, m2

nabs= galex[m1].nuv_mag- lf_distmod(atlas[m2].zdist)

nmr= nabs- absmag[m2].absmag[2]
rmk= absmag[m2].absmag[2]- kabs[m2]

mir= absmag[m2].absmag[5]-absmag[m2].absmag[7]

ii= where(galex[m1].nuv_mag gt 0. and mir ne 0. and $
          absmag[m2].absmag[5] lt 0. and absmag[m2].absmag[7]  lt 0. and $
          absmag[m2].absmag[2] gt -23. and absmag[m2].absmag[2] lt -18.5)

k_print, filename='wise_mir_nmr.ps', xsize=13., ysize=13.

hogg_usersym, 10, /fill
djs_plot, xra=[-2.8, 2.8], yra=[0.7, 8.7], xtitle='!8[12]-[3.4]!6', $
  ytitle='!8N-r!6', -mir[ii], nmr[ii], psym=8, symsize=0.5, $
  xcharsize=2.3, ycharsize=2.3

djs_xyouts, -2., 1.0, '!8star-forming!6', color='blue', charsize=2.0
djs_xyouts, 1., 8.3, '!8quiescent!6', color='red', charsize=2.0

k_end_print

end
