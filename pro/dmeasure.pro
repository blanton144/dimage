;+
; NAME:
;   dmeasure
; PURPOSE:
;   measure objects in an image
; CALLING SEQUENCE:
;   dmeasure, image, invvar, object=object, measure=measure [ , small=]
; INPUTS:
;   image - [nx, ny] input image
;   invvar - [nx, ny] input image inverse variance
;   object - [nx, ny] which object each pixel corresponds to
; OPTIONAL INPUTS:
;   small - if set, only process objects with size of detected area
;           smaller than this value
; OUTPUTS:
;   measure - [N] arrays of structures with objects and properties
;                 .XST - X start of atlas
;                 .YST - Y start of atlas
;                 .XND - X end of atlas
;                 .YND - Y end of atlas
;                 .XCEN
;                 .YCEN
;                 .ATLAS - pointer to atlas arra:w
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro dmeasure, image, invvar, object=object, measure=measure, small=small

nx=(size(image,/dim))[0]
ny=(size(image,/dim))[1]

isort=sort(object)
iuniq=uniq(object[isort])
istart=iuniq[0]+1
xcen=fltarr(max(object)+1)
ycen=fltarr(max(object)+1)
xst=lonarr(max(object)+1)
yst=lonarr(max(object)+1)
xnd=lonarr(max(object)+1)
ynd=lonarr(max(object)+1)
good=lonarr(max(object)+1)
for i=1L, n_elements(iuniq)-1L do begin
    iend=iuniq[i]
    ipix=isort[istart:iend]
    ix=ipix mod nx              ;
    iy=ipix / nx;
    ixlims=minmax(ix)
    iylims=minmax(iy)
    
    mit=1
    if(keyword_set(small)) then begin
        mit= (ixlims[1]-ixlims[0] lt small AND $
              iylims[1]-iylims[0] lt small)
    endif
    if(mit gt 0) then begin
        subimg=image[ixlims[0]:ixlims[1], $
                     iylims[0]:iylims[1]]
        if(total(subimg) gt 1000) then begin
            suboim=object[ixlims[0]:ixlims[1], $
                           iylims[0]:iylims[1]]
            subinv=invvar[ixlims[0]:ixlims[1], $
                          iylims[0]:iylims[1]]
            inot=where(suboim ge 0 and suboim ne i-1 and subinv gt 0, nnot)
            sm=dsmooth(subimg, 2)
            smmax=max(sm, icen)
            xst[i-1]=ixlims[0]
            xnd[i-1]=ixlims[1]
            yst[i-1]=iylims[0]
            ynd[i-1]=iylims[1]
            xcen[i-1]=(icen mod (ixlims[1]-ixlims[0]+1))+ixlims[0]
            ycen[i-1]=(icen / (ixlims[1]-ixlims[0]+1))+iylims[0]
            good[i-1]=1
        endif
    endif
    istart=iend+1
endfor

igood=where(good, ngood)
measure=replicate({xcen:0., $
                   ycen:0., $
                   xst:0L, $
                   yst:0L, $
                   xnd:0L, $
                   ynd:0L}, ngood)
measure.xcen=xcen[igood]
measure.ycen=ycen[igood]
measure.xst=xst[igood]
measure.yst=yst[igood]
measure.xnd=xnd[igood]
measure.ynd=ynd[igood]

end
;------------------------------------------------------------------------------
