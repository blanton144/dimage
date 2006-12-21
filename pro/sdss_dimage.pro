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
pro sdss_dimage, ra, dec, sz, rerun=rerun, nodetect=nodetect, $
                 noclobber=noclobber, links=links, gmosaic=gmosaic, $
                 all=all, hand=hand

if(n_elements(ra) gt 1) then begin
    if(n_elements(sz) ne n_elements(ra)) then $
      sz=fltarr(n_elements(ra))+sz[0]
    for i=0L, n_elements(ra)-1L do begin
        sdss_dimage, ra[i], dec[i], sz[i], rerun=rerun, nodetect=nodetect, $
          noclobber=noclobber, links=links, gmosaic=gmosaic, all=all, $
          hand=hand
    endfor
    return
endif

common com_sdss_dimage, seed

if(NOT keyword_set(sz)) then sz=0.1
if(NOT keyword_set(rerun)) then rerun=137

ihr=long(ra/15.)
idec=long(abs(dec)/2.)*2.
dsign='p'
if(dec lt 0.) then dsign='m'
outdir=getenv('DATA')+'/dimages/'+string(ihr,f='(i2.2)')+'h'
outdir=outdir+'/'+dsign+strtrim(string(idec, f='(i2.2)'),2)
prefix=(strtrim(hogg_iau_name(ra, dec,''),2))[0]
outdir=outdir+'/'+prefix
spawn, 'mkdir -p '+outdir
if(keyword_set(links)) then $
	spawn, 'ln -sf '+outdir+' '+links

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
  /fpbin, rerun=137, prefix=prefix[0], /all, /ivarout, $
	noclobber=noclobber, /dropweights
;;hdr=headfits(outdir+'/'+prefix[0]+'-z.fits.gz')
;;extast, hdr, bigast
;;bigast= create_struct(bigast, 'NAXIS', [long(sxpar(hdr, 'NAXIS1')), long(sxpar(hdr, 'NAXIS2'))])
if(keyword_set(gmosaic)) then $
  gmosaic_make, ra, dec, sz, nd=nd, gr='gr2' 
mwrfits, nd, prefix[0]+'-nd.fits', /create
spawn, 'gzip -vf '+prefix[0]+'-nd.fits'
filters=['u','g','r','i','z']
base=prefix[0]
if(NOT keyword_set(nodetect)) then $
  detect_multi, base, prefix[0]+'-'+filters+'.fits.gz', hand=hand, ref=2, $
  all=all

cd, cdir

end
;------------------------------------------------------------------------------
