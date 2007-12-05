pro try_hvc_stack

;-----------------------;
; Read In Data For HVCs ;
;-----------------------;
readcol, getenv('DIMAGE_DIR')+'/data/Putman_HVC_all.dat', put_ID, $
  type, rah, ram, Phvc_decd, Phvc_decm, VLSR, VGSR, VLGSR, V_FWHM, $
  put_maj, min, $
  PA, size, T_peak, N, Pflux, F = 'I,A,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F'

readcol, getenv('DIMAGE_DIR')+'/data/LDS_catalog.dat', lds_ID, lds_type, $
  lds_rah, lds_ram, lds_decd, lds_decm, lds_vlsr, lds_vgsr, lds_vlgsr, $
  lds_fwhm, $
  lds_maj, lds_min, lds_PA, lds_T, lds_N, lds_flux, $
  F = 'I,A,X,F,F,F,F,F,F,F,F,F,F,F,F,F,I,X,X'

string2radec, string([rah, lds_rah]), $
  string([ram, lds_ram]), $
  string(replicate('30',n_elements(rah)+n_elements(lds_rah))), $
  string([phvc_decd, lds_decd]), $
  string([phvc_decm, lds_decm]), $
  string(replicate('30',n_elements(rah)+n_elements(lds_rah))), $
  ra, dec

glactc, ra, dec, 2000, gl, gb, 1, /deg

for i=0L, n_elements(ra)-1L do begin
    if(dec[i] gt -10. and gb[i] gt 20.) then begin
        pixscale=4.*0.396/3600.
        angsz=20./60.
        
        ihr=long(ra[i]/15.)
        idec=long(abs(dec[i])/2.)*2.
        dsign='p'
        if(dec[i] lt 0.) then dsign='m'
        outdir='/global/bias2/dimage_hvc/'+string(ihr,f='(i2.2)')+'h'
        outdir=outdir+'/'+dsign+strtrim(string(idec, f='(i2.2)'),2)
        prefix='mhvc-'+hogg_iau_name(ra[i],dec[i],'')
        outdir=outdir+'/'+prefix
        spawn, 'mkdir -p '+outdir

        rim=mrdfits(outdir[0]+'/'+prefix[0]+'-r.fits.gz',0)
        gim=mrdfits(outdir[0]+'/'+prefix[0]+'-g.fits.gz',0)
        iim=mrdfits(outdir[0]+'/'+prefix[0]+'-i.fits.gz',0)

        if(keyword_set(gim)) then begin
            if(NOT keyword_set(gfull)) then begin
                nx=(size(gim,/dim))[0]
                ny=(size(gim,/dim))[1]
                gfull=fltarr(nx,ny)
                rfull=fltarr(nx,ny)
                ifull=fltarr(nx,ny)
                weight=fltarr(nx,ny)
            endif
            gfull=gfull+gim
            rfull=rfull+rim
            ifull=ifull+iim
            iw=where(iim ne 0., nw)
            if(nw gt 0) then $
              weight[iw]=weight[iw]+1.
        endif
        
    endif
endfor

rfinal=rfull/(weight+float(rfull eq 0.))
gfinal=gfull/(weight+float(gfull eq 0.))
ifinal=ifull/(weight+float(ifull eq 0.))

nw_rgb_make, ifinal, rfinal, gfinal, name='final_hvc.jpg', $
  scales=[400., 400., 400.]

save, filename='try.sav'

end
