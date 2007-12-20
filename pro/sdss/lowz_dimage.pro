;+
; NAME:
;   lowz_dimage
; PURPOSE:
;   go to each lowz, make an image, and analyze it
; CALLING SEQUENCE:
;   lowz_dimage [, sample=]
; REVISION HISTORY:
;   3-Aug-2004  MRB, NYU
;-
;------------------------------------------------------------------------------
pro lowz_dimage, sample=sample, clobber=clobber, $
                 nodetect=nodetect, redetect=redetect, start=start, $
                 nd=nd, sort=sort

noclobber=keyword_set(clobber) eq 0

if(NOT keyword_set(sample)) then sample='dr7'
if(NOT keyword_set(start)) then start=0L

cand=gz_mrdfits(getenv('VAGC_REDUX')+'/lowz/lowz_candidates.'+sample+ $
                '.fits', 1)

lowzdir=getenv('VAGC_REDUX')+'/lowz/'
rootdir=lowzdir


if(NOT keyword_set(nd)) then nd=n_elements(cand)-1L

isort=lindgen(n_elements(cand))
if(keyword_set(sort)) then $
  isort=sort(cand.mag)

iexclude=[3208, 2926, 2740]

for istep=start, nd do begin
    i=isort[istep]
    splog, i
    ii=where(iexclude eq i, nii)
    if(nii eq 0) then begin
        subdir=image_subdir(cand[i].ra, cand[i].dec, $
                            prefix=prefix, rootdir=rootdir)
        spawn, 'mkdir -p '+subdir

        sc=1.-((((cand[i].mag-10.)/(16.-10.))>0.)<1.)
        sz=0.1+0.25*sc
        
        cd, subdir
        smosaic_dimage, cand[i].ra, cand[i].dec, sz=sz, prefix=prefix, $
          noclobber=noclobber

        rim=mrdfits(subdir+'/'+prefix+'-r.fits.gz',0,hdr)
        if(keyword_set(rim)) then begin
            nx=(size(rim,/dim))[0]
            ny=(size(rim,/dim))[1]
            npix=n_elements(rim)
            izero=where(rim eq 0., nzero)
            fzero=float(nzero)/float(npix)
            
            gmosaic_make, cand[i].ra, cand[i].dec, sz, prefix=prefix, /sky, $
              noclobber=noclobber
            
            if(keyword_set(nodetect) eq 0 AND $
               fzero lt 0.2) then begin
                iseed=i
                detect, noclobber=(keyword_set(redetect) eq 0), /cen, $
                  glim=10., gsmooth=4., seed=iseed
            endif
        endif
    endif
endfor

end
