;+
; NAME:
;   dfind
; PURPOSE:
;   identify objects in a boolean image
; CALLING SEQUENCE:
;   dfind, image [, object= ]
; INPUTS:
;   image - [nx, ny] input image
; OUTPUTS:
;   object - [nx, ny] -1 where no object, object # otherwise
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro dfind, image, object=object

nx=(size(image,/dim))[0]
ny=(size(image,/dim))[1]

; Set source object name
soname=filepath('libdimage.'+idlutils_so_ext(), $
                root_dir=getenv('DIMAGE_DIR'), subdirectory='lib')

object=lonarr(nx,ny)
retval=call_external(soname, 'idl_dfind', float(image), $
                     long(nx), long(ny), long(object))

end
;------------------------------------------------------------------------------
