;+
; NAME:
;   gather_fake_info
; REVISION HISTORY:
;   2-Aug-2010 MRB, NYU
;-
pro gather_fake_info

stamps= mrdfits(getenv('DIMAGE_DIR')+'/data/fake/fake_stamps_003.fits',1)

pars0= {ra:0.D, dec:0.D, stamp:' ', flux:0., r50:0., n:0., axisratio:0., orient:0.}
pars= replicate(pars0, n_elements(stamps))
for i=0L, n_elements(stamps)-1L do begin
   hdr= headfits(stamps[i].stamp)
   pars[i].flux= float(sxpar(hdr, 'SERSICFL'))
   pars[i].r50= float(sxpar(hdr, 'SERSICR5'))
   pars[i].n= float(sxpar(hdr, 'SERSICN'))
   pars[i].axisratio= float(sxpar(hdr, 'AXISRATI'))
   pars[i].orient= float(sxpar(hdr, 'ORIENT'))
   pars[i].ra= stamps[i].ra
   pars[i].dec= stamps[i].dec
   pars[i].stamp= stamps[i].stamp
endfor

mwrfits, pars, getenv('DIMAGE_DIR')+'/data/fake/fake_stamps_info_003.fits', /create



end
