;+
; NAME:
;   dmsmooth
; PURPOSE:
;   median smooth 
; CALLING SEQUENCE:
;   smooth= dmsmooth(image, sigma)
; INPUTS:
;   image - [nx, ny] input image
;   box - box size for smooth
; OUTPUTS:
;   smooth - [nx, ny] smooth image
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
function dmsmooth, image, box

nx=(size(image,/dim))[0]
ny=(size(image,/dim))[1]

; Set source object name
soname=filepath('libdimage.'+idlutils_so_ext(), $
                root_dir=getenv('DIMAGE_DIR'), subdirectory='lib')

smooth=fltarr(nx,ny)
retval=call_external(soname, 'idl_dmsmooth', float(image), $
                     long(nx), long(ny), long(box), float(smooth))

return, smooth

end
;------------------------------------------------------------------------------
