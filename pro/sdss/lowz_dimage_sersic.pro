;+
; NAME:
;   lowz_dimage_sersic
; PURPOSE:
;   go to each lowz image and satellite and make sersic 
; REVISION HISTORY:
;   31-July-2008
;-
;------------------------------------------------------------------------------
pro lowz_dimage_sersic, sample=sample, dnearest=dnearest, $
                        start=start, nd=nd, noclobber=noclobber, $
                        check=check

if(NOT keyword_set(sample)) then sample='dr6'
if(NOT keyword_set(start)) then start=0L
if(keyword_set(check)) then noclobber=1
ref=2

lowz=gz_mrdfits(getenv('VAGC_REDUX')+'/lowz/lowz_plus_ned.fits', 1)

lowzdir=getenv('VAGC_REDUX')+'/lowz/'
rootdir=getenv('DATA')+'/lowz-sdss'

if(NOT keyword_set(nd)) then nd=n_elements(lowz)-1L

isort=lindgen(n_elements(lowz))
iexclude=lowz_iexclude()

nband=5


if(NOT keyword_set(nd)) then nd=n_elements(lowz)-1L
for istep=start, nd do begin
    splog, i
    i=isort[istep]
    ii=where(iexclude eq i, nii)
    
    if(nii eq 0 AND lowz[i].icomb ge 0) then begin
        subdir=image_subdir(lowz[i].ra, lowz[i].dec, $
                            prefix=prefix, rootdir=rootdir)
        spawn, 'mkdir -p '+subdir
        
        pim= gz_mrdfits(subdir+'/'+prefix+'-pimage.fits')
        if(keyword_set(pim)) then begin
            nx=(size(pim,/dim))[0]
            ny=(size(pim,/dim))[1]
            pid=pim[nx/2L, ny/2L]
            pstr=strtrim(string(pid),2)
            
            sub='atlases'
            if(gz_file_test('hand/'+pstr)) then $
              sub='hand'
            
            sfile=subdir+'/'+sub+'/'+pstr+'/'+prefix+'-'+pstr+'-sersic.fits'
            if(keyword_set(noclobber) eq 0 OR $
               gz_file_test(sfile) eq 0 OR $
               keyword_set(check) gt 0) then begin
                
                acat=gz_mrdfits(subdir+'/'+sub+'/'+pstr+'/'+prefix+'-'+pstr+ $
                                '-acat.fits',1)
                nkeep=0

                if(n_tags(acat) gt 0) then $
                  ikeep=where(acat.good gt 0 and acat.type eq 0, nkeep)
                
                if(tag_exist(acat, 'RACEN') gt 0 AND $
                   nkeep gt 0) then begin
                    acat=acat[ikeep]
                    spherematch, lowz[i].ra, lowz[i].dec, acat.racen, $
                      acat.deccen, 1., m1, m2
                    if (m1[0] eq -1) then $
                      message, 'no match?'
                    aid=acat[m2].aid
                    astr=strtrim(string(aid),2)
                    
                    rimage=gz_mrdfits(subdir+'/'+sub+'/'+pstr+'/'+prefix+'-'+ $
                                  pstr+'-atlas-'+astr+'.fits', ref, hdr)
                    rinvvar=gz_mrdfits(subdir+'/parents/'+prefix+'-parent-'+ $
                                   pstr+'.fits', ref*2L+1L, hdr)
                    rinvvar=rinvvar>0.

                    if(keyword_set(noclobber) eq 0 OR $
                       gz_file_test(sfile) eq 0) then begin
                        
                        adxy, hdr, acat[m2].racen, acat[m2].deccen, xcen, ycen
                        
                        dsersic, rimage, rinvvar, xcen=xcen, ycen=ycen, $
                          model=model, /reinit, /fixcen, /fixsky, sersic=sersic
                        r50=sersic.sersicr50
                        
                        help,/st,sersic
                        
                        sersic= create_struct(sersic, 'aid', aid)
                        sfit=struct_trimtags(sersic, except='SERSICFLUX')
                        sfit=create_struct(sfit, 'SERSICFLUX',fltarr(7))
                        models=ptrarr(nband)
                        for iband=0L, nband-1 do begin
                            image=gz_mrdfits(subdir+'/'+sub+'/'+pstr+ $
                                             '/'+prefix+'-'+ $
                                             pstr+'-atlas-'+astr+'.fits', $
                                             iband, hdr)
                            invvar=gz_mrdfits(subdir+'/parents/'+prefix+ $
                                              '-parent-'+pstr+'.fits', $
                                              iband*2L+1L, hdr)
                            invvar=invvar>0.
                            
                            adxy, hdr, acat[m2].racen, acat[m2].deccen, $
                              xcen, ycen
                            
                            sersic.xcen=xcen
                            sersic.ycen=ycen
                            
                            dsersic, image, invvar, xcen=xcen, ycen=ycen, $
                              model=model, /fixcen, /fixsky, sersic=sersic, $
                              /onlyflux
                            help,/st,sersic
                            sfit.sersicflux[iband]= sersic.sersicflux
                            models[iband]=ptr_new(model)
                        endfor
                        
                        omodel=model/sersic.sersicflux
                        mwrfits, sfit, sfile, /create
                        for iband=0L, nband-1 do $
                          mwrfits, *models[iband], sfile
                        spawn, 'gzip -vf '+sfile
                    endif
                    
                    if(keyword_set(check) gt 0) then begin
                        rmodel=gz_mrdfits(sfile, 2L+ref)
                        anx=(size(rmodel, /dim))[0]
                        any=(size(rmodel, /dim))[1]
                        full= fltarr(anx*2L, any*2L)
                        full[0:anx-1L, 0:any-1L]= rimage
                        full[anx:2*anx-1L, 0:any-1L]= rmodel
                        full[0:anx-1L, any:2*any-1L]= rimage-rmodel
                        full[anx:2*anx-1L, any:2*any-1L]= $
                          (rimage-rmodel)*sqrt(rinvvar)
                        atv, full, /block
                    endif
                endif
            endif 
        endif
    endif
endfor
    
end
