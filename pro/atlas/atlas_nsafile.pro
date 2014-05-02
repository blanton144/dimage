;+
; NAME:
;   atlas_nsafile
; PURPOSE:
;   Create a final atlas file with all information
; CALLING SEQUENCE:
;   atlas_nsafile[, version]
; OPTIONAL INPUTS:
;   version - version
; REVISION HISTORY:
;   15-Apr-2011  MRB, NYU
;-
;------------------------------------------------------------------------------
pro atlas_nsafile, version, nosdssline=nosdssline

if(not keyword_set(version)) then $
  version= atlas_default_version()

info= atlas_version_info(version)

rootdir= atlas_rootdir(version=version, cdir=cdir)

;; read in atlas and associated information 
atlas= read_atlas(version=version, measure=measure, kcorrect=kcorrect, $
                  finalz=finalz, velmod=velmod)

;; read in the SDSS catalog, which has some meta-data of importance
sdss= mrdfits(cdir+'/sdss_atlas.fits',1)

;; now read in the SDSS line catalog, which needs to be sorted
;; correctly with respect to the full atlas
if(NOT keyword_set(nosdssline)) then begin
   osdssline= mrdfits(rootdir+'/misc/sdssline/'+version+ $
                      '/sdssline_atlas.fits',1)
   osdssline0= osdssline[0]
   struct_assign, {junk:0}, osdssline0
   sdssline= replicate(osdssline0, n_elements(atlas))
   isdssmatch= where(finalz.isdssmatch ge 0, nsdssmatch)
   if(nsdssmatch gt 0) then $
      sdssline[isdssmatch]= osdssline[finalz[isdssmatch].isdssmatch]
   sdssline0= struct_trimtags(sdssline[0], except=['RA', 'DEC', 'Z'])
endif else begin
   sdssline0= {plate:-1L, fiberid:-1, mjd:-1L}
endelse

atlas0= atlas[0]
measure0= struct_trimtags(measure[0], except=['RACEN', 'DECCEN', $
                                              'PROFRADIUS', $
                                              'PETRORAD', $
                                              'PETROR50', $
                                              'PETROR90', $
                                              'SERSIC_R50'])
if(NOT keyword_set(nosdssline)) then $
  kcorrect0= struct_trimtags(kcorrect[0], except=['ZDIST', 'RA', 'DEC']) $
else $
  kcorrect0= struct_trimtags(kcorrect[0], except=['RA', 'DEC'])

all0= create_struct(atlas0, kcorrect0, measure0, $
                    'PROFTHETA', 0.*measure[0].profradius, $
                    'PETROTHETA', 0.*measure[0].petrorad, $
                    'PETROTH50', 0.*measure[0].petror50, $
                    'PETROTH90', 0.*measure[0].petror90, $
                    'SERSIC_TH50', 0.*measure[0].sersic_r50, $
                    sdssline0, $
                    'RACAT', 0.D, 'DECCAT', 0.D, 'ZSDSSLINE', 0., $
                    'SURVEY', ' ', 'PROGRAMNAME', ' ', 'PLATEQUALITY', ' ', $
                    'TILE', 0L, 'PLUG_RA', 0.D, 'PLUG_DEC', 0.D)

all= replicate(all0, n_elements(atlas))

struct_assign, atlas, all
struct_assign, velmod, all, /nozero
struct_assign, measure, all, /nozero
struct_assign, kcorrect, all, /nozero
if(NOT keyword_set(nosdssline)) then $
   struct_assign, sdssline, all, /nozero

all.ra= measure.racen
all.dec= measure.deccen
all.racat= atlas.ra
all.deccat= atlas.dec
if(NOT keyword_set(nosdssline)) then $
   all.zsdssline= sdssline.z
all.z= finalz.z
all.zsrc= finalz.zsrc

;; convert pixels to arcsec
pixscale=0.396D
all.proftheta= measure.profradius*pixscale
all.petrotheta= measure.petrorad*pixscale
all.petroth50= measure.petror50*pixscale
all.petroth90= measure.petror90*pixscale
all.sersic_th50= measure.sersic_r50*pixscale

