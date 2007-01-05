pro dexplore_event, ev  

common com_dexplore_widget, $
  basename, imagenames, $
  parent, full, base, done, $
  images, phdr, $
  sgset, aset, subdir, $
  stretch, band, iband, child, iparent, ichild, glist, slist, acat, ig, is, $
  igstr, isstr, settings, setstr, setval, aset, sgset, starset, $
  starshow, galset, galshow, redeblend
common atv_point, markcoord

if(ev.ID eq done) then begin
    if ev.SELECT then WIDGET_CONTROL, ev.TOP, /DESTROY  
    slist=0
    glist=0
    band=0
    parent=0
    full=0
endif

if(ev.ID eq parent) then begin
    if(ev.update) then begin
        iparent=ev.value
        dexplore_parent_display
    endif
endif

if(ev.ID eq band) then begin
    if(ev.update) then $
      iband=ev.value
endif

if(keyword_set(starset)) then begin
    if(ev.ID eq starset) then begin
        if(ev.SELECT) then begin
            if(n_tags(sgset) gt 0) then begin
                sgset.nstars=n_elements(markcoord)/2L
                if(sgset.nstars gt 0) then begin
                    sgset.xstars= markcoord[0,*]
                    sgset.ystars= markcoord[1,*]
                endif
            endif
        endif
    endif
    
    if(ev.ID eq starshow) then begin
        if(ev.SELECT) then begin
            if(n_tags(sgset) gt 0) then begin
                markcoord=fltarr(2,sgset.nstars)
                markcoord[0, *]= sgset.xstars[0:sgset.nstars-1]
                markcoord[1, *]= sgset.ystars[0:sgset.nstars-1]
            endif
        endif
    endif
    
    if(ev.ID eq galset) then begin
        if(ev.SELECT) then begin
            if(n_tags(sgset) gt 0) then begin
                sgset.ngals=n_elements(markcoord)/2L
                if(sgset.ngals gt 0) then begin
                    sgset.xgals= markcoord[0,*]
                    sgset.ygals= markcoord[1,*]
                endif
            endif
        endif
    endif
    
    if(ev.ID eq galshow) then begin
        if(ev.SELECT) then begin
            if(n_tags(sgset) gt 0) then begin
                markcoord=fltarr(2,sgset.ngals)
                markcoord[0, *]= sgset.xgals[0:sgset.ngals-1]
                markcoord[1, *]= sgset.ygals[0:sgset.ngals-1]
            endif
        endif
    endif

    if(ev.ID eq redeblend) then begin
        subdir='hand'
        spawn, 'mkdir -p '+subdir+'/'+strtrim(string(iparent),2)
        sgsetfile=subdir+'/'+strtrim(string(iparent),2)+'/'+basename+ $
          '-sgset.fits'
        mwrfits, sgset, sgsetfile, /create
        detect_multi, basename, imagenames, ref=aset.ref, $
          single=iparent, /sgset, /hand, /noclobber
        dexplore_parent_display
    endif
endif

end  

function dexplore_settings, ev
COMPILE_OPT hidden

common com_dexplore_widget

WIDGET_CONTROL, ev.ID, GET_VALUE=val, GET_UVALUE=uval

for i=0L, n_elements(setstr)-1L do begin
    if(setstr[i] eq ev.value) then begin
        setval[i]=val
    endif
endfor

end

function dexplore_full_display, ev
COMPILE_OPT hidden

common com_dexplore_widget

image=mrdfits(ev.value,0,hdr)
atv, image, /align, head=hdr, stretch=setval[0]

END

pro dexplore_parent_display, nomarks=nomarks
COMPILE_OPT hidden

common com_dexplore_widget

if(keyword_set(image)) then $
  atv, image, /align, head=hdr, stretch=setval[0]

if(keyword_set(slist)) then $
  WIDGET_CONTROL, slist, /destroy
if(keyword_set(glist)) then $
  WIDGET_CONTROL, glist, /destroy
if(keyword_set(starshow)) then $
  WIDGET_CONTROL, starshow, /destroy
if(keyword_set(galshow)) then $
  WIDGET_CONTROL, galshow, /destroy
if(keyword_set(starset)) then $
  WIDGET_CONTROL, starset, /destroy
if(keyword_set(galset)) then $
  WIDGET_CONTROL, galset, /destroy

if(setval[1] eq 0) then $
  subdir='atlases' $
else $
  subdir='hand'
acatfile=subdir+'/'+strtrim(string(iparent),2)+'/'+basename+'-'+ $
  strtrim(string(iparent),2)+ '-acat.fits'
