;+
; NAME:
;   lowz_dimage_measure
; PURPOSE:
;   go to each lowz image and satellite and make measuremeanst
; REVISION HISTORY:
;   31-July-2008
;-
;------------------------------------------------------------------------------
pro lowz_dimage_measure, sample=sample, dnearest=dnearest, $
                         start=start, nd=nd, noclobber=noclobber, $
                         check=check, gather=gather, ref=ref, $
                         hand=hand, ned=ned, nomeasure=nomeasure

common com_ldm, lowz

if(NOT keyword_set(sample)) then sample='dr6'
if(NOT keyword_set(start)) then start=0L
if(n_elements(ref) eq 0) then ref=2

if(n_tags(lowz) eq 0) then $
  lowz=gz_mrdfits(getenv('VAGC_REDUX')+'/lowz/lowz_plus_ned.fits', 1)

lowzdir=getenv('VAGC_REDUX')+'/lowz/'
rootdir=getenv('DATA')+'/lowz-sdss'

if(NOT keyword_set(nd)) then nd=n_elements(lowz)-1L

isort=lindgen(n_elements(lowz))
iexclude=lowz_iexclude()

bands=['u', 'g', 'r', 'i', 'z']
nbands=n_elements(bands)

if(NOT keyword_set(nd)) then nd=n_elements(lowz)-1L
for istep=start, nd do begin
    splog, istep
    i=isort[istep]
    ii=where(iexclude eq i, nii)
    
    if(nii eq 0 AND lowz[i].icomb ge 0) then begin
        subdir=image_subdir(lowz[i].ra, lowz[i].dec, $
                            prefix=prefix, rootdir=rootdir)
        spawn, 'mkdir -p '+subdir
        
        pim= gz_mrdfits(subdir+'/'+prefix+'-pimage.fits', /silent)
        if(keyword_set(pim)) then begin
            nx=(size(pim,/dim))[0]
            ny=(size(pim,/dim))[1]
            pid=pim[nx/2L, ny/2L]
            pstr=strtrim(string(pid),2)
            
            sub='atlases'
            postfix=''
            if(gz_file_test('hand/'+pstr) gt 0 AND $
               keyword_set(hand) gt 0) then begin
                sub='hand'
                postfix='-hand'
            endif
            
            mfile=subdir+'/'+sub+'/'+pstr+'/'+prefix+'-'+pstr+ $
              '-measure'+postfix+'.fits'
            if(keyword_set(noclobber) eq 0 OR $
               gz_file_test(mfile) eq 0 OR $
               keyword_set(check) gt 0 OR $
               keyword_set(gather) gt 0) then begin
                
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

                    if((keyword_set(noclobber) eq 0 OR $
                        gz_file_test(mfile) eq 0) AND $
											 keyword_set(nomeasure) eq 0) then begin
                        
                        adxy, hdr, acat[m2].racen, acat[m2].deccen, xcen, ycen
                        
                        dmeasure, rimage, rinvvar, xcen=xcen, ycen=ycen, $
                          measure=r_measure
                        
                        help,/st,r_measure
                        
                        mall= {xcen:r_measure.xcen, $
                               ycen:r_measure.ycen, $
                               nprof:fltarr(nbands), $
                               profmean:fltarr(nbands, 15), $
                               profmean_ivar:fltarr(nbands, 15), $
                               profradius:r_measure.profradius, $
                               qstokes:fltarr(nbands, 15), $
                               ustokes:fltarr(nbands, 15), $
                               bastokes:fltarr(nbands, 15), $
                               phistokes:fltarr(nbands, 15), $
                               petroflux:fltarr(nbands), $
                               petrorad:r_measure.petrorad, $
                               petror50:r_measure.petror50, $
                               petror90:r_measure.petror90, $
                               ba50:r_measure.ba50, $
                               phi50:r_measure.phi50, $
                               ba90:r_measure.ba90, $
                               phi90:r_measure.phi90, $
                               asymmetry:fltarr(5), $
                               clumpy:fltarr(5), $
                               dflags:lonarr(5), $
                               aid:aid}

                        for iband=0L, nbands-1L do begin
                            image=gz_mrdfits(subdir+'/'+sub+'/'+pstr+'/'+ $
                                             prefix+'-'+pstr+'-atlas-'+ $
                                              astr+'.fits', iband, hdr)
                            invvar=gz_mrdfits(subdir+'/parents/'+prefix+ $
                                              '-parent-'+pstr+'.fits', $
                                              iband*2L+1L, hdr)
                            invvar=invvar>0.

                            dmeasure, image, invvar, xcen=mall.xcen, $
                              ycen=mall.ycen, /fixcen, measure=tmp_measure, $
                              cpetrorad= mall.petrorad
                            
                            mall.nprof[iband]= tmp_measure.nprof
                            mall.profmean[iband,*]= $
                              tmp_measure.profmean
                            mall.profmean_ivar[iband,*]= $
                              tmp_measure.profmean_ivar
                            mall.qstokes[iband,*]= tmp_measure.qstokes
                            mall.ustokes[iband,*]= tmp_measure.ustokes
                            mall.bastokes[iband,*]= tmp_measure.bastokes
                            mall.phistokes[iband,*]= tmp_measure.phistokes
                            mall.petroflux[iband]= tmp_measure.petroflux
                            mall.asymmetry[iband]= tmp_measure.asymmetry
                            mall.clumpy[iband]= tmp_measure.clumpy
                            mall.dflags[iband]= tmp_measure.dflags
                        endfor
                        
                        mwrfits, mall, mfile, /create
                        spawn, 'gzip -vf '+mfile
                    endif

                    if(keyword_set(check)) then begin
                        mall= gz_mrdfits(mfile,1)
                        dmeasure_check, rimage, rinvvar, measure=mall
                    endif

                    if(keyword_set(gather)) then begin
                        mall= gz_mrdfits(mfile,1, /silent)
												if(n_tags(mall) gt 0) then begin
                          if(n_tags(full) eq 0) then begin
                              full0= create_struct(mall[0], $
                                                   'subdir', ' ', $
                                                   'prefix', ' ', $
                                                   'pid', 0L, $
                                                   'ra', 0.D, $
                                                   'dec', 0.D)
                              struct_assign, {junk:0}, full0
                              full= replicate(full0, nd+1L)
                          endif
                          struct_assign, mall[0], full0
                          full0.subdir=subdir
                          full0.prefix=prefix
                          full0.pid=pid
                          full0.ra=lowz[i].ra
                          full0.dec=lowz[i].dec
                          full[i]=full0
                        endif
                    endif
                endif
            endif 
        endif
    endif
endfor

postfix=''
if(keyword_set(hand) gt 0) then $
  postfix=postfix+'.hand'
if(keyword_set(ned) gt 0) then $
  postfix=postfix+'.ned'
outfile=getenv('VAGC_REDUX')+'/lowz/lowz_measure.'+sample+postfix+'.fits' 
mwrfits, full, outfile, /create
    
end
