;+
; NAME: 
;   convert_wise_cat
; PURPOSE: 
;   Convert the searched WISE catalog
; CALLING SEQUENCE: 
;   convert_wise_cat
; COMMENTS:
;   Reads in:
;    wise_prelim.wise_prelim_p3as_psd9504.fits
;   (created using read_wise_cat.pro) and also
;    wise_atlas_search.txt
;   to create:
;     atlas_wise_cat.fits
;   in parallel with the atlas.fits file
;   Has SOUGHT, which indicates whether each point
;   was originally sought
; REVISION HISTORY:
;   14-Apr-2011 MRB NYU
;-
pro convert_wise_cat

wise=mrdfits('wise_prelim.wise_prelim_p3as_psd17879.fits',1)

nsearch= numlines('wise_atlas_search.txt')-1L
openr, unit, 'wise_atlas_search.txt', /get_lun
line=' '
readf, unit, line
indx= lonarr(nsearch)
for i=0L, nsearch-1L do begin
    readf, unit, line
    words= strsplit(line,',', /extr)
    indx[i]= long(words[0])
endfor
free_lun, unit

so= replicate({SOUGHT:0}, n_elements(wise))
wise= struct_addtags(wise, so)

atlas= mrdfits(getenv('DIMAGE_DIR')+'/data/atlas/atlas.fits',1)

atwise0= wise[0]
struct_assign, {junk:0}, atwise0
atwise= replicate(atwise0, n_elements(atlas))
atwise[wise.id_u]= wise
atwise[indx].sought=1

mwrfits, atwise, 'atlas_wise_cat.fits', /create

END 
