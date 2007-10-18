;+
; NAME:
;   dobjects
; PURPOSE:
;   detect objects in multi-band, multi-res images
; CALLING SEQUENCE:
;   dobjects, images, objects= [, dpsf=, plim=]
; INPUTS:
;   images - [nim] pointer to images, OR 
;            [nx,ny,nim] array of images
; OPTIONAL INPUTS:
;   dpsf - smoothing of PSF for detection (defaults to sigma=1 pixel)
;   plim - limiting significance in sky sigma (defaults to 10 sig )
;   puse - [nim] 0 or 1 whether to use image to detect
; OUTPUTS:
;   objects - [nim] pointer to object images OR 
;             [nx, ny] object image; object image has which object
;             each pixel belongs to (-1 if none)
;   fobject - [max(nx), max(ny)] full object image at highest res
; COMMENTS:
;   Any detected pixel in any band counts as a detection.
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro dobjects, images, objects=objects, dpsf=dpsf, plim=plim, puse=puse, $
              fobject=fobject

nlevel=3L

if((size(images))[0] eq 1) then begin
    ptrs=1
    nim=n_elements(images)
    nx=lonarr(nim)
    ny=lonarr(nim)
    for k=0L, nim-1L do begin
        nx[k]=(size(*images[k], /dim))[0]
        ny[k]=(size(*images[k], /dim))[1]
    endfor
endif else begin
    ptrs=0
    if((size(images))[0] eq 2) then $
      nim=1 $
    else $
      nim=(size(images,/dim))[2]
    nx=replicate((size(images,/dim))[0],nim)
    ny=replicate((size(images,/dim))[1],nim)
endelse

if(NOT keyword_set(dpsf)) then dpsf=1.
if(NOT keyword_set(puse)) then puse=replicate(1, nim)
if(NOT keyword_set(plim)) then plim=10.

; Set source object name
soname=filepath('libdimage.'+idlutils_so_ext(), $
                root_dir=getenv('DIMAGE_DIR'), subdirectory='lib')
maxnx=max(nx)
maxny=max(ny)
full=lonarr(maxnx, maxny)
for k=0L, nim-1L do begin
    if(puse[k]) then begin
        objects=lonarr(nx[k], ny[k])
        if(ptrs) then $
          curr=*images[k] $
        else $
          curr=images[*,*,k]
        sigma=dsigma(curr, sp=8L)
        currnx=nx[k]
        currny=ny[k]
        retval=call_external(soname, 'idl_dobjects', $
                             float(curr), $
                             long(currnx), long(currny), $
                             float(dpsf), $
                             float(plim), $
                             long(objects))
        mask=long(objects ge 0L)

        ;; now iterate
        for level=1L, nlevel do begin
            rnx=nx[k]/2L^level
            rny=ny[k]/2L^level
            nnx=rnx*2L^level
            nny=rny*2L^level
            tmp_image=curr[0L:nnx-1L,0L:nny-1L]
            tmp_mask=mask[0L:nnx-1L,0L:nny-1L]
            idet=where(tmp_mask gt 0L, ndet)
            if(ndet gt 0) then $
              tmp_image[idet]=randomn(seed, ndet)*sigma
            tmp_image=rebin(tmp_image, rnx, rny)
            tmp_objects=lonarr(rnx, rny)
            retval=call_external(soname, 'idl_dobjects', $
                                 float(tmp_image), $
                                 long(rnx), long(rnx), $
                                 float(dpsf), $
                                 float(plim), $
                                 long(tmp_objects))
            newmask=lonarr(nx[k], ny[k])
            newmask[0L:nnx-1L,0L:nny-1L]= $
              rebin(float(tmp_objects ge 0L), nnx, nny, /sample)
            mask=(mask gt 0) OR (newmask gt 0L)
        endfor
        
        full=full OR (congrid(mask, maxnx, maxny))
    endif
endfor

dfind, full, object=fobject
if(ptrs) then $
  objects=ptrarr(nim) $
else $
  objects=lonarr(nx[0], ny[0], nim)
for k=0L, nim-1L do begin
    curr=congrid(fobject, nx[k], ny[k])
    if(ptrs) then $
      objects[k]=ptr_new(curr) $
    else $
      objects[*,*,k]=curr 
endfor

end
