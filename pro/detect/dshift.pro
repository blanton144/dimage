;+
; NAME:
;   dshift
; PURPOSE:
;   shift in 2D with chosen interpolation
; CALLING SEQUENCE:
;   newimage= dshift(image, xshift, yshift [, kernel=])
; INPUTS:
;   image - [nx, ny] input image
;   xshift, yshift, - shift in x and y
; OUTPUTS:
;   newimage - [nx, ny] shifted image
; REVISION HISTORY:
;   11-Oct-2009  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
function dshift, image, dx, dy, kernel=kernel

if(NOT keyword_set(kernel)) then $
  kernel='dampsinc'

if((size(image))[0] eq 1) then begin
    ny=1
    nx=(size(image,/dim))[0]
endif else begin
    nx=(size(image,/dim))[0]
    ny=(size(image,/dim))[1]
endelse

; Set source object name
soname=filepath('libdimage.'+idlutils_so_ext(), $
                root_dir=getenv('DIMAGE_DIR'), subdirectory='lib')

newimage=image
case kernel of
    'linear': ktype=0L
    'puresinc': ktype=1L
    'dampsinc': ktype=2L
    'bicubic': ktype=3L
    else: message, 'No such kernel type '+string(kernel)+' !!!'
endcase
retval=call_external(soname, 'idl_dshift', float(newimage), $
                     long(nx), long(ny), long(ktype), $
                     float(dx), float(dy))

return, newimage

end
;------------------------------------------------------------------------------
