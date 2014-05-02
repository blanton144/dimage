pro mk_recovery_galex, st=st, nd=nd

rootdir=atlas_rootdir(version=version, ddir=ddir, cdir=cdir, subname=subname)
infile=cdir+'/atlas.fits'
atlas= gz_mrdfits(infile, 1)

redo=bytarr(n_elements(atlas))
if(n_elements(st) eq 0) then st=0L
if(n_elements(nd) eq 0) then nd=n_elements(atlas)-1L
for i=st, nd do begin
    if((i mod 100) eq 0) then help, i
    subdir=strtrim(atlas[i].subdir, 2)
    iauname=strtrim(atlas[i].iauname, 2)
    gdir= rootdir+'/detect/galex/'+subdir
    hasn= file_test(gdir+'/'+iauname+'-nd.fits.gz') 
    nfile= rootdir+'/'+subname+'/'+subdir+'/'+ $
      iauname+'-nd.fits.gz'
    ffile= rootdir+'/'+subname+'/'+subdir+'/'+ $
      iauname+'-fd.fits.gz'
    pfile= rootdir+'/'+subname+'/'+subdir+'/'+ $
      iauname+'-pimage.fits.gz'

    notlinkedn= $
      (file_test(nfile, /sym) eq 0 OR $
       file_test(nfile) eq 0)
    hasf=file_test(gdir+'/'+iauname+'-fd.fits.gz') 
    notlinkedf= $
      (file_test(ffile, /sym) eq 0 OR $
       file_test(ffile) eq 0)
    if((hasn ne 0 and notlinkedn ne 0) OR $
       (hasf ne 0 and notlinkedf ne 0)) then begin
        splog, 'NOT LINK '+string(i)
        redo[i]=1
    endif
    
    if(redo[i] eq 0) then begin
        if(file_test(pfile) eq 0) then begin
            splog, 'PIMAGE '+string(i)
            redo[i]=3
            continue
        endif
        spawn, /nosh, ['stat', '-t', pfile], pout
        ptime=long64((strsplit(pout,/extr))[12])
        if(file_test(nfile) ne 0) then begin
            spawn, /nosh, ['stat', '-t', nfile], nout
            ntime=long64((strsplit(nout,/extr))[12])
            if(ptime lt ntime) then begin
                splog, 'TIME '+string(i)
                redo[i]=2
            endif
        endif 
        if(file_test(ffile) ne 0) then begin
            spawn, /nosh, ['stat', '-t', ffile], fout
            ftime=long64((strsplit(fout,/extr))[12])
            if(ptime lt ftime) then begin
                splog, 'TIME '+string(i)
                redo[i]=2
            endif
        endif
    endif
endfor

ibad= where(redo gt 0, nbad)

if(nbad eq 0) then return

out0= {nsaid:-1L, why:0L}
out= replicate(out0, nbad)
out.nsaid=ibad
out.why=redo[ibad]

mwrfits, out, 'recovery_galex_'+strtrim(st,2)+'.fits', /create

end
