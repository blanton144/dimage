pro make_edgeon_images, noclobber=noclobber

if(NOT keyword_set(outbase)) then $
  outbase='edgeon'

cal=mrdfits(getenv('DATA')+'/'+outbase+'/'+outbase+'-cal.fits',1)
im=mrdfits(getenv('DATA')+'/'+outbase+'/'+outbase+'-im.fits',1)
sp=mrdfits(getenv('DATA')+'/'+outbase+'/'+outbase+'-sp.fits',1)

spherematch, 240.977979817, -0.362394478839, cal.ra, cal.dec, 1./3600., $
  m1,m2,d12

cal=cal[m2]
im=im[m2]
sp=sp[m2]

nflat=n_elements(cal)

for i=0L, nflat-1L do begin
    help,i
    
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
    spawn, 'mkdir -p '+outdir
    smosaic_dimage, cal[i].ra, cal[i].dec, 0.02, run=cal[i].run, $
      objlist=cal[i], orientation=(-cal[i].phi_iso_deg[2]), /maskobj, $
      /ivarclip, prefix=outdir[0]+'/'+prefix[0], noclobber=noclobber
endfor

end
