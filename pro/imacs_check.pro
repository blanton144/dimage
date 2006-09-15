;+
; NAME:
;   dimage
; PURPOSE:
;   process an image	
; CALLING SEQUENCE:
;   dimage, image, invvar [, object= ]
; INPUTS:
;   image - [nx, ny] input image
;   invvar - [nx, ny] input image inverse variance
; OPTIONAL INPUTS:
;   spsf - PSF sigma for smoothing (default is 1.5)
;   plim - limiting sigma for peak (default is 5)
; OUTPUTS:
;   object - [N] arrays of structures with objects and properties
;                 .XST - X start of atlas
;                 .YST - Y start of atlas
;                 .ATLAS - pointer to atlas arra:w
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro imacs_check, ccd

image=mrdfits('ccd0051c'+strtrim(string(ccd),2)+'.fits',/dsc)
invvar=1./image
image=(image-median(image)) > (-5.)
slits=mrdfits('ccd0050c'+strtrim(string(ccd),2)+'.fits',/dsc)

nx=(size(image,/dim))[0]
ny=(size(image,/dim))[1]

dobjects, image, invvar, object=oimage

isort=sort(oimage)
iuniq=uniq(oimage[isort])
istart=iuniq[0]+1
xcen=fltarr(max(oimage)+1)
ycen=fltarr(max(oimage)+1)
good=lonarr(max(oimage)+1)
for i=1L, n_elements(iuniq)-1L do begin
    iend=iuniq[i]
    ipix=isort[istart:iend]
    ix=ipix mod nx              ;
    iy=ipix / nx;
    ixlims=minmax(ix)
    iylims=minmax(iy)
    
    if(ixlims[0] gt 200 and ixlims[1] lt 1800 and $
       iylims[0] gt 200 and iylims[1] lt 2900 and $
       ixlims[1]-ixlims[0] lt 30 AND $
       iylims[1]-iylims[0] lt 30) then begin
        subimg=image[ixlims[0]:ixlims[1], $
                     iylims[0]:iylims[1]]
        if(total(subimg) gt 1000) then begin
            suboim=oimage[ixlims[0]:ixlims[1], $
                          iylims[0]:iylims[1]]
            subinv=invvar[ixlims[0]:ixlims[1], $
                          iylims[0]:iylims[1]]
            inot=where(suboim ge 0 and suboim ne i-1 and subinv gt 0, nnot)
            ;;if(nnot gt 0) then $
              ;;subimg[inot]=randomn(seed, nnot)*1./sqrt(subinv[inot])
            sm=dsmooth(subimg, 2)
            smmax=max(sm, icen)
            xcen[i-1]=(icen mod (ixlims[1]-ixlims[0]+1))+ixlims[0]
            ycen[i-1]=(icen / (ixlims[1]-ixlims[0]+1))+iylims[0]
            good[i-1]=1
            help,i
        endif
    endif
    istart=iend+1
endfor

save, filename='ic-'+strtrim(string(ccd),2)+'.sav'

end
;------------------------------------------------------------------------------
