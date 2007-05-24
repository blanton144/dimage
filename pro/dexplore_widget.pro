pro dexplore_clean

common com_dexplore_widget, $
  w_parent, w_full, w_base, w_done, w_slist, w_band, w_child, w_glist, $
  w_settings, w_gsmooth, w_glim, w_sersic, w_redeblend, w_mark, w_smooth, $
  basename, imagenames, $
  parent_images, parent_hdr, $
  setval, band, smooth, child, parent, $
  pcat, acat, ig, is, igstr, isstr, ng, ns, lsb, $
  fix_stretch, hand, show_templates, gsmooth, glim, sersic, atset, $
  subdir, setstr, w_eyeball, eyeball, eyeball_name, cup, pup, psfs

w_slist=0
w_glist=0
w_band=0
w_smooth=0
w_sersic=0
w_gsmooth=0
w_glim=0
w_redeblend=0
w_mark=0
w_parent=0
w_full=0
w_eyeball=0
psfs=0

end
;
pro dexplore_event, ev  

common com_dexplore_widget
common atv2_point, markcoord

;; if we are done, close us out
if(ev.ID eq w_done) then begin
    if ev.SELECT then begin
        WIDGET_CONTROL, ev.TOP, /DESTROY  
        dexplore_clean
    endif
endif

if(ev.ID eq w_parent) then begin
    if(ev.update) then begin
        newone=0
        if(parent ne ev.value) then newone=1
        parent=ev.value
        dexplore_read_parent
        dexplore_parent_display
        if(newone eq 1) then dexplore_child_list
        dexplore_mark_children
    endif
endif

if(ev.ID eq w_band) then begin
    if(ev.update) then begin
        band=ev.value
        if(keyword_set(pup)) then begin
            dexplore_parent_display
            dexplore_mark_children
        endif else if(keyword_set(cup)) then begin
            dexplore_child_display
        endif
    endif
endif

if(ev.ID eq w_smooth) then begin
    if(ev.update) then begin
        smooth=ev.value
        if(keyword_set(pup)) then begin
            dexplore_parent_display
            dexplore_mark_children
        endif else if(keyword_set(cup)) then begin
            dexplore_child_display
        endif
    endif
endif

if(ev.ID eq w_gsmooth) then begin
    if(ev.update) then begin
        gsmooth=ev.value
    endif
endif

if(ev.ID eq w_glim) then begin
    if(ev.update) then begin
        glim=ev.value
    endif
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
endif

if(ev.ID eq w_redeblend or ev.ID eq w_mark) then begin
    if(ev.ID eq w_mark) then begin
        print, 'ablh'
    endif

    dexplore_setval, /hand
    spawn, 'mkdir -p '+subdir+'/'+strtrim(string(parent),2)
    atsetfile=subdir+'/'+strtrim(string(parent),2)+'/'+basename+ $
      '-aset.fits'
    atset_hand=atset
    atset_hand.sersic=sersic
    atset_hand.gsmooth=gsmooth
    atset_hand.glim=glim
    mwrfits, atset_hand, atsetfile, /create
    if(NOT keyword_set(lsb)) then $
      detect_multi, basename, imagenames, ref=atset.ref, $
      single=parent, /aset, /hand, /noclobber $
    else $
      detect_lsb, basename, imagenames, ref=atset.ref, $
      single=parent, /aset, /hand, /noclobber 
    dexplore_parent_display
    dexplore_child_list
    dexplore_mark_children
endif

end  

pro dexplore_setval, hand=in_hand
COMPILE_OPT hidden
common com_dexplore_widget

if(keyword_set(hand) ne keyword_set(setval[1])) then begin
    if(setval[1]) then begin
        subdir='hand'
    endif else begin
        subdir='atlases'
    endelse
    dexplore_parent_display
    dexplore_child_list
    dexplore_mark_children
endif

if(keyword_set(show_templates) ne keyword_set(setval[2])) then begin
    show_templates=setval[2]
    if(keyword_set(pup)) then begin
        dexplore_parent_display
        dexplore_mark_children
    endif else if(keyword_set(cup)) then begin
        dexplore_child_display
    endif
endif

fix_stretch=setval[0]
hand=setval[1]

if(keyword_set(in_hand) gt 0) then begin
    hand=in_hand
    setval[1]=in_hand
    subdir='hand'
endif

end

;; settings
function dexplore_settings, ev
COMPILE_OPT hidden

common com_dexplore_widget

