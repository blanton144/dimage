;+
; NAME:
;   dtemplates
; PURPOSE:
;   build templates around centers  
; CALLING SEQUENCE:
;   dtemplates, image, xc, yc, templates= [, parallel=, sigma=, /sersic]
; INPUTS:
;   image - [nx, ny] input image
;   xc, yc - [N] centers of templates 
; OPTIONAL KEYWORDS;
;   /sersic - fit Sersic profile in 2D, and use to taper template
; OPTIONAL INPUTS:
;   sigma - typical sky sigma (default is inferred from image)
; OUTPUTS:
;   templates - [nx, ny, N] templates around each center
;   parallel - how similar two templates are 
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU, based on RHL deblend
;-
;------------------------------------------------------------------------------
pro dtemplates, image, xc, yc, templates=templates, parallel=parallel, $
                sigma=sigma, sersic=sersic, ikept=ikept

nx=(size(image,/dim))[0]
ny=(size(image,/dim))[1]
nt=n_elements(xc)
templates=fltarr(nx,ny,nt)

if(NOT keyword_set(parallel)) then parallel=0.5
if(NOT keyword_set(sigma)) then sigma=dsigma(image, sp=5)
if(sigma le 0.) then begin
    inot= where(image ne 0., nnot)
    if(nnot eq 0) then begin
        return
    endif else begin
        sigma= djsig(image[inot])
    endelse
endif

soname=filepath('libdimage.'+idlutils_so_ext(), $
                root_dir=getenv('DIMAGE_DIR'), subdirectory='lib')

xin=long(round(xc))
yin=long(round(yc))
ikept=lonarr(nt)
retval=call_external(soname, 'idl_dtemplates', float(image), $
                     long(nx), long(ny), $
                     long(nt), $
                     long(xin), $
                     long(yin), $
                     float(templates), $
                     float(sigma), $
                     float(parallel), $
                     long(ikept))

templates=templates[*,*,0:nt-1L]
ikept=ikept[0:nt-1L]

if(keyword_set(sersic)) then begin
    sub=3L
    snx= nx/sub
    sny= ny/sub
    nnx= snx*sub
    nny= sny*sub
    for i=0L, nt-1L do begin
       btemplate= rebin(templates[0:nnx-1L,0:nny-1L,i], snx, sny)
       iv=fltarr(snx,sny)+1.
       dsersic, btemplate, iv, xcen=xin[i]/float(sub), ycen=yin[i]/float(sub), $
                /fixcen, model=model, /reinit, /fixsky, /simple
       fmodel= fltarr(nx, ny)
       fmodel[0:nnx-1L, 0:nny-1L]= rebin(model, nnx, nny)
       signt=2.*(float(templates[*,*,i] gt 0.)-0.5)
       templates[*,*,i]=signt*(abs(templates[*,*,i]) < $
                               (fmodel*1.3+0.05*sigma))
    endfor
endif

end
;------------------------------------------------------------------------------
