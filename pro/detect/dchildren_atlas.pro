;+
; NAME:
;   dchildren_atlas
; PURPOSE:
;   deblend children of a parent atlas image
; CALLING SEQUENCE:
;   dchildren_atlas [, /galex, /noclobber, glim=, puse=puse, tuse=tuse, $
;           slim=, gsaddle=, gsmooth=, /nostarim ]
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro dchildren_atlas, glim=glim, slim=slim, gsaddle=gsaddle, gsmooth=gsmooth, $
                     noclobber=noclobber, puse=puse, tuse=tuse, $
                     nostarim=nostarim

if(NOT keyword_set(slim)) then slim=5.
if(NOT keyword_set(glim)) then glim=5.
if(NOT keyword_set(gsaddle)) then gsaddle=20.
if(NOT keyword_set(gsmooth)) then gsmooth=2.
if(NOT keyword_set(saddle)) then saddle=5.
if(NOT keyword_set(maxnstar)) then maxnstar=300L

;; find center object
pim=gz_mrdfits(base+'-pimage.fits')
pcat=gz_mrdfits(base+'-pcat.fits',1)
nx=(size(pim,/dim))[0]
ny=(size(pim,/dim))[1]
iparent=pim[nx/2L, ny/2L]

if(iparent eq -1) then return

;; if result exists, skip out
acatfile=subdir+'/'+strtrim(string(iparent),2)+ $
      '/'+base+'-'+strtrim(string(iparent),2)+ $
      '-acat.fits'
if(gz_file_test(acatfile) gt 0 AND $
   keyword_set(noclobber) gt 0) then $
      return

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
simages=ptrarr(nim)
sivars=ptrarr(nim)
nimages=ptrarr(nim)
ivars=ptrarr(nim)
hdrs=ptrarr(nim)
subhdrs=ptrarr(nim)

;; set up settings
aset={base:base, $
      iparent:iparent, $
      ref:ref, $
      sersic:sersic, $
      gsmooth:gsmooth, $
      glim:glim, $
      gsaddle:gsaddle, $
      tuse:tuse}

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
    simages[k]=images[k]
    hdrs[k]=ptr_new(hdr)
    nx[k]=(size(*images[k],/dim))[0]
    ny[k]=(size(*images[k],/dim))[1]
    ivars[k]=ptr_new(gz_mrdfits('parents/'+base+'-parent-'+ $
                                strtrim(string(iparent),2)+'.fits',1+k*2L))
    sivars[k]=ivars[k]
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
dstars, images, ivars, psfs, hdrs, slim=slim, ref=ref, $
        nimages=nimages, ra_stars=ra_stars, dec_stars=dec_stars, $
        nstars=nstars, puse=puse, maxnstar=maxnstar
dgals, nimages, psfs, hdrs, gsmooth=gsmooth, glim=glim, $
       ra_gals=ra_gals, dec_gals=dec_gals, ngals=ngals, puse=puse, $
       gsaddle=gsaddle
for k=0L, nim-1L do begin
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

;; output parent info
asetfile=subdir+'/'+strtrim(string(iparent),2)+'/'+base+'-aset.fits'
mwrfits, aset, asetfile, /create

;; output star and galaxy info
sgsetfile=subdir+'/'+strtrim(string(iparent),2)+'/'+base+'-sgset.fits'
mwrfits, sgset, sgsetfile, /create

if(ngals eq 0 and nstars eq 0) then begin
   return
endif

;; create acat structure to store children in
acat=replicate({pid:iparent, $
                aid:-1L, $
                racen:0.D, $
                deccen:0.D, $
                bgood:lonarr(nim), $
                type:0L, $
                good:0L}, ngals+nstars)
acat.aid=lindgen(ngals+nstars)

