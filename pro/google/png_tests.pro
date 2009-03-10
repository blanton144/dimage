;+
; NAME:
;   png_tests
; PURPOSE:
;   Make a Google-style PNG of varying scales
; CALLING SEQUENCE:
;   png_tests, prefix 
; INPUTS:
;   prefix - prefix name (assumes prefix-[gri].fits.gz all exist)
; OPTIONAL INPUTS:
;   patchpath - path to inputs (default ".")
;   pngpath - path to outputs (default ".")
; COMMENTS:
;   Write outputs to:
;     pngpath/prefix-[N].png (PNG files with images)
;   In conformance to Google Sky, these are flipped images.
; REVISION HISTORY:
;   25-Oct-2007 MRB, NYU
;-
pro png_tests, prefix, patchpath=patchpath, pngpath=pngpath

if(NOT keyword_set(patchpath)) then patchpath='.'
if(NOT keyword_set(pngpath)) then pngpath='.'

origscales=[5., 6.5, 10.]

nonlin= [1.5, 3., 5.]
rescale= [1., 0.5, 0.25, 0.15, 0.10]

colornames=['redder', $
            'normal', $
            'bluer']
colors= [[7., 6.5, 8.], $
         [5., 6.5, 10.], $
         [4., 6.5, 12.]]

;; read in images
iim=mrdfits(patchpath+'/'+prefix+'-i.fits.gz',0)
if(NOT keyword_set(iim)) then begin
    splog, 'No i-iimage!'
    return
endif

rim=mrdfits(patchpath+'/'+prefix+'-r.fits.gz',0,hdr)
if(NOT keyword_set(rim)) then begin
    splog, 'No r-iimage!'
    return
endif

gim=mrdfits(patchpath+'/'+prefix+'-g.fits.gz',0)
if(NOT keyword_set(gim)) then begin
    splog, 'No g-iimage!'
    return
endif



for irb=0L, 3L do begin
    binname=prefix+'-'+'rb'+strtrim(string(irb),2)
    htmlname= binname+'.html'
    
    openw, unit, htmlname, /get_lun
    printf, unit, '<html>'
    printf, unit, '<head>'
    printf, unit, '<title>'+binname+'</title>'
    printf, unit, '</head>'
    printf, unit, '<body>'
    printf, unit, '<font size=8><b>'+binname+'</b></font>'
    printf, unit, '<hr>'
    width    = '300'

    if(irb gt 0) then begin
        nx=(size(iim,/dim))[0]
        ny=(size(iim,/dim))[1]
        
        iim= dsmooth(iim, 1.3)
        iim= rebin(iim, nx/2L, ny/2L)
        rim= dsmooth(rim, 1.3)
        rim= rebin(rim, nx/2L, ny/2L)
        gim= dsmooth(gim, 1.3)
        gim= rebin(gim, nx/2L, ny/2L)
    endif

    for j=0L, n_elements(rescale)-1L do begin
        printf, unit, '<table border=0 cellspacing=30>'
        for i=0L, n_elements(nonlin)-1L do begin
            printf, unit, '<tr>'
            for k=0L, n_elements(colornames)-1L do begin
                
                nonlinearity=nonlin[i]
                scales=rescale[j]*colors[*,k]
                
                name= 'nl'+strtrim(string(f='(f40.2)', nonlin[i]),2)+'-'+ $
                      'rs'+strtrim(string(f='(f40.2)', rescale[j]),2)+'-'+ $
                      colornames[k]

                if(irb gt 0) then $
                  name=name+'-rb'+strtrim(string(irb),2)

                pngname=pngpath+'/'+prefix+'-'+name+'.png'
                djs_rgb_make, iim, rim, gim, scales=scales, $
                              nonlinearity=nonlinearity, $
                              satvalue=100., /png, name=pngname

                printf, unit, '<td>'
                printf, unit, colornames[k]+' nonlin='+ $
                        strtrim(string(f='(f40.2)', nonlin[i]),2)+ $
                        ' rescale='+ $
                        strtrim(string(f='(f40.2)', rescale[j]),2)
                printf, unit, '<a href="'+pngname+'">' + $
                        '<img src="'+pngname+'" width='+width+'></a>'
                printf, unit, '</td>'
            endfor
            printf, unit, '</tr>'
        endfor
        printf, unit, '</table>'
        printf, unit, '<hr>'
        printf, unit, '<hr>'
    endfor

    printf, unit, '</table>'
    printf, unit, '</font>'
    printf, unit, '</body>'
    printf, unit, '</html>'
    free_lun, unit
endfor

end

