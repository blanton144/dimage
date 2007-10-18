;+
; NAME:
;   dchildren
; PURPOSE:
;   deblend children of a parent, in multi-band, multi-res images
; CALLING SEQUENCE:
;   dchildren, base, iparent [, psfs=, plim=, gsmooth=, glim=, $
;      saddle=, xstars=, ystars=, xgals=, ygals=, /hand, ref=, $
;      nstars=, /sersic ]
; INPUTS:
;   base - FITS image base name
;   iparent - parent to process 
; OPTIONAL KEYWORDS:
;   /hand - brings up ATV so user can pick galaxy and star centers
;   /sersic - fit template with Sersic profile to constrain better
;   /aset - use [base]-aset.fits file for parameter setting
;   /sgset - use [base]-aset.fits file for star and galaxy locations
; OPTIONAL INPUTS:
;   psf - [npx, npy] PSF to assume (if none, doesn't search for stars)
;   plim - nsigma limit for point source detection (default 5.)
;   glim - nsigma limit for galaxy detection (default 5.)
;   gsmooth - smoothing for galaxy detection (default 2.)
;   saddle - saddle point for galaxy peak checking (default 100.)
;   xstars, ystars - [N] input where you want stars assumed
;   xgals, ygals - [N] input where you want galaxies assumed
;   ref - reference band (default 0)
;   sdss - pass this to dvpsf() to use SDSS PSF estimate
;   puse - [Nband] 0 or 1 whether to detect stars and galaxies in each
;          band
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro dchildren, base, iparent, psfs=psfs, plim=plim, gsmooth=gsmooth, $
               glim=glim, xstars=xstars, ystars=ystars, xgals=xgals, $
               ygals=ygals, hand=hand, saddle=saddle, ref=ref, $
               sersic=in_sersic, aset=in_aset, sgset=in_sgset, $
               sdss=sdss, puse=puse, tuse=tuse

maxnstar=2000L
if(NOT keyword_set(plim)) then plim=5.
if(NOT keyword_set(glim)) then glim=5.
if(NOT keyword_set(gsmooth)) then gsmooth=2.
if(NOT keyword_set(saddle)) then saddle=5.
if(keyword_set(xstars)) then nstars=n_elements(xstars)
if(keyword_set(xgals)) then ngals=n_elements(xgals)
if(keyword_set(in_sersic)) then sersic=in_sersic else sersic=0

;; pick directory (auto or hand)
subdir='atlases'
if(keyword_set(hand)) then subdir='hand'
spawn, 'mkdir -p '+subdir+'/'+strtrim(string(iparent),2)

;; read in images and psfs
hdr=headfits('parents/'+base+'-parent-'+ $
             strtrim(string(iparent),2)+'.fits',ext=0)

nim=long(sxpar(hdr, 'NIM'))
if(NOT keyword_set(tuse)) then tuse=lindgen(nim)
nx=lonarr(nim)
ny=lonarr(nim)
images=ptrarr(nim)
nimages=ptrarr(nim)
ivars=ptrarr(nim)
hdrs=ptrarr(nim)

;; read in settings if desired
asetfile=subdir+'/'+strtrim(string(iparent),2)+'/'+base+'-aset.fits'
if(keyword_set(in_aset) eq 0 OR file_test(asetfile) eq 0) then begin
    aset={base:base, $
          ref:ref, $
          iparent:iparent, $
          sersic:sersic, $
          gsmooth:gsmooth, $
          glim:glim}
endif else begin
    aset=mrdfits(asetfile, 1)
    gsmooth=aset.gsmooth
    glim=aset.glim
    sersic=aset.sersic
endelse

;; read in star and galaxy settings if desired
sgsetfile=subdir+'/'+strtrim(string(iparent),2)+'/'+base+'-sgset.fits'
newsg=1
if(keyword_set(in_sgset) eq 0 OR file_test(sgsetfile) eq 0) then begin
    sgset={base:base, $
           ref:ref, $
           iparent:iparent, $
           nstars:0L, $
           ra_stars:fltarr(maxnstar), $
           dec_stars:fltarr(maxnstar), $
           ngals:0L, $
           ra_gals:fltarr(maxnstar), $
           dec_gals:fltarr(maxnstar) }
endif else begin
    newsg=0
    sgset=mrdfits(sgsetfile, 1)
endelse

;; read in images 
for k=0L, nim-1L do begin
    images[k]=ptr_new(mrdfits('parents/'+base+'-parent-'+ $
                              strtrim(string(iparent),2)+'.fits',0+k*2L,hdr))
    hdrs[k]=ptr_new(hdr)
    nx[k]=(size(*images[k],/dim))[0]
    ny[k]=(size(*images[k],/dim))[1]
    ivars[k]=ptr_new(mrdfits('parents/'+base+'-parent-'+ $
                             strtrim(string(iparent),2)+'.fits',1+k*2L))
endfor

;; read in basic PSFs and get approximate size
if(n_tags(sdss) gt 0) then begin
    sdss.filter=filtername(ref)
    bpsf=dvpsf(nx[ref]/2L, ny[ref]/2L, sdss=sdss) 
endif else begin
    bpsf=dvpsf(nx[ref]/2L, ny[ref]/2L, psf=psfs[ref])
endelse
pnx=(size(bpsf,/dim))[0]
pny=(size(bpsf,/dim))[1]
dfit_mult_gauss, bpsf, 1, amp, psfsig, model=model, /quiet 

;; find stars and galaxies
if(keyword_set(newsg)) then begin
    dstars, images, ivars, psfs, hdrs, sdss=sdss, plim=plim, ref=ref, $
      nimages=nimages, ra_stars=ra_stars, dec_stars=dec_stars, $
      nstars=nstars, puse=puse
    dgals, nimages, psfs, hdrs, gsmooth=gsmooth, glim=glim, $
      ra_gals=ra_gals, dec_gals=dec_gals, ngals=ngals, puse=puse
    
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
    
    sgset.nstars= nstars
    if(nstars gt 0) then begin
        sgset.ra_stars[0:(nstars-1)<maxnstar]= ra_stars
        sgset.dec_stars[0:(nstars-1)<maxnstar]= dec_stars
    endif
    sgset.ngals= ngals
    if(ngals gt 0) then begin
        sgset.ra_gals[0:ngals-1]= ra_gals
        sgset.dec_gals[0:ngals-1]= dec_gals
    endif
endif else begin
    nstars=sgset.nstars
    if(nstars gt 0) then begin
        ra_stars=sgset.ra_stars[0:(nstars-1)<maxnstar]
        dec_stars=sgset.dec_stars[0:(nstars-1)<maxnstar]
    endif
    ngals=sgset.ngals
    if(ngals gt 0) then begin
        ra_gals=sgset.ra_gals[0:ngals-1]
        dec_gals=sgset.dec_gals[0:ngals-1]
    endif
endelse

mwrfits, aset, asetfile, /create
mwrfits, sgset, sgsetfile, /create

if(ngals eq 0 and nstars eq 0) then return

acat=replicate({pid:iparent, $
                aid:-1L, $
                racen:0., $
                deccen:0., $
                bgood:lonarr(nim), $
                type:0L, $
                good:0L}, ngals+nstars)
acat.aid=lindgen(ngals+nstars)

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

if(ngals gt 0) then begin
    acat[0:ngals-1].racen=ra_gals
    acat[0:ngals-1].deccen=dec_gals
    acat[0:ngals-1].type=0
endif
if(nstars gt 0) then begin
    acat[ngals:nstars+ngals-1].racen=ra_stars
    acat[ngals:nstars+ngals-1].deccen=dec_stars
    acat[ngals:nstars+ngals-1].type=1
endif

for k=0L, nim-1L do begin
    if(k eq 0) then first=1 else first=0
    kuse=tuse[k]
    
    spawn, 'mkdir -p '+subdir+'/'+strtrim(string(iparent),2)
    
    model=fltarr(nx[kuse],ny[kuse])
    if(nstars gt 0) then begin
        stimages=fltarr(nx[kuse], ny[kuse], nstars)
        msimage=dmedsmooth(*images[kuse], box=long(psfsig*30L))
        fimage=*images[kuse]-msimage
        fivar=*ivars[kuse]
        adxy, *hdrs[kuse], ra_stars, dec_stars, xstars, ystars
        for i=0L, nstars-1L do begin 
            if(xstars[i] gt 0L and xstars[i] lt nx[kuse]-1 AND $
               ystars[i] gt 0L and ystars[i] lt ny[kuse]-1) then begin
                if(n_tags(sdss) gt 0) then begin
                    sdss.filter=filtername(kuse)
                    psf=dvpsf(xstars[i], ystars[i], sdss=sdss)
                endif else begin
                    psf=dvpsf(xstars[i], ystars[i], psf=psfs[kuse])
                endelse
                dprefine, fimage, psf, xstars[i], ystars[i], xr=xr, yr=yr
                tmp_model=fltarr(nx[kuse],ny[kuse])
                embed_stamp, tmp_model, psf, $
                  xr-float(pnx/2L), $
                  yr-float(pny/2L)
                ifit=where(tmp_model ne 0.)
                scale= total(fimage[ifit]*tmp_model[ifit]*fivar[ifit])/ $
                  total(tmp_model[ifit]*tmp_model[ifit]*fivar[ifit])
                stimages[*,*,i]=tmp_model
                model=model+stimages[*,*,i]*scale
            endif
        endfor
    endif
    nimages[kuse]=ptr_new((*images[kuse]-model) > 0.)
    
    if(ngals gt 0) then begin
        ;; make galaxy templates
        adxy, *hdrs[kuse], ra_gals, dec_gals, xgals, ygals
        dtemplates, *nimages[kuse], xgals, ygals, templates=gtemplates, $
          sersic=sersic, ikept=ikept
        sig=dsigma(*nimages[kuse],sp=5)
        nchild=n_elements(gtemplates)/nx[kuse]/ny[kuse]
        stemplates=fltarr(nx[kuse],ny[kuse],nchild)
        stemplates2=fltarr(nx[kuse],ny[kuse],nchild)
        for i=0L, nchild-1L do begin
            stemplates[*,*,i]= dsmooth(gtemplates[*,*,i], 2.5)
            stemplates2[*,*,i]= dsmooth(gtemplates[*,*,i], 7.5)
            tmp_stemplates=reform(stemplates[*,*,i],nx[kuse]*ny[kuse])
            tmp_stemplates2=reform(stemplates2[*,*,i],nx[kuse]*ny[kuse])
            tmp_templates=reform(gtemplates[*,*,i],nx[kuse]*ny[kuse])
            ii=where(tmp_stemplates lt 2.*sig, nii)
            if(nii gt 0) then $
              tmp_templates[ii]= tmp_stemplates[ii]
            ii=where(tmp_stemplates lt 0.2*sig, nii)
            if(nii gt 0) then $
              tmp_templates[ii]=tmp_stemplates2[ii]
            gtemplates[*,*,i]=reform(tmp_templates, nx[kuse], ny[kuse])
        endfor
    endif

    ;; add stars as templates
    nkept=n_elements(ikept)
    nchild=nkept+nstars
    templates=fltarr(nx[kuse],ny[kuse], nchild)
    if(nkept gt 0) then $
      templates[*,*,0:nkept-1L]=gtemplates
    if(nstars gt 0) then $
      templates[*,*,nkept:nchild-1L]=stimages

    if(nx[k] ne nx[kuse] OR $
       ny[k] ne ny[kuse]) then begin
        extast, *hdrs[k], k_ast
        extast, *hdrs[kuse], kuse_ast
        use_templates=fltarr(nx[k], ny[k], nchild)
        for i=0L, nchild-1L do begin
            tmp_ut=fltarr(nx[k], ny[k])
            smosaic_remap, templates[*,*,i], kuse_ast, k_ast, $
              refimage=tmp_ut
            use_templates[*,*,i]=tmp_ut
        endfor
        templates=use_templates
    endif

    ;; find weights
    if(ngals gt 0 and nstars gt 0) then begin
        xcen=[xgals[ikept], xstars]
        ycen=[ygals[ikept], ystars]
    endif else begin
        if(ngals gt 0) then begin
            xcen=[xgals[ikept]]
            ycen=[ygals[ikept]]
        endif
        if(nstars gt 0) then begin
            xcen=xstars
            ycen=ystars
        endif
    endelse 
    
    dweights, *images[k], *ivars[k], templates, weights=weights, /nonneg
    dfluxes, *images[k], templates, weights, xcen, ycen, children=children
    
    use_child=lindgen(nstars+ngals)
    if(ngals gt 0) then begin
        use_child[0:ngals-1]=-1L
        use_child[ikept]=ikept
        use_child[ngals:ngals+nstars-1]=nkept+lindgen(nstars)
    endif

    for i=0L, nstars+ngals-1L do begin
        aid=acat[i].aid
        if(use_child[i] ge 0) then begin
            if(total(children[*,*,use_child[i]]) gt 0) then begin
                acat[i].bgood[k]=	1
            endif 
        endif 
        if(acat[i].bgood[k]) then begin
            mwrfits, children[*,*,use_child[i]], subdir+'/'+ $
              strtrim(string(iparent),2)+ $
              '/'+base+'-'+strtrim(string(iparent),2)+ $
              '-atlas-'+strtrim(string(aid),2)+'.fits', hdr, create=first
            mwrfits, templates[*,*,use_child[i]], subdir+'/'+ $
              strtrim(string(iparent),2)+ $
              '/'+base+'-'+strtrim(string(iparent),2)+ $
              '-templates-'+strtrim(string(aid),2)+'.fits', hdr, $
              create=first
        endif else begin
            mwrfits, fltarr(nx[k],ny[k]), $
              subdir+'/'+strtrim(string(iparent),2)+ $
              '/'+base+'-'+strtrim(string(iparent),2)+ $
              '-atlas-'+strtrim(string(aid),2)+'.fits', hdr, $
              create=first
            mwrfits, fltarr(nx[k],ny[k]), $
              subdir+'/'+strtrim(string(iparent),2)+ $
              '/'+base+'-'+strtrim(string(iparent),2)+ $
              '-templates-'+strtrim(string(aid),2)+'.fits', hdr, $
              create=first
        endelse
    endfor
endfor

if(n_tags(acat) gt 0) then begin
    acat.good= total(acat.bgood, 1) gt 0
    mwrfits, acat, subdir+'/'+strtrim(string(iparent),2)+ $
      '/'+base+'-'+strtrim(string(iparent),2)+ $
      '-acat.fits', /create
endif

end
;------------------------------------------------------------------------------
