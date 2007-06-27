;+
; NAME:
;   sdss_gal_field
; PURPOSE:
;   make images of an SDSS field with the point sources removed
; CALLING SEQUENCE:
;   sdss_gal_field, run, camcol, field, rerun=, outdir=
; INPUTS:
;   run, camcol, field, rerun - image to write
; OPTIONAL INPUTS:
;   outdir - output directory
; COMMENTS:
;   Primarily for going back and detecting large galaxies.
;   Uses global sky to subtract.
;   Writes out:
;     [outdir]/sdss-gal-[run6]-[camcol]-[field4]-[rerun]-[ugriz].fits
; REVISION HISTORY:
;   22-May-2007  Written by Mike Blanton, NYU
;-
;------------------------------------------------------------------------------
pro sdss_gal_field, run, camcol, field, rerun=rerun, outdir=outdir, $
                    noclobber=noclobber, base=base

if(NOT keyword_set(outdir)) then outdir='.'

fpdata=sdss_readobj(run, camcol, field, rerun=rerun)
rmag=22.5-2.5*alog10(fpdata.modelflux[2])
ikeep=where(fpdata.objc_type eq 3 OR $
            rmag gt 21., nkeep)
if(nkeep gt 0) then $
  ids=fpdata[ikeep].id

base='sdss-gal-'+strtrim(string(run, f='(i6.6)'),2)+ $
  '-'+strtrim(string(camcol, f='(i1.1)'),2)+ $
  '-'+strtrim(string(field, f='(i4.4)'),2)+ $
  '-'+strtrim(string(rerun),2)
for ifilter=0L, 4L do begin
    
    outfile=outdir+'/'+base+'-'+filtername(ifilter)+'.fits'
    
    if(file_test(outfile+'.gz') eq 0 OR $
       keyword_set(noclobber) eq 0) then begin
        image = fpbin_to_frame(run, camcol, field, $
                               ids, rerun=rerun, $
                               filter=ifilter, $
                               invvar=invvar, seed=seed, $
                               /addsky, /sheldon, /register, hdr=hdr)
        
        if (keyword_set(rerun)) then $
          calib = sdss_calib(run, rerun=rerun, camcol, field)
        if (keyword_set(calib)) then begin
            nmgypercount = (calib.nmgypercount[ifilter])[0]
        endif else begin
            nmgypercount = pfit_default_aterm(run, camcol, $
                                              filter=ifilter)
        endelse
        image = nmgypercount * image
        invvar= invvar / nmgypercount^2
        
        sdss_skyfield, run, camcol, field, $
          rerun=rerun, sky=sky, filter=ifilter
        sky=sky*nmgypercount
        
        image=image-sky
        
        mwrfits, image, outfile, hdr, /create
        mwrfits, invvar, outfile, hdr
        
        spawn, 'gzip -fv '+outfile
    endif
endfor

end
;------------------------------------------------------------------------------
