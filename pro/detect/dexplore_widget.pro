pro dexplore_clean

common com_dexplore_widget, $
  w_parent, w_full, w_base, w_next, w_previous, w_finish, $
  w_slist, w_band, w_child, w_glist, $
  w_settings, w_gsmooth, w_glim, w_redeblend, w_mark, w_smooth, $
  w_gsaddle, basename, imagenames, $
  parent_images, parent_hdrs, $
  setval, band, smooth, child, parent, $
  pcat, acat, ig, is, igstr, isstr, ng, ns, lsb, $
  fix_stretch, hand, show_templates, gsmooth, glim, gsaddle, atset, $
  subdir, setstr, w_eyeball, eyeball, eyeball_name, cup, pup, psfs, $
  curr_nx, curr_ny, curr_nx_2, curr_ny_2, hidestars, bandnames, $
  dexcen, extra_for_detect, raplot, decplot, $
  send_next, send_previous, send_finish

curr_nx=0
curr_ny=0
w_slist=0
w_glist=0
w_band=0
w_smooth=0
w_gsmooth=0
w_glim=0
w_gsaddle=0
w_redeblend=0
w_mark=0
w_parent=0
w_full=0
parent=-1L

if(keyword_set(w_eyeball)) then $
  WIDGET_CONTROL, w_eyeball, /destroy
w_eyeball=0
psfs=0

end
;
pro dexplore_event, ev  

common com_dexplore_widget
common atv2_point, markcoord

;; if we are done, close us out
if(ev.ID eq w_next OR $
   ev.ID eq w_previous OR $
   ev.ID eq w_finish) then begin
    if ev.SELECT then begin
        WIDGET_CONTROL, ev.TOP, /DESTROY  
        dexplore_clean
    endif
    send_next=0
    send_previous=0
    send_finish=0
    if(ev.ID eq w_next) then $
      send_next=1
    if(ev.ID eq w_previous) then $
      send_previous=1
    if(ev.ID eq w_finish) then $
      send_finish=1
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

if(ev.ID eq w_gsaddle) then begin
    if(ev.update) then begin
        gsaddle=ev.value
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
    atset_hand.gsmooth=gsmooth
    atset_hand.glim=glim
    atset_hand.gsaddle=gsaddle
    mwrfits, atset_hand, atsetfile, /create
    help,extra_for_detect,/st
    detect, basename, imagenames, ref=atset.ref, $
      single=parent, /aset, /hand, /pset, /noparentclobber, $
      cen=dexcen, _EXTRA=extra_for_detect
    dexplore_parent_display
    dexplore_child_list
    dexplore_mark_children
endif

end  

function dexplore_setband, ev
COMPILE_OPT hidden
common com_dexplore_widget

band=(where(ev.value eq bandnames))[0]
if(keyword_set(pup)) then begin
    dexplore_parent_display
    dexplore_mark_children
endif else if(keyword_set(cup)) then begin
    dexplore_child_display
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

;; display full images
function dexplore_full_display, ev
COMPILE_OPT hidden

common com_dexplore_widget

image=gz_mrdfits(ev.value,0,hdr,/silent)
nx=(size(image, /dim))[0]
ny=(size(image, /dim))[1]
align=0
if(keyword_set(curr_nx) AND keyword_set(curr_ny)) then begin
    if(nx eq curr_nx and ny eq curr_ny) then $
      align=1
endif
atv, image, align=align, head=hdr, stretch=fix_stretch
fix_stretch=setval[0]
curr_nx=nx
curr_ny=ny

END

;; display a parent
pro dexplore_parent_display, nomarks=nomarks
COMPILE_OPT hidden

common com_dexplore_widget

if(keyword_set(parent_images)) then begin
    pim=(*parent_images[band])
    phdr=(*parent_hdrs[band])
    if(keyword_set(smooth)) then $
      pim=dsmooth(pim, smooth)
    nx=(size(pim,/dim))[0]
    ny=(size(pim,/dim))[0]
    align=0
    if(keyword_set(curr_nx_2) AND keyword_set(curr_ny_2)) then begin
        if(nx eq curr_nx_2 and ny eq curr_ny_2) then $
          align=1
    endif
    atv2, pim, align=align, head=phdr, stretch=fix_stretch
    curr_nx_2=nx
    curr_ny_2=ny
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
if(keyword_set(w_glim)) then $
  WIDGET_CONTROL, w_glim, /destroy
if(keyword_set(w_gsaddle)) then $
  WIDGET_CONTROL, w_gsaddle, /destroy
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
w_glim=0
w_gsaddle=0
w_slist=0
w_glist=0

if(NOT keyword_set(parent_images)) then return

pcatfile=basename+'-pcat.fits'
pcat= gz_mrdfits(pcatfile,1,/silent)
acatfile=subdir+'/'+strtrim(string(parent),2)+'/'+basename+'-'+ $
  strtrim(string(parent),2)+ '-acat.fits'
acat= gz_mrdfits(acatfile,1,/silent)
if(n_tags(acat) eq 0) then begin
   acatfile=subdir+'/'+strtrim(string(parent),2)+'/'+basename+'-acat-'+ $
            strtrim(string(parent),2)+ '.fits'
   acat= gz_mrdfits(acatfile,1,/silent)
