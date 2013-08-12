;+
; NAME:
;   sixdf2fits
; PURPOSE:
;   Convert the 6dF file into FITS
; CALLING SEQUENCE:
;   sixdf2fits
; REVISION HISTORY:
;   31-Jul-2010  MRB, NYU
;-
;------------------------------------------------------------------------------
pro sixdf2fits, version=version

rootdir=atlas_rootdir(version=version)

readcol, rootdir+'/catalogs/sixdf/6dFGSzDR3.txt', $
         comment='#', $
         format='(a,a,a,a,a,a,a,l,l,f,l,f,l,l,f,f,l,f,f,f,l,l,a,a,a)', $
         targetid, $
         rahr, ramin, rasec, $
         decdeg, decmin, decsec, $
         nmeas, nquality, $
         bj, progid, rf, sgclass, comparison, $
         cz, czerr, czsrc, quality


six0= {targetid:' ', $
       ra:0.D, dec:0.D , $
       nmeas:0L, nquality:0L, $
       bj:0., progid:0L, rf:0., sgclass:0L, $
       comparison:0L, cz:0., czerr:0., czsrc:0L, $
       quality:0L}

six= replicate(six0, n_elements(targetid))

six.targetid= targetid
six.nmeas= nmeas
six.nquality= nquality
six.bj= bj
six.progid= progid
six.rf= rf
six.sgclass= sgclass
six.comparison= comparison
six.cz= cz
six.czerr= czerr
six.czsrc= czsrc
six.quality= quality

string2radec, rahr, ramin, rasec, decdeg, decmin, decsec, ra, dec
six.ra= ra
six.dec= dec

mwrfits, six, rootdir+'/catalogs/sixdf/sixdf.fits', /create

end
