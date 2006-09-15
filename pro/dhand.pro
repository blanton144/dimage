;+
; NAME:
;   dhand
; PURPOSE:
;   given an image, select stars and galaxies using ATV
; CALLING SEQUENCE:
;   dhand, image, xstars=, ystars=, nstars=, xgals=, ygals=, ngals= [, $
;         /srefine, /grefine ]
; INPUTS:
;   image - [nx, ny] image
; INPUT/OUTPUTS:
;   xstars, ystars - [nn] star positions
;   nstars - number of stars
;   xgals, ygals - [nn] galaxy positions
;   ngals - number of galaxies
; OPTIONAL KEYWORDS:
;   /srefine - refine star positions
;   /grefine - refine galaxy positions
; COMMENTS:
;   Brings up image in ATV. First it allows you to manipulate the 
;   stars. Type "d" to display them first.  Then you can mark new
;   stars with "m" and delete stars with "k". Press "Done" on ATV when
;   you are satisfied. Second, it will allow you to manipulate
;   galaxies in the same way. Third, when you are done with that it
;   will ask if you are done. If you don't reply "y" then the process
;   will repeat.
;
;   If /srefine is set, the stars will be refined within 1 pixel.
;   If /grefine is set, the galaxies will be refined within 3 pixels.
;
;   Note that if you are doing this as part of the deblender in
;   dchildren.pro it is usually better, if you see a star with
;   diffraction spikes, to classify it as a galaxy.
; REVISION HISTORY:
;   11-Aug-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro dhand, image, xstars=xstars, ystars=ystars, xgals=xgals, $
           ygals=ygals, nstars=nstars, ngals=ngals, srefine=srefine, $
           grefine=grefine

common atv_point, markcoord

notdone=1
while(notdone) do begin
    mark=0
    if(nstars gt 0) then $
      mark=transpose(reform([xstars, ystars], n_elements(xstars),2))
    splog, 'Hand mark stars in the image!'
    splog, '(d: shows marks, m: makes mark, k: kills mark)'
    atv,image, /block, mark= mark
    
    ;; refine stellar peaks 
    nstars=n_elements(mark)/2L
    if(keyword_set(mark)) then begin
        if(keyword_set(srefine)) then begin
            xstarsold=reform(long(mark[0,*]), nstars)
            ystarsold=reform(long(mark[1,*]), nstars)
            drefine, image, xstarsold, ystarsold, smooth=1., xr=xstars, $
              yr=ystars 
        endif else begin
            xstars=reform(float(mark[0,*]), nstars)
            ystars=reform(float(mark[1,*]), nstars)
        endelse
    endif
    
    mark=0
    if(ngals gt 0) then $
      mark=transpose(reform([xgals, ygals], n_elements(xgals),2))
    splog, 'Hand mark galaxies in the image!'
    splog, '(d: shows marks, m: makes mark, k: kills mark)'
    atv,image, /block, mark= mark
    
    ;; refine galaxy peaks 
    ngals=n_elements(mark)/2L
    if(keyword_set(mark)) then begin
        if(keyword_set(grefine)) then begin
            xgalsold=long(mark[0,*])
            ygalsold=long(mark[1,*])
            drefine, image, xgalsold, ygalsold, smooth=1., xr=xgals, $
              yr=ygals, box=7L
        endif else begin
            xgals=reform(float(mark[0,*]), ngals)
            ygals=reform(float(mark[1,*]), ngals)
        endelse
    endif
    
    print, 'Are you done? (y/[n])'
    donestr=''
    read, donestr
    if(donestr eq 'y') then $
      notdone=0
endwhile
            
end
;------------------------------------------------------------------------------
