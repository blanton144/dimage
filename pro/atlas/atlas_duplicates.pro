;+
; NAME:
;   atlas_duplicates
; PURPOSE:
;   Mark duplications in atlas
; CALLING SEQUENCE:
;   atlas_duplicates
; COMMENTS:
;   Reads in the files:
;      $DIMAGE_DIR/data/atlas/atlas.fits
;      $DIMAGE_DIR/data/atlas/atlas_measure.fits
;   Outputs the file:
;      $DIMAGE_DIR/data/atlas/atlas_duplicates.fits
;   Basically, identifies cases where the 
;   central object has the same RA/Dec in multiple 
;   entries, and picks that with the largest SIZE
;   as the primary. Output file has:
;       .PRIMARY - is a unique object (requires GOOD)
;       .GOOD - ra/dec center is non-zero
;       .IPRIMARY - index of primary for this duplicate (or self)
;       .NDUP - number of duplicates in this group
; REVISION HISTORY:
;   15-Aug-2010  MRB, NYU
;-
;------------------------------------------------------------------------------
pro atlas_duplicates

measure=mrdfits(getenv('DIMAGE_DIR')+'/data/atlas/atlas_measure.fits',1)
atlas=mrdfits(getenv('DIMAGE_DIR')+'/data/atlas/atlas.fits',1)

dup= replicate({primary:0, good:1, iprimary:-1L, ndup:0}, $
               n_elements(measure))

inotok= where(measure.racen eq 0. and measure.deccen eq 0., nnotok)
if(nnotok gt 0) then $
  dup[inotok].good=0
iok= where(dup.good, nok)

ing= spheregroup(measure[iok].racen, measure[iok].deccen, 4./3600., $
                 firstg=firstg, multg=multg, nextg=nextg)
ng= max(ing)+1L

for i=0L, ng-1L do begin
    j= firstg[i]
    ig= j
    while(nextg[j] ne -1) do begin
        ig=[ig, nextg[j]]
        j=nextg[j]
    endwhile
    msize= max(atlas[iok[ig]].size, imax)
    dup[iok[ig[imax]]].primary=1
    dup[iok[ig]].iprimary=iok[ig[imax]]
    dup[iok[ig]].ndup=n_elements(ig)
endfor

mwrfits, dup, getenv('DIMAGE_DIR')+'/data/atlas/atlas_duplicates.fits', /create



end
