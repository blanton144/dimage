;+
; NAME:
;   dchildren_atlas
; PURPOSE:
;   deblend children of a parent atlas image
; CALLING SEQUENCE:
;   dstargal_atlas [, /galex, /noclobber ]
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro dstargal_atlas

if(NOT keyword_set(slim)) then slim=10.
if(NOT keyword_set(ref)) then ref=2L
if(NOT keyword_set(gsmooth)) then gsmooth=5.
if(NOT keyword_set(glim)) then glim=15.
if(NOT keyword_set(gsaddle)) then gsaddle=20.
if(NOT keyword_set(maxnstar)) then maxnstar=300L

;; default to use base name same as directory name
spawn, 'pwd', cwd
base=(file_basename(cwd))[0]

;; read in pset
pset= mrdfits(base+'-pset.fits',1)
imfiles=pset.imfiles
puse=pset.puse
nim= n_elements(imfiles)

;; find center object
pim=gz_mrdfits(base+'-pimage.fits')
pcat=gz_mrdfits(base+'-pcat.fits',1)
nx=(size(pim,/dim))[0]
ny=(size(pim,/dim))[1]
iparent=pim[nx/2L, ny/2L]

if(iparent eq -1) then return

;; setup output directory
subdir= 'atlases'
spawn, /nosh, ['mkdir', '-p', subdir+'/'+strtrim(string(iparent),2)]

;; read in the psf information
for k=0L, nim-1L do begin
   bimfile=(stregex(imfiles[k], '(.*)\.fits.*', /sub, /extr))[1]
   tmp_psf=dpsfread(bimfile+'-vpsf.fits') 
   if(n_tags(psfs) eq 0) then $
      psfs=tmp_psf $
   else $
      psfs=[psfs, tmp_psf]
endfor
psfs.xst= pcat[iparent].xst
psfs.yst= pcat[iparent].yst

;; read in images and psfs
hdr=gz_headfits('parents/'+base+'-parent-'+ $
                strtrim(string(iparent),2)+'.fits',ext=0)

;; set up memory
nim=long(sxpar(hdr, 'NIM'))
nx=lonarr(nim)
ny=lonarr(nim)
images=ptrarr(nim)
nimages=ptrarr(nim)
ivars=ptrarr(nim)
hdrs=ptrarr(nim)

;; set up star and galaxy locations
sgset={base:base, $
       ref:ref, $
       iparent:iparent, $
       nstars:0L, $
       ra_stars:dblarr(maxnstar), $
       dec_stars:dblarr(maxnstar), $
       ngals:0L, $
       ra_gals:dblarr(maxnstar), $
       dec_gals:dblarr(maxnstar) }

;; read in images and ivars
for k=0L, nim-1L do begin
    images[k]=ptr_new(gz_mrdfits('parents/'+base+'-parent-'+ $
                              strtrim(string(iparent),2)+'.fits',0+k*2L,hdr))
    hdrs[k]=ptr_new(hdr)
    nx[k]=(size(*images[k],/dim))[0]
    ny[k]=(size(*images[k],/dim))[1]
    ivars[k]=ptr_new(gz_mrdfits('parents/'+base+'-parent-'+ $
                                strtrim(string(iparent),2)+'.fits',1+k*2L))
endfor

;; get basic psf size
bpsf=dvpsf(nx[ref]/2L, ny[ref]/2L, psf=psfs[ref])
pnx=(size(bpsf,/dim))[0]
pny=(size(bpsf,/dim))[1]
dfit_mult_gauss, bpsf, 1, amp, psfsig, model=model, /quiet 

;; find stars and galaxies
dstars, images, ivars, psfs, hdrs, slim=slim, ref=ref, $
  nimages=nimages, ra_stars=ra_stars, dec_stars=dec_stars, $
  nstars=nstars, puse=puse, maxnstar=maxnstar
dgals, nimages, psfs, hdrs, gsmooth=gsmooth, glim=glim, $
  ra_gals=ra_gals, dec_gals=dec_gals, ngals=ngals, puse=puse, $
  gsaddle=gsaddle
