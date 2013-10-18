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
cirrange, racen

if(iparent eq -1) then return

dreadcen, measure=measure, acat=acat, aid=aid

if(n_tags(measure) eq 0) then return

iacat= where(aid eq acat.aid, nacat)
if(nacat eq 0) then return

iparent=acat[iacat].pid
racen=acat[iacat].racen
deccen=acat[iacat].deccen

rcutout_size= ((long(measure[0].sersic_r50*9.)>100L)<npx)<npy

imnames= ['irg', 'Krg', 'rgn']
imnums= [[3,2,1], $
         [9,2,1], $
         [2,1,5]]
imposts= [['i','r','g'], $
          ['K','r','g'], $
          ['r','g','nd']]
imscales=[ [3.6, 4.5, 5.4], $
           [3.2e-2, 4.5, 5.4], $
           [4.5, 5.4, 6.]]
imsats=[ 30., 1000000., 10.]
             
indx=0L
nband=5L
bands= ['u', 'g', 'r', 'i', 'z']
bwscales= [18., 15., 11., 9., 7.5]
if(keyword_set(galex)) then begin
    indx=[indx, 2L]
    nband+=2L
    bands= [bands, 'nd', 'fd']
    bwscales= [bwscales, 20., 20.]
endif
if(keyword_set(twomass)) then begin
    indx=[indx, 1L]
    nband+=3L
    bands= [bands, 'J', 'H', 'K']
    bwscales= [bwscales, 3.e-2, 3.e-2, 3.e-2]
endif

for i= 0L, n_elements(indx)-1L do begin 
    rnum= imnums[0,indx[i]]
    gnum= imnums[1,indx[i]]
    bnum= imnums[2,indx[i]]
    post= imnames[indx[i]]
    satvalue= imsats[indx[i]]
    scales= imscales[*,indx[i]]
    print, scales
    
    fullfile=base+'-'+post+'.jpg'
    if(file_test(fullfile) eq 0 OR $
       keyword_set(noclobber) eq 0) then begin

        ifile= base+'-'+imposts[0,indx[i]]+'.fits.gz'
        rfile= base+'-'+imposts[1,indx[i]]+'.fits.gz'
        gfile= base+'-'+imposts[2,indx[i]]+'.fits.gz'
        iim= gz_mrdfits(ifile, 0L, ihdr)
        rim= gz_mrdfits(rfile, 0L, rhdr)
        gim= gz_mrdfits(gfile, 0L, ghdr)
        extast, rhdr, fast
        cutout_size= rcutout_size

        if(post eq 'Krg') then begin
            nx= (size(iim, /dim))[0]
            ny= (size(iim, /dim))[1]
            iim= gz_mrdfits(opfile, 7)+ $
              gz_mrdfits(opfile, 8)+ $
              gz_mrdfits(opfile, 9)
            extast, rhdr, rast
            extast, ghdr, gast
            extast, ihdr, iast
            fast=iast
            smosaic_remap, rim, rast, fast, rimout, reflimits=reflimits, outlimits=outlimits
            rim=fltarr(nx,ny)
            rim[reflimits[0,0]:reflimits[0,1],reflimits[1,0]:reflimits[1,1]]= $
              rimout[outlimits[0,0]:outlimits[0,1],outlimits[1,0]:outlimits[1,1]]
            smosaic_remap, gim, gast, fast, gimout, reflimits=reflimits, outlimits=outlimits
            gim=fltarr(nx,ny)
            gim[reflimits[0,0]:reflimits[0,1],reflimits[1,0]:reflimits[1,1]]= $
              gimout[outlimits[0,0]:outlimits[0,1],outlimits[1,0]:outlimits[1,1]]
        endif

        if(post eq 'rgn') then begin
            nx= (size(gim, /dim))[0]
            ny= (size(gim, /dim))[1]
            cutout_size= ((long(rcutout_size*0.396/1.5))<nx)<ny
            extast, rhdr, rast
            extast, ghdr, gast
            extast, ihdr, iast
            fast=gast
            ;;rim= dsmooth(rim, 0.5*1.5/0.396)
            smosaic_remap, rim, rast, fast, rimout, reflimits=reflimits, outlimits=outlimits
            rim=fltarr(nx,ny)
            rim[reflimits[0,0]:reflimits[0,1],reflimits[1,0]:reflimits[1,1]]= $
              rimout[outlimits[0,0]:outlimits[0,1],outlimits[1,0]:outlimits[1,1]]
            ;;iim= dsmooth(iim, 0.5*1.5/0.396)
            smosaic_remap, iim, iast, fast, iimout, reflimits=reflimits, outlimits=outlimits
            iim=fltarr(nx,ny)
            iim[reflimits[0,0]:reflimits[0,1],reflimits[1,0]:reflimits[1,1]]= $
              iimout[outlimits[0,0]:outlimits[0,1],outlimits[1,0]:outlimits[1,1]]
        endif
        
        djs_rgb_make, iim, rim, gim, $
          scales=scales, name=fullfile, $
          nonlinearity=nonlinearity, satvalue=satvalue, $
          quality=100.

        ad2xy, racen, deccen, fast, xcen, ycen
        iimcut= fltarr(cutout_size, cutout_size)
        rimcut= fltarr(cutout_size, cutout_size)
        gimcut= fltarr(cutout_size, cutout_size)
        fxcen= long(xcen+0.5)
        fycen= long(ycen+0.5)
        cxmin= (cutout_size/2L)-(fxcen)
        cymin= (cutout_size/2L)-(fycen)
        embed_stamp, iimcut, iim, cxmin, cymin
        embed_stamp, rimcut, rim, cxmin, cymin
        embed_stamp, gimcut, gim, cxmin, cymin
        cutfile=base+'-'+post+'.cutout.jpg'
        djs_rgb_make, iimcut, rimcut, gimcut, $
          scales=scales, name=cutfile, $
          nonlinearity=nonlinearity, satvalue=satvalue, $
          quality=100.
        
    endif
    
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
    
    ;; make child image
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

