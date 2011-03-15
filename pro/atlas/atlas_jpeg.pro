;+
; NAME:
;   atlas_jpeg
; PURPOSE:
;   make JPEG of primary parent and child in current dir
; CALLING SEQUENCE:
;   atlas_jpeg
; REVISION HISTORY:
;   3-Aug-2004  MRB, NYU
;-
;------------------------------------------------------------------------------
pro atlas_jpeg, noclobber=noclobber

subdir='atlases'
if(NOT keyword_set(scales)) then scales=[4., 5., 6.]*0.9
if(NOT keyword_set(satvalue)) then satvalue=30.
if(NOT keyword_set(nonlinearity)) then nonlinearity=3.

;; default to use base name same as directory name
spawn, 'pwd', cwd
base=(file_basename(cwd))[0]

;; find center object and RA/Dec
pim=gz_mrdfits(base+'-2-pimage.fits',0,hdr)
if(NOT keyword_set(pim)) then $
   return
npx=(size(pim,/dim))[0]
npy=(size(pim,/dim))[1]
iparent=pim[npx/2L, npy/2L]
xyad, hdr, float(npx/2L), float(npy/2L), racen, deccen
  
if(iparent eq -1) then return

;; find closest child to center
acatfile=subdir+'/'+strtrim(string(iparent),2)+ $
      '/'+base+'-acat-'+strtrim(string(iparent),2)+ $
      '.fits'
acat= gz_mrdfits(acatfile, 1)
if(NOT keyword_set(acat)) then $
   return
spherematch, racen, deccen, acat.racen, acat.deccen, 1., m1, m2, d12
aid=m2[0]

;; make parent image
pbase=base+'-parent-'+strtrim(string(iparent),2)
opfile= subdir+'/'+ strtrim(string(iparent),2)+ $
        '/'+pbase+'.fits'
jpgfile= subdir+'/'+strtrim(string(iparent),2)+ '/'+pbase+'-irg.jpg'
if(file_test(jpgfile) eq 0 OR $
   keyword_set(noclobber) eq 0) then begin
   iim= gz_mrdfits(opfile, 3)
   rim= gz_mrdfits(opfile, 2)
   gim= gz_mrdfits(opfile, 1)
   if(NOT keyword_set(iim) OR $
      NOT keyword_set(rim) OR $
      NOT keyword_set(gim)) then $
         return
   djs_rgb_make, iim, rim, gim, name= jpgfile, $
                 scales=scales, nonlinearity=nonlinearity, satvalue=satvalue, $
                 quality=100
endif

;; make atlas image
abase= subdir+'/'+ strtrim(string(iparent),2)+ $
       '/'+base+'-'+strtrim(string(iparent),2)+ $
       '-atlas-'+strtrim(string(aid),2)
afile= abase+'.fits'
jpgfile=abase+'-irg.jpg'
if(file_test(jpgfile) eq 0 OR $
   keyword_set(noclobber) eq 0) then begin
   iim= gz_mrdfits(afile, 3)
   rim= gz_mrdfits(afile, 2)
   gim= gz_mrdfits(afile, 1)
   if(NOT keyword_set(iim) OR $
      NOT keyword_set(rim) OR $
      NOT keyword_set(gim)) then $
         return
   djs_rgb_make, iim, rim, gim, name= jpgfile, $
                 scales=scales, nonlinearity=nonlinearity, satvalue=satvalue, $
                 quality=100
endif


end
