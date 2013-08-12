;+
; NAME:
;   final_atlas
; PURPOSE:
;   Create atlas.fits
; CALLING SEQUENCE:
;   final_atlas
; COMMENTS:
;   Reads in the files:
;      atlas_rootdir/catalogs/atlas_combine.fits
;      atlas_rootdir/catalogs/atlas_iminfo.fits
;   Outputs the file:
;      atlas_rootdir/catalogs/atlas_indx.fits
;      atlas_rootdir/catalogs/atlas.fits
;   Basically, restricts atlas to objects within the 
;   SDSS area, and adds in the correct distances.
;   The indx file just stores the indices selected
; REVISION HISTORY:
;   15-Aug-2010  MRB, NYU
;-
;------------------------------------------------------------------------------
pro final_atlas, version=version

rootdir=atlas_rootdir(version=version)

combine=mrdfits(rootdir+'/catalogs/atlas_combine.fits',1)
iminfo=mrdfits(rootdir+'/catalogs/atlas_iminfo.fits',1)

ikeep= where(iminfo.run gt 0 and iminfo.score ge 0.5, nkeep)
combine=combine[ikeep]
iminfo=iminfo[ikeep]

mwrfits, ikeep, rootdir+'/catalogs/atlas_indx.fits', /create

atlas0= create_struct('iauname', ' ', $
                      'subdir', ' ', $
                      combine[0], $
                      'run', 0, $
                      'camcol', 0B, $
                      'field', 0, $
                      'rerun', ' ', $
                      'xpos', 0., $
                      'ypos', 0.)
atlas= replicate(atlas0, nkeep)
struct_assign, combine, atlas
atlas.iauname= hogg_iau_name(atlas.ra, atlas.dec, '')
for i=0L, n_elements(atlas)-1L do $
   atlas[i].subdir=strmid(image_subdir(atlas[i].ra, atlas[i].dec, $
                                       subname=' ', rootdir=' '), 4)
atlas.run= iminfo.run
atlas.camcol= iminfo.camcol
atlas.field= iminfo.field
atlas.rerun= iminfo.rerun
atlas.xpos= iminfo.xpos
atlas.ypos= iminfo.ypos

mwrfits, atlas, rootdir+'/catalogs/atlas.fits', /create

end
