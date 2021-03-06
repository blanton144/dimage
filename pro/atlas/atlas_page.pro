;+
; NAME:
;   atlas_page
; PURPOSE:
;   write an atlas page
; CALLING SEQUENCE:
;   atlas_page
; COMMENTS:
;   Emails some batch queries to NED.
; REVISION HISTORY:
;   31-Mar-2004  MRB, NYU
;-
;------------------------------------------------------------------------------
pro atlas_page, dir, sra=sra, sdec=sdec

if(NOT keyword_set(dir)) then $
  dir='.'

if(NOT keyword_set(base)) then begin
    spawn, 'pwd', cwd
    words=strsplit(cwd[0], '/',/extr)
    base=words[n_elements(words)-1]
endif

srastr=strtrim(string(sra, f='(f40.10)'),2)
sdecstr=strtrim(string(sdec, f='(f40.10)'),2)

bands= ['u', 'g', 'r', 'i', 'z', 'N', 'F']

images=[ ['i', 'r', 'g'], $
         ['N', 'N', 'F'] ]
nimages= (size(images, /dim))[1]

names=strarr(nimages*2L)
shorthand=strarr(nimages*2L)

;; make parent images
for i=0L, nimages-1L do begin

    iband= where(images[0,i] eq bands, nband)
    if(nband eq 0) then $
      message, 'No such band: '+images[0,i]
    rim= mrdfits(base+'-parent.fits.gz', iband[0]*2L, hdr)
    if(i eq 0) then $
      limits= hdrlimits(hdr)

    iband= where(images[1,i] eq bands, nband)
    if(nband eq 0) then $
      message, 'No such band: '+images[1,i]
    gim= mrdfits(base+'-parent.fits.gz', iband[0]*2L)

    iband= where(images[2,i] eq bands, nband)
    if(nband eq 0) then $
      message, 'No such band: '+images[1,i]
    bim= mrdfits(base+'-parent.fits.gz', iband[0]*2L)

    names[i]= base+'-parent-'+strjoin(images[*,i])+'.jpg'

    rescale= 0.4 ;; hardish
    scales= rescale*[5., 6.5, 9.] ;; "normal"
    nonlinearity= 2.25 ;; less than default nonlinearity
    djs_rgb_make, rim, gim, bim, name=names[i], $
      scales=scales, nonlinearity=nonlinearity
    
    shorthand[i]= strjoin(images[*,i], '-')
endfor

;; make child images
for i=0L, nimages-1L do begin

    iband= where(images[0,i] eq bands, nband)
    if(nband eq 0) then $
      message, 'No such band: '+images[0,i]
    rim= mrdfits(base+'-child.fits.gz', iband[0])

    iband= where(images[1,i] eq bands, nband)
    if(nband eq 0) then $
      message, 'No such band: '+images[1,i]
    gim= mrdfits(base+'-child.fits.gz', iband[0])

    iband= where(images[2,i] eq bands, nband)
    if(nband eq 0) then $
      message, 'No such band: '+images[1,i]
    bim= mrdfits(base+'-child.fits.gz', iband[0])

    names[i+nimages]= base+'-child-'+strjoin(images[*,i])+'.jpg'

    rescale= 0.4 ;; hardish
    scales= rescale*[5., 6.5, 9.] ;; "normal"
    nonlinearity= 2.25 ;; less than default nonlinearity
    djs_rgb_make, rim, gim, bim, name=names[i+nimages], $
      scales=scales, nonlinearity=nonlinearity
    
    shorthand[i+nimages]= strjoin(images[*,i], '-')
endfor

spawn, 'cp '+getenv('DIMAGE_DIR')+'/www/demo/*.js '+dir

openw, unit, dir+'/switch1.js', /get_lun
printf, unit, 'function switch1(div) {'
printf, unit, 'if (document.getElementById("image0")) {'
printf, unit, 'var option=[' 
for i=0L, 2L*nimages-1L do $
      printf, unit, '"image'+strtrim(string(i),2)+'", '
printf, unit, '];'
printf, unit, 'for(var i=0; i<option.length; i++)'
printf, unit, '{ obj=document.getElementById(option[i]);'
printf, unit, 'obj.style.display=(option[i]==div)? "block" : "none"; }'
printf, unit, '}'
printf, unit, '}'
free_lun, unit

openw, unit, dir+'/index.html', /get_lun

openr, bunit, getenv('DIMAGE_DIR')+'/www/demo/index-base.html', /get_lun
line=' '
while(NOT eof(bunit)) do begin
    readf, bunit, line
    line=' '+line
    isub= stregex(line, '.*(NAME).*', /sub, len=len)
    if(isub[0] ge 0) then $
    for i=n_elements(isub)-1L,1L,-1L do $
          line= strmid(line, 0L, isub[i])+base+strmid(line, isub[i]+len[i])
    printf, unit, line
endwhile
free_lun, bunit

imtop='55'
imleft='25'

printf, unit, '<div id="image-switch">'
for i=0L, 2*nimages-1L do begin
    istr= strtrim(string(i),2)
    printf, unit, '<div id="image'+istr+'">'
    printf, unit, '<img src="'+names[i]+'"'
    printf, unit, 'style="position:absolute;left:'+imleft+'px;top:'+imtop+'px;width:400px;height:400px;"></img></div>'
endfor
printf, unit, '</div>'

printf, unit, '<div id="image" style="position:absolute;left:'+imleft+'px;top:'+imtop+'px;width:400px;height:400px;"></div>'

printf, unit, '<table border="0" cellspacing="5" style="position:absolute;left:420px;top:50px;color:white;list-style-type:none;margin-left:0;padding-left:1em;">'
printf, unit, '<thead><tr><td style="color:red">parent</td><td style="color:red">child</td></tr></thead>'
for i=0L, nimages-1L do begin
    printf, unit, '<tr>'

    printf, unit, '<td>'
    istr= strtrim(string(i),2)
    printf, unit, '<li><a onmouseover="'+"switch1('image"+istr+"')"+';">'+shorthand[i]+'</a></li>'
    printf, unit, '</td>'

    printf, unit, '<td>'
    istr= strtrim(string(i+nimages),2)
    printf, unit, '<li><a onmouseover="'+"switch1('image"+istr+"')"+';">'+shorthand[i]+'</a></li>'
    printf, unit, '</td>'

    printf, unit, '</tr>'
endfor
printf, unit, '</table>'

printf, unit, '<script id="source" language="javascript" type="text/javascript">'

raminstr= strtrim(string(f='(f40.6)', limits.ramin),2)
ramaxstr= strtrim(string(f='(f40.6)', limits.ramax),2)
decminstr= strtrim(string(f='(f40.6)', limits.decmin),2)
decmaxstr= strtrim(string(f='(f40.6)', limits.decmax),2)
printf, unit, 'var limits = {ramin: '+raminstr+ $
  ', ramax: '+ramaxstr+ $
  ', decmin: '+decminstr+ $
  ', decmax: '+decmaxstr+ $
  '} ;'
printf, unit, 'var sra = '+srastr+';'
printf, unit, 'var sdec = '+sdecstr+';'
printf, unit, 'prospectus(limits, sra, sdec, "stack.json");'
printf, unit, '</script>'

printf, unit, '</body></html>'
free_lun, unit
 

end
