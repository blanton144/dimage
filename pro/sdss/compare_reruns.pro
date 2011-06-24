;+
; NAME:
;   compare_reruns
; PURPOSE:
;   Compare 301 fluxes with 137 fluxes from DR7
; CALLING SEQUENCE:
;   compare_reruns
; COMMENTS:
;   Takes data from:
;     atlas_rootdir/catalogs/sdss_atlas.fits
;     /global/data/vagc-dr7/vagc2/object_sdss_imaging.fits
; REVISION HISTORY:
;   2-Dec-2010  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro compare_reruns, version=version

common com_compare_reruns, atlas, im

rootdir=atlas_rootdir(version=version)

if(n_tags(im) eq 0) then begin
    imfile= '/global/data/vagc-dr7/vagc2/object_sdss_imaging.fits'
    im= hogg_mrdfits(imfile, 1, nrow=28800, $
                     columns=['ra', 'dec', 'petroflux', 'petroflux_ivar', $
                              'petror50', 'petror90', 'modelflux', $
                              'modelflux_ivar', 'theta_dev', 'theta_exp'])
endif

if(n_tags(atlas) eq 0) then $
  atlas= mrdfits(rootdir+'/catalogs/sdss_atlas.fits',1)
    
spherematch, atlas.ra, atlas.dec, im.ra, im.dec, 2./3600., m1, m2

irkeep= where(atlas[m1].petroth50[2] gt 0.8 AND $
              im[m2].petror50[2] gt 1. AND $
              atlas[m1].petroflux[2] gt 0. AND $
              im[m2].petroflux[2] gt 0., nrkeep)

r50= atlas[m1[irkeep]].petroth50[2]
rflux_v5_6= atlas[m1[irkeep]].petroflux[2]
rflux_v5_4= im[m2[irkeep]].petroflux[2]

hogg_usersym, 10, /fill

k_print, filename='compare_reruns.ps'

hogg_scatterplot, alog10(r50), -2.5*alog10(rflux_v5_4/rflux_v5_6), $
  xtitle=textoidl('!8r_{50} !6(arcsec)'), $
  ytitle='!8m_r(!6v5_4!8)-m_r(!6v5_4!8)!6', $
  xra=[-0.01, 1.59], yra=[-0.45, 1.05], /conditional, xnpix=35, $
  quantiles=[0.01, 0.05, 0.25, 0.5, 0.75, 0.95, 0.99], ynpix=35

k_end_print

end
