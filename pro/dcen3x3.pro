;+
; NAME:
;   dcen3x3
; PURPOSE:
;   fit center to a 3x3 image with a peak in the center
; CALLING SEQUENCE:
;   dcen3x3, image, xcen, ycen
; INPUTS:
;   image - [3, 3] input image
; OUTPUTS:
;   xcen, ycen - fit peak (pixels run from 0-2)
; REVISION HISTORY:
;   1-Mar-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro dcen3x3, image, xcen, ycen

nx=(size(image,/dim))[0]
ny=(size(image,/dim))[1]

; Set source object name
soname=filepath('libdimage.'+idlutils_so_ext(), $
                root_dir=getenv('DIMAGE_DIR'), subdirectory='lib')

xcen=0.
ycen=0.
retval=call_external(soname, 'idl_dcen3x3', float(image), $
                     float(xcen), float(ycen))

end
;------------------------------------------------------------------------------
