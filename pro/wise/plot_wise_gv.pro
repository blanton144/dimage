;+
; NAME: 
;   plot_wise_gv
; PURPOSE: 
;   plot WISE green valley galaxies
; CALLING SEQUENCE: 
;   plot_wise_gv
; REVISION HISTORY:
;   11-Apr-2011 MRB NYU
;-
pro plot_wise_gv

atlas= mrdfits(getenv('DIMAGE_DIR')+'/data/atlas/atlas.fits',1)
measure= mrdfits(getenv('DIMAGE_DIR')+'/data/atlas/atlas_measure.fits',1)
absmag= mrdfits('atlas_wise_absmag.fits',1)

k_print, filename='wise_cmd_mir.ps'

hogg_usersym, 10, /fill

igd= where(absmag.mag[2] gt 10. and $
           absmag.mag[2] lt 17. and $
           absmag.absmag[1] lt 0. and $
           absmag.absmag[2] lt 0. and $
           absmag.absmag[6] lt 0. and $
           absmag.absmag[7] lt 0., ngd)

absmr= absmag[igd].absmag[2]
mircolor= absmag[igd].absmag[6]-absmag[igd].absmag[7]
gmr= absmag[igd].absmag[1]-absmag[igd].absmag[2]

djs_plot, absmr, mircolor, psym=8, symsize=0.3, xti='!8M_r-5!6log_{10}h!6', $
  yti='[4.6]-[12]', xra=[-23.5,- 17.5], yra=[-0.1,4.6]

k_end_print

END 
