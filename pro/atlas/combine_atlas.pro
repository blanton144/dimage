;+
; NAME:
;   combine_atlas
; PURPOSE:
;   Combine NED and SDSS lists into a single file
; CALLING SEQUENCE:
;   combine_atlas
; COMMENTS:
;   Reads in the files:
;      $DIMAGE_DIR/data/atlas/sdss_atlas.fits
;      $DIMAGE_DIR/data/atlas/ned_atlas.fits
;      $DIMAGE_DIR/data/atlas/alfalfa_atlas.fits
;      $DIMAGE_DIR/data/atlas/sixdf_atlas.fits
;      $DIMAGE_DIR/data/atlas/zcat_atlas.fits
;   and outputs:
;      $DIMAGE_DIR/data/atlas/atlas.fits
;   which has the contents:
;        .RA (J2000 deg)
;        .DEC (J2000 deg)
;        .ISDSS (position in SdSS)
;        .INED (position in NEd)
;        .SIZE (desired image size in deg )
; REVISION HISTORY:
;   31-Mar-2004  MRB, NYU
;-
;------------------------------------------------------------------------------
pro combine_atlas

atlas0={ra:0.D, dec:0.D, $
        isdss:-1L, $
        ined:-1L, $
        isixdf:-1L, $
        ialfalfa:-1L, $
        izcat:-1L, $
        size:0.}

sdss=mrdfits(getenv('DIMAGE_DIR')+'/data/atlas/sdss_atlas.fits', 1)
sdss_size= sdss.petrotheta[2]*8L > 0.07
sdss_atlas= replicate(atlas0, n_elements(sdss))
sdss_atlas.ra= sdss.ra
sdss_atlas.dec= sdss.dec
sdss_atlas.isdss= lindgen(n_elements(sdss))
sdss_atlas.size= sdss_size

ned=mrdfits(getenv('DIMAGE_DIR')+'/data/atlas/ned_atlas.fits', 1)
ned_size= (ned.major*6L > 0.15) < 0.5
ned_atlas= replicate(atlas0, n_elements(ned))
ned_atlas.ra= ned.ra
ned_atlas.dec= ned.dec
ned_atlas.ined= lindgen(n_elements(ned))
ned_atlas.size= ned_size

zcat=mrdfits(getenv('DIMAGE_DIR')+'/data/atlas/zcat_atlas.fits', 1)
zcat_size= 0.15
zcat_atlas= replicate(atlas0, n_elements(zcat))
zcat_atlas.ra= zcat.ra
zcat_atlas.dec= zcat.dec
zcat_atlas.izcat= lindgen(n_elements(zcat))
zcat_atlas.size= zcat_size

alfalfa=mrdfits(getenv('DIMAGE_DIR')+'/data/atlas/alfalfa_atlas.fits', 1)
alfalfa_size= 0.15
alfalfa_atlas= replicate(atlas0, n_elements(alfalfa))
alfalfa_atlas.ra= alfalfa.ra
alfalfa_atlas.dec= alfalfa.dec
alfalfa_atlas.ialfalfa= lindgen(n_elements(alfalfa))
alfalfa_atlas.size= alfalfa_size

sixdf=mrdfits(getenv('DIMAGE_DIR')+'/data/atlas/sixdf_atlas.fits', 1)
sixdf_size= 0.15
sixdf_atlas= replicate(atlas0, n_elements(sixdf))
sixdf_atlas.ra= sixdf.ra
sixdf_atlas.dec= sixdf.dec
sixdf_atlas.isixdf= lindgen(n_elements(sixdf))
sixdf_atlas.size= sixdf_size

;; first combine all RA/Decs into a unique list 
all_atlas= [sdss_atlas, ned_atlas, zcat_atlas, alfalfa_atlas, sixdf_atlas]
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
   
   ;; use first for RA, DEC, SIZE
   atlas[i].ra= all_atlas[indx[0]].ra
   atlas[i].dec= all_atlas[indx[0]].dec
   atlas[i].size= all_atlas[indx[0]].size

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
endfor

mwrfits, atlas, getenv('DIMAGE_DIR')+'/data/atlas/atlas_combine.fits', /create

end
