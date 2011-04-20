;+
; NAME:
;   atlas_startrim
; PURPOSE:
;   Identify cases where a bright star has been detected 
; CALLING SEQUENCE:
;   atlas_startrim
; COMMENTS:
;   Reads in the files:
;      $DIMAGE_DIR/data/atlas/atlas.fits
;      $DIMAGE_DIR/data/atlas/atlas_measure.fits
;   Outputs the file:
;      $DIMAGE_DIR/data/atlas/atlas_startrim.fits
;   Basically, identifies cases where the object
;   that has been measured is in fact a bright star,
;   either based on its structural parameters or that 
;   it is in the Tycho-2 catalog.
;       .ISSTAR - is a unique object (requires GOOD)
;       .GOOD - actually a good measurement
;       .ITYCHO - index in Tycho-2 catalog (-1 if none)
; REVISION HISTORY:
;   15-Aug-2010  MRB, NYU
;-
;------------------------------------------------------------------------------
pro atlas_startrim

measure=mrdfits(getenv('DIMAGE_DIR')+'/data/atlas/atlas_measure.fits',1)
atlas=mrdfits(getenv('DIMAGE_DIR')+'/data/atlas/atlas.fits',1)

tycho= tycho_read()

st= replicate({isstar:0, good:1, itycho:-1L}, $
              n_elements(measure))

inotok= where(measure.racen eq 0. and measure.deccen eq 0., nnotok)
if(nnotok gt 0) then $
  st[inotok].good=0
iok= where(st.good, nok)

rmag= 22.5-2.5*alog10(measure[iok].sersicflux[2]>0.001)
th50= measure[iok].sersic_r50*0.396

;; use both mean ...
tmatch=lonarr(nok)
spherematch, measure[iok].racen, measure[iok].deccen, $
  tycho.ramdeg, tycho.demdeg, 10./3600., m1, m2
tmatch[m1]=1
st[iok[m1]].itycho=m2

;; ... and observed
spherematch, measure[iok].racen, measure[iok].deccen, $
  tycho.radeg, tycho.dedeg, 10./3600., m1, m2
tmatch[m1]=1
st[iok[m1]].itycho=m2

;; also use redshift
lowz= atlas[iok].zlg lt 0.0015 and $
  measure[iok].sersic_r50 lt 30. OR $
  measure[iok].sersicflux[2] lt 250.

istar= where((th50 lt 1. and rmag gt 16.5) OR $
             (th50 lt 2.25 and rmag lt 15.) OR $
             (th50 lt 2.25-(rmag-15.)*1.25/1.5 and rmag gt 15. and rmag lt 16.5) OR $
             tmatch gt 0 OR lowz gt 0)
st[iok[istar]].isstar=1

mwrfits, st, getenv('DIMAGE_DIR')+'/data/atlas/atlas_startrim.fits', /create

end
