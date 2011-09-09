;+
; NAME:
;   finalz_atlas
; PURPOSE:
;   Re-match to SDSS to derive final redshift
; CALLING SEQUENCE:
;   finalz_atlas
; COMMENTS:
;   Uses read_atlas() to get measure, atlas heliocentric redshift,
;     plus sdssline
;   Matches to sdssline and adds closest SDSS match where appropriate
;   Writes out finalz_atlas.fits with columns:
;     .RA
;     .DEC
;     .Z
;     .ZSRC
;     .ISDSS
;   These numbers should be used for subsequent derived paramaters
;     as well as the final NSA file.
; REVISION HISTORY:
;   15-Aug-2010  MRB, NYU
;-
;------------------------------------------------------------------------------
pro finalz_atlas, version=version

rootdir=atlas_rootdir(version=version, cdir=cdir, ddir=ddir)

atlas=read_atlas(measure=measure, /notrim)
sdssline= mrdfits(rootdir+'/misc/sdssline/'+version+'/sdssline_atlas.fits',1)
sdss= mrdfits(cdir+'/sdss_atlas.fits',1)

fz1={ z:-1., $
      zsrc:' ', $
      isdssmatch:-1L, $
      ra:0.D, $
      dec:0.D}
fz=replicate(fz1, n_elements(atlas))
fz.ra= measure.racen
fz.dec= measure.deccen
fz.isdssmatch= -1L
fz.z= atlas.z
fz.zsrc= atlas.zsrc

iok= where(fz.ra ne 0 or fz.dec ne 0, nok)
if(nok gt 0) then begin
    spherematch, fz[iok].ra, fz[iok].dec, sdss.plug_ra, sdss.plug_dec, 2./3600., m1, m2, max=0
    isort= sort(m1)
    iuniq= uniq(m1[isort])
    istart=0L
    for i=0L, n_elements(iuniq)-1L do begin
        iend= iuniq[i]
        icurr= isort[istart:iend]
        fz[iok[m1[icurr[0]]]].isdssmatch= m2[icurr[0]]
        fz[iok[m1[icurr[0]]]].z= sdssline[m2[icurr[0]]].z
        fz[iok[m1[icurr[0]]]].zsrc= 'sdss'
        istart= iend+1L
    endfor
endif

mwrfits, fz, ddir+'/atlas_finalz.fits', /create

end
