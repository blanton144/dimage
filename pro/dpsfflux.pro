;+
; NAME:
;   dpsfflux
; PURPOSE:
;   calculate a "psf" flux
; CALLING SEQUENCE:
;   dpsfflux, image, x, y [ ,gauss=, flux =]
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro dpsfflux, image, x, y, gauss=gauss, flux=flux

nx=(size(image,/dim))[0]
ny=(size(image,/dim))[1]

flux=fltarr(n_elements(x))
for i=0L, n_elements(x)-1L do begin
    xst=(long(x[i])-long(gauss*5.))>0L
    yst=(long(y[i])-long(gauss*5.))>0L
    xnd=(long(x[i])+long(gauss*5.))<(nx-1l)
    ynd=(long(y[i])+long(gauss*5.))<(ny-1l)
    nxcut=xnd-xst+1L
    nycut=ynd-yst+1L
    cut=image[xst:xnd, yst:ynd]
    xx=findgen(nxcut)#replicate(1., nycut)
    yy=replicate(1., nxcut)#findgen(nycut)
    xccut=x[i]-xst
    yccut=y[i]-yst
    psf=exp(-0.5*((xx-xccut)^2+(yy-yccut)^2)/gauss^2)
    psf=psf/total(psf)
    flux[i]=total(cut*psf)/total(psf*psf)
endfor

end
;------------------------------------------------------------------------------
