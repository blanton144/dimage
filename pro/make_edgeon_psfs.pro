pro make_edgeon_psfs, noclobber=noclobber

nmax=1
if(NOT keyword_set(outbase)) then $
  outbase='edgeon'

cal=mrdfits(getenv('DATA')+'/'+outbase+'/'+outbase+'-cal.fits',1)
im=mrdfits(getenv('DATA')+'/'+outbase+'/'+outbase+'-im.fits',1)
sp=mrdfits(getenv('DATA')+'/'+outbase+'/'+outbase+'-sp.fits',1)

nflat=n_elements(cal)

for i=0L, nflat-1L do begin
    help,i
    
    fp=sdss_readobj(cal[i].run, cal[i].camcol, cal[i].field, $
                    rerun=cal[i].rerun)
    istar=where(fp.psfflux[2] gt 150. and fp.psfflux[2] lt 300. and $
                fp.objc_type eq 6 and fp.nchild eq 0, nstar)
    if(nstar gt 0) then begin
        indx=shuffle_indx(nstar, num_sub=nmax)
        istar=istar[indx]
        nstar=n_elements(istar)
        
        for j=0L, nstar-1L do begin
            ra=cal[i].ra
            dec=cal[i].dec
            ihr=long(ra/15.)
            idec=long(abs(dec)/2.)*2.
            dsign='p'
            if(dec lt 0.) then dsign='m'
            outdir=getenv('DATA')+'/'+outbase+'/'+string(ihr,f='(i2.2)')+'h'
            outdir=outdir+'/'+dsign+strtrim(string(idec, f='(i2.2)'),2)
            prefix=hogg_iau_name(ra,dec,'')
            outdir=outdir+'/'+prefix
            prefix=prefix+'-psf-'+strtrim(string(j),2)
            spawn, 'mkdir -p '+outdir
            smosaic_dimage, fp[istar[j]].ra, fp[istar[j]].dec, 0.02, $
              run=fp[istar[j]].run, objlist=fp[istar[j]], $
              orientation=(-cal[i].phi_iso_deg[2]), /maskobj, $
              /ivarclip, prefix=outdir[0]+'/'+prefix[0], noclobber=noclobber
        endfor
    endif
endfor

end
