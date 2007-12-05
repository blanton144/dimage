;+
; NAME:
;   dweights
; PURPOSE:
;   fit templates to image
; CALLING SEQUENCE:
;   dweights, image, invvar, templates, weights= [, /nonneg ]
; INPUTS:
;   image - [nx, ny] input image
;   invvar - [nx, ny] input image
;   templates - [nx, ny, N] centers of templates 
; OPTIONAL KEYWORDS;
;   /nonneg - use nonnegative fitting routine
; OUTPUTS:
;   weights - [N] weights assigned to each template
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU, based on RHL deblend
;-
;------------------------------------------------------------------------------
pro dweights, image, invvar, templates, weights=weights, nonneg=in_nonneg

nonneg=keyword_set(in_nonneg)

nx=(size(image,/dim))[0]
ny=(size(image,/dim))[1]
nt=n_elements(templates)/nx/ny

soname=filepath('libdimage.'+idlutils_so_ext(), $
                root_dir=getenv('DIMAGE_DIR'), subdirectory='lib')

weights=fltarr(nt)
retval=call_external(soname, 'idl_dweights', float(image), $
                     float(invvar), $
                     long(nx), long(ny), $
                     long(nt), $
                     float(templates), $
                     long(nonneg), $
                     float(weights))

end
;------------------------------------------------------------------------------
