;+
; NAME:
;   biggal_tests
; PURPOSE:
;   Make FITS images of a number of big galaxies from NED
; CALLING SEQUENCE:
;   biggal_tests [, ngal=, seed=]
; OPTIONAL INPUTS:
;   ngal - number of tests to run (default 20)
;   seed - random seed (default -10)
; COMMENTS:
;   Write outputs to:
;     $GOOGLE_DIR/biggals/montage/[name]/[name]-[ugriz].fits.gz
;     $GOOGLE_DIR/biggals/dimage/[name]/[name]-[ugriz].fits.gz
;   for random NED galaxies selected from:
;     $DATA/lowz-sdss/lowz_plus_ned.dr6.fits
; REVISION HISTORY:
;   25-Oct-2007 MRB, NYU
;-
pro biggal_tests, seed=seed, ngal=ngal

common com_biggal_tests, lowz

if(NOT keyword_set(ngal)) then ngal= 200L
if(NOT keyword_set(seed)) then seed= -14L

if(n_tags(lowz) eq 0) then begin
    lowz= mrdfits(getenv('DATA')+'/lowz-sdss/lowz_plus_ned.dr6.fits',1)
    glactc, lowz.ra, lowz.dec, 2000., gl, gb, 1, /deg
    ikeep= where(lowz.ned gt 0 and lowz.icomb ge 0 and gb gt 20. and $
                 (lowz.petroflux[2] gt 1000. OR lowz.ned_mag lt 15.))
    lowz=lowz[ikeep]
endif
nlowz= n_elements(lowz)

indx= shuffle_indx(nlowz, num_sub=ngal, seed=seed)

filters=['u', 'g', 'r', 'i', 'z']
sz=0.1
for i=0L, ngal-1L do begin
    name=strjoin(strsplit(strtrim(lowz[indx[i]].ned_name1),/extr),'_')

    outdir= getenv('GOOGLE_DIR')+'/biggals/dimage/'+name
    spawn, 'mkdir -p '+outdir
    if(file_test(name+'-z.fits.gz') eq 0 OR $
       keyword_set(clobber) gt 0) then begin
        smosaic_make, lowz[indx[i]].ra, lowz[indx[i]].dec, sz, sz, $
          rerun=137, /global, /dropweights, prefix=outdir+'/'+name, $
          /ignoreframesstatus, minscore=0.5, /processed
    endif
    spawn, 'gzip -vf '+outdir+'/'+name+'-?.fits'

    outdir= getenv('GOOGLE_DIR')+'/biggals/montage/'+name
    spawn, 'mkdir -p '+outdir
    rastr= strtrim(string(f='(f40.20)', lowz[indx[i]].ra),2)
    decstr= strtrim(string(f='(f40.20)', lowz[indx[i]].dec),2)
    sizestr= strtrim(string(f='(f40.5)', sz),2)
    for j=0L, n_elements(filters)-1L do begin
        outfile= outdir+'/'+name+'-'+filters[j]+'.fits'
        spawn, 'getMontage '+outfile+' '+filters[j]+' '+ $
          rastr+' '+decstr+' '+sizestr
        spawn, 'gzip -vf '+outfile
    endfor
    montage_recal,  outdir+'/'+name
endfor

end
