;+
; NAME:
;   twomass_convert
; PURPOSE:
;   convert twomass images to sky-subtracted versions with nice names
; CALLING SEQUENCE:
;   twomass_convert, jfile, hfile, kfile, outbase
; COMMENTS:
;   Converts all images into nmgy per pixel
;   Subtracts out a constant median value across the whole frame.
;   Creates an ivar HDU based on sigma (assuming variance scales
;     proportional to un-sky-subtacted flux)
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro twomass_convert, jfile, hfile, kfile, outbase

jim=mrdfits(jfile,0,hdr)
magzp=sxpar(hdr, 'MAGZP')
jim=jim*10.^(-0.4*(magzp-22.5))
med_jim=median(jim)
sigma=dsigma(jim, sp=10)
jiv=med_jim/sigma^2/jim
jim=jim-med_jim
mwrfits, jim, outbase+'-J.fits', hdr, /create
mwrfits, jiv, outbase+'-J.fits'
spawn, 'gzip -vf '+outbase+'-J.fits'


him=mrdfits(hfile,0,hdr)
magzp=sxpar(hdr, 'MAGZP')
him=him*10.^(-0.4*(magzp-22.5))
med_him=median(him)
sigma=dsigma(him, sp=10)
hiv=med_him/sigma^2/him
him=him-med_him
mwrfits, him, outbase+'-H.fits', hdr, /create
mwrfits, hiv, outbase+'-H.fits'
spawn, 'gzip -vf '+outbase+'-H.fits'


kim=mrdfits(kfile,0,hdr)
magzp=sxpar(hdr, 'MAGZP')
kim=kim*10.^(-0.4*(magzp-22.5))
med_kim=median(kim)
sigma=dsigma(kim, sp=10)
kiv=med_kim/sigma^2/kim
kim=kim-med_kim
mwrfits, kim, outbase+'-K.fits', hdr, /create
mwrfits, kiv, outbase+'-K.fits'
spawn, 'gzip -vf '+outbase+'-K.fits'


end
;------------------------------------------------------------------------------
