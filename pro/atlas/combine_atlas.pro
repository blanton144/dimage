;+
; NAME:
;   combine_atlas
; PURPOSE:
;   Combine NED and SDSS lists into a single file
; CALLING SEQUENCE:
;   combine_atlas
; COMMENTS:
;   Reads in the files:
;      atlas_rootdir/catalogs/sdss_atlas.fits
;      atlas_rootdir/catalogs/ned_atlas.fits
;      atlas_rootdir/catalogs/alfalfa_atlas.fits
;      atlas_rootdir/catalogs/sixdf_atlas.fits
;      atlas_rootdir/catalogs/zcat_atlas.fits
;      atlas_rootdir/catalogs/twodf_atlas.fits
;   and outputs:
;      atlas_rootdir/catalogs/atlas_combine.fits
;   which has the contents:
;        .RA (J2000 deg)
;        .DEC (J2000 deg)
;        .ISDSS (position in SdSS)
;        .INED (position in NEd)
;        .IALFALFA (position in NEd)
;        .ISIXDF (position in NEd)
;        .IZCAT (position in NEd)
;        .MAG (a rough B or g magnitude; not science grade)
;        .Z (best heliocentric redshift)
;        .ZSRC (best heliocentric redshift source)
;        .SIZE (desired image size in deg )
; REVISION HISTORY:
;   31-Mar-2004  MRB, NYU
;-
;------------------------------------------------------------------------------
pro combine_atlas, version=version

rootdir=atlas_rootdir(sample=sample, version=version)

atlas0={ra:0.D, dec:0.D, $
        isdss:-1L, $
        ined:-1L, $
        isixdf:-1L, $
        ialfalfa:-1L, $
        izcat:-1L, $
        itwodf:-1L, $
        mag:0., $
        z:0., $
        zsrc:' ', $
        size:0.}

sdss=mrdfits(rootdir+'/catalogs/sdss_atlas.fits', 1)
sdss_size= ((sdss.petrotheta[2]*10L)/3600.) > 0.07
sdss_atlas= replicate(atlas0, n_elements(sdss))
sdss_atlas.ra= sdss.ra
sdss_atlas.dec= sdss.dec
sdss_atlas.isdss= lindgen(n_elements(sdss))
sdss_flux2lups, sdss.cmodelflux, mag, /noivar
sdss_atlas.mag= transpose(mag[1,*]-sdss.extinction[1])
sdss_atlas.z= sdss.z
sdss_atlas.zsrc= 'sdss'
sdss_atlas.size= sdss_size

ned=mrdfits(rootdir+'/catalogs/ned_atlas.fits', 1)
izero= where(ned.mag eq 0, nzero)
if(nzero gt 0) then $
   ned[izero].mag=25.
ned_size= ((ned.major*4./60.) > 0.10) < 0.5
ned_atlas= replicate(atlas0, n_elements(ned))
ned_atlas.ra= ned.ra
ned_atlas.dec= ned.dec
ned_atlas.ined= lindgen(n_elements(ned))
ned_atlas.mag= ned.mag
ned_atlas.z= ned.vel/299792.
ned_atlas.zsrc= 'ned'
ned_atlas.size= ned_size

sixdf=mrdfits(rootdir+'/catalogs/sixdf_atlas.fits', 1)
izero= where(sixdf.bj eq 0, nzero)
if(nzero gt 0) then $
   sixdf[izero].bj=25.
sixdf_size= ((-0.1*(sixdf.bj-10.)+0.5) > 0.10) < 0.5
sixdf_atlas= replicate(atlas0, n_elements(sixdf))
sixdf_atlas.ra= sixdf.ra
sixdf_atlas.dec= sixdf.dec
sixdf_atlas.isixdf= lindgen(n_elements(sixdf))
sixdf_atlas.mag= sixdf.bj
sixdf_atlas.z= sixdf.cz/299792.
sixdf_atlas.zsrc= 'sixdf'
sixdf_atlas.size= sixdf_size

