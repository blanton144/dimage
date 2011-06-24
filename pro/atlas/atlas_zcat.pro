;+
; NAME:
;   atlas_zcat
; PURPOSE:
;   builds the ZCAT catalog for atlas
; CALLING SEQUENCE:
;   atlas_zcat
; REVISION HISTORY:
;   18-Nov-2003  Written by Mike Blanton, NYU
;   15-Aug-2010  Fixed for atlas, MRB NYU
;-
;------------------------------------------------------------------------------
pro atlas_zcat, version=version

rootdir=atlas_rootdir(sample=sample, version=version)

zcat=mrdfits(rootdir+'/catalogs/zcat/zcat-velocity.fits',1)

ikeep= where(zcat.z lt 0.055 and $
             zcat.z gt -0.05 and $
             zcat.z ne 0. and $
             strmatch(zcat.comments, 'SDSS*') eq 0)
zcat=zcat[ikeep]

mwrfits, zcat, rootdir+'/catalogs/zcat_atlas.fits', /create

end
