;+
; NAME:
;   dexplore
; PURPOSE:
;   interactive explorer of dimage results
; CALLING SEQUENCE:
;   dexplore [, base ]
; OPTIONAL INPUTS:
;   base - base name for output (otherwise uses current dir name)
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro dexplore, base, lsb=lsb, twomass=twomass, eyeball_name=eyeball_name, $
              hidestars=hidestars, cen=cen, nogalex=nogalex, $
              ra=ra, dec=dec, next=next, previous=previous, finish=finish, $
              wise=wise, _EXTRA=_extra_for_detect

if(NOT keyword_set(base)) then begin
    spawn, 'pwd', cwd
    words=strsplit(cwd[0], '/',/extr)
    base=words[n_elements(words)-1]
endif

icen=-1L
if(keyword_set(cen)) then begin
    pim=gz_mrdfits(base+'-pimage.fits', /silent)
    if(keyword_set(pim)) then begin
        pnx=(size(pim, /dim))[0]
        pny=(size(pim, /dim))[1]
        icen= pim[pnx/2L, pny/2L]
    endif
endif

images=base+'-'+['u', 'g', 'r', 'i', 'z', 'nd', 'fd']+'.fits.gz' 
if(keyword_set(nogalex)) then $
  images=base+'-'+['u', 'g', 'r', 'i', 'z']+'.fits.gz' 
if(keyword_set(twomass)) then $
  images=[images, base+'-'+['J', 'H', 'K']+'.fits.gz' ]
if(keyword_set(wise)) then $
  images=[images, base+'-'+['w1', 'w2', 'w3', 'w4']+'.fits.gz' ]

dexplore_widget, base, images, lsb=lsb, twomass=twomass, wise=wise, $
  eyeball_name=eyeball_name, hidestars=hidestars, parent=icen, $
  nogalex=nogalex, cen=cen, ra=ra, dec=dec, next=next, $
  previous=previous, finish=finish, _EXTRA=_extra_for_detect

end
;------------------------------------------------------------------------------