acat= mrdfits(acatfile,1)
if(n_tags(acat) gt 0) then begin
    ig=where(acat.good gt 0 and acat.type eq 0L, ng)
    if(ng gt 0) then begin
        igstr=strtrim(string(ig),2)
        atvplot, acat[ig].xcen, acat[ig].ycen, psym=4, th=2
        if(NOT keyword_set(nomarks)) then $
          atvxyouts, acat[ig].xcen, acat[ig].ycen, igstr, align=0.8, $
          charsize=1.7
        glist = CW_BGROUP(base, igstr, /row, /return_name, frame=1, $
                          event_func='dexplore_child_display', $
                          label_left='gals')
    endif
    is=where(acat.good gt 0 and acat.type eq 1L, ns)
    if(ns gt 0) then begin
        isstr=strtrim(string(is),2)
        atvplot, acat[is].xcen, acat[is].ycen, psym=5
        if(NOT keyword_set(nomarks)) then $
          atvxyouts, acat[is].xcen, acat[is].ycen, isstr, align=0.8, $
          charsize=1.7
        slist = CW_BGROUP(base, isstr, /row, /return_name, frame=1, $
                          event_func='dexplore_child_display', $
                          label_left='stars')
    endif
endif

if(setval[1] eq 0) then $
  subdir='atlases' $
else $
  subdir='hand'
sgsetfile=subdir+'/'+strtrim(string(iparent),2)+'/'+basename+'-sgset.fits'
if(file_test(sgsetfile)) then begin
    sgset=mrdfits(sgsetfile,1)
;; star marking
    starshow = WIDGET_BUTTON(base, value='star show')  
    starset = WIDGET_BUTTON(base, value='star set')  
    galshow = WIDGET_BUTTON(base, value='gal show')  
    galset = WIDGET_BUTTON(base, value='gal set')  
    redeblend = WIDGET_BUTTON(base, value='redeblend')  
endif

asetfile=subdir+'/'+strtrim(string(iparent),2)+'/'+basename+'-aset.fits'
if(file_test(asetfile)) then begin
    aset=mrdfits(asetfile,1)
endif

END

function dexplore_child_display, ev
COMPILE_OPT hidden

common com_dexplore_widget

imfile='atlases/'+strtrim(string(iparent),2)+'/'+basename+'-'+ $
  strtrim(string(iparent),2)+'-atlas-'+strtrim(string(ev.value),2)+'.fits'
if(file_test(imfile)) then begin
    image=mrdfits(imfile, iband, hdr)
    atv, image, /align, head=hdr, stretch=setval[0]
    atvplot, acat[ig].xcen, acat[ig].ycen, psym=4, th=2
    atvxyouts, acat[ig].xcen, acat[ig].ycen, igstr, align=0.8, $
      charsize=1.7
    atvplot, acat[is].xcen, acat[is].ycen, psym=5
    atvxyouts, acat[is].xcen, acat[is].ycen, isstr, align=0.8, $
      charsize=1.7
endif

END

pro dexplore_read_parent, ip
COMPILE_OPT hidden

common com_dexplore_widget

;; read in parent image
imfile='parents/'+basename+'-parent-'+strtrim(string(ip),2)+'.fits'
image=mrdfits(imfile, 0L, phdr)
nx=(size(image, /dim))[0]
ny=(size(image, /dim))[1]
images=fltarr(nx,ny, n_elements(imagenames))
for i=0L, n_elements(imagenames)-1L do begin
    images[*,*,i]=mrdfits(imfile, i*2L)
endfor

subdir='atlases'
if(keyword_set(hand)) then subdir='hand'

;; read in sgset file
sgsetfile=subdir+'/'+strtrim(string(iparent),2)+'/'+basename+'-sgset.fits'
if(file_test(sgsetfile)) then begin
    sgset=mrdfits(sgsetfile,1)
endif

;; read in aset file
asetfile=subdir+'/'+strtrim(string(iparent),2)+'/'+basename+'-aset.fits'
if(file_test(asetfile)) then begin
    aset=mrdfits(asetfile,1)
endif

end
  
pro dexplore_widget, in_basename, in_imagenames

common com_dexplore_widget

basename=in_basename
imagenames=in_imagenames
ichild=0L
iband=0L
iparent=0L

;; set up base widget
base = WIDGET_BASE(ROW=14)  
done = WIDGET_BUTTON(base, value='Done')  

;; set up full image display widget
allimagenames= [basename+'-pimage.fits', imagenames]
full = CW_BGROUP(base, allimagenames, /column, /return_name, $
                 event_func='dexplore_full_display', $
                 label_top='Images of field', $
                 frame=2)

;; settings
setstr= ['fix stretch', 'hand']
setval=bytarr(n_elements(setstr))+1L
settings = CW_BGROUP(base, setstr, /nonexclusive, /column, /return_name, $
                     uvalue=0, event_func='dexplore_settings', $
                     set_value=setval)

;; set up band selection widget
band = CW_FIELD(base, TITLE = "band", $
                /LONG, /FRAME, /return_events)  

;; set up parent display widget
parent = CW_FIELD(base, TITLE = "parent", $
                  /LONG, /FRAME, /return_events)  


stash = {done: done}

WIDGET_CONTROL, base, /REALIZE, set_uvalue=stash

XMANAGER, 'dexplore', base

end  

