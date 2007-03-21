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
pro masked_cluster, ra, dec, z, obj=obj, include=include, outdir=outdir

pixscale=4.*0.396/3600.
angsz=(1./(angdidis(z, 0.3, 0.7)*3000.))*(180./!DPI)

ihr=long(ra/15.)
idec=long(abs(dec)/2.)*2.
dsign='p'
if(dec lt 0.) then dsign='m'
outdir=getenv('DATA')+'/masked_clusters/'+string(ihr,f='(i2.2)')+'h'
outdir=outdir+'/'+dsign+strtrim(string(idec, f='(i2.2)'),2)
prefix='mBCG-'+hogg_iau_name(ra,dec,'')
outdir=outdir+'/'+prefix
spawn, 'mkdir -p '+outdir

cd, outdir

if(keyword_set(include)) then begin
    use_prefix='cen-'+prefix
    smosaic_make, ra, dec, angsz, angsz, rerun=[137,161], /fpbin, $
      /global, /noran, /ivarout, prefix=use_prefix, pixscale=pixscale, $
      objlist=include, /maskobj, ncache=1, /ivarclip, /processed
endif

smosaic_make, ra, dec, angsz, angsz, rerun=[137,161], /fpbin, $
  /global, /maskobj, objlist={run:0, camcol:0, field:0, id:0, rerun:''}, $
  /noran, /ivarout, prefix=prefix, pixscale=pixscale, ncache=1, $
  /ivarclip, /processed

if(keyword_set(obj)) then begin
    use_prefix='all-'+prefix
    smosaic_make, ra, dec, angsz, angsz, rerun=[137,161], /fpbin, $
      /global, /noran, /ivarout, prefix=use_prefix, pixscale=pixscale, $
      ncache=1, /ivarclip, /processed
endif
    
end
