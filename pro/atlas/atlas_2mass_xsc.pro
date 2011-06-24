;+
; NAME:
;   atlas_2mass_xsc
; PURPOSE:
;   match atlas_combine.fits to the 2MASS XSC
; CALLING SEQUENCE:
;   atlas_2mass_xsc 
; COMMENTS:
;   Reads from: 
;     atlas_rootdir/catalogs/atlas_combine.fits
;     $VAGC_REDUX/twomass/twomass_catalog_00[0-3].fits
;   Writes to:
;     atlas_rootdir/catalogs/atlas_2mass_xsc.fits
; REVISION HISTORY:
;   3-Aug-2004  MRB, NYU
;-
;------------------------------------------------------------------------------
pro atlas_2mass_xsc, version=version

rootdir= atlas_rootdir(version=version)
combine=gz_mrdfits(rootdir+'/catalogs/atlas_combine.fits', 1)

for i=0L, 3L do begin
    filebase= getenv('VAGC_REDUX')+'/twomass/twomass_catalog_'
    filename= filebase+string(f='(i3.3)', i)+'.fits'
    xsc= mrdfits(filename,1)
    spherematch, combine.ra, combine.dec, xsc.ra, xsc.decl, 3./3600., m1, m2
    if(n_tags(outx) eq 0) then begin
        outx0= xsc[0]
        struct_assign, {junk:0}, outx0
        outx= replicate(outx0, n_elements(combine))
    endif 
    outx[m1]= xsc[m2]
endfor

mwrfits, outx, rootdir+'/catalogs/atlas_2mass_xsc.fits', /create
  
end
