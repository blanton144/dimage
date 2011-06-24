;+
; NAME:
;   read_atlas
; PURPOSE:
;   Read in atlas, with options
; CALLING SEQUENCE:
;   atlas= read_atlas([, /notrim])
; OPTIONAL KEYWORDS:
;   /notrim - do not trim on quality
; COMMENTS:
;   By default, trims out:
;     - duplicates
;     - likely stars
; REVISION HISTORY:
;   15-Apr-2011  MRB, NYU
;-
;------------------------------------------------------------------------------
function read_atlas, notrim=notrim, measure=measure, kcorrect=kcorrect, $
                     sdssline=sdssline, version=version

rootdir=atlas_rootdir(version=version, cdir=cdir, mdir=mdir, ddir=ddir)

atlas=mrdfits(cdir+'/atlas.fits',1)
if(arg_present(measure)) then $
  measure=mrdfits(mdir+'/atlas_measure.fits',1)
if(arg_present(kcorrect)) then $
  kcorrect=mrdfits(ddir+'/atlas_kcorrect.fits',1)
if(arg_present(sdssline)) then $
  sdssline=mrdfits(cdir+'/sdssline_atlas.fits',1)
dup=mrdfits(ddir+'/atlas_duplicates.fits',1)
st=mrdfits(ddir+'/atlas_startrim.fits',1)

nsaid= replicate({nsaid:-1L}, n_elements(atlas))
nsaid.nsaid= lindgen(n_elements(atlas))
atlas= struct_addtags(atlas, nsaid)

if(NOT keyword_set(notrim)) then begin
    itrim= where(dup.primary gt 0 and st.isstar eq 0 and $
                 atlas.zdist gt 0., ntrim)

    atlas= atlas[itrim]
    if(n_tags(measure) gt 0) then $
      measure= measure[itrim]
    if(n_tags(kcorrect) gt 0) then $
      kcorrect= kcorrect[itrim]
    if(n_tags(sdssline) gt 0) then $
      sdssline= sdssline[itrim]
endif

return, atlas

end
