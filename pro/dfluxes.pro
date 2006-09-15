;+
; NAME:
;   dfluxes
; PURPOSE:
;   get pixel fluxes of children, given weights and templates
; CALLING SEQUENCE:
;   dfluxes, image, templates, weights, xcen, ycen, children= [, sigma= ]
; INPUTS:
;   image - [nx, ny] input image
;   templates - [nx, ny, N] templates 
;   weights - [N] weights of templates 
;   xcen, ycen - [N] centers of templates 
; OPTIONAL INPUTS;
;   sigma - error level of image
; OUTPUTS:
;   children - [nx, ny, N] resulting children
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU, based on RHL deblend
;-
;------------------------------------------------------------------------------
pro dfluxes, image, templates, weights, xcen, ycen, children=children, $
             sigma=sigma

if(NOT keyword_set(sigma)) then sigma=dsigma(image, sp=5)

nx=(size(image,/dim))[0]
ny=(size(image,/dim))[1]
nt=n_elements(templates)/nx/ny
children=fltarr(nx,ny, nt)

soname=filepath('libdimage.'+idlutils_so_ext(), $
                root_dir=getenv('DIMAGE_DIR'), subdirectory='lib')

retval=call_external(soname, 'idl_dfluxes', float(image), $
                     float(templates), float(weights), $
                     long(nx), long(ny), $
                     float(xcen), float(ycen), $
                     long(nt), float(children), $
                     float(sigma))

end
;------------------------------------------------------------------------------
