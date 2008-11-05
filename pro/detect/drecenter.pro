;+
; NAME:
;   drecenter
; PURPOSE:
;   find a better galaxy center using symmetric templates
; CALLING SEQUENCE:
;   drecenter, image, xc, yc
; COMMENTS:
;   Iterates starting with initial center to find one that maximizes
;   flux associated with a symmetric template. 
; REVISION HISTORY:
;   11-Aug-2008  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
function drecenter_func, image, ivar, x, y

dtemplates, image, x, y, template=template
scale= total(template*image*ivar)/total(template*template*ivar)

dtemplates, image, x, y, template=template

return, scale

end
;
pro drecenter, image, ivar, xc, yc, box=box

if(NOT keyword_set(box)) then box=6L

nx=(size(image, /dim))[0]
ny=(size(image, /dim))[1]

if(n_elements(xc) eq 0 OR n_elements(yc) eq 0) then begin
    dpeaks, image, xcen=xc, ycen=yc, maxnpeaks=1L, /refine
endif

xchange=1L
ychange=1L
xcurr= long(xc[0])
ycurr= long(yc[0])
while(xchange ne 0L OR ychange ne 0L) do begin 
    xst= (xcurr-box)>0L
    yst= (ycurr-box)>0L
    xnd= (xcurr+box)<(nx-1L)
    ynd= (ycurr+box)<(ny-1L)
    scalearray= fltarr(xnd-xst+1L, ynd-yst+1L)
    for i=xst, xnd do begin
        for j=yst, ynd do begin
            scalearray[i-xst, j-yst]= drecenter_func(image,ivar,i,j)
        endfor
    endfor
    maxscale= max(scalearray, imaxscale)
    xnew= xst+ (imaxscale mod (xnd-xst+1L))
    ynew= yst+ (imaxscale / (xnd-xst+1L))
    xchange=xnew-xcurr
    ychange=ynew-ycurr
    xcurr= xnew
    ycurr= ynew
endwhile

drefine, image, xcurr, ycurr, xr= xc, yr= yc

end
;------------------------------------------------------------------------------
