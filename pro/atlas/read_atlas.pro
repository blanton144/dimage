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
function read_atlas, notrim=notrim, measure=measure

atlas=mrdfits(getenv('DIMAGE_DIR')+'/data/atlas/atlas.fits',1)
if(arg_present(measure)) then $
  measure=mrdfits(getenv('DIMAGE_DIR')+'/data/atlas/atlas_measure.fits',1)
dup=mrdfits(getenv('DIMAGE_DIR')+'/data/atlas/atlas_duplicates.fits',1)
st=mrdfits(getenv('DIMAGE_DIR')+'/data/atlas/atlas_startrim.fits',1)

nsaid= replicate({nsaid:-1L}, n_elements(atlas))
nsaid.nsaid= lindgen(n_elements(atlas))
atlas= struct_addtags(atlas, nsaid)

if(NOT keyword_set(notrim)) then begin
    itrim= where(dup.primary gt 0 and st.isstar eq 0 and $
                 atlas.zdist gt 0., ntrim)

    atlas= atlas[itrim]
    if(n_tags(measure) gt 0) then $
      measure= measure[itrim]
endif

return, atlas

end