pbase=base+'-parent-'+strtrim(string(iparent),2)
opfile= subdir+'/'+ strtrim(string(iparent),2)+ $
  '/'+pbase+'.fits'
for j=0L, nband-1L do begin
    bwjpgbase= subdir+'/'+strtrim(string(iparent),2)+ '/'+pbase+'-'+bands[j]
    if(file_test(bwjpgbase+'.jpg') eq 0 or $
       keyword_set(noclobber) eq 0) then begin
       dim= gz_mrdfits(opfile, j)
       nw_rgb_make, dim, dim, dim, name= bwjpgbase+'.jpg', $
                    scales=bwscales[j]*[1.,1.,1.], nonlinearity=nonlinearity, $
                    quality=100, /invert
       spawn, /nosh, ['convert', '-resize', '130', bwjpgbase+'.jpg', $
                      bwjpgbase+'.thumb.jpg']
    endif
endfor

abase= subdir+'/'+ strtrim(string(iparent),2)+ $
  '/'+base+'-'+strtrim(string(iparent),2)+ $
  '-atlas-'+strtrim(string(aid),2)
afile= abase+'.fits'
for j=0L, nband-1L do begin
    bwjpgbase= abase+'-'+bands[j]
    if(file_test(bwjpgbase+'.jpg') eq 0 or $
       keyword_set(noclobber) eq 0) then begin
       dim= gz_mrdfits(afile, j)
       nw_rgb_make, dim, dim, dim, name= bwjpgbase+'.jpg', $
                    scales=bwscales[j]*[1.,1.,1.], nonlinearity=nonlinearity, $
                    quality=100, /invert
       spawn, /nosh, ['convert', '-resize', '130', bwjpgbase+'.jpg', $
                      bwjpgbase+'.thumb.jpg']
    endif
endfor

sbase= subdir+'/'+ strtrim(string(iparent),2)+ $
  '/'+base+'-'+strtrim(string(iparent),2)+ $
  '-sersic'
if(file_test(sbase+'.jpg') eq 0 or $
   keyword_set(noclobber) eq 0) then begin
   sfile= sbase+'.fits'
   mim= gz_mrdfits(sfile)
   dim= gz_mrdfits(afile, 2)
   nw_rgb_make, mim, mim, mim, name= sbase+'.jpg', $
                scales=bwscales[2]*[1.,1.,1.], nonlinearity=nonlinearity, $
                quality=100, /invert
   spawn, /nosh, ['convert', '-resize', '330', sbase+'.jpg', $
                  sbase+'.thumb.jpg']
   bwjpgfile= sbase+'-sub.jpg'
   nw_rgb_make, dim-mim+3.e-2, dim-mim+3.e-2, dim-mim+3.e-2, name= bwjpgfile, $
                scales=bwscales[2]*[1.,1.,1.], nonlinearity=nonlinearity, $
                quality=100, /invert
   spawn, /nosh, ['convert', '-resize', '330', sbase+'-sub.jpg', $
                  sbase+'-sub.thumb.jpg']
endif
   
end
