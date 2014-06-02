;+
; NAME:
;   atlas_petro_kcorrect
; PURPOSE:
;   Runs kcorrect on the elliptical Petrosian fluxes
; CALLING SEQUENCE:
;   atlas_petro_kcorrect
; COMMENTS:
; REVISION HISTORY:
;   15-Aug-2010  MRB, NYU
;-
;------------------------------------------------------------------------------
pro petro_kcorrect_sdss_maggies, measure, extinction, nmgy, nmgy_ivar

errband=[0.05,0.02,0.02,0.02,0.03]

nmgy= measure.petroflux[2:6]*10.^(0.4*extinction)
;;nmgy_ivar= measure.sersicflux_ivar[2:6]*10.^(-0.8*extinction)
nmgy_ivar= fltarr(5, n_elements(measure))
for i=0L, 4L do $
  nmgy_ivar[i,*]= float(nmgy[i,*] ne 0.)/ $
  ((errband[i]^2*nmgy[i,*])+float(nmgy[i,*] eq 0.))
k_minerror, nmgy, nmgy_ivar
k_abfix, nmgy, nmgy_ivar

end
;
pro petro_kcorrect_galex_maggies, measure, extinction, nmgy, nmgy_ivar

errband=[0.04,0.04]

nmgy= fltarr(2, n_elements(measure))
nmgy_ivar= fltarr(2, n_elements(measure))
nmgy[0,*]= measure.petroflux[0]*10.^(0.4*extinction[0,*])
nmgy[1,*]= measure.petroflux[1]*10.^(0.4*extinction[1,*])
;;nmgy_ivar[0,*]= measure.sersicflux_ivar[0]*10.^(-0.8*extinction[0,*])
;;nmgy_ivar[1,*]= measure.sersicflux_ivar[1]*10.^(-0.8*extinction[1,*])
for i=0L, 1L do $
  nmgy_ivar[i,*]= float(nmgy[i,*] ne 0.)/ $
  ((errband[i]^2*nmgy[i,*])+float(nmgy[i,*] eq 0.))
k_minerror, nmgy, nmgy_ivar, errband

end
;
pro atlas_petro_kcorrect, version=version

if(NOT keyword_set(version)) then $
  version= atlas_default_version()

sfilterlist= 'sdss_'+['u','g','r','i','z']+'0.par'
gfilterlist= 'galex_'+['FUV','NUV']+'.par'

info= atlas_version_info(version)
rootdir=atlas_rootdir(version=version, mdir=mdir, cdir=cdir, ddir=ddir)

nsa= read_nsa()
petro= mrdfits('petro_'+version+'.fits',1)

glactc, nsa.ra, nsa.dec, 2000., gl, gb, 1, /deg
ebv= dust_getval(gl, gb, /noloop)
redfac= [ 8.29, 8.18, 5.155, 3.793, 2.751, 2.086, 1.479 ]
extinction= redfac#ebv

case info.kcorrect of
    'sdss': begin
        nband=5L
        fkcorrect='sdss_kcorrect'
        petro_kcorrect_sdss_maggies, petro, extinction[2:6,*], $
          nmgy, nmgy_ivar
        filterlist= sfilterlist
    end
    'galex': begin
        nband=7L
        fkcorrect='galex_kcorrect'
        nmgy= fltarr(nband, n_elements(petro))
        nmgy_ivar= fltarr(nband, n_elements(petro))
        petro_kcorrect_sdss_maggies, petro, extinction[2:6,*], $
          snmgy, snmgy_ivar
        nmgy[2:6, *]= snmgy
        nmgy_ivar[2:6, *]= snmgy_ivar
        petro_kcorrect_galex_maggies, petro, extinction[0:1,*], $
          gnmgy, gnmgy_ivar
        nmgy[0:1, *]= gnmgy
        nmgy_ivar[0:1, *]= gnmgy_ivar
        izero= where(abs(nmgy) lt 1.d-20, nzero)
        if(nzero gt 0) then $
          nmgy_ivar[izero]=0.
        filterlist= [gfilterlist, sfilterlist]
    end
    default: message, 'No such kcorrection '+info.kcorrect
endcase

iok= where(nsa.zdist gt 0. and $
           (nsa.ra ne 0. or nsa.dec ne 0.) and $
           total(nmgy_ivar,1) ne 0., nok)

kcorrect, nmgy[*,iok]*1.e-9, nmgy_ivar[*,iok]*1.e+18, nsa[iok].zdist, kc, $
  band_shift=0., filterlist=filterlist, mass=mass, absmag=absmag, $
  rmaggies=rmgy, amivar=amivar, b300=b300, b1000=b1000, mets=mets, $
  mtol=mtol, coeff=coeff
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
            extinction:fltarr(nband), $
            kcorrect:fltarr(nband), $
            kcoeff:fltarr(5L), $
            mtol:fltarr(nband), $
            b300:0., $
            b1000:0., $
            mets:0., $
            mass:0.}
kcorrect= replicate(kcorrect0, n_elements(nsa))
kcorrect.ra= nsa.ra
kcorrect.dec= nsa.dec
kcorrect.zdist= nsa.zdist
kcorrect.nmgy= nmgy
kcorrect.nmgy_ivar= nmgy_ivar
kcorrect[iok].ok= 1
kcorrect[iok].rnmgy= rnmgy
kcorrect[iok].absmag= absmag
kcorrect[iok].amivar= amivar
kcorrect[iok].extinction= extinction[*,iok]
kcorrect[iok].kcorrect= kc
kcorrect[iok].mtol= mtol
kcorrect[iok].b300= b300
kcorrect[iok].b1000= b1000
kcorrect[iok].mets= mets
kcorrect[iok].mass= mass
kcorrect[iok].kcoeff= coeff

mwrfits, kcorrect, 'petro_kcorrect_'+version+'.fits', /create

end
