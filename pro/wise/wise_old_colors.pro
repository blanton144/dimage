;+
; NAME: 
;   wise_old_colors
; PURPOSE: 
;   Determine colors in SDSS-WISE for old galaxies
; CALLING SEQUENCE: 
;   wise_old_colors, absmag
; OUTPUTS:
;   absmag - [9] ugriz1234 absolute magnitudes
; REVISION HISTORY:
;   11-Apr-2011 MRB NYU
;-
pro wise_old_colors, lambda_eff, absmag

ancient= k_im_read_bc03(age=13.,met=3, /vac)
lambda= k_lambda_to_edges(ancient.wave)

filterlist= ['sdss_'+['u','g','r','i','z']+'0.par', $
             'wise_w'+['1','2','3','4']+'.par']
maggies= k_project_filters(lambda, ancient.flux, filterlist=filterlist)

absmag= -2.5*alog10(maggies)
lambda_eff= k_lambda_eff(filterlist=filterlist)


end 