WIDGET_CONTROL, ev.ID, GET_VALUE=val, GET_UVALUE=uval

for i=0L, n_elements(setstr)-1L do begin
    if(setstr[i] eq ev.value) then begin
        setval[i]=val[i]
    endif
endfor
dexplore_setval

end

;; sersic  or not
function dexplore_sersic, ev
COMPILE_OPT hidden

common com_dexplore_widget

WIDGET_CONTROL, ev.ID, GET_VALUE=val, GET_UVALUE=uval

if(ev.value eq 'sersic') then begin
    sersic=val
endif

end

;; display full images
function dexplore_full_display, ev
COMPILE_OPT hidden

common com_dexplore_widget

image=mrdfits(ev.value,0,hdr)
atv, image, /align, head=hdr, stretch=fix_stretch
fix_stretch=setval[0]

END

;; display a parent
pro dexplore_parent_display, nomarks=nomarks
COMPILE_OPT hidden

common com_dexplore_widget

if(keyword_set(parent_images)) then begin
    pim=parent_images[*,*,band]
    if(keyword_set(smooth)) then $
      pim=dsmooth(pim, smooth)
    atv2, pim, /align, head=hdr, stretch=fix_stretch
    fix_stretch=setval[0]
endif

pup=1
cup=0

end

;; create new list
pro dexplore_child_list
COMPILE_OPT hidden

common com_dexplore_widget

;; destroy previous
if(keyword_set(w_redeblend)) then $
  WIDGET_CONTROL, w_redeblend, /destroy
if(keyword_set(w_mark)) then $
  WIDGET_CONTROL, w_mark, /destroy
if(keyword_set(w_gsmooth)) then $
  WIDGET_CONTROL, w_gsmooth, /destroy
if(keyword_set(w_sersic)) then $
  WIDGET_CONTROL, w_sersic, /destroy
if(keyword_set(w_glim)) then $
  WIDGET_CONTROL, w_glim, /destroy
if(keyword_set(w_slist)) then $
  WIDGET_CONTROL, w_slist, /destroy
if(keyword_set(w_glist)) then $
  WIDGET_CONTROL, w_glist, /destroy
if(keyword_set(starshow)) then $
  WIDGET_CONTROL, starshow, /destroy
if(keyword_set(galshow)) then $
  WIDGET_CONTROL, galshow, /destroy
if(keyword_set(starset)) then $
  WIDGET_CONTROL, starset, /destroy
if(keyword_set(galset)) then $
  WIDGET_CONTROL, galset, /destroy
if(keyword_set(w_eyeball)) then $
  WIDGET_CONTROL, w_eyeball, /destroy
w_redeblend=0
w_mark=0
w_eyeball=0
w_gsmooth=0
w_sersic=0
w_glim=0
w_slist=0
w_glist=0

if(NOT keyword_set(parent_images)) then return

pcatfile=basename+'-pcat.fits'
pcat= mrdfits(pcatfile,1)
acatfile=subdir+'/'+strtrim(string(parent),2)+'/'+basename+'-'+ $
  strtrim(string(parent),2)+ '-acat.fits'
acat= mrdfits(acatfile,1)
if(n_tags(acat) gt 0) then begin
    ig=where(acat.good gt 0 and acat.type eq 0L, ng)
    
    if(ng gt 0) then begin
        igstr=strtrim(string(ig),2)
        w_glist = CW_BGROUP(w_base, igstr, /row, /return_name, frame=1, $
                            event_func='dexplore_child_display_widget', $
                            label_left='gals')
    endif

    is=where(acat.good gt 0 and acat.type eq 1L, ns)
    if(ns gt 0) then begin
        isstr=strtrim(string(is),2)
        w_slist = CW_BGROUP(w_base, isstr, /row, /return_name, frame=1, $
                          event_func='dexplore_child_display_widget', $
                          label_left='stars')
    endif
endif

dexplore_mark_children

sgsetfile=subdir+'/'+strtrim(string(parent),2)+'/'+basename+'-sgset.fits'
if(file_test(sgsetfile)) then begin
    sgset=mrdfits(sgsetfile,1)
;; star marking
    ;;starshow = WIDGET_BUTTON(w_base, value='star show')  
    ;;starset = WIDGET_BUTTON(w_base, value='star set')  
    ;;galshow = WIDGET_BUTTON(w_base, value='gal show')  
    ;;galset = WIDGET_BUTTON(w_base, value='gal set')  
endif

