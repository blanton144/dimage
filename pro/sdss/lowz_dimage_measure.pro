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
                         check=check, gather=gather, ref=ref

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

nband=5


if(NOT keyword_set(nd)) then nd=n_elements(lowz)-1L
for istep=start, nd do begin
    splog, istep
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
            
            mfile=subdir+'/'+sub+'/'+pstr+'/'+prefix+'-'+pstr+'-measure.fits'
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

                    if(keyword_set(noclobber) eq 0 OR $
                       gz_file_test(mfile) eq 0) then begin
                        
                        adxy, hdr, acat[m2].racen, acat[m2].deccen, xcen, ycen
                        
                        dmeasure, rimage, rinvvar, xcen=xcen, ycen=ycen, $
                          measure=measure
                        
                        help,/st,measure
                        
                        mall= create_struct(measure, 'aid', aid)
                        
                        mwrfits, mall, mfile, /create
                        spawn, 'gzip -vf '+mfile
                    endif

                    if(keyword_set(check)) then begin
                        mall= gz_mrdfits(mfile,1)
                        dmeasure_check, rimage, rinvvar, measure=mall
                    endif

                    if(keyword_set(gather)) then begin
                        mall= gz_mrdfits(mfile,1)
                        if(n_tags(full) eq 0) then begin
                            full0= create_struct(mall[0], $
                                                 'subdir', ' ', $
                                                 'prefix', ' ', $
                                                 'pid', 0L, $
                                                 'ra', 0.D, $
                                                 'dec', 0.D)
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
endfor

bands=['u', 'g', 'r', 'i', 'z']

outfile=getenv('VAGC_REDUX')+'/lowz/lowz_measure_'+bands[ref]+'.'+sample+'.fits' 
mwrfits, full, outfile, /create
    
end
