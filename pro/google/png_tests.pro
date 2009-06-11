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

nonlin= [1.5, 2.25, 3.]
rescale= [0.5, 0.4, 0.32, 0.25]

colornames=['redder', $
            'normal', $
            'bluer']
colors= [[6., 6.5, 9.], $
         [5., 6.5, 10.], $
         [4.5, 6.5, 11.]]

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

for irb=0L, 7L do begin
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
        
				if(nx/2L ne float(nx)/2.) then $
				 	return
	
        iim= dsmooth(iim, 2.)
        iim= rebin(iim, nx/2L, ny/2L, /sample)
        rim= dsmooth(rim, 2.)
        rim= rebin(rim, nx/2L, ny/2L, /sample)
        gim= dsmooth(gim, 2.)
        gim= rebin(gim, nx/2L, ny/2L, /sample)
    endif

    nx=(size(iim,/dim))[0]
    ny=(size(iim,/dim))[1]
    nxsub= nx<800L
    nysub= ny<800L
    isubim= iim[0:nxsub-1L, 0L:nysub-1L]
    rsubim= rim[0:nxsub-1L, 0L:nysub-1L]
    gsubim= gim[0:nxsub-1L, 0L:nysub-1L]

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
                djs_rgb_make, isubim, rsubim, gsubim, scales=scales, $
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

