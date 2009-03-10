;+
; NAME:
;   smosaic_qastats
; PURPOSE:
;   Make plots and statistics for a smosaic QA file
; CALLING SEQUENCE:
;   smosaic_qastats, prefix [, path=, /notitle]
; INPUTS:
;   prefix - prefix of file names (expect prefix-qa.fits)
; OPTIONAL INPUTS;
;   path - path to file [default '.']
; OPTIONAL KEYWORDS:
;   /notitle - no title at top
; COMMENTS:
;   Reads in file:
;     path/prefix-qa.fits
;   with a structure with one element per star, with tags:
;     .SDSS[5] - SDSS PSF flux in each band
;     .FLUX[5] - our aperture flux in each band
;     .FLERR[5] - our aperture flux in each band
;     .X - X position in image
;     .Y - Y position in image
;   (as produced by smosaic_qa.pro)
;   It writes out a file:
;     path/prefix-qastats.fits
;   with a structure with some basic statistics:
;     .MEDIAN[5] - median difference in magnitude (for 17<r<20)
;     .SIGMA[5] - sigma of difference in magnitude (for 16<r<19)
;   And produces a PostScript file:
;     path/prefix-qastats.ps
;   which has the following plots:
;     flux/sdss in each band vs. mag
;     flux/sdss in each band vs. x
;     flux/sdss in each band vs. y
;     histograms of flux/sdss in each band
;     histograms of (flux-sdss)/flerr in each band
; REVISION HISTORY:
;   2-Mar-2009  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro smosaic_qastats, prefix, path=path, notitle=notitle

if(NOT keyword_set(path)) then path='.'

bands=['u', 'g', 'r', 'i', 'z']
limits=[[15., 17.], $
        [15., 18.], $
        [15., 18.], $
        [15., 17.], $
        [14., 16]]

qa= mrdfits(prefix+'-qa.fits', 1)

mag=22.5-2.5*alog10(qa.sdss)
ratio= qa.flux/qa.sdss

;; impose minimum relevant error
minerr=0.005
for i=0L, 4L do begin
    inz= where(qa.sdssivar[i] ne 0, nnz)
    if(nnz gt 0) then begin
        err=1./sqrt(qa[inz].sdssivar[i])
        err=sqrt(err^2+ (qa[inz].sdss[i]*minerr)^2)
        qa[inz].sdssivar[i]= 1./err^2
    endif
endfor

;; get differences scaled to sigma
diff= (qa.flux-qa.sdss)*sqrt(qa.sdssivar)
scaled_diff=diff*0.
for i=0, 4L do begin
    ii=where(mag[i,*] gt limits[0,i] and $
             mag[i,*] lt limits[1,i])
    scale= 1./median(ratio[i,ii])
    scaled_diff[i,*]= (scale*qa.flux[i]-qa.sdss[i])*sqrt(qa.sdssivar[i])
endfor

k_print, filename=path+'/'+prefix+'-qastats-magdiff.ps'

!P.MULTI=[5,1,5]
!Y.MARGIN=0

hogg_usersym, 10, /fill
for i=0L, 4L do begin
    xx=14.1+8.*findgen(100)/99. 
    fxx= 10.^(-0.4*(xx-22.5))
    yylo= 1.-qa[0].flerr[i]/fxx
    yyhi= 1.+qa[0].flerr[i]/fxx

    ycharsize=0.8
    xcharsize=0.0001
    if(i eq 4) then xcharsize=ycharsize

    xtitle='!6Magnitude'
    ytitle='!8f_{!6us}/!8f_{!6SDSS}!6'

    if(keyword_set(notitle) eq 0 and i eq 0) then $
      title= prefix $
    else $
      title=''

    ii=where(mag[i,*] gt limits[0,i] and mag[2,*] lt limits[1,i],nii)
    sig=djsig(ratio[i,ii])
    med=median(ratio[i,ii])

    djs_plot, mag[i,*], ratio[i,*], psym=8, symsize=0.25, $
              xra=[14.1, 22.1], yra=[0.86, 1.14], xcharsize=xcharsize, $
              ycharsize=ycharsize, xtitle=xtitle, ytitle=ytitle, $
              title=title, charsize=2.5

    xst= !X.CRANGE[0]+0.04*(!X.CRANGE[1]-!X.CRANGE[0])
    yst= !Y.CRANGE[0]+0.82*(!Y.CRANGE[1]-!Y.CRANGE[0])
    djs_xyouts, xst, yst, '!8'+bands[i]+'!6'

    limitstr= '('+strtrim(string(long(limits[0,i])),2)+'<'+bands[i]+'<'+ $
              strtrim(string(long(limits[1,i])),2)+')'
    yst= !Y.CRANGE[0]+0.24*(!Y.CRANGE[1]-!Y.CRANGE[0])
    djs_xyouts, xst, yst, '!8\sigma'+limitstr+' = '+ $
                strtrim(string(f='(f40.3)', sig),2)
    yst= !Y.CRANGE[0]+0.08*(!Y.CRANGE[1]-!Y.CRANGE[0])
    djs_xyouts, xst, yst, '!8\Delta'+limitstr+' = '+ $
                strtrim(string(f='(f40.3)', med),2)

    quantplot, mag[i,*], ratio[i,*], minx=14., maxx=21.5, npix=15, $
               thick=5, color='red'

    djs_oplot, xx, yylo
    djs_oplot, xx, yyhi
endfor
k_end_print

k_print, filename=path+'/'+prefix+'-qastats-scaled-diff.ps'

