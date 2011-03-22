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
pro atlas_jpeg, noclobber=noclobber, twomass=twomass, galex=galex

subdir='atlases'
if(NOT keyword_set(nonlinearity)) then nonlinearity=3.

;; default to use base name same as directory name
spawn, /nosh, 'pwd', cwd
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

imnames= ['irg', 'Krg', 'rgn']
imnums= [[3,2,1], $
         [9,2,1], $
         [2,1,5]]
imscales=[ [3.6, 4.5, 5.4], $
           [3.e-2, 4.5, 5.4], $
           [4.5, 5.4, 10.]]
imsats=[ 30., 1000000., 10.]
             
indx=0L
if(keyword_set(twomass)) then $
  indx=[indx, 1L]
if(keyword_set(galex)) then $
  indx=[indx, 2L]

for i= 0L, n_elements(indx)-1L do begin 
    rnum= imnums[0,indx[i]]
    gnum= imnums[1,indx[i]]
    bnum= imnums[2,indx[i]]
    post= imnames[indx[i]]
    satvalue= imsats[indx[i]]
    scales= imscales[*,indx[i]]
    
    ;; make parent image
    pbase=base+'-parent-'+strtrim(string(iparent),2)
    opfile= subdir+'/'+ strtrim(string(iparent),2)+ $
      '/'+pbase+'.fits'
    jpgfile= subdir+'/'+strtrim(string(iparent),2)+ '/'+pbase+'-'+post+'.jpg'
    if(file_test(jpgfile) eq 0 OR $
       keyword_set(noclobber) eq 0) then begin
        iim= gz_mrdfits(opfile, rnum, ihdr)
        rim= gz_mrdfits(opfile, gnum, rhdr)
        gim= gz_mrdfits(opfile, bnum, ghdr)
        if(post eq 'Krg') then begin
            nx= (size(iim, /dim))[0]
            ny= (size(iim, /dim))[1]
            iim= gz_mrdfits(opfile, 7)+ $
              gz_mrdfits(opfile, 8)+ $
              gz_mrdfits(opfile, 9)
            extast, rhdr, rast
            extast, ghdr, gast
            extast, ihdr, iast
            smosaic_remap, rim, rast, iast, rimout, reflimits=reflimits, outlimits=outlimits
            rim=fltarr(nx,ny)
            rim[reflimits[0,0]:reflimits[0,1],reflimits[1,0]:reflimits[1,1]]= $
              rimout[outlimits[0,0]:outlimits[0,1],outlimits[1,0]:outlimits[1,1]]
            smosaic_remap, gim, gast, iast, gimout, reflimits=reflimits, outlimits=outlimits
            gim=fltarr(nx,ny)
            gim[reflimits[0,0]:reflimits[0,1],reflimits[1,0]:reflimits[1,1]]= $
              gimout[outlimits[0,0]:outlimits[0,1],outlimits[1,0]:outlimits[1,1]]
        endif
        if(post eq 'rgn') then begin
            nx= (size(gim, /dim))[0]
            ny= (size(gim, /dim))[1]
            extast, rhdr, rast
            extast, ghdr, gast
            extast, ihdr, iast
            smosaic_remap, rim, rast, gast, rimout, reflimits=reflimits, outlimits=outlimits
            rim=fltarr(nx,ny)
            rim[reflimits[0,0]:reflimits[0,1],reflimits[1,0]:reflimits[1,1]]= $
              rimout[outlimits[0,0]:outlimits[0,1],outlimits[1,0]:outlimits[1,1]]
            smosaic_remap, iim, iast, gast, iimout, reflimits=reflimits, outlimits=outlimits
            iim=fltarr(nx,ny)
            iim[reflimits[0,0]:reflimits[0,1],reflimits[1,0]:reflimits[1,1]]= $
              iimout[outlimits[0,0]:outlimits[0,1],outlimits[1,0]:outlimits[1,1]]
        endif
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
    jpgfile=abase+'-'+post+'.jpg'
    if(file_test(jpgfile) eq 0 OR $
       keyword_set(noclobber) eq 0) then begin
        iim= gz_mrdfits(afile, rnum)
        rim= gz_mrdfits(afile, gnum)
        gim= gz_mrdfits(afile, bnum)
        if(post eq 'Krg') then begin
            nx= (size(iim, /dim))[0]
            ny= (size(iim, /dim))[1]
            iim= gz_mrdfits(afile, 7)+ $
              gz_mrdfits(afile, 8)+ $
              gz_mrdfits(afile, 9)
            extast, rhdr, rast
            extast, ghdr, gast
            extast, ihdr, iast
            smosaic_remap, rim, rast, iast, rimout, reflimits=reflimits, outlimits=outlimits
            rim=fltarr(nx,ny)
            rim[reflimits[0,0]:reflimits[0,1],reflimits[1,0]:reflimits[1,1]]= $
              rimout[outlimits[0,0]:outlimits[0,1],outlimits[1,0]:outlimits[1,1]]
            smosaic_remap, gim, gast, iast, gimout, reflimits=reflimits, outlimits=outlimits
            gim=fltarr(nx,ny)
            gim[reflimits[0,0]:reflimits[0,1],reflimits[1,0]:reflimits[1,1]]= $
              gimout[outlimits[0,0]:outlimits[0,1],outlimits[1,0]:outlimits[1,1]]
        endif
        if(post eq 'rgn') then begin
            nx= (size(gim, /dim))[0]
            ny= (size(gim, /dim))[1]
            extast, rhdr, rast
            extast, ghdr, gast
            extast, ihdr, iast
            smosaic_remap, rim, rast, gast, rimout, reflimits=reflimits, outlimits=outlimits
            rim=fltarr(nx,ny)
            rim[reflimits[0,0]:reflimits[0,1],reflimits[1,0]:reflimits[1,1]]= $
              rimout[outlimits[0,0]:outlimits[0,1],outlimits[1,0]:outlimits[1,1]]
            smosaic_remap, iim, iast, gast, iimout, reflimits=reflimits, outlimits=outlimits
            iim=fltarr(nx,ny)
            iim[reflimits[0,0]:reflimits[0,1],reflimits[1,0]:reflimits[1,1]]= $
              iimout[outlimits[0,0]:outlimits[0,1],outlimits[1,0]:outlimits[1,1]]
        endif
        if(NOT keyword_set(iim) OR $
           NOT keyword_set(rim) OR $
           NOT keyword_set(gim)) then $
          return
        djs_rgb_make, iim, rim, gim, name= jpgfile, $
          scales=scales, nonlinearity=nonlinearity, satvalue=satvalue, $
          quality=100
    endif 
endfor 


end
