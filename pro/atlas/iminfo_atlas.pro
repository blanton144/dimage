;+
; NAME:
;   iminfo_atlas
; PURPOSE:
;   Get SDSS imaging coverage of all combined atlas positions
; CALLING SEQUENCE:
;   iminfo_atlas
; COMMENTS:
;   Reads in the file:
;      atlas_rootdir/catalogs/atlas_combine.fits
;   Outputs the file:
;      atlas_rootdir/catalogs/atlas_iminfo.fits
; REVISION HISTORY:
;   15-Aug-2010  MRB, NYU
;-
;------------------------------------------------------------------------------
pro iminfo_atlas, version=version

common com_iminfo_atlas, atlas, flist, run

rootdir=atlas_rootdir(sample=sample, version=version)

if(n_tags(atlas) eq 0) then $
  atlas=mrdfits(rootdir+'/catalogs/atlas_combine.fits',1)

if(n_tags(flist) eq 0 or n_elements(run) eq 0) then begin
    window_read, flist=flist
    ikeep= where(flist.rerun eq '301' and flist.run ne 1473)
    run= (uniqtag(flist[ikeep], 'run')).run
endif

;; check what field, if any, it is in
tmp_iminfo= sdss_findimage(atlas.ra, atlas.dec, rerun=301, /best, run=run)

;; add score to structure
iminfo0= create_struct(tmp_iminfo[0], 'score', 0.)
iminfo= replicate(iminfo0, n_elements(tmp_iminfo))
struct_assign, tmp_iminfo, iminfo

;; find score of each field
isdss= where(iminfo.run gt 0, nsdss)
if(nsdss gt 0) then begin
   iminfo[isdss].score= sdss_score(iminfo[isdss].run, iminfo[isdss].camcol, $
                                   iminfo[isdss].field, $
                                   rerun=iminfo[isdss].rerun, $
                                   /ignoreframesstatus)
endif

hdr=['']
sxaddpar,hdr, 'TREE_DIR', getenv('TREE_DIR')
mwrfits, iminfo, rootdir+'/catalogs/atlas_iminfo.fits', /create

end