!P.MULTI=0
hogg_usersym, 10, /fill
pxst=0.1
pxnd=0.70
pxnd2=0.95
pymax=0.9
pdy=0.15
charsize=1.2
for i=0L, 4L do begin
    ycharsize=0.7
    xcharsize=0.0001
    if(i eq 4) then xcharsize=1.2*ycharsize
    noerase=i gt 0

    xtitle='!6Magnitude'
    ytitle='!8(f_{!6us}-!8f_{!6SDSS})/\sigma!6'

    if(keyword_set(notitle) eq 0 and i eq 0) then $
      title= prefix $
    else $
      title=''

    pyst=pymax-(i+1.)*pdy
    pynd=pyst+pdy

    !P.POSITION=[pxst, pyst, pxnd, pynd]

    djs_plot, mag[i,*], scaled_diff[i,*], psym=8, symsize=0.25, $
              xra=[14.1, 22.1], yra=[-5.9, 5.9], xcharsize=xcharsize, $
              ycharsize=ycharsize, xtitle=xtitle, ytitle=ytitle, $
              title=title, charsize=charsize, noerase=noerase

    !P.POSITION=[pxnd, pyst, pxnd2, pynd]

    nbin=30L
    minhist=-6.
    maxhist=6.
    ii=where(scaled_diff[i,*] ne 0., nii)
    diffhist= histogram(scaled_diff[i,ii], min=minhist, max=maxhist, $
                        nbin=nbin+1)
    xhist= minhist+(maxhist-minhist)*(findgen(nbin)+0.5)/float(nbin)
    djs_plot, xhist, diffhist, xra=[-5.9, 5.9], $
              yra=[-0.02, 1.05]*max(diffhist), ycharsize=0.0001, $
              xcharsize=xcharsize, charsize=charsize, /noerase, $
              psym=10, xtitle=ytitle
    xx=minhist+(maxhist-minhist)*(findgen(nbin)+0.5)/float(nbin)
    yy=exp(-0.5*xx^2)
    scale=total(yy*diffhist)/total(yy*yy)    
    djs_oplot, xx, yy*scale

    xst= !X.CRANGE[0]+0.04*(!X.CRANGE[1]-!X.CRANGE[0])
    yst= !Y.CRANGE[0]+0.82*(!Y.CRANGE[1]-!Y.CRANGE[0])
    djs_xyouts, xst, yst, '!8'+bands[i]+'!6'
endfor
k_end_print

k_print, filename=path+'/'+prefix+'-qastats-xdep.ps'

!P.POSITION=0
!P.MULTI=[0,1,5]

hogg_usersym, 10, /fill
for i=0L, 4L do begin
    xx=14.1+8.*findgen(100)/99. 
    fxx= 10.^(-0.4*(xx-22.5))
    yylo= 1.-qa[0].flerr[i]/fxx
    yyhi= 1.+qa[0].flerr[i]/fxx

    ycharsize=0.8
    xcharsize=0.0001
    if(i eq 4) then xcharsize=ycharsize

    xtitle='!6X'
    ytitle='!8f_{!6us}/!8f_{!6SDSS}!6'

    if(keyword_set(notitle) eq 0 and i eq 0) then $
      title= prefix $
    else $
      title=''

    ii=where(mag[2,*] gt 15. and mag[2,*] lt 18.)
    djs_plot, qa[ii].x, ratio[i,ii], psym=8, symsize=0.25, $
              xra=[min(qa.x), max(qa.x)], yra=[0.86, 1.14], $
              xcharsize=xcharsize, $
              ycharsize=ycharsize, xtitle=xtitle, ytitle=ytitle, $
              title=title, charsize=2.5

    xst= !X.CRANGE[0]+0.04*(!X.CRANGE[1]-!X.CRANGE[0])
    yst= !Y.CRANGE[0]+0.82*(!Y.CRANGE[1]-!Y.CRANGE[0])
    djs_xyouts, xst, yst, '!8'+bands[i]+'!6'

    djs_oplot, xx, yylo
    djs_oplot, xx, yyhi
endfor
k_end_print

k_print, filename=path+'/'+prefix+'-qastats-ydep.ps'

!P.POSITION=0
!P.MULTI=[0,1,5]

hogg_usersym, 10, /fill
for i=0L, 4L do begin
    xx=14.1+8.*findgen(100)/99. 
    fxx= 10.^(-0.4*(xx-22.5))
    yylo= 1.-qa[0].flerr[i]/fxx
    yyhi= 1.+qa[0].flerr[i]/fxx

    ycharsize=0.8
    xcharsize=0.0001
    if(i eq 4) then xcharsize=ycharsize

    xtitle='!6Y'
    ytitle='!8f_{!6us}/!8f_{!6SDSS}!6'

    if(keyword_set(notitle) eq 0 and i eq 0) then $
      title= prefix $
    else $
      title=''

    ii=where(mag[2,*] gt 15. and mag[2,*] lt 18.)
    djs_plot, qa[ii].y, ratio[i,ii], psym=8, symsize=0.25, $
              xra=[min(qa.y), max(qa.y)], yra=[0.86, 1.14], $
              xcharsize=xcharsize, $
              ycharsize=ycharsize, xtitle=xtitle, ytitle=ytitle, $
              title=title, charsize=2.5

    xst= !X.CRANGE[0]+0.04*(!X.CRANGE[1]-!X.CRANGE[0])
    yst= !Y.CRANGE[0]+0.82*(!Y.CRANGE[1]-!Y.CRANGE[0])
    djs_xyouts, xst, yst, '!8'+bands[i]+'!6'

    djs_oplot, xx, yylo
    djs_oplot, xx, yyhi
endfor

k_end_print

return
end
