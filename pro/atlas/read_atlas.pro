;+
; NAME:
;   read_atlas
; PURPOSE:
;   Read in atlas, with options
; CALLING SEQUENCE:
;   atlas= read_atlas([, /notrim, measure=, kcorrect=, velmod=, $
;     finalz=, version=])
; OUTPUTS:
;   atlas - [Natlas] trimmed version of atlas catalog
; OPTIONAL INPUTS:
;   version - use a particular version of atlas (not default version)
; OPTIONAL KEYWORDS:
;   /notrim - do not trim on quality
; OPTIONAL OUTPUTS:
;   measure - [Natlas] measurements of image
;   kcorrect - [Natlas] K-correction information
;   velmod - [Natlas] pec. vel. corrected distances
; COMMENTS:
;   By default (unless /notrim is set), trims out:
;     - duplicates
;     - likely stars
; REVISION HISTORY:
;   15-Apr-2011  MRB, NYU
;-
;------------------------------------------------------------------------------
function read_atlas, notrim=notrim, measure=measure, kcorrect=kcorrect, $
                     velmod=velmod, finalz=finalz, version=version, sdss=sdss

rootdir=atlas_rootdir(version=version, cdir=cdir, mdir=mdir, ddir=ddir)

atlas=mrdfits(cdir+'/atlas.fits',1)
measure=mrdfits(mdir+'/atlas_measure.fits',1)
if(arg_present(kcorrect) ne 0) then $
  kcorrect=mrdfits(ddir+'/atlas_kcorrect.fits',1)
if(arg_present(sdss) ne 0) then $
  sdss=mrdfits(cdir+'/sdss_atlas.fits',1)
if(arg_present(finalz) ne 0) then $
  finalz=mrdfits(ddir+'/atlas_finalz.fits',1)
if(arg_present(velmod) ne 0 OR keyword_set(notrim) eq 0) then $
  velmod=mrdfits(ddir+'/atlas_velmod.fits',1)
if(arg_present(dup) ne 0 OR keyword_set(notrim) eq 0) then $
  dup=mrdfits(ddir+'/atlas_duplicates.fits',1)
if(arg_present(st) ne 0 OR keyword_set(notrim) eq 0) then $
  st=mrdfits(ddir+'/atlas_startrim.fits',1)

nsaid= replicate({nsaid:-1L}, n_elements(atlas))
nsaid.nsaid= lindgen(n_elements(atlas))
atlas= struct_addtags(atlas, nsaid)

if(NOT keyword_set(notrim)) then begin
    itrim= where(dup.primary gt 0 and st.isstar eq 0 and $
                 velmod.zdist gt 0., ntrim)

    atlas= atlas[itrim]
    if(n_tags(measure) gt 0) then $
      measure= measure[itrim]
    if(n_tags(kcorrect) gt 0) then $
      kcorrect= kcorrect[itrim]
    if(n_tags(velmod) gt 0) then $
      velmod= velmod[itrim]
    if(n_tags(finalz) gt 0) then $
      finalz= finalz[itrim]
endif 

return, atlas

end