;; convert angles to E of N
all.phistokes= (all.phistokes+270.) MOD 180.
all.phi50= (all.phi50+270.) MOD 180.
all.phi90= (all.phi90+270.) MOD 180.
all.sersic_phi= (all.sersic_phi+270.) MOD 180.

;; use SDSS numbers from original catalog ...
isdss= where(all.isdss ge 0, nsdss)
if(nsdss gt 0) then begin
    all[isdss].plug_ra= sdss[all[isdss].isdss].plug_ra
    all[isdss].plug_dec= sdss[all[isdss].isdss].plug_dec
    all[isdss].survey= sdss[all[isdss].isdss].survey
    all[isdss].programname= sdss[all[isdss].isdss].programname
    all[isdss].platequality= sdss[all[isdss].isdss].platequality
    all[isdss].tile= sdss[all[isdss].isdss].tile
    all[isdss].plate= sdss[all[isdss].isdss].plate
    all[isdss].mjd= sdss[all[isdss].isdss].mjd
    all[isdss].fiberid= sdss[all[isdss].isdss].fiberid
endif

;; ... or preferentially the closest match
isdssmatch= where(finalz.isdssmatch ge 0, nsdss)
if(nsdss gt 0) then begin
    all[isdssmatch].plug_ra= sdss[finalz[isdssmatch].isdssmatch].plug_ra
    all[isdssmatch].plug_dec= sdss[finalz[isdssmatch].isdssmatch].plug_dec
    all[isdssmatch].survey= sdss[finalz[isdssmatch].isdssmatch].survey
    all[isdssmatch].programname= sdss[finalz[isdssmatch].isdssmatch].programname
    all[isdssmatch].platequality= sdss[finalz[isdssmatch].isdssmatch].platequality
    all[isdssmatch].tile= sdss[finalz[isdssmatch].isdssmatch].tile
    all[isdssmatch].plate= sdss[finalz[isdssmatch].isdssmatch].plate
    all[isdssmatch].mjd= sdss[finalz[isdssmatch].isdssmatch].mjd
    all[isdssmatch].fiberid= sdss[finalz[isdssmatch].isdssmatch].fiberid
endif

case info.imagetypes of
    'SDSS': begin
        nband=5L
        inband=lindgen(nband)
        outband=inband
    end 
    'SDSS GALEX': begin
        nband=7L
        inband=lindgen(nband)
        outband=[2,3,4,5,6,1,0]
    end
    default: message, 'No image type '+info.imagetypes
endcase

for i=0L, nband-1L do begin
    all.nprof[outband[i]]= measure.nprof[inband[i]]
    all.profmean[outband[i],*]= measure.profmean[inband[i],*]
    all.profmean_ivar[outband[i],*]= measure.profmean_ivar[inband[i],*]
    all.qstokes[outband[i],*]= measure.qstokes[inband[i],*]
    all.ustokes[outband[i],*]= measure.ustokes[inband[i],*]
    all.bastokes[outband[i],*]= measure.bastokes[inband[i],*]
    all.phistokes[outband[i],*]= measure.phistokes[inband[i],*]
    all.petroflux[outband[i]]= measure.petroflux[inband[i]]
    all.petroflux_ivar[outband[i]]= measure.petroflux_ivar[inband[i]]
    all.fiberflux[outband[i]]= measure.fiberflux[inband[i]]
    all.fiberflux_ivar[outband[i]]= measure.fiberflux_ivar[inband[i]]
    all.sersicflux[outband[i]]= measure.sersicflux[inband[i]]
    all.sersicflux_ivar[outband[i]]= measure.sersicflux_ivar[inband[i]]
    all.asymmetry[outband[i]]= measure.asymmetry[inband[i]]
    all.clumpy[outband[i]]= measure.clumpy[inband[i]]
    all.dflags[outband[i]]= measure.dflags[inband[i]]
endfor

outfile= rootdir+'/nsa_'+version+'.fits'
mwrfits, all, outfile, /create

end
