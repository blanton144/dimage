pro make_lowz_grid, seed=in_seed

common com_mlg, lowz, measure

sample='dr6'
if(NOT keyword_set(satvalue)) then satvalue=30.
if(NOT keyword_set(nonlinearity)) then nonlinearity=3.
if(n_tags(lowz) eq 0) then begin
    lowz= mrdfits(getenv('VAGC_REDUX')+'/lowz/lowz_plus_ned.fits',1)
    il= lindgen(n_elements(lowz))
    indx= where(il lt 20000L OR (il gt 77153 and lowz.icomb ge 0))
    lowz=lowz[indx]
    help,lowz
    ;;measure= mrdfits(getenv('VAGC_REDUX')+'/lowz/lowz_measure.'+sample+'.fits',1)
 ;;   indx=where(lowz.lowz gt 0)
  ;;  lowz=lowz[indx]
    ;;measure=measure[indx]
endif

gmr= lowz.absmag[1]-lowz.absmag[2]
absm= lowz.absmag[2]

ngmr=16L
gmr_min=0.1
gmr_max=0.95
gmr_bin= gmr_min+(gmr_max-gmr_min)*findgen(ngmr+1L)/float(ngmr)

nabsm=16L
absm_min=-15.5
absm_max=-22.5
absm_bin= absm_min+(absm_max-absm_min)*findgen(nabsm+1L)/float(nabsm)

if(NOT keyword_set(in_seed)) then in_seed=101L
seed=in_seed

outdir= getenv('VAGC_REDUX')+'/lowz/lowz-grid-'+ $
  strtrim(string(seed),2)+'-'+ $
  strtrim(string(nabsm, f='(i2.2)'),2)+'-'+ $
  strtrim(string(ngmr, f='(i2.2)'),2)
spawn, 'mkdir -p '+outdir
cd, outdir

rootdir=getenv('DATA')+'/lowz-sdss'
size='150'
write_jpeg, 'blank.jpg', bytarr(long(size), long(size),3), true=3
cmd='montage -bordercolor black -borderwidth 1 '+ $
  '-tile '+strtrim(string(n_elements(absm_bin)-1),2)+'x' $
  +strtrim(string(n_elements(gmr_bin)-1),2)+' ' $
  +'-geometry +0+0 -quality 100 -resize '+size+'x'+size
for igmr= n_elements(gmr_bin)-2L, 0L, -1L do begin
    for iabsm= 0L, n_elements(absm_bin)-2L do begin
        ii= where(gmr gt gmr_bin[igmr] AND $
                  gmr lt gmr_bin[igmr+1] AND $
                  absm lt absm_bin[iabsm] AND $
                  absm gt absm_bin[iabsm+1], nii)
        if(nii gt 5) then begin
            ifile=''
            while(NOT file_test(ifile)) do begin
                indx= ii[shuffle_indx(nii, num_sub=1, seed=seed)]
                subdir= image_subdir(lowz[indx].ra, lowz[indx].dec, $
                                     prefix=prefix, rootdir=rootdir)
                ifile=subdir+'/'+prefix+'-i.fits.gz'
                rfile=subdir+'/'+prefix+'-r.fits.gz'
                gfile=subdir+'/'+prefix+'-g.fits.gz'
            endwhile
            scales= [6., 7., 9.]
            origfile= 'orig-'+strtrim(string(igmr),2)+'-'+ $
              strtrim(string(iabsm),2)+'.jpg'
            djs_rgb_make, ifile, rfile, gfile, name=origfile, $
              scales=scales, nonlinearity=nonlinearity, satvalue=satvalue, $
              quality=100.
            cmd= cmd+' '+origfile
        endif else begin
            cmd= cmd+' blank.jpg'
        endelse
    endfor
endfor
cmd= cmd+' lowz-grid.jpg'

print, cmd
spawn, cmd

end