asetfile=subdir+'/'+strtrim(string(parent),2)+'/'+basename+'-aset.fits'
if(file_test(asetfile)) then begin
    atset=mrdfits(asetfile,1)
    sersic=atset.sersic
    gsmooth=atset.gsmooth
    glim=atset.glim
    w_gsmooth = CW_FIELD(w_base, TITLE = "gsmooth", $
                         /FLOAT, /FRAME, /return_events, $
                         value=gsmooth)  
    w_glim = CW_FIELD(w_base, TITLE = "glim", $
                      /FLOAT, /FRAME, /return_events, $
                      value=glim)  
    w_sersic = CW_BGROUP(w_base, 'sersic', /nonexclusive, /column, $
                         /return_name, uvalue=0, $
                         event_func='dexplore_sersic', $
                         set_value=sersic)
    w_redeblend = WIDGET_BUTTON(w_base, value='redeblend')  
    w_mark = WIDGET_BUTTON(w_base, value='mark')  
endif

END

pro dexplore_mark_children
COMPILE_OPT hidden

common com_dexplore_widget

if(n_tags(acat)) then begin
    if(ng gt 0) then begin
        atv2plot, acat[ig].xcen, acat[ig].ycen, psym=4, th=2
        atv2xyouts, acat[ig].xcen, acat[ig].ycen, igstr, align=0.8, $
          charsize=1.7
    endif
    if(ns gt 0) then begin
        atv2plot, acat[is].xcen, acat[is].ycen, psym=5
        atv2xyouts, acat[is].xcen, acat[is].ycen, isstr, align=0.8, $
          charsize=1.7
    endif
endif
end

function dexplore_child_display_widget, ev
COMPILE_OPT hidden

common com_dexplore_widget

child=long(ev.value)

dexplore_child_display

end
;
pro dexplore_child_display

common com_dexplore_widget

imfile=subdir+'/'+strtrim(string(parent),2)+'/'+basename+'-'+ $
  strtrim(string(parent),2)+'-atlas-'+strtrim(string(child),2)+'.fits'
if(keyword_set(show_templates)) then $
  imfile=subdir+'/'+strtrim(string(parent),2)+'/'+basename+'-'+ $
  strtrim(string(parent),2)+'-templates-'+strtrim(string(child),2)+'.fits'
if(file_test(imfile)) then begin
    image=mrdfits(imfile, band, hdr)
    if(keyword_set(smooth)) then $
      image=dsmooth(image, smooth)
    atv2, image, /align, head=hdr, stretch=fix_stretch

    ;;atv3, dvpsf(pcat[parent].xst+acat[child].xcen, $
    ;;            pcat[parent].yst+acat[child].ycen, $
    ;;            psf=psfs[band]), /align, /stretch
    fix_stretch=setval[0]
    dexplore_mark_children
endif

if(keyword_set(eyeball_name)) then $
  dexplore_child_eyeball

cup=1
pup=0

END
;;
pro dexplore_child_eyeball
COMPILE_OPT hidden

common com_dexplore_widget

if(keyword_set(w_eyeball)) then $
  WIDGET_CONTROL, w_eyeball, /destroy
w_eyeball=0

;; read in eyeball
eyeball=mrdfits(subdir+'/'+strtrim(string(parent),2)+'/'+basename+'-'+ $
                strtrim(string(parent),2)+'-eyeball-'+eyeball_name+'.fits',1)
if(n_tags(eyeball) eq 0) then begin
    eyeball=replicate(create_struct('EYEBALL_'+eyeball_name, 0L), $
                      n_elements(acat))
endif

w_eyeball = WIDGET_BASE(/COLUMN, /BASE_ALIGN_TOP, /SCROLL, $
                        scr_xsize=200, scr_ysize=500)

w_label = WIDGET_LABEL(w_eyeball, VALUE='Flag values')

group1=0
for i=0L, 31L do begin
    tmp_group1=dimage_flagname('DEBLEND_EYEBALL_'+eyeball_name, 2L^i)
    if(keyword_set(tmp_group1)) then begin
        if(NOT keyword_set(group1)) then $
          group1=tmp_group1 $
        else $
          group1=[group1, tmp_group1]
    endif
endfor

ngroup1=n_elements(group1)
init_group1=bytarr(ngroup1)
if(keyword_set(eyeball)) then begin
    for i=0L, ngroup1-1L do begin
        if((eyeball[child].(0) AND $
            dimage_flagval('DEBLEND_EYEBALL_'+eyeball_name,group1[i])) $
           gt 0) then $
          init_group1[i]=1
    endfor
