pro test_gildepaz

gdp= mrdfits(getenv('DIMAGE_DIR')+'/data/sstest/gildepaz07.fits',1)

version= atlas_default_version()
rdir= atlas_rootdir(version=version)
nsa= mrdfits(rdir+'/nsa_'+version+'.fits',1)

spherematch, gdp._raj2000, gdp._dej2000, nsa.ra, nsa.dec, 5./3600., m1, m2, d12

gdpcomp0= create_struct(gdp[0], $
                        'nd25_child', 0., $
                        'nd25_parent', 0., $
                        'nd25_schild', 0., $
                        'nd25_sparent', 0., $
                        'nd25_full', 0., $
                        'nd25_orig', 0., $
                        'nsersic_child', 0., $
                        'nsersic_parent', 0., $
                        'nsersic_schild', 0., $
                        'nsersic_schild_fit', 0., $
                        'nsersic_schild_fit_sky', 0., $
                        'nsersic_sparent', 0., $
                        'nsersic_full', 0., $
                        'nsersic_orig', 0., $
                        'nsersic_full_fit', 0., $
                        'nsersic_full_fit_sky', 0., $
                        'sersic_th50', 0., $
                        'sersic_phi', 0., $
                        'sersic_n', 0., $
                        'sersic_ba', 0., $
                        'sersic_nmag', 0.)
gdpcomp= replicate(gdpcomp0, n_elements(m1))
struct_assign, gdp[m1], gdpcomp

