;+
; NAME:
;   all_hvcs
; PURPOSE:
;   read in hvc list and do all of them
; REVISION HISTORY:
;   13-Mar-2007  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro all_hvcs

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

for i=0L, n_elements(ra)-1L do begin
    if(dec[i] gt -20.) then begin
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
        
        cd, outdir
        smosaic_make, ra[i], dec[i], angsz, angsz, rerun=[137,161], /fpbin, $
          /global, /maskobj, $
          objlist={run:0, camcol:0, field:0, id:0, rerun:''}, $
          /noran, /ivarout, prefix=prefix, pixscale=pixscale, ncache=1, $
          /ivarclip, /processed, /all
    endif
endfor

end
