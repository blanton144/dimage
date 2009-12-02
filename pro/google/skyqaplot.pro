;+
; NAME:
;   skyqaplot
; PURPOSE:
;   make plot of sky qa 
; CALLING SEQUENCE:
;   skyqaplot
; REVISION HISTORY:
;   19-Jun-2009 MRB, NYU
;-
;------------------------------------------------------------------------------
pro skyqaplot

if(0) then begin
skyqafiles= file_search(getenv('GOOGLE_DIR')+'/skyqa/137/*/skyvals-*.fits')

qa0= {run:0L, $
      camcol:0L, $
      field:0L, $
      rerun:0L, $
      skyval:fltarr(5)}

nqa=0L
for i=0L, n_elements(skyqafiles)-1L do begin
    hdr= headfits(skyqafiles[i],ext=1,errmsg=errmsg)
    if(keyword_set(hdr) gt 0 AND $
       keyword_set(errmsg) eq 0) then begin
        nqa= nqa+long(sxpar(hdr, 'NAXIS2'))
    endif
endfor

qa= replicate(qa0, nqa)
nqa=0L
for i=0L, n_elements(skyqafiles)-1L do begin
    tmp= mrdfits(skyqafiles[i],1)
    if(n_tags(tmp) gt 0) then begin
        tmp_qa=replicate(qa0, n_elements(tmp))
        struct_assign, tmp, tmp_qa
        qa[nqa:nqa+n_elements(tmp_qa)-1L]=tmp_qa
        nqa= nqa+n_elements(tmp_qa)
    endif
endfor


score= sdss_score(qa.run, qa.camcol, qa.field, rerun=qa.rerun)
save
endif
restore
help,score,qa
jj= where(score gt 0.8)
qa=qa[jj]

;; 211 - nasty Galactic emission
;; 250 - weather?
;; 259 - light source at r-field 133, ISM past 500
;; 1659 - brightening at end
;; 1739 - brightening at end
;; 2589 - u4 fit goes haywire (associated with missing field?)
;; 2711 - wacky camcol 1, and weather throughout, glitch @ 107,
;;               star @ 53
;; 2825 - massively bright star
;; 3563 - u1 fit goes haywire!
;; 3629 - bad field 11, ISM near end
;; 3600 - brightening at end
;; 3628 - ISM at end
;; 4552 - u2, u3 fits go haywire!

ii= where(qa.run ne 0 AND $
          (qa.run ne 211 OR qa.field lt 250 OR qa.field gt 350) AND $
          qa.run ne 250 AND $
          (qa.run ne 259 OR (qa.field gt 140 AND qa.field lt 500)) AND $
          (qa.run ne 1659 OR qa.field lt 305) AND $
          (qa.run ne 3628 OR qa.field lt 150) AND $
          (qa.run ne 1739 OR qa.field lt 315) AND $
          (qa.run ne 2589 OR qa.camcol ne 4) AND $
          (qa.run ne 2711) AND $
          (qa.run ne 2825 OR qa.field lt 40 or qa.field gt 50) AND $
          (qa.run ne 3563 OR qa.camcol ne 1) AND $
          (qa.run ne 3629 OR (qa.field gt 15 and qa.field lt 110)) AND $
          (qa.run ne 3600 OR qa.field lt 112) AND $
          (qa.run ne 4552 OR (qa.camcol ne 2 and qa.camcol ne 3))  $
         )
qa=qa[ii]


k_print, filename=getenv('DIMAGE_DIR')+'/tex/skyqa.ps'

!P.MULTI=[5,1,5]
!Y.MARGIN=0

for i=0L, 4L do begin 
    fmin= -0.4 
    fmax= 1.99 
    nbin=200L 
    xx= fmin+(fmax-fmin)*(findgen(nbin)+0.5)/float(nbin) 
    yy= alog10(histogram(qa.skyval[i], min=fmin, max=fmax, nbin=nbin)>1.e-1) 
    yra= [alog10(0.5), max(yy)+0.2] 
    djs_plot, xx, yy, psym=10, th=2, xra=[fmin, fmax], yra=yra, $ 
      xtitle='!8f_{!6resid}!6 (nanomaggies)!6', $ 
      ytitle='!6log_{10} !8N_{!6field}!6', /leftaxis, bottomaxis=(i eq 4) , $
      charsize=1.4
    sig= djsig(qa.skyval[i]) 
    ymodel= alog10(float(n_elements(qa))* $
                   exp(-0.5*xx^2/sig^2)/sqrt(2.*!DPI)/sig) 
    ii=where(10.^ymodel gt 1., nii) 
    scale= total(10.^ymodel[ii]*10.^yy[ii])/ $
      total(10.^ymodel[ii]*10.^ymodel[ii]) 
    ymodel=ymodel+alog10(scale) 
    djs_oplot, xx, ymodel, color='red', th=2 
    
    sigstr= strtrim(string(f='(f40.2)', sig),2)
    nout= n_elements(qa)-total(10.^ymodel)
    fout= nout/float(n_elements(qa))
    foutstr= strtrim(string(f='(f40.3)', fout),2)
    help, qa, nout, fout
    
    xst= !X.CRANGE[0]+0.7*(!X.CRANGE[1]-!X.CRANGE[0])
    yst= !Y.CRANGE[0]+0.85*(!Y.CRANGE[1]-!Y.CRANGE[0])
    djs_xyouts, xst, yst, '!8'+filtername(i)+'!6-band residuals', charsize=1.2
    yst= !Y.CRANGE[0]+0.73*(!Y.CRANGE[1]-!Y.CRANGE[0])
    djs_xyouts, xst, yst, '!8\sigma = '+sigstr+' !6nmgy', charsize=1.2
    yst= !Y.CRANGE[0]+0.61*(!Y.CRANGE[1]-!Y.CRANGE[0])
    djs_xyouts, xst, yst, '!8f_{!6out!8}!6 = '+foutstr+'!6', charsize=1.2
endfor


k_end_print

end
;------------------------------------------------------------------------------
