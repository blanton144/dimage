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

if(NOT keyword_set(parallel)) then parallel=0.5
if(NOT keyword_set(sigma)) then sigma=dsigma(image, sp=5)

nx=(size(image,/dim))[0]
ny=(size(image,/dim))[1]
nt=n_elements(xc)
templates=fltarr(nx,ny,nt)

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
    iv=fltarr(nx,ny)+1./sigma^2
    for i=0L, nt-1L do begin
        dsersic, templates[*,*,i], iv, xcen=xin[i], ycen=yin[i], $
          /fixcen, model=model, /reinit, /fixsky, /simple
        signt=2.*(float(templates[*,*,i] gt 0.)-0.5)
        templates[*,*,i]=signt*(abs(templates[*,*,i]) < (model*2.+0.1*sigma))
    endfor
endif

end
;------------------------------------------------------------------------------
