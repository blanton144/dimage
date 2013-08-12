;+
; NAME:
;   atlas_sixdf
; PURPOSE:
;   Convert the 6dF file into an atlas-appropriate file
; CALLING SEQUENCE:
;   sixdf_atlas
; REVISION HISTORY:
;   31-Jul-2010  MRB, NYU
;-
;------------------------------------------------------------------------------
pro atlas_sixdf, version=version

rootdir=atlas_rootdir(version=version)
if(file_test(rootdir, /dir) eq 0) then $
   message, 'No root directory for '+version+': '+rootdir
info= atlas_version_info(version)

spawn, /nosh, ['mkdir', '-p', rootdir+'/catalogs/sixdf']
spawn, ['cp', getenv('DIMAGE_DIR')+'/data/atlas/catalogs/6dFGSzDR3.txt', $
        rootdir+'/catalogs/sixdf'], /nosh

sixdf2fits, version=version

six= mrdfits(rootdir+'/catalogs/sixdf/sixdf.fits', 1)

z=six.cz/299792.
ikeep= where(z lt info.zmax)
six=six[ikeep]

mwrfits, six, rootdir+'/catalogs/sixdf_atlas.fits', /create

end