twodf=mrdfits(rootdir+'/catalogs/twodf_atlas.fits', 1)
twodf_size= ((-0.1*(twodf.bjg-10.)+0.5) > 0.10) < 0.5
twodf_atlas= replicate(atlas0, n_elements(twodf))
twodf_atlas.ra= twodf.ra
twodf_atlas.dec= twodf.dec
twodf_atlas.itwodf= lindgen(n_elements(twodf))
twodf_atlas.mag= twodf.bjsel
twodf_atlas.z= twodf.z_helio
twodf_atlas.zsrc= 'twodf'
twodf_atlas.size= twodf_size

alfalfa=mrdfits(rootdir+'/catalogs/alfalfa_atlas.fits', 1)
alfalfa_size= 0.15
alfalfa_atlas= replicate(atlas0, n_elements(alfalfa))
alfalfa_atlas.ra= alfalfa.ra
alfalfa_atlas.dec= alfalfa.dec
alfalfa_atlas.ialfalfa= lindgen(n_elements(alfalfa))
alfalfa_atlas.mag= 25.
alfalfa_atlas.z= alfalfa.cz/299792.
alfalfa_atlas.zsrc= 'alfalfa'
alfalfa_atlas.size= alfalfa_size

zcat=mrdfits(rootdir+'/catalogs/zcat_atlas.fits', 1)
izero= where(zcat.bmag eq 0, nzero)
if(nzero gt 0) then $
   zcat[izero].bmag=25.
zcat_size= ((-0.1*(zcat.bmag-10.)+0.5) > 0.10) < 0.5
zcat_atlas= replicate(atlas0, n_elements(zcat))
zcat_atlas.ra= zcat.ra
zcat_atlas.dec= zcat.dec
zcat_atlas.izcat= lindgen(n_elements(zcat))
zcat_atlas.mag= zcat.bmag
zcat_atlas.z= zcat.z
zcat_atlas.zsrc= 'zcat'
zcat_atlas.size= zcat_size

;; first combine all RA/Decs into a unique list 
all_atlas= [sdss_atlas, ned_atlas, zcat_atlas, alfalfa_atlas, $
            sixdf_atlas, twodf_atlas]
ing= spheregroup(all_atlas.ra, all_atlas.dec, 3./3600., $
                 multg=multg, firstg=firstg, nextg=nextg)


;; now combine information
ng= max(ing)+1L
atlas= replicate(atlas0, ng)
for i=0L, ng-1L do begin
   ;; get list in this group
   indx=firstg[i]
   while(nextg[indx[n_elements(indx)-1]] ne -1) do $
      indx= [indx, nextg[indx[n_elements(indx)-1]]]
   
   ;; use first for RA, DEC, SIZE, MAG, Z, ZSRC
   atlas[i].ra= all_atlas[indx[0]].ra
   atlas[i].dec= all_atlas[indx[0]].dec
   atlas[i].size= all_atlas[indx[0]].size
   atlas[i].mag= all_atlas[indx[0]].mag
   atlas[i].z= all_atlas[indx[0]].z
   atlas[i].zsrc= all_atlas[indx[0]].zsrc

   ;; set each catalog appropriately
   iin= where(all_atlas[indx].isdss ge 0, nin)
   if(nin gt 0) then $
      atlas[i].isdss= all_atlas[indx[iin[0]]].isdss
   iin= where(all_atlas[indx].ined ge 0, nin)
   if(nin gt 0) then $
      atlas[i].ined= all_atlas[indx[iin[0]]].ined
   iin= where(all_atlas[indx].izcat ge 0, nin)
   if(nin gt 0) then $
      atlas[i].izcat= all_atlas[indx[iin[0]]].izcat
   iin= where(all_atlas[indx].ialfalfa ge 0, nin)
   if(nin gt 0) then $
      atlas[i].ialfalfa= all_atlas[indx[iin[0]]].ialfalfa
   iin= where(all_atlas[indx].isixdf ge 0, nin)
   if(nin gt 0) then $
      atlas[i].isixdf= all_atlas[indx[iin[0]]].isixdf
   iin= where(all_atlas[indx].itwodf ge 0, nin)
   if(nin gt 0) then $
      atlas[i].itwodf= all_atlas[indx[iin[0]]].itwodf
endfor

mwrfits, atlas, rootdir+'/catalogs/atlas_combine.fits', /create

end
