lowz=lowz_read(sample='dr4')
ii=where(lowz.absmag[2] lt -22. and lowz.zdist lt 0.04)

ra=lowz[5840].ra
dec=lowz[5840].dec

sdss_dimage, ra, dec
