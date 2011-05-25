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
pro atcd, indx, name=name, subname=subname, sample=sample

common com_atcd, atlas, iauname

if(NOT keyword_set(subname)) then subname='detect'

rootdir=atlas_rootdir(sample=sample)
atlasfile=getenv('DIMAGE_DIR')+'/data/atlas/atlas.fits'
if(keyword_set(sample)) then begin
    atlasfile=getenv('DIMAGE_DIR')+'/data/atlas/atlas_sample.fits'
endif

if(n_tags(atlas) eq 0) then $
  atlas=mrdfits(atlasfile,1, /silent)
if(n_elements(iauname) eq 0) then $
  iauname= hogg_iau_name(atlas.ra, atlas.dec, '')

if(n_elements(indx) eq 0) then begin
    if(keyword_set(name)) then begin
        indx= where(iauname eq name, nindx)
        if(nindx eq 0) then begin
            splog, 'No such name '+name
        endif
    endif else begin
        splog, 'Must specify INDX'
    endelse
endif

subdir=image_subdir(atlas[indx].ra, atlas[indx].dec, $
                    prefix=prefix, rootdir=rootdir, $
                    subname=subname)

cd, subdir

end
