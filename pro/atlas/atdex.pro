;+
; NAME:
;   atdex
; PURPOSE:
;   dexplore an atlas
; CALLING SEQUENCE:
;   sdss_sfit, plate, fiberid, mjd [, sfit= ]
; REVISION HISTORY:
;   3-Aug-2007  MRB, NYU
;-
;------------------------------------------------------------------------------
pro atdex, indx, name=name, subname=subname, sample=sample, twomass=twomass

common com_atdex, atlas

if(n_elements(name) gt 0) then $
  nat= n_elements(name) $
else $
  nat=n_elements(indx)

atlasfile=getenv('DIMAGE_DIR')+'/data/atlas/atlas.fits'
if(n_tags(atlas) eq 0) then $
  atlas=mrdfits(atlasfile,1, /silent)

i=0L
while (i lt nat) do begin
    if(n_elements(name) eq 0) then begin
        splog, indx[i]
        atcd, indx[i], subname=subname, sample=sample
        tmp_indx=indx[i]
    endif else begin
        atcd, tmp_indx, name=name[i], subname=subname, sample=sample
    endelse
    
    dexplore, /cen, twomass=twomass, next=next, previous=previous, finish=finish, $
      ra=atlas[tmp_indx].ra, dec=atlas[tmp_indx].dec
    delvarx, tmp_indx
    if(keyword_set(finish)) then return
    if(keyword_set(next)) then i=i+1
    if(keyword_set(previous)) then i=(i-1)>0L
endwhile

end
