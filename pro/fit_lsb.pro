pro fit_lsb

if(NOT keyword_set(base)) then begin
    spawn, 'pwd', cwd
    words=strsplit(cwd[0], '/',/extr)
    base=words[n_elements(words)-1]
    imfiles=base+'-'+['u', 'g', 'r', 'i', 'z']+'.fits.gz'
endif

ucat=mrdfits(base+'-ucat.fits',1)

igal=where(ucat.type eq 0, ngal)

for i=0L, ngal-1L do begin
    pid=ucat[igal[i]].pid
    aid=ucat[igal[i]].aid
    afile= 'atlases'+'/'+ $
      strtrim(string(pid),2)+ $
      '/'+base+'-'+strtrim(string(pid),2)+ $
      '-atlas-'+strtrim(string(aid),2)+'.fits'
    rim=mrdfits(afile,2)
    nx=(size(rim,/dim))[0]
    ny=(size(rim,/dim))[1]
    sig=dsigma(rim, sp=5)

    if(sig gt 0) then begin
        riv=fltarr(nx,ny)+1./sig^2
        
        xcen=ucat[igal[i]].xcen
        ycen=ucat[igal[i]].ycen
        dsersic, rim, riv, xcen= xcen, ycen=ycen, sersic=tmp_sersic, $
          model=tmp_model, /fixcen, /fixsky, /axisymmetric
        
        if(n_tags(sersic) eq 0) then begin
            sersic=replicate(tmp_sersic, n_elements(ucat))
            struct_assign, {junk:0}, sersic
        endif
        sersic[igal[i]]=tmp_sersic
        
        tmp_model=0
        tmp_sersic=0
    endif

endfor

mwrfits, sersic, base+'-sersic.fits', /create

end
