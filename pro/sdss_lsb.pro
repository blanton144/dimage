;+
; NAME:
;   sdss_dimage
; PURPOSE:
;   make an SDSS image and process it
; CALLING SEQUENCE:
;   sdss_dimage, ra, dec, sz [, rerun= ]
; REVISION HISTORY:
;   23-Oct-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro sdss_lsb, ra, dec, sz, rerun=rerun, nodetect=nodetect, $
              noclobber=noclobber, links=links, gmosaic=gmosaic, $
              all=all, hand=hand, runs=runs

common com_sdss_dimage, seed

if(NOT keyword_set(sz)) then sz=0.5
if(NOT keyword_set(rerun)) then rerun=['137', '161']

ihr=long(ra/15.)
idec=long(abs(dec)/2.)*2.
dsign='p'
if(dec lt 0.) then dsign='m'
outdir=getenv('DATA')+'/lsb/'+string(ihr,f='(i2.2)')+'h'
outdir=outdir+'/'+dsign+strtrim(string(idec, f='(i2.2)'),2)
prefix=(strtrim(hogg_iau_name(ra, dec,''),2))[0]
outdir=outdir+'/'+prefix
spawn, 'mkdir -p '+outdir

spawn, 'pwd', cdir
cdir=cdir[0]

cd, outdir
doit=1
if(keyword_set(noclobber)) then begin
  doit=0
  if(NOT file_test(outdir+'/'+prefix[0]+'-u.fits.gz')) then doit=1 
  if(NOT file_test(outdir+'/'+prefix[0]+'-g.fits.gz')) then doit=1 
  if(NOT file_test(outdir+'/'+prefix[0]+'-r.fits.gz')) then doit=1 
  if(NOT file_test(outdir+'/'+prefix[0]+'-i.fits.gz')) then doit=1 
  if(NOT file_test(outdir+'/'+prefix[0]+'-z.fits.gz')) then doit=1 
endif
if(keyword_set(doit)) then $
  smosaic_make, ra, dec, sz, sz, /global, seed=seed, $
  /fpbin, rerun=rerun, prefix=prefix[0], /ivarout, $
  noclobber=noclobber, /dropweights, /sheldon, run=runs

filters=['u','g','r','i','z']
base=prefix[0]
splog, prefix[0]
if(file_test(prefix[0]+'-'+filters[2]+'.fits.gz')) then begin
if(NOT keyword_set(nodetect)) then $
  detect_lsb, base, prefix[0]+'-'+filters+'.fits.gz', hand=hand, ref=2, $
  all=all, gsmooth=8., noclobber=noclobber
endif

cd, cdir

end
;------------------------------------------------------------------------------