nimfile=subdir+'/'+strtrim(string(iparent),2)+'/'+base+ $
  '-'+strtrim(string(iparent),2)+'-nimage.fits'
for k=0L, nim-1L do begin
    mwrfits, *nimages[k], nimfile, create=(k eq 0)
    ptr_free, nimages[k]
endfor
nimages=0

;; then take out stars that are near galaxies
;; but give the center as the center of the star
if(nstars gt 0 and ngals gt 0) then begin
   spherematch, ra_stars, dec_stars, ra_gals, dec_gals, gsmooth/3600., $
                m1,m2, d12
   if(m1[0] ne -1) then begin
      keep=lonarr(nstars)+1L
      keep[m1]=0
      ra_gals[m2]=ra_stars[m1]
      dec_gals[m2]=dec_stars[m1]
      ikeep=where(keep gt 0, nstars)
      if(nstars gt 0) then begin
         ra_stars=ra_stars[ikeep]
         dec_stars=dec_stars[ikeep]
      endif
   endif
endif

;; refine star and galaxy peaks again based on the reference image
model=fltarr(nx[ref],ny[ref])
if(nstars gt 0) then begin
    msimage=dmedsmooth(*images[ref], box=long(psfsig*30L))
    fimage=*images[ref]-msimage
    fivar=*ivars[ref]
    adxy, *hdrs[ref], ra_stars, dec_stars, xstars, ystars
    drefine, fimage, xstars, ystars, xr=xr, yr=yr, smooth=2
    xyad, *hdrs[ref], xr, yr, ra_stars, dec_stars
    for i=0L, nstars-1L do begin 
        if(xr[i] gt 0L and xr[i] lt nx[ref]-1 AND $
           yr[i] gt 0L and yr[i] lt ny[ref]-1) then begin
            if(n_tags(sdss) gt 0) then begin
                sdss.filter=filtername(ref)
                psf=dvpsf(xr[i], yr[i], sdss=sdss)
            endif else begin
                psf=dvpsf(xr[i], yr[i], psf=psfs[ref])
            endelse
            tmp_model=fltarr(nx[ref],ny[ref])
            embed_stamp, tmp_model, psf, $
              xr[i]-float(pnx/2L), $
              yr[i]-float(pny/2L)
            ifit=where(tmp_model ne 0., nfit)
            if(nfit gt 0) then begin
                scale= total(fimage[ifit]*tmp_model[ifit]*fivar[ifit])/ $
                  total(tmp_model[ifit]*tmp_model[ifit]*fivar[ifit])
                model=model+tmp_model*scale
            endif
        endif
    endfor
endif
rimage=*images[ref]-model
if(ngals gt 0) then begin
    adxy, *hdrs[ref], ra_gals, dec_gals, xgals, ygals
    drefine, rimage, xgals, ygals, smooth=2., $
      xr=r_xgals, yr=r_ygals, box=9L
    xyad, *hdrs[ref], r_xgals, r_ygals, ra_gals, dec_gals
endif 

;; store locations in sgset
sgset.nstars= nstars
if(nstars gt 0) then begin
   sgset.ra_stars[0:(nstars-1)]= ra_stars
   sgset.dec_stars[0:(nstars-1)]= dec_stars
endif
sgset.ngals= ngals
if(ngals gt 0) then begin
   sgset.ra_gals[0:ngals-1]= ra_gals
   sgset.dec_gals[0:ngals-1]= dec_gals
endif

;; output star and galaxy info
sgsetfile=subdir+'/'+strtrim(string(iparent),2)+'/'+base+'-'+ $
  strtrim(string(iparent),2)+'-sgset.fits'
mwrfits, sgset, sgsetfile, /create

for i=0L, n_elements(images)-1L do $
   ptr_free, images[i]
for i=0L, n_elements(ivars)-1L do $
   ptr_free, ivars[i]
for i=0L, n_elements(hdrs)-1L do $
   ptr_free, hdrs[i]

return 
end
;------------------------------------------------------------------------------
