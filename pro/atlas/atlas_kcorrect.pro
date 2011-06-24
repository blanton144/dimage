;+
; NAME:
;   atlas_kcorrect
; PURPOSE:
;   Runs kcorrect and stores results
; CALLING SEQUENCE:
;   atlas_kcorrect
; COMMENTS:
;   Reads in the files:
;      atlas_rootdir/catalogs/atlas.fits
;      atlas_rootdir/catalogs/atlas_measure.fits
;   Outputs the file:
;      atlas_rootdir/catalogs/atlas_duplicates.fits
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
pro atlas_kcorrect_sdss_maggies, measure, nmgy, nmgy_ivar

errband=[0.05,0.02,0.02,0.02,0.03]

nmgy= measure.sersicflux[0:4]
nmgy_ivar= measure.sersicflux_ivar[0:4]
k_minerror, nmgy, nmgy_ivar
k_abfix, nmgy, nmgy_ivar

end
;
pro atlas_kcorrect_galex_maggies, measure, nmgy, nmgy_ivar

errband=[0.04,0.04]

nmgy= fltarr(2, n_elements(measure))
nmgy_ivar= fltarr(2, n_elements(measure))
nmgy[0,*]= measure.sersicflux[6]
nmgy[1,*]= measure.sersicflux[5]
nmgy_ivar[0,*]= measure.sersicflux_ivar[6]
nmgy_ivar[1,*]= measure.sersicflux_ivar[5]
k_minerror, nmgy, nmgy_ivar, errband

end
;
pro atlas_kcorrect, version=version

sfilterlist= 'sdss_'+['u','g','r','i','z']+'0.par'
gfilterlist= 'galex_'+['FUV','NUV']+'.par'

info= atlas_version_info(version)
rootdir=atlas_rootdir(version=version, mdir=mdir, cdir=cdir, ddir=ddir)

measure=mrdfits(mdir+'/atlas_measure.fits',1)
atlas=mrdfits(cdir+'/atlas.fits',1)

case info.kcorrect of
    'sdss': begin
        nband=5L
        fkcorrect='sdss_kcorrect'
        atlas_kcorrect_sdss_maggies, measure, nmgy, nmgy_ivar
        filterlist= sfilterlist
    end
    'galex': begin
        nband=7L
        fkcorrect='galex_kcorrect'
        nmgy= fltarr(nband, n_elements(measure))
        nmgy_ivar= fltarr(nband, n_elements(measure))
        atlas_kcorrect_sdss_maggies, measure, snmgy, snmgy_ivar
        nmgy[2:6, *]= snmgy
        nmgy_ivar[2:6, *]= snmgy_ivar
        atlas_kcorrect_galex_maggies, measure, gnmgy, gnmgy_ivar
        nmgy[0:1, *]= gnmgy
        nmgy_ivar[0:1, *]= gnmgy_ivar
        filterlist= [gfilterlist, sfilterlist]
    end
    default: message, 'No such kcorrection '+info.kcorrect
endcase

iok= where(atlas.zdist gt 0. and $
           (measure.racen ne 0. or measure.deccen ne 0.), nok)

kcorrect, nmgy[*,iok]*1.e-9, nmgy_ivar[*,iok]*1.e+18, atlas[iok].zdist, kc, $
  band_shift=0., filterlist=filterlist, mass=mass, absmag=absmag, $
  rmaggies=rmgy, amivar=amivar, b300=b300, b1000=b1000, mets=mets, $
  mtol=mtol
rnmgy= 1.e+9*rmgy

kcorrect0= {ra:0.D, $
            dec:0.D, $
            zdist:0., $
            nmgy:fltarr(nband), $
            nmgy_ivar:fltarr(nband), $
            ok:0, $
            rnmgy:fltarr(nband), $
            absmag:fltarr(nband), $
            amivar:fltarr(nband), $
            kcorrect:fltarr(nband), $
            mtol:fltarr(nband), $
            b300:0., $
            b1000:0., $
            mets:0., $
            mass:0.}
kcorrect= replicate(kcorrect0, n_elements(atlas))
kcorrect.ra= measure.racen
kcorrect.dec= measure.deccen
kcorrect.zdist= atlas.zdist
kcorrect.nmgy= nmgy
kcorrect.nmgy_ivar= nmgy_ivar
kcorrect[iok].ok= 1
kcorrect[iok].rnmgy= rnmgy
kcorrect[iok].absmag= absmag
kcorrect[iok].amivar= amivar
kcorrect[iok].kcorrect= kc
kcorrect[iok].mtol= mtol
kcorrect[iok].b300= b300
kcorrect[iok].b1000= b1000
kcorrect[iok].mets= mets
kcorrect[iok].mass= mass

mwrfits, kcorrect, ddir+'/atlas_kcorrect.fits', /create

end
