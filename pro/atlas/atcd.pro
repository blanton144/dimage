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
pro atcd, indx, name=name, version=version

common com_atcd, atlas, iauname

rootdir=atlas_rootdir(version=version, cdir=cdir, subname=subname)
atlasfile=cdir+'/atlas.fits'

if(n_tags(atlas) eq 0) then begin
   atlas=mrdfits(atlasfile,1, /silent)
   iauname= atlas.iauname
endif

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