endif

if(n_tags(acat) gt 0) then begin
    ig=where(acat.good gt 0 and acat.type eq 0L, ng)
    
    if(ng gt 0) then begin
        igstr=strtrim(string(ig),2)
        w_glist = CW_BGROUP(w_base, ['all', igstr], /row, /return_name, $
                            frame=1, $
                            event_func='dexplore_child_display_widget', $
                            label_left='gals')
    endif

    is=where(acat.good gt 0 and acat.type eq 1L, ns)
    if(ns gt 0) then begin
        isstr=strtrim(string(is),2)
        if(NOT keyword_set(hidestars)) then $
          w_slist = CW_BGROUP(w_base, isstr, /row, /return_name, frame=1, $
                          event_func='dexplore_child_display_widget', $
                          label_left='stars')
    endif
endif

dexplore_mark_children

sgsetfile=subdir+'/'+strtrim(string(parent),2)+'/'+basename+'-sgset.fits'
if(file_test(sgsetfile) gt 0 OR $
   file_test(sgsetfile+'.gz') gt 0) then begin
    sgset=gz_mrdfits(sgsetfile,1,/silent)
;; star marking
    ;;starshow = WIDGET_BUTTON(w_base, value='star show')  
    ;;starset = WIDGET_BUTTON(w_base, value='star set')  
    ;;galshow = WIDGET_BUTTON(w_base, value='gal show')  
    ;;galset = WIDGET_BUTTON(w_base, value='gal set')  
endif

asetfile=subdir+'/'+strtrim(string(parent),2)+'/'+basename+'-aset.fits'
if(file_test(asetfile) OR $
   file_test(asetfile+'.gz') gt 0) then begin
    atset=gz_mrdfits(asetfile,1,/silent)
    gsmooth=atset.gsmooth
    glim=atset.glim
    if(tag_exist(atset, 'GSADDLE')) then $
       gsaddle=atset.gsaddle $
       else $
       gsaddle=0.
    w_gsmooth = CW_FIELD(w_base, TITLE = "gsmooth", $
                         /FLOAT, /FRAME, /return_events, $
                         value=gsmooth)  
    w_glim = CW_FIELD(w_base, TITLE = "glim", $
                      /FLOAT, /FRAME, /return_events, $
                      value=glim)  
    w_gsaddle = CW_FIELD(w_base, TITLE = "gsaddle", $
                         /FLOAT, /FRAME, /return_events, $
                         value=gsaddle)  
    w_redeblend = WIDGET_BUTTON(w_base, value='redeblend')  
    w_mark = WIDGET_BUTTON(w_base, value='mark')  
endif

END

pro dexplore_mark_children
COMPILE_OPT hidden

common com_dexplore_widget

if(n_tags(acat) gt 0) then begin
    if(ng gt 0) then begin
        phdr=(*parent_hdrs[band])
        adxy, phdr, acat[ig].racen, acat[ig].deccen, xcen, ycen
        atv2plot, xcen, ycen, psym=4, th=2
        atv2xyouts, xcen, ycen, igstr, align=0.8, charsize=1.7
    endif
    if(ns gt 0) then begin
        phdr=(*parent_hdrs[band])
        adxy, phdr, acat[is].racen, acat[is].deccen, xcen, ycen
        atv2plot, xcen, ycen, psym=5
        atv2xyouts, xcen, ycen, isstr, align=0.8, charsize=1.7
    endif
endif

if(n_elements(raplot) gt 0 and n_elements(decplot) gt 0) then begin
    adxy, phdr, raplot, decplot, xplot, yplot
    atv2plot, xplot, yplot, psym=1, color='green', symsize=2.
endif

end

function dexplore_child_display_widget, ev
COMPILE_OPT hidden

common com_dexplore_widget

if(ev.value eq 'all') then begin
    dexplore_parent_display
    dexplore_mark_children
endif else begin
    child=long(ev.value)
    dexplore_child_display
endelse

end
;
pro dexplore_child_display

common com_dexplore_widget

imfile=subdir+'/'+strtrim(string(parent),2)+'/'+basename+'-'+ $
  strtrim(string(parent),2)+'-atlas-'+strtrim(string(child),2)+'.fits'
if(keyword_set(show_templates)) then $
  imfile=subdir+'/'+strtrim(string(parent),2)+'/'+basename+'-'+ $
  strtrim(string(parent),2)+'-templates-'+strtrim(string(child),2)+'.fits'
if(file_test(imfile) gt 0 OR $
   file_test(imfile+'.gz') gt 0) then begin
    image=gz_mrdfits(imfile, band, hdr,/silent)
    if(keyword_set(smooth)) then $
      image=dsmooth(image, smooth)
    nx=(size(image,/dim))[0]
    ny=(size(image,/dim))[0]
    align=0
    if(keyword_set(curr_nx_2) AND keyword_set(curr_ny_2)) then begin
        if(nx eq curr_nx_2 and ny eq curr_ny_2) then $
          align=1
    endif
    atv2, image, align=align, head=hdr, stretch=fix_stretch
    curr_nx_2=nx
    curr_ny_2=ny

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
eyeball=gz_mrdfits(subdir+'/'+strtrim(string(parent),2)+'/'+basename+'-'+ $
                   strtrim(string(parent),2)+'-eyeball-'+eyeball_name+ $
                   '.fits', 1, /silent)
