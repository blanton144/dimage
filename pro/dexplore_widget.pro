pro dexplore_event, ev  

common com_dexplore_widget, stretch, basename, parent, full, base, done, $
  band, iband, child, iparent, ichild

if(ev.ID eq done) then begin
    if ev.SELECT then WIDGET_CONTROL, ev.TOP, /DESTROY  
endif

if(ev.ID eq parent) then begin
    if(ev.update) then begin
        iparent=ev.value
        dexplore_parent_display
    endif
endif

if(ev.ID eq child) then begin
    if(ev.update) then begin
        ichild=ev.value
        dexplore_child_display
    endif
endif

if(ev.ID eq band) then begin
    if(ev.update) then $
      iband=ev.value
endif

end  

function dexplore_full_display, ev
COMPILE_OPT hidden

common com_dexplore_widget

image=mrdfits(ev.value,0,hdr)
atv, image, /align, stretch=stretch, head=hdr

END

pro dexplore_parent_display
COMPILE_OPT hidden

common com_dexplore_widget

imfile='parents/'+basename+'-parent-'+strtrim(string(iparent),2)+'.fits'
image=mrdfits(imfile, iband*2L, hdr)
if(keyword_set(image)) then $
  atv, image, head=hdr, stretch=stretch

END

pro dexplore_child_display
COMPILE_OPT hidden

common com_dexplore_widget

imfile='atlases/'+strtrim(string(iparent),2)+'/'+basename+'-'+ $
  strtrim(string(iparent),2)+'-atlas-'+strtrim(string(ichild),2)+'.fits'
if(file_test(imfile)) then begin
    image=mrdfits(imfile, iband, hdr)
    atv, image, head=hdr, stretch=stretch
endif

END
  
pro dexplore_widget, in_basename, images

common com_dexplore_widget

basename=in_basename
ichild=0L
iband=0L
iparent=0L

;; set up base widget
base = WIDGET_BASE(ROW=3)  
done = WIDGET_BUTTON(base, value='Done')  

;; set up full image display widget
allimages= [basename+'-pimage.fits', images]
full = CW_BGROUP(base, allimages, /column, /return_name, $
                 event_func='dexplore_full_display', $
                 label_top='Images of field', $
                 frame=2)

;; set up band selection widget
band = CW_FIELD(base, TITLE = "band", $
                /LONG, /FRAME, /return_events)  

;; set up parent display widget
parent = CW_FIELD(base, TITLE = "parent", $
                  /LONG, /FRAME, /return_events)  

;; set up parent display widget
child = CW_FIELD(base, TITLE = "child", $
                 /LONG, /FRAME, /return_events)  

stash = {done: done}

WIDGET_CONTROL, base, /REALIZE, set_uvalue=stash

XMANAGER, 'dexplore', base

end  