endif else begin
    eyeball=0L
endelse
w_eyeball_list = CW_BGROUP(w_eyeball, group1, /COLUMN, /NONEXCLUSIVE, $
                           /RETURN_NAME, UVALUE=0, $
                           EVENT_FUNC='dexplore_eyeball_save', $
                           SET_VALUE=init_group1)

WIDGET_CONTROL, w_eyeball, /REALIZE

end
;
FUNCTION dexplore_eyeball_save, ev
COMPILE_OPT hidden

common com_dexplore_widget

WIDGET_CONTROL, ev.ID, GET_VALUE=val, GET_UVALUE=uval

eyeball[child].(0)=0L
for i=0L, n_elements(val)-1L do begin
    if(val[i]) then $
      eyeball[child].(0)= $
      eyeball[child].(0) OR 2L^(i)
endfor

outfile=subdir+'/'+strtrim(string(parent),2)+'/'+basename+'-'+ $
  strtrim(string(parent),2)+'-eyeball-'+eyeball_name+'.fits'
mwrfits, eyeball, outfile, /create

END
;;
pro dexplore_read_parent
COMPILE_OPT hidden

common com_dexplore_widget

;; read in parent image
imfile='parents/'+basename+'-parent-'+strtrim(string(parent),2)+'.fits'
parent_image=mrdfits(imfile, 0L, parent_hdr)

nx=(size(parent_image, /dim))[0]
ny=(size(parent_image, /dim))[1]
parent_images=fltarr(nx,ny, n_elements(imagenames))
for i=0L, n_elements(imagenames)-1L do begin
    parent_images[*,*,i]=mrdfits(imfile, i*2L)
endfor

;; read in sgset file
sgsetfile=subdir+'/'+strtrim(string(parent),2)+'/'+basename+'-sgset.fits'
if(file_test(sgsetfile)) then begin
    sgset=mrdfits(sgsetfile,1)
endif

;; read in aset file
asetfile=subdir+'/'+strtrim(string(parent),2)+'/'+basename+'-aset.fits'
if(file_test(asetfile)) then begin
    atset=mrdfits(asetfile,1)
endif


end
  
;; main
pro dexplore_widget, in_basename, in_imagenames, lsb= in_lsb

common com_dexplore_widget

if(keyword_set(in_lsb)) then lsb=1

;; clean up before starting
dexplore_clean

basename=in_basename
imagenames=in_imagenames
child=0L
band=0L
smooth=0.
parent=-1L
subdir='atlases'

psfs=0
for i=0L, n_elements(imagenames)-1L do begin
    imbase=(stregex(imagenames[i],'(.*)\.fits.*',/sub,/extr))[1]
    ;;tmppsf=dpsfread(imbase+'-vpsf.fits')
    ;;if(n_tags(psfs) eq 0) then $
    ;;  psfs=tmppsf $
    ;;else $
    ;;  psfs=[psfs, tmppsf]
endfor

;; set up base widget
w_base = WIDGET_BASE(ROW=14)  
w_done = WIDGET_BUTTON(w_base, value='Done')  

;; set up full image display widget
allimagenames= [basename+'-pimage.fits', imagenames]
w_full = CW_BGROUP(w_base, allimagenames, /column, /return_name, $
                   event_func='dexplore_full_display', $
                   label_top='Images of field', $
                   frame=2)

;; settings
setstr= ['fix stretch', 'hand', 'show templates']
setval=bytarr(n_elements(setstr))
fix_stretch=1
setval[0]=1 ;; fix stretch by default
w_settings = CW_BGROUP(w_base, setstr, /nonexclusive, /column, /return_name, $
                       uvalue=0, event_func='dexplore_settings', $
                       set_value=setval)
dexplore_setval

;; set up smoothing widget
w_smooth = CW_FIELD(w_base, TITLE = "smooth", $
                  /FLOAT, /FRAME, /return_events, value=smooth)  

;; set up band selection widget
w_band = CW_FIELD(w_base, TITLE = "band", $
                  /LONG, /FRAME, /return_events, value=band)  

;; set up parent display widget
w_parent = CW_FIELD(w_base, TITLE = "parent", $
                    /LONG, /FRAME, /return_events)  


stash = {done: w_done}

WIDGET_CONTROL, w_base, /REALIZE, set_uvalue=stash

XMANAGER, 'dexplore', w_base

dexplore_clean

end  

