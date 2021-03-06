;+
; NAME:
;   masked_cluster
; PURPOSE:
;   make a masked SDSS image around a cluster, for ICL analysis
; CALLING SEQUENCE:
;   masked_cluster, ra, dec
; REVISION HISTORY:
;   13-Mar-2007  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro masked_cluster, ra, dec, z, obj=obj, include=include, outdir=outdir, $
                    outbase=outbase, rerun=rerun, noclobber=noclobber

if(NOT keyword_set(rerun)) then $
  rerun=[137, 161]
if(NOT keyword_set(outbase)) then $
  outbase='masked_clusters'
pixscale=4.*0.396/3600.
angsz=(1./(angdidis(z, 0.3, 0.7)*3000.))*(180./!DPI)

ihr=long(ra/15.)
idec=long(abs(dec)/2.)*2.
dsign='p'
if(dec lt 0.) then dsign='m'
outdir=getenv('DATA')+'/'+outbase+'/'+string(ihr,f='(i2.2)')+'h'
outdir=outdir+'/'+dsign+strtrim(string(idec, f='(i2.2)'),2)
prefix='mBCG-'+hogg_iau_name(ra,dec,'')
outdir=outdir+'/'+prefix
spawn, 'mkdir -p '+outdir

cd, outdir

filters=['u', 'g', 'r', 'i', 'z']
nfilter=n_elements(filters)

if(keyword_set(include)) then begin
    use_prefix='cen-'+prefix
	  doagain=keyword_set(noclobber) eq 0
		for ifilter=0L, nfilter-1L do begin
		  if(NOT file_test(use_prefix+'-'+filters[ifilter]+'.fits.gz')) then $
				doagain=1
    endfor
		if(keyword_set(doagain)) then $
    smosaic_make, ra, dec, angsz, angsz, rerun=rerun, /fpbin, $
      /global, /noran, /ivarout, prefix=use_prefix, pixscale=pixscale, $
      objlist=include, /maskobj, ncache=1, /ivarclip, /processed
endif

doagain=keyword_set(noclobber) eq 0
for ifilter=0L, nfilter-1L do begin
  if(NOT file_test(prefix+'-'+filters[ifilter]+'.fits.gz')) then $
	doagain=1
endfor
if(keyword_set(doagain)) then $
  smosaic_make, ra, dec, angsz, angsz, rerun=rerun, /fpbin, $
  /global, /maskobj, objlist={run:0, camcol:0, field:0, id:0, rerun:''}, $
  /noran, /ivarout, prefix=prefix, pixscale=pixscale, ncache=1, $
  /ivarclip, /processed

if(keyword_set(obj)) then begin
    use_prefix='all-'+prefix
	  doagain=keyword_set(noclobber) eq 0
		for ifilter=0L, nfilter-1L do begin
		  if(NOT file_test(use_prefix+'-'+filters[ifilter]+'.fits.gz')) then $
				doagain=1
    endfor
 		if(keyword_set(doagain)) then $
    smosaic_make, ra, dec, angsz, angsz, rerun=rerun, /fpbin, $
      /global, /noran, /ivarout, prefix=use_prefix, pixscale=pixscale, $
      ncache=1, /ivarclip, /processed
endif
    
end