for i=0L, n_elements(m1)-1L do begin
    atcd, nsa[m2[i]].nsaid 
    dreadcen, image, invvar, band=5L, measure=measure, parent=parent, hdr=hdr

    nimage= mrdfits(nsa[m2[i]].iauname+'-nd.fits.gz',0, nhdr)
    nivar= mrdfits(nsa[m2[i]].iauname+'-nd.fits.gz',1)
    psf= gz_mrdfits(nsa[m2[i]].iauname+'-nd-bpsf.fits.gz',0, /silent)
    cts= mrdfits(nsa[m2[i]].iauname+'-nd.fits.gz',2)
    rr= mrdfits(nsa[m2[i]].iauname+'-nd.fits.gz',3)

    adxy, hdr, nsa[m2[i]].ra, nsa[m2[i]].dec, xcen, ycen
    
    dobjects, parent, plim=5., obj=obj

    nx= (size(image, /dim))[0]
    ny= (size(image, /dim))[1]
    ivar= fltarr(nx, ny)+1.
    izero= where(obj ge 0 or parent eq 0., nzero)
    if(nzero gt 0) then $
      ivar[izero]=0.
    box=80L
    sky= dmedsmooth(parent, ivar, box=box)
    
    sparent= parent
    simage= image
    inz= where(parent ne 0., nnz)
    sparent[inz]= sparent[inz]-sky[inz]
    simage[inz]= simage[inz]-sky[inz]

    dist_ellipse, rad, [nx, ny], xcen, ycen, gdp[m1[i]].majaxis/gdp[m1[i]].minaxis, $
      ((nsa[m2[i]].sersic_phi) mod 180.)
    mask= float(rad lt gdp[m1[i]].majaxis*60./1.5/2.)

    flux_child_d25= total(image*mask)
    flux_parent_d25= total(parent*mask)
    flux_schild_d25= total(simage*mask)
    flux_sparent_d25= total(sparent*mask)

    tsersic={SKY:0., XCEN:xcen, YCEN:ycen, SERSICFLUX:1., $
             SERSICFLUX_IVAR:1., SERSICR50:nsa[m2[i]].sersic_th50/1.5, $
             SERSICN:nsa[m2[i]].sersic_n, AXISRATIO:nsa[m2[i]].sersic_ba, $
             ORIENTATION:nsa[m2[i]].sersic_phi+90., NDOF:0L, $
             CHISQUARED:0., FITPARAM:fltarr(8), PERROR:fltarr(8), $
             COVARIANCE:fltarr(8,8)}
    dsersic, image, invvar, xcen= xcen, ycen= ycen, /fixsky, /fixcen, $
             /onlyflux, sersic=tsersic, psf=psf
    flux_child_sersic= tsersic.sersicflux
    dsersic, simage, invvar, xcen= xcen, ycen= ycen, /fixsky, /fixcen, $
             /onlyflux, sersic=tsersic, psf=psf
    flux_schild_sersic= tsersic.sersicflux
    dsersic, parent, invvar, xcen= xcen, ycen= ycen, /fixsky, /fixcen, $
             /onlyflux, sersic=tsersic, psf=psf
    flux_parent_sersic= tsersic.sersicflux
    dsersic, sparent, invvar, xcen= xcen, ycen= ycen, /fixsky, /fixcen, $
             /onlyflux, sersic=tsersic, psf=psf
    flux_sparent_sersic= tsersic.sersicflux

    dsersic, simage, invvar, xcen= xcen, ycen= ycen, /fixsky, /fixcen, $
             sersic=tsersic, psf=psf
    flux_schild_sersic_fit= tsersic.sersicflux

    dsersic, simage, invvar, xcen= xcen, ycen= ycen, /fixcen, $
             sersic=tsersic, psf=psf
    flux_schild_sersic_fit_sky= tsersic.sersicflux

    adxy, nhdr, nsa[m2[i]].ra, nsa[m2[i]].dec, xcen, ycen
    
    dobjects, nimage, plim=8., obj=obj

    nx= (size(nimage, /dim))[0]
    ny= (size(nimage, /dim))[1]
    factor= 0.3
    box= long(min([nx*factor, ny*factor, 100.]))>10L

    ;; make image
    fimage= fltarr(nx, ny)
    inz= where(rr gt 0., nnz)
    if(nnz gt 0) then $
      fimage[inz]=cts[inz]/rr[inz]*10.^(0.4*(22.5-20.08))

    dist_ellipse, rad, [nx, ny], xcen, ycen, gdp[m1[i]].majaxis/gdp[m1[i]].minaxis, $
      ((nsa[m2[i]].sersic_phi) mod 180.)
    smask= float(rad lt 1.5*gdp[m1[i]].majaxis*60./1.5/2.)

    fivar= fltarr(nx, ny)+1.
    izero= where(obj ge 0 or rr le 0. or smask gt 0., nzero)
    if(nzero gt 0) then $
      fivar[izero]=0.
    sky= dmedsmooth(fimage, fivar, box=box)

    inz= where(rr ne 0., nnz)
    fimage[inz]= fimage[inz]-sky[inz]

    mask= float(rad lt gdp[m1[i]].majaxis*60./1.5/2.)


    flux_orig_d25= total(nimage*mask)
    flux_full_d25= total(fimage*mask)

    tsersic={SKY:0., XCEN:xcen, YCEN:ycen, SERSICFLUX:1., $
             SERSICFLUX_IVAR:1., SERSICR50:nsa[m2[i]].sersic_th50/1.5, $
             SERSICN:nsa[m2[i]].sersic_n, AXISRATIO:nsa[m2[i]].sersic_ba, $
             ORIENTATION:nsa[m2[i]].sersic_phi+90., NDOF:0L, $
             CHISQUARED:0., FITPARAM:fltarr(8), PERROR:fltarr(8), $
             COVARIANCE:fltarr(8,8)}
    dsersic, nimage, nivar, xcen= xcen, ycen= ycen, /fixsky, /fixcen, $
             /onlyflux, sersic=tsersic, psf=psf
    flux_orig_sersic= tsersic.sersicflux
    dsersic, fimage, nivar, xcen= xcen, ycen= ycen, /fixsky, /fixcen, $
             /onlyflux, sersic=tsersic, psf=psf
    flux_full_sersic= tsersic.sersicflux

    dsersic, fimage, nivar, xcen= xcen, ycen= ycen, /fixsky, /fixcen, $
             sersic=tsersic, psf=psf
    flux_full_sersic_fit= tsersic.sersicflux

    dsersic, fimage, nivar, xcen= xcen, ycen= ycen, /fixcen, $
             sersic=tsersic, psf=psf
    flux_full_sersic_fit_sky= tsersic.sersicflux
    
    gdpcomp[i].nd25_child= 22.5-2.5*alog10(flux_child_d25)
    gdpcomp[i].nd25_schild= 22.5-2.5*alog10(flux_schild_d25)
    gdpcomp[i].nd25_parent= 22.5-2.5*alog10(flux_parent_d25)
    gdpcomp[i].nd25_sparent= 22.5-2.5*alog10(flux_sparent_d25)
    gdpcomp[i].nd25_full= 22.5-2.5*alog10(flux_full_d25)
    gdpcomp[i].nd25_orig= 22.5-2.5*alog10(flux_orig_d25)
    gdpcomp[i].nsersic_child= 22.5-2.5*alog10(flux_child_sersic)
    gdpcomp[i].nsersic_schild= 22.5-2.5*alog10(flux_schild_sersic)
    gdpcomp[i].nsersic_schild_fit= 22.5-2.5*alog10(flux_schild_sersic_fit)
    gdpcomp[i].nsersic_schild_fit_sky= 22.5-2.5*alog10(flux_schild_sersic_fit_sky)
    gdpcomp[i].nsersic_parent= 22.5-2.5*alog10(flux_parent_sersic)
    gdpcomp[i].nsersic_sparent= 22.5-2.5*alog10(flux_sparent_sersic)
    gdpcomp[i].nsersic_full= 22.5-2.5*alog10(flux_full_sersic)
    gdpcomp[i].nsersic_orig= 22.5-2.5*alog10(flux_orig_sersic)
    gdpcomp[i].nsersic_full_fit= 22.5-2.5*alog10(flux_full_sersic_fit)
    gdpcomp[i].nsersic_full_fit_sky= 22.5-2.5*alog10(flux_full_sersic_fit_sky)
    gdpcomp[i].sersic_nmag= 22.5-2.5*alog10(nsa[m2[i]].sersicflux[1]>0.001)
    gdpcomp[i].sersic_th50= nsa[m2[i]].sersic_th50
    gdpcomp[i].sersic_phi= nsa[m2[i]].sersic_phi
    gdpcomp[i].sersic_n= nsa[m2[i]].sersic_n
    gdpcomp[i].sersic_ba= nsa[m2[i]].sersic_ba

    help, gdpcomp[i].nd25_full
    help, gdpcomp[i].d25nuv

endfor

mwrfits, gdpcomp, getenv('DIMAGE_DIR')+'/data/sstest/gdpcomp.fits', /create

end
