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

if(NOT keyword_set(sample)) then sample='dr6'
if(NOT keyword_set(start)) then start=0L

lowz=gz_mrdfits(getenv('VAGC_REDUX')+'/lowz/lowz_plus_ned.fits', 1)

lowzdir=getenv('VAGC_REDUX')+'/lowz/'
rootdir=getenv('DATA')+'/lowz-sdss'

if(NOT keyword_set(nd)) then nd=n_elements(lowz)-1L

isort=lindgen(n_elements(lowz))
iexclude=-1

;; set maximum and minimum sizes
pixscale=0.396/3600.
minsz=100.*pixscale
maxsz=3000.*pixscale

for istep=start, nd do begin
    i=isort[istep]
    splog, i
    ii=where(iexclude eq i, nii)
    if(nii eq 0 AND lowz[i].icomb ge 0) then begin
        subdir=image_subdir(lowz[i].ra, lowz[i].dec, $
                            prefix=prefix, rootdir=rootdir)
        spawn, 'mkdir -p '+subdir

        ;; get diameter in deg
	      ldiam=0.
	      ndiam=0.
        if(lowz[i].lowz eq 1) then ldiam= lowz[i].petroth90[2]*3.5 
        if(lowz[i].ned eq 1) then ndiam= lowz[i].ned_major*3.5 
        diam=max([ldiam, ndiam])/3600. 
        
        ;; set size of image to be a bit bigger
				sz= ((1.5*diam) > minsz)<maxsz
        
        cd, subdir
        smosaic_dimage, lowz[i].ra, lowz[i].dec, sz=sz, prefix=prefix, $
          noclobber=noclobber, minscore=0.

        rim=mrdfits(subdir+'/'+prefix+'-r.fits.gz',0,hdr)
        if(keyword_set(rim)) then begin
            nx=(size(rim,/dim))[0]
            ny=(size(rim,/dim))[1]
            npix=n_elements(rim)
            izero=where(rim eq 0., nzero)
            fzero=float(nzero)/float(npix)
            
            if(0) then $
            gmosaic_make, lowz[i].ra, lowz[i].dec, sz, prefix=prefix, /sky, $
              noclobber=noclobber
            
            if(keyword_set(nodetect) eq 0 AND $
               fzero lt 0.2) then begin
                iseed=i
                detect, noclobber=(keyword_set(redetect) eq 0), /cen, $
                  glim=10., gsmooth=4., seed=iseed, /gbig, /nogalex, $
                  /nostarim
            endif
        endif
    endif
endfor

end
