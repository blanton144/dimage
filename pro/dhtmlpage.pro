;+
; NAME:
;   dhtmlpage
; PURPOSE:
;   make HTML page with results
; CALLING SEQUENCE:
;   dhtmlpage, base, iparent
; INPUTS:
;   base - FITS image base name
;   iparent - parent to process 
; COMMENTS:
;   Makes a tar file with the relevant files:
;     [base]/[base]-dbset.fits
;     [base]/[base]-[iparent]/[base]-[iparent]-index.html 
;     [base]/[base]-[iparent]/[base]-[iparent]-[atlas].jpg (for all children)
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro dhtmlpage, inbase, iparent, install=install


base=strtrim(inbase, 2)

spawn, 'rm -rf tmp-htmlpage'
path='tmp-htmlpage/'+base+'/'+base+'-'+strtrim(string(iparent),2)
spawn, 'mkdir -p '+path
spawn, 'cp -p '+base+'-dbset.fits tmp-htmlpage/'+base

htmlfile=path+'/index.html'
openw, unit, htmlfile, /get_lun
printf, unit, '<html>'
printf, unit, '<head>'
printf, unit, '<title>'+base+'-'+strtrim(string(iparent),2)+'</title>'
printf, unit, '</head>'
printf, unit, '<body>'
printf, unit, '<font size=8><b>'+base+'-'+strtrim(string(iparent),2)+ $
  '</b></font>'
printf, unit, '<hr>'
printf, unit, '<a href="../'+base+'-dbset.fits">'+base+'-dbset.fits</a>'
printf, unit, '<table border=0>'
parent=mrdfits(base+'-parents.fits', 1+2*iparent)
scales=[3., 3., 3.]*dsigma(parent)/0.014
nx=(size(parent, /dim))[0]
ny=(size(parent, /dim))[1]
width    = '300'
height   = strtrim(string(long(float(ny)/float(nx)*300.)),2)
img_name=base+strtrim(string(iparent),2)+'.jpg'
nw_rgb_make, parent, parent, parent, name=path+'/'+img_name, $
  /invert, scales=scales, nonlinearity=1.5, quality=100, $
  colors=ncolors
printf, unit, '<tr>'
printf, unit, '<td>'
printf, unit, '<a href="'+img_name+'"><img src="'+img_name+ $
  '" width='+width+' height='+height+'></a>'
printf, unit, '</td>'
printf, unit, '</tr>'
ichild=0
child=mrdfits(base+'-'+strtrim(string(iparent),2)+ $
              '-atlas.fits', ichild)
while(keyword_set(child)) do begin
    nx=(size(child, /dim))[0]
    ny=(size(child, /dim))[1]
    width    = '300'
    height   = strtrim(string(long(float(ny)/float(nx)*300.)),2)
    img_name=base+'-'+ $
      strtrim(string(iparent),2)+'-'+strtrim(string(ichild),2)+'.jpg'
    nw_rgb_make, child, child, child, name=path+'/'+img_name, $
      /invert, scales=scales, nonlinearity=1.5, quality=100, $
      colors=ncolors
    printf, unit, '<tr>'
    printf, unit, '<td>'
    printf, unit, '<a href="'+img_name+'"><img src="'+img_name+ $
      '" width='+width+' height='+height+'></a>'
    printf, unit, '</td>'
    printf, unit, '</tr>'
    ichild=ichild+1L
    child=mrdfits(base+'-'+strtrim(string(iparent),2)+ $
                  '-atlas.fits', ichild)
endwhile
printf, unit, '</table>'
printf, unit, '</font>'
printf, unit, '</body>'
printf, unit, '</html>'
free_lun, unit

cd, 'tmp-htmlpage'
spawn, 'tar -cvf ../'+base+'-'+strtrim(string(iparent),2)+'.tar '+base
cd, '..'
spawn, 'gzip -fv '+base+'-'+strtrim(string(iparent),2)+'.tar'
spawn, 'rm -rf tmp-htmlpage'

if(keyword_set(install)) then begin
    spawn, 'tar -xvzf '+base+'-'+strtrim(string(iparent),2)+'.tar.gz '+ $
      '-C ~/wwwblanton/deblends/'
endif

end
;------------------------------------------------------------------------------
