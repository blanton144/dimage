;+
; NAME:
;   atlas_kcorrect
; PURPOSE:
;   Runs kcorrect and stores results
; CALLING SEQUENCE:
;   atlas_kcorrect
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
pro atlas_kcorrect

measure=mrdfits(getenv('DIMAGE_DIR')+'/data/atlas/atlas_measure.fits',1)
atlas=mrdfits(getenv('DIMAGE_DIR')+'/data/atlas/atlas.fits',1)

iok= where(atlas.zdist gt 0. and $
           (measure.racen ne 0. or measure.deccen ne 0.), nok)

kc= sdss_kcorrect(atlas[iok].zdist, cal=measure[iok], flux='sersic', absmag=absmag, $
                  amivar=amivar, mass=mass, rmaggies=rmaggies, omaggies=omaggies, $
                  mtol=mtol)

kcorrect0= {ra:0.D, $
            dec:0.D, $
            zdist:0., $
            omaggies:fltarr(5), $
            rmaggies:fltarr(5), $
            absmag:fltarr(5), $
            amivar:fltarr(5), $
            kcorrect:fltarr(5), $
            mtol:fltarr(5), $
            mass:0.}
kcorrect= replicate(kcorrect0, n_elements(atlas))
kcorrect.ra= measure.racen
kcorrect.dec= measure.deccen
kcorrect.zdist= atlas.zdist
kcorrect[iok].omaggies= omaggies
kcorrect[iok].rmaggies= rmaggies
kcorrect[iok].absmag= absmag
kcorrect[iok].amivar= amivar
kcorrect[iok].mtol= mtol
kcorrect[iok].kcorrect= kc
kcorrect[iok].mass= mass

mwrfits, kcorrect, getenv('DIMAGE_DIR')+'/data/atlas/atlas_kcorrect.fits', /create



end