;; now store away the centers in acat
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
    
    splog, 'Making stellar templates ...'
    spawn, 'mkdir -p '+subdir+'/'+strtrim(string(iparent),2)

    model=fltarr(nx[kuse],ny[kuse])
    if(nstars gt 0) then begin
        ;; use nxsub, nysub
        stimages=fltarr(nxsub[kuse], nysub[kuse], nstars)
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
                
                ;; need to smooth before storing
                if(keyword_set(gbig) eq 0 or subpix[kuse] eq 1) then begin
                    stimages[*,*,i]=tmp_model
                endif else begin
                    tmp_image=gbig_smooth(tmp_model, nxsub[kuse], $
                                          nysub[kuse], subpix[kuse])
                    stimages[*,*,i]=tmp_image
                    xstars[i]= (xstars[i]+0.5)/float(subpix[kuse])-0.5
                    ystars[i]= (ystars[i]+0.5)/float(subpix[kuse])-0.5
                endelse

                ;; but use UNSMOOTHED model for subtraction
                model=model+tmp_model*scale
            endif
        endfor
    endif
    if(keyword_set(gbig) eq 0 OR subpix[kuse] eq 1) then begin
        nimage=((*simages[kuse])-model) > 0.
    endif else begin 
        smodel=gbig_smooth(model, nxsub[kuse], nysub[kuse], subpix[kuse])
        nimage=((*simages[kuse])-smodel)>0.
        ssig=dsigma(nimage, sp=10)
        nivar=fltarr(nxsub[kuse], nysub[kuse])+1./ssig^2
    endelse
    
    splog, 'Making galaxy templates ...'
    if(ngals gt 0) then begin
        ;; make galaxy templates
        adxy, *subhdrs[kuse], ra_gals, dec_gals, xgals, ygals
        dtemplates, nimage, xgals, ygals, templates=gtemplates, $
          sersic=sersic, ikept=ikept
        sig=dsigma(nimage,sp=5)
        nchild=n_elements(gtemplates)/nxsub[kuse]/nysub[kuse]
        stemplates=fltarr(nxsub[kuse],nysub[kuse],nchild)
        stemplates2=fltarr(nxsub[kuse],nysub[kuse],nchild)
        for i=0L, nchild-1L do begin
            stemplates[*,*,i]= dsmooth(gtemplates[*,*,i], 2.5)
            stemplates2[*,*,i]= dsmooth(gtemplates[*,*,i], 7.5)
            tmp_stemplates=reform(stemplates[*,*,i],nxsub[kuse]*nysub[kuse])
            tmp_stemplates2=reform(stemplates2[*,*,i],nxsub[kuse]*nysub[kuse])
            tmp_templates=reform(gtemplates[*,*,i],nxsub[kuse]*nysub[kuse])
            ii=where(tmp_stemplates lt 2.*sig, nii)
            if(nii gt 0) then $
              tmp_templates[ii]= tmp_stemplates[ii]
            ii=where(tmp_stemplates lt 0.2*sig, nii)
            if(nii gt 0) then $
              tmp_templates[ii]=tmp_stemplates2[ii]
            gtemplates[*,*,i]=reform(tmp_templates, nxsub[kuse], nysub[kuse])
        endfor
    endif

    ;; add stars as templates
    nkept=n_elements(ikept)
    nchild=nkept+nstars
    templates=fltarr(nxsub[kuse],nysub[kuse], nchild)
    if(nkept gt 0) then $
      templates[*,*,0:nkept-1L]=gtemplates
    if(nstars gt 0) then $
      templates[*,*,nkept:nchild-1L]=stimages
    
    if(nxsub[k] ne nxsub[kuse] OR $
       nysub[k] ne nysub[kuse]) then begin
        splog, 'Mapping templates ...'
        extast, *subhdrs[k], k_ast
        extast, *subhdrs[kuse], kuse_ast
        use_templates=fltarr(nxsub[k], nysub[k], nchild)
        for i=0L, nchild-1L do begin
            tmp_ut=fltarr(nxsub[k], nysub[k])
            smosaic_remap, templates[*,*,i], kuse_ast, k_ast, $
              refimage=tmp_ut
            use_templates[*,*,i]=tmp_ut
        endfor
        templates=use_templates
    endif

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
    
    splog, 'Finding weights ...'
    dweights, *simages[k], *sivars[k], templates, weights=weights, /nonneg

    splog, 'Finding fluxes ...'
    dfluxes, *simages[k], templates, weights, xcen, ycen, children=children

    use_child=lindgen(nstars+ngals)
    if(ngals gt 0) then begin
        use_child[0:ngals-1]=-1L
        use_child[ikept]=lindgen(nkept)
        if(nstars gt 0) then $
          use_child[ngals:ngals+nstars-1]=nkept+lindgen(nstars)
    endif

    splog, 'Outputting results ...'
    if(NOT keyword_set(nostarim)) then $
      lastchild=nstars+ngals-1L $ 
    else $
      lastchild=ngals-1L  
    for i=0L, lastchild do begin
        aid=acat[i].aid
        if(use_child[i] ge 0) then begin
            if(total(children[*,*,use_child[i]]) gt 0) then begin
                acat[i].bgood[k]=	1
            endif 
            mwrfits, children[*,*,use_child[i]], subdir+'/'+ $
              strtrim(string(iparent),2)+ $
              '/'+base+'-'+strtrim(string(iparent),2)+ $
              '-atlas-'+strtrim(string(aid),2)+'.fits', *subhdrs[k], $
              create=first
            mwrfits, templates[*,*,use_child[i]], subdir+'/'+ $
              strtrim(string(iparent),2)+ $
              '/'+base+'-'+strtrim(string(iparent),2)+ $
              '-templates-'+strtrim(string(aid),2)+'.fits', *subhdrs[k], $
              create=first
        endif else begin
            mwrfits, fltarr(nxsub[kuse], nysub[kuse]), subdir+'/'+ $
              strtrim(string(iparent),2)+ $
              '/'+base+'-'+strtrim(string(iparent),2)+ $
              '-atlas-'+strtrim(string(aid),2)+'.fits', *subhdrs[k], $
              create=first
            mwrfits, fltarr(nxsub[kuse], nysub[kuse]), subdir+'/'+ $
              strtrim(string(iparent),2)+ $
              '/'+base+'-'+strtrim(string(iparent),2)+ $
              '-templates-'+strtrim(string(aid),2)+'.fits', *subhdrs[k], $
              create=first
        endelse
    endfor
    
    mwrfits, *simages[k], subdir+'/'+ $
      strtrim(string(iparent),2)+ $
      '/'+base+'-'+strtrim(string(iparent),2)+ $
      '-parent.fits', *subhdrs[k], create=first
endfor

if(n_tags(acat) gt 0) then begin
    acat.good= total(acat.bgood, 1) gt 0
    mwrfits, acat, acatfile, /create
 endif

;; free memory
for i=0L, n_elements(images)-1L do $
   ptr_free, images[i]
for i=0L, n_elements(simages)-1L do $
   ptr_free, simages[i]
for i=0L, n_elements(sivars)-1L do $
   ptr_free, sivars[i]
for i=0L, n_elements(nimages)-1L do $
   ptr_free, nimages[i]
for i=0L, n_elements(ivars)-1L do $
   ptr_free, ivars[i]
for i=0L, n_elements(hdrs)-1L do $
   ptr_free, hdrs[i]
for i=0L, n_elements(subhdrs)-1L do $
   ptr_free, subhdrs[i]

return 
end
;------------------------------------------------------------------------------