if(n_tags(eyeball) eq 0) then begin
    eyeball=replicate(create_struct('EYEBALL_'+eyeball_name, 0L), $
                      n_elements(acat))
endif

w_eyeball = WIDGET_BASE(/COLUMN, /BASE_ALIGN_TOP, /SCROLL, $
                        xoff=300, ysize=900, scr_xsize=200, scr_ysize=900)

w_label = WIDGET_LABEL(w_eyeball, VALUE='Flag values')

group1=0
for i=0L, 31L do begin
    tmp_group1=dimage_flagname('DEBLEND_EYEBALL_'+eyeball_name, 2L^i, /silent)
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
imfile=subdir+'/'+strtrim(string(parent),2)+'/'+ $
  basename+'-'+strtrim(string(parent),2)+'-parent.fits'
parent_images=ptrarr(n_elements(imagenames))
parent_hdrs=ptrarr(n_elements(imagenames))
for i=0L, n_elements(imagenames)-1L do begin
   im=gz_mrdfits(imfile, i, hdr, /silent)
   if(keyword_set(im) eq 0) then begin
      imfile=subdir+'/'+strtrim(string(parent),2)+'/'+ $
             basename+'-parent-'+strtrim(string(parent),2)+'.fits'
      im=gz_mrdfits(imfile, i, hdr, /silent)
   endif
   parent_images[i]=ptr_new(im)
   parent_hdrs[i]=ptr_new(hdr)
endfor

;; read in sgset file
sgsetfile=subdir+'/'+strtrim(string(parent),2)+'/'+basename+'-sgset.fits'
if(file_test(sgsetfile) gt 0 OR $
   file_test(sgsetfile+'.gz') gt 0) then begin
    sgset=gz_mrdfits(sgsetfile,1, /silent)
endif

;; read in aset file
asetfile=subdir+'/'+strtrim(string(parent),2)+'/'+basename+'-aset.fits'
if(file_test(asetfile) gt 0 OR $
   file_test(asetfile+'.gz') gt 0) then begin
    atset=gz_mrdfits(asetfile,1, /silent)
endif


end
  
;; main
pro dexplore_widget, in_basename, in_imagenames, lsb= in_lsb, $
                     twomass=in_twomass, wise=in_wise, $
                     eyeball_name=in_eyeball_name, $
                     hidestars=in_hidestars, parent=in_parent, $
                     cen=cen, ra=in_ra, dec=in_dec, next=next, $
                     previous=previous, finish=finish, _EXTRA=_extra_for_detect

common com_dexplore_widget

if(keyword_set(in_lsb)) then lsb=1
if(keyword_set(in_eyeball_name)) then eyeball_name=in_eyeball_name
if(keyword_set(in_hidestars)) then hidestars=in_hidestars
if(keyword_set(_extra_for_detect)) then extra_for_detect=_extra_for_detect
if(keyword_set(in_ra)) then raplot=in_ra
if(keyword_set(in_dec)) then decplot=in_dec

;; clean up before starting
dexplore_clean

dexcen= keyword_set(cen)

basename=in_basename
imagenames=in_imagenames

bandnames=strarr(n_elements(imagenames))
for i=0L, n_elements(imagenames)-1L do begin
    tmpname=strmid(imagenames[i], strlen(basename))
    bandnames[i]=(stregex(tmpname, '-(.*)\.fits.*', /extr, /sub))[1]
endfor

child=0L
band=0L
smooth=0.
parent=-1L
if(n_elements(in_parent) gt 0) then parent=in_parent
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
w_base = WIDGET_BASE(xoff=60, ROW=20)
w_next = WIDGET_BUTTON(w_base, value='Next')  
w_previous = WIDGET_BUTTON(w_base, value='Previous')  
w_finish = WIDGET_BUTTON(w_base, value='Finish')  

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
bandstr=strtrim(string(lindgen(n_elements(imagenames))),2)
w_band = CW_BGROUP(w_base, bandnames, /row, /return_name, frame=1, $
                   uvalue=0, event_func='dexplore_setband', $
                   label_left='bands')  

;; set up parent display widget
w_parent = CW_FIELD(w_base, TITLE = "parent", $
                    /LONG, /FRAME, /return_events, value=parent)  


stash = {next: w_next, previous:w_previous, finish:w_finish}

if(parent ge 0) then begin
    dexplore_read_parent
    dexplore_parent_display
    dexplore_child_list
    dexplore_mark_children
endif

WIDGET_CONTROL, w_base, /REALIZE, set_uvalue=stash

XMANAGER, 'dexplore', w_base

if(keyword_set(w_eyeball)) then $
  WIDGET_CONTROL, w_eyeball, /destroy
dexplore_clean

next= send_next
previous= send_previous
finish= send_finish

end  

