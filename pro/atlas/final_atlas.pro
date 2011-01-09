;+
; NAME:
;   final_atlas
; PURPOSE:
;   Create atlas.fits
; CALLING SEQUENCE:
;   final_atlas
; COMMENTS:
;   Reads in the files:
;      $DIMAGE_DIR/data/atlas/atlas_combine.fits
;      $DIMAGE_DIR/data/atlas/atlas_iminfo.fits
;      $DIMAGE_DIR/data/atlas/atlas_velmod.fits
;   Outputs the file:
;      $DIMAGE_DIR/data/atlas/atlas_indx.fits
;      $DIMAGE_DIR/data/atlas/atlas.fits
;   Basically, restricts atlas to objects within the 
;   SDSS area, and adds in the correct distances.
;   The indx file just stores the indices selected
; REVISION HISTORY:
;   15-Aug-2010  MRB, NYU
;-
;------------------------------------------------------------------------------
pro final_atlas

combine=mrdfits(getenv('DIMAGE_DIR')+'/data/atlas/atlas_combine.fits',1)
iminfo=mrdfits(getenv('DIMAGE_DIR')+'/data/atlas/atlas_iminfo.fits',1)
velmod=mrdfits(getenv('DIMAGE_DIR')+'/data/atlas/atlas_velmod.fits',1)

ikeep= where(iminfo.run gt 0 and iminfo.score ge 0.5, nkeep)
combine=combine[ikeep]
iminfo=iminfo[ikeep]
velmod=velmod[ikeep]

mwrfits, ikeep, getenv('DIMAGE_DIR')+'/data/atlas/atlas_indx.fits', /create

atlas0= create_struct(combine[0], $
                      'run', 0, $
                      'camcol', 0B, $
                      'field', 0, $
                      'rerun', ' ', $
                      'xpos', 0., $
                      'ypos', 0., $
                      'zlg', 0., $
                      'zdist', 0., $
                      'zdist_err', 0.)
atlas= replicate(atlas0, nkeep)
struct_assign, combine, atlas
atlas.run= iminfo.run
atlas.camcol= iminfo.camcol
atlas.field= iminfo.field
atlas.rerun= iminfo.rerun
atlas.xpos= iminfo.xpos
atlas.ypos= iminfo.ypos
atlas.zlg= velmod.zlg
atlas.zdist= velmod.zdist
atlas.zdist_err= velmod.zdist_err

mwrfits, atlas, getenv('DIMAGE_DIR')+'/data/atlas/atlas.fits', /create

end
