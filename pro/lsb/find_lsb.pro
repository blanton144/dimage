pro find_lsb

files=file_search('*/*/*-sersic.fits')
for i=0L, n_elements(files)-1L do begin
    base=(stregex(files[i],'.*/.*/(.*)-sersic.fits', /extr, /sub))[1]
    path=(stregex(files[i],'(.*/.*)/.*-sersic.fits', /extr, /sub))[1]
    sersic=mrdfits(path+'/'+base+'-sersic.fits',1)
    ucat=mrdfits(path+'/'+base+'-ucat.fits',1)
    ii=where(sersic.sersicr50 gt 30. and sersic.sersicn lt 5. and $
             sersic.sersicflux gt 10., nii)
    for j=0L, nii-1L do $
      print, path+' pid='+strtrim(string(ucat[ii[j]].pid),2)
endfor

end
