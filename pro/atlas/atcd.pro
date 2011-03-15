;+
; NAME:
;   atcd
; PURPOSE:
;   go to dir for a particular atlas
; CALLING SEQUENCE:
;   atcd, indx
; REVISION HISTORY:
;   3-Aug-2007  MRB, NYU
;-
;------------------------------------------------------------------------------
pro atcd, indx, subname=subname

common com_atcd, atlas

atlasfile=getenv('DIMAGE_DIR')+'/data/atlas/atlas.fits'
if(NOT keyword_set(subname)) then subname='detect'

if(n_tags(atlas) eq 0) then $
  atlas=mrdfits(atlasfile,1, /silent)

rootdir='/mount/hercules5/sdss/atlas/v0'
subdir=image_subdir(atlas[indx].ra, atlas[indx].dec, $
                    prefix=prefix, rootdir=rootdir, $
                    subname=subname)

cd, subdir

end
