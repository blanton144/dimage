;+
; NAME:
;   dchildren_atlas
; PURPOSE:
;   deblend children of a parent atlas image
; CALLING SEQUENCE:
;   dstargal_atlas 
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro dstargal_atlas, plot=plot

if(NOT keyword_set(ref)) then ref=2L
if(NOT keyword_set(gsmooth)) then gsmooth=10.
if(NOT keyword_set(glim)) then glim=25.
if(NOT keyword_set(gsaddle)) then gsaddle=50.
if(NOT keyword_set(maxnstar)) then maxnstar=3000L

;; default to use base name same as directory name
spawn, 'pwd', cwd
base=(file_basename(cwd))[0]

;; set up star and galaxy locations
sgset={base:base, $
       ref:ref, $
       iparent:-1L, $
       nstars:0L, $
       ra_stars:dblarr(maxnstar), $
       dec_stars:dblarr(maxnstar), $
       ngals:0L, $
       ra_gals:dblarr(maxnstar), $
       dec_gals:dblarr(maxnstar) }

;; read in pset
pset= mrdfits(base+'-pset.fits',1)
imfiles=pset.imfiles
puse=pset.puse
nim= n_elements(imfiles)
nx=lonarr(nim)
ny=lonarr(nim)
images=ptrarr(nim)
nimages=ptrarr(nim)
ivars=ptrarr(nim)
hdrs=ptrarr(nim)
psfs=ptrarr(nim)

;; find center object
phdr=gz_headfits(base+'-r.fits')
pim=gz_mrdfits(base+'-pimage.fits')
pcat=gz_mrdfits(base+'-pcat.fits',1)
npx=(size(pim,/dim))[0]
npy=(size(pim,/dim))[1]
iparent=pim[npx/2L, npy/2L]
xyad, phdr, float(npx/2L), float(npy/2L), raex, decex
sgset.iparent=iparent

if(iparent eq -1) then return

;; setup output directory
subdir= 'atlases'
spawn, /nosh, ['mkdir', '-p', subdir+'/'+strtrim(string(iparent),2)]

;; read in the psf information
for k=0L, nim-1L do begin
   bimfile=(stregex(imfiles[k], '(.*)\.fits.*', /sub, /extr))[1]
   psfs[k]=ptr_new(mrdfits(bimfile+'-bpsf.fits'))
endfor

;; read in the images
ntest=10L
for k=0L, nim-1L do begin
   images[k]=ptr_new(gz_mrdfits('parents/'+base+'-parent-'+ $
                                strtrim(string(iparent),2)+'.fits',0+k*2L,hdr))
   hdrs[k]=ptr_new(hdr)
   nx[k]=(size(*images[k],/dim))[0]
   ny[k]=(size(*images[k],/dim))[1]
   ivars[k]=ptr_new(gz_mrdfits('parents/'+base+'-parent-'+ $
                               strtrim(string(iparent),2)+'.fits',1+k*2L))
endfor

;; find and subtract stars in the reference image
adxy, *hdrs[ref], raex, decex, xex, yex
nimages[ref]= ptr_new(dpsfsub_atlas(image=*images[ref], ivar=*ivars[ref], $
                                    psf=*psfs[ref], x=xstar_r, y=ystar_r, $
                                    flux=fluxstar_r, nstars=nstars, exx=xex, $
                                    exy=yex, exr=1.5))
if(nstars gt 0) then begin
   xyad, *hdrs[ref], xstar_r, ystar_r, ra_stars, dec_stars
   fluxstar= fltarr(n_elements(fluxstar_r), nim)
   fluxstar[*,ref]= fluxstar_r
endif

;; subtract same stars in all other images
if(nstars gt 0) then begin
   for k=0L, nim-1L do begin
      if(k ne ref) then begin
         adxy, *hdrs[k], ra_stars, dec_stars, xstar, ystar
         nimages[k]= ptr_new(dpsfsub_atlas(image=*images[k], ivar=*ivars[k], $
                                           psf=*psfs[k], x=xstar, y=ystar, $
                                           flux=tmp_fluxstar))
         fluxstar[*,k]=tmp_fluxstar
      endif
   endfor
endif else begin
   for k=0L, nim-1L do $
      if(k ne ref) then $
         nimages[k]= ptr_new(*images[k])
endelse

;; output subtracted images
nimfile=subdir+'/'+strtrim(string(iparent),2)+'/'+base+ $
  '-'+strtrim(string(iparent),2)+'-nimage.fits'
for k=0L, nim-1L do $
   mwrfits, *nimages[k], nimfile, create=(k eq 0)

;; find galaxies in reference image
simage=dsmooth(*nimages[ref], gsmooth)
ssig=dsigma(simage, sp=long(gsmooth*5.))
saddle=gsaddle*ssig
dpeaks, simage, xc=xc, yc=yc, sigma=ssig, minpeak=glim*ssig, npeaks=ngals, $
        /check, saddle= gsaddle, /refine
if(ngals gt 0) then begin
   xgals=float(xc)
   ygals=float(yc)
   
   ;; refine the centers
   drefine, *nimages[ref], xgals, ygals, smooth=2., $
            xr=xrgals, yr=yrgals, box=long(5)
   xyad, *hdrs[ref], xrgals, yrgals, ra_gals, dec_gals
endif

;; store locations in sgset
sgset.nstars= nstars
if(nstars gt 0) then begin
   sgset.ra_stars[0:nstars-1]= ra_stars
   sgset.dec_stars[0:nstars-1]= dec_stars
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

if(keyword_set(plot)) then begin
   atv, *nimages[ref]
   if(ngals gt 0) then begin
      adxy, *hdrs[ref], sgset.ra_gals[0:ngals-1], sgset.dec_gals[0:ngals-1], $
            xg, yg
      atvplot, xg, yg, psym=4, color='blue', th=4
   endif
   if(nstars gt 0) then begin
      adxy, *hdrs[ref], sgset.ra_stars[0:nstars-1], sgset.dec_stars[0:nstars-1], $
            xs, ys
      atvplot, xs, ys, psym=4, color='red'
   endif
endif

heap_free, psfs
heap_free, images
heap_free, nimages
heap_free, ivars
heap_free, hdrs

return 
end
;------------------------------------------------------------------------------