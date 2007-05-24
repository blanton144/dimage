;+
; NAME:
;   all_masked_cluster
; PURPOSE:
;   read in masked cluster list and do all of them
; CALLING SEQUENCE:
;   masked_cluster, ra, dec
; REVISION HISTORY:
;   13-Mar-2007  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro all_masked_cluster

all=mrdfits(getenv('DATA')+'/masked_clusters/maxbcg_icl_sample.fits',1)

runs=all.photoid/ulong64(10)^15L
reruns=(all.photoid mod ulong64(10)^15L)/ulong64(10L)^12L
camcols=(all.photoid mod ulong64(10)^12L)/ulong64(10L)^11L
fields=(all.photoid mod ulong64(10)^11L)/ulong64(10L)^6L

;; i==59 hits run 4512 (looking for unprocessed frames)
;; i==180 hits run 308 (no u-band skyframes!)
;; i==185(?) hits run 4512 (looking for unprocessed frames)
;; 12429 does somethiong super-weird
;; 13608 does somethiong super-weird
for i=13609, n_elements(all)-1L do begin
    splog, string(i)
    obj=sdss_findobj(all[i].ra, all[i].dec, run=runs[i], $
                     rerun=[137], childobj=include)
    masked_cluster, all[i].ra, all[i].dec, all[i].z, include=include, $
      outdir=outdir, /obj
    outcat=outdir+'/cat-'+hogg_iau_name(all[i].ra, all[i].dec,'')+'.fits'
    mwrfits, all[i], outcat, /create
    outphoto=outdir+'/photo-'+hogg_iau_name(all[i].ra, all[i].dec,'')+'.fits'
    mwrfits, include, outphoto, /create
endfor

end
