;+
; NAME:
;   fake_masked_cluster
; PURPOSE:
;   read in masked cluster list and do all of them
; CALLING SEQUENCE:
;   masked_cluster, ra, dec
; REVISION HISTORY:
;   13-Mar-2007  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro fake_masked_cluster

all=mrdfits(getenv('DATA')+'/fakeobs/icl/fake_icl_sample_stamps.fits',1)

z=0.1
for i=0, n_elements(all)-1L do begin
    im=sdss_findimage(all[i].ra, all[i].dec, rerun=9137)
    run=im[0].run
    rerun=9137
    camcol=im[0].camcol
    field=im[0].field

    print,run,camcol,field
    
    obj=sdss_findobj(all[i].ra, all[i].dec, run=run, $
                     rerun=[9137], childobj=include)
    masked_cluster, all[i].ra, all[i].dec, z, include=include, $
      outdir=outdir, /obj, outbase='fake_masked_clusters'
    outcat=outdir+'/cat-'+hogg_iau_name(all[i].ra, all[i].dec,'')+'.fits'
    mwrfits, all[i], outcat, /create
    outphoto=outdir+'/photo-'+hogg_iau_name(all[i].ra, all[i].dec,'')+'.fits'
    mwrfits, include, outphoto, /create
endfor

end
