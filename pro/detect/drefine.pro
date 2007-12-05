;+
; NAME:
;   drefine
; PURPOSE:
;   refine some approximate centers
; CALLING SEQUENCE:
;   drefine, image, xc, yc, [, box=, smooth=, xr=, yr= ]
; INPUTS:
;   image - [nx, ny] image
;   xc, yc - [N] centers to refine around
; OUTPUTS:
;   xr, yr - [N] output centers
; OPTIONAL INPUTS:
;   box - size of box to refine within (default 3)
;   smooth - sigma for gaussian smoothing (default 0, no smoothing)
; COMMENTS:
;   box sizes will be change to be odd, and >=3.
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro drefine, image, xc, yc, box=box, smooth=smooth, xr=xr, yr=yr

if(NOT keyword_set(box)) then box=3L
box=((long(box)/2L)*2L+1L)>3L

nx=(size(image,/dim))[0]
ny=(size(image,/dim))[1]

if(keyword_set(smooth)) then $
  simage=dsmooth(image, smooth) $ 
else $
  simage=image

ncen=n_elements(xc)
xr=fltarr(ncen)
yr=fltarr(ncen)

;; refine the centers
for i=0L, ncen-1L do begin

    ;; make sub-image
    xst=(long(xc[i])-box/2L) > 0L
    xnd=(long(xc[i])+box/2L) < (nx-1L)
    yst=(long(yc[i])-box/2L) > 0L
    ynd=(long(yc[i])+box/2L) < (ny-1L)
    if(xst eq 0) then xnd=(xst+box-1L)<(nx-1L)
    if(xnd eq nx-1L) then xst=(xnd-(box-1L))>0L
    if(yst eq 0) then ynd=(yst+box-1L)<(ny-1L)
    if(ynd eq ny-1L) then yst=(ynd-(box-1L))>0L
    nxs=xnd-xst+1L
    nys=ynd-yst+1L
    if(nxs ne box OR nys ne box) then $
      message, 'image smaller than box in drefine'
    subimg=simage[xst:xnd, yst:ynd]
    
    if(box gt 3L) then begin
        submax=max(subimg, imax)
        tmpx=long(imax mod nxs)
        tmpy=long(imax / nxs)
        if(tmpx eq 0) then tmpx=1L
        if(tmpx eq nxs-1L) then tmpx=nxs-2L
        if(tmpy eq 0) then tmpy=1L
        if(tmpy eq nys-1L) then tmpy=nys-2L
        subimg=subimg[tmpx-1L:tmpx+1L, tmpy-1L:tmpy+1L]
    endif else begin
        tmpx=long(xc[i])-xst
        tmpy=long(yc[i])-yst
    endelse
    
    dcen3x3, subimg, txr, tyr
    if(txr ge -0.5 and txr lt 2.5 and $
       tyr ge -0.5 and tyr lt 2.5) then begin
        tmpx=tmpx-1.+txr
        tmpy=tmpy-1.+tyr
    endif else begin
        tmpx=tmpx
        tmpy=tmpy
    endelse
    
    xr[i]=float(xst)+float(tmpx)
    yr[i]=float(yst)+float(tmpy)
endfor

end
;------------------------------------------------------------------------------
