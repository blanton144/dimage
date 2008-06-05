;+
; NAME:
;   dfloodfill
; PURPOSE:
;   starting at x,y, flood identical, connected pixels to same value
; CALLING SEQUENCE:
;   newim= dfloodfill(im, x, y, newval [, xst=, yst=, xnd=, ynd=])
; INPUTS:
;   im- [nx, ny] input image
;   x, y - pixel value to start flood at
;   newval - value to set new pixels to
; OPTIONAL INPUTS:
;   xst, xnd, yst, ynd - boundaries of floodable region 
;                        [defaults of 0, nx-1, 0, ny-1, respectively]
; OUTPUTS:
;   newim - [nx, ny] output image with flooded pixels replaced with newval
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
function dfloodfill, im, x, y, newval, xst=xst, xnd=xnd, yst=yst, ynd=ynd

nx=(size(im,/dim))[0]
ny=(size(im,/dim))[1]

if(NOT keyword_set(xst)) then xst=0L
if(NOT keyword_set(xnd)) then xnd=nx-1L
if(NOT keyword_set(yst)) then yst=0L
if(NOT keyword_set(ynd)) then ynd=ny-1L

xst=(xst>0L)<(nx-1L)
xnd=(xnd>0L)<(nx-1L)
yst=(yst>0L)<(ny-1L)
ynd=(ynd>0L)<(ny-1L)

newim=long(im)
soname=filepath('libdimage.'+idlutils_so_ext(), $
                root_dir=getenv('DIMAGE_DIR'), subdirectory='lib')

retval=call_external(soname, 'idl_dfloodfill', long(newim), $
                     long(nx), long(ny), long(x), long(y), $
                     long(xst), long(xnd), long(yst), long(ynd), $
                     long(newval))

return, newim

end
;------------------------------------------------------------------------------
