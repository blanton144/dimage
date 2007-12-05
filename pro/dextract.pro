;+
; NAME:
;   dextract
; PURPOSE:
;   extract objects in an image based on object image
; CALLING SEQUENCE:
;   dextract, image, invvar, object=object, extract=extract [, small=]
; INPUTS:
;   image - [nx, ny] input image
;   invvar - [nx, ny] input image inverse variance
;   object - [nx, ny] which object each pixel corresponds to
; OPTIONAL INPUTS:
;   small - if set, only process objects with size of detected area
;           smaller than this value
; OUTPUTS:
;   extract - [N] arrays of structures with objects and properties
;                 .XST - X start of atlas
;                 .YST - Y start of atlas
;                 .XND - X end of atlas
;                 .YND - Y end of atlas
;                 .XCEN
;                 .YCEN
;                 .ATLAS - atlas structure
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro dextract, image, invvar, object=object, extract=extract, small=small, $
              seed=seed

nx=(size(image,/dim))[0]
ny=(size(image,/dim))[1]
asize=2*small+1L
sigma=1./sqrt(median(invvar))

if(max(object) eq -1L) then return

isort=sort(object)
iuniq=uniq(object[isort])
istart=iuniq[0]+1
xcen=fltarr(max(object)+1)
ycen=fltarr(max(object)+1)
xfit=fltarr(max(object)+1)
yfit=fltarr(max(object)+1)
xst=lonarr(max(object)+1)
yst=lonarr(max(object)+1)
xnd=lonarr(max(object)+1)
ynd=lonarr(max(object)+1)
good=lonarr(max(object)+1)
atlas=fltarr(asize,asize,max(object)+1)
atlas_ivar=fltarr(asize,asize,max(object)+1)
for i=1L, n_elements(iuniq)-1L do begin
    iend=iuniq[i]
    ipix=isort[istart:iend]
    iobj=object[ipix[0]]

    ;; check size of object
    ix=ipix mod nx              ;
    iy=ipix / nx;
    ixlims=minmax(ix)
    iylims=minmax(iy)
    nxs=ixlims[1]-ixlims[0]+1L
    nys=iylims[1]-iylims[0]+1L
    mit=1
    if(keyword_set(small)) then $
      mit= (nxs lt small AND nys lt small)

    ;; for selected objects cut out
    if(mit gt 0) then begin
        subimg=image[ixlims[0]:ixlims[1], $
                     iylims[0]:iylims[1]]
        suboim=object[ixlims[0]:ixlims[1], $
                      iylims[0]:iylims[1]]
        subinv=invvar[ixlims[0]:ixlims[1], $
                      iylims[0]:iylims[1]]
        inot=where(suboim ge 0 and suboim ne iobj and subinv gt 0, nnot)
        if(nnot gt 0) then $
          subimg[inot]=randomn(seed, nnot)/sqrt(subinv[inot])
        
        ;; find centers
        sm=dsmooth(subimg, 1.)
        smmax=max(sm, icen)
        xst[i-1]=ixlims[0]
        xnd[i-1]=ixlims[1]
        yst[i-1]=iylims[0]
        ynd[i-1]=iylims[1]
        xcen[i-1]=(icen mod (ixlims[1]-ixlims[0]+1))+ixlims[0]
        ycen[i-1]=(icen / (ixlims[1]-ixlims[0]+1))+iylims[0]
        if(xcen[i-1]-ixlims[0] gt 0 and $
           xcen[i-1]-ixlims[0] lt nxs-1L and $
           ycen[i-1]-iylims[0] gt 0 and $
           ycen[i-1]-iylims[0] lt nys-1L) then begin
            dcen3x3, sm[xcen[i-1]-ixlims[0]-1:xcen[i-1]-ixlims[0]+1, $
                        ycen[i-1]-iylims[0]-1:ycen[i-1]-iylims[0]+1], xx, yy
            xfit[i-1]=xx+float(xcen[i-1])-1.
            yfit[i-1]=yy+float(ycen[i-1])-1.
            
            ;; if there is a good center shift to center
            if(xx gt -1. AND xx lt 3. AND yy gt -1. AND yy lt 3.) then begin
                ixlims=[long(xcen[i-1])-small, long(xcen[i-1])+small]
                iylims=[long(ycen[i-1])-small, long(ycen[i-1])+small]
                
                txst=ixlims[0]>0L
                txnd=ixlims[1]<(nx-1L)
                tyst=iylims[0]>0L
                tynd=iylims[1]<(ny-1L)
                
                subimg=randomn(seed,2*small+1L, 2*small+1L)*sigma
                suboim=lonarr(2*small+1L, 2*small+1L)-1L
                subinv=fltarr(2*small+1L, 2*small+1L)
                
                subimg[txst-ixlims[0]:txnd-ixlims[0], $
                       tyst-iylims[0]:tynd-iylims[0]]= $
                  image[txst:txnd, tyst:tynd]
                suboim[txst-ixlims[0]:txnd-ixlims[0], $
                       tyst-iylims[0]:tynd-iylims[0]]= $
                  object[txst:txnd, tyst:tynd]
                subinv[txst-ixlims[0]:txnd-ixlims[0], $
                       tyst-iylims[0]:tynd-iylims[0]]= $
                  invvar[txst:txnd, tyst:tynd]
                inot=where(suboim ge 0 and suboim ne iobj and subinv gt 0, $
                           nnot)
                if(nnot gt 0) then $
                  subimg[inot]=randomn(seed, nnot)/sqrt(subinv[inot])
                
                atlas[*,*,i-1]=sshift2d(subimg, -[xfit[i-1]-xcen[i-1], $
                                                  yfit[i-1]-ycen[i-1]])
                atlas_ivar[*,*,i-1]= $
                  sshift2d(subinv, -[xfit[i-1]-xcen[i-1], $
                                     yfit[i-1]-ycen[i-1]]) > 0.
                
                good[i-1]=1
            endif
        endif
    endif
    istart=iend+1
endfor

igood=where(good, ngood)

extract=0
if(ngood gt 0) then begin
    extract=replicate({xcen:0., $
                       ycen:0., $
                       xfit:0., $
                       yfit:0., $
                       xst:0L, $
                       yst:0L, $
                       xnd:0L, $
                       ynd:0L, $
                       atlas:fltarr(asize, asize), $
                       atlas_ivar:fltarr(asize, asize)}, ngood)
    extract.xcen=xcen[igood]
    extract.ycen=ycen[igood]
    extract.xfit=xfit[igood]
    extract.yfit=yfit[igood]
    extract.xst=xst[igood]
    extract.yst=yst[igood]
    extract.xnd=xnd[igood]
    extract.ynd=ynd[igood]
    extract.atlas=atlas[*,*,igood]
    extract.atlas_ivar=atlas_ivar[*,*,igood]
endif
    
end
;------------------------------------------------------------------------------
