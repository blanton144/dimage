pro try_cluster_stack

cldir=getenv('DATA')+'/masked_clusters/'

all=mrdfits(cldir+'/maxbcg_icl_sample.fits',1)

ii=where(lindgen(n_elements(all)) ge 0 and $
         lindgen(n_elements(all)) le 8000 AND $
         all.z gt 0.10 and all.z lt 0.15, nii)

gfull=dblarr(500,500)
rfull=dblarr(500,500)
ifull=dblarr(500,500)
weight=dblarr(500,500)
for i=0L, nii-1L do begin
    ra=all[ii[i]].ra
    dec=all[ii[i]].dec
    ihr=long(ra/15.)
    idec=long(abs(dec)/2.)*2.
    dsign='p'
    if(dec lt 0.) then dsign='m'
    outdir=getenv('DATA')+'/masked_clusters/'+string(ihr,f='(i2.2)')+'h'
    outdir=outdir+'/'+dsign+strtrim(string(idec, f='(i2.2)'),2)
    prefix='mBCG-'+hogg_iau_name(ra,dec,'')
    outdir=outdir+'/'+prefix
    rim=mrdfits(outdir[0]+'/cen-'+prefix[0]+'-r.fits.gz',0)
    gim=mrdfits(outdir[0]+'/cen-'+prefix[0]+'-g.fits.gz',0)
    iim=mrdfits(outdir[0]+'/cen-'+prefix[0]+'-i.fits.gz',0)
    if(keyword_set(gim)) then begin
        nx=(size(gim,/dim))[0]
        nf=(size(gfull,/dim))[0]
        is=nf/2L-nx/2L
        gfull[is:is+nx-1L, is:is+nx-1L]= $
          gfull[is:is+nx-1L,is:is+nx-1L]+gim
        rfull[is:is+nx-1L, is:is+nx-1L]= $
          rfull[is:is+nx-1L,is:is+nx-1L]+rim
        ifull[is:is+nx-1L, is:is+nx-1L]= $
          ifull[is:is+nx-1L,is:is+nx-1L]+iim
        iw=where(iim ne 0., nw)
        if(nw gt 0) then $
          weight[is:is+nx-1L, is:is+nx-1L]= $
          weight[is:is+nx-1L,is:is+nx-1L]+1.
    endif
endfor

rfinal=rfull/(weight+float(rfull eq 0.))
gfinal=gfull/(weight+float(gfull eq 0.))
ifinal=ifull/(weight+float(ifull eq 0.))

nw_rgb_make, ifinal, rfinal, gfinal, name='final_low.jpg', $
  scales=[400., 400., 400.]

save, filename='try.sav'

end
