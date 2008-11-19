;+
; NAME:
;   lowz_dlinks
; PURPOSE:
;   go to each lowz, make an image, and analyze it
; CALLING SEQUENCE:
;   lowz_dimage [, sample=]
; REVISION HISTORY:
;   3-Aug-2004  MRB, NYU
;-
;------------------------------------------------------------------------------
pro lowz_dlinks, sample=sample, redetect=redetect, start=start, nd=nd, $
                 lrootdir=lrootdir

common com_lowz_dlinks, lowz

noclobber=keyword_set(clobber) eq 0

if(NOT keyword_set(sample)) then sample='dr6'
if(NOT keyword_set(start)) then start=0L

if(n_tags(lowz) eq 0) then $
  lowz=gz_mrdfits(getenv('VAGC_REDUX')+'/lowz/lowz_plus_ned.fits', 1)

lowzdir=getenv('VAGC_REDUX')+'/lowz/'
rootdir=getenv('DATA')+'/lowz-sdss'
if(NOT keyword_set(lrootdir)) then $
  lrootdir=rootdir

if(NOT keyword_set(nd)) then nd=n_elements(lowz)-1L

spawn, 'ln -sf '+getenv('VAGC_REDUX')+'/lowz/lowz_plus_ned.fits'+ $
  ' '+rootdir+'/dlinks/lowz.fits'

for i=start, nd do begin
    splog, i
    if(lowz[i].icomb ge 0) then begin

        dsubdir=image_subdir(lowz[i].ra, lowz[i].dec, $
                             prefix=prefix, rootdir=rootdir, $
                             subname='dimages')
        lsubdir=image_subdir(lowz[i].ra, lowz[i].dec, $
                             prefix=prefix, rootdir=lrootdir, $
                             subname='dlinks')
        spawn, 'mkdir -p '+lsubdir

        pim= gz_mrdfits(dsubdir+'/'+prefix+'-pimage.fits')
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
            
            acat=gz_mrdfits(dsubdir+'/'+sub+'/'+pstr+'/'+prefix+'-'+pstr+ $
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
                
                jpbase=prefix+'.jpg'
                pabase=prefix+'-parent-'+pstr+'.fits'
                atbase=prefix+'-'+pstr+'-atlas-'+astr+'.fits'

                ljpbase=prefix+'.jpg'
                lpabase=prefix+'-parent-fits'
                latbase=prefix+'-child-fits'

                jpfile=dsubdir+'/'+jpbase
                pafile=dsubdir+'/parents/'+pabase
                atfile=dsubdir+'/'+sub+'/'+pstr+'/'+atbase

                jplink=lsubdir+'/'+jpbase
                palink=lsubdir+'/'+lpabase
                atlink=lsubdir+'/'+latbase
                
                jpz=0
                if(NOT file_test(jpfile)) then begin
                    jpfile=jpfile+'.gz'
                    jplink=jplink+'.gz'
                    jpz=1
                endif
                if(NOT file_test(pafile)) then begin
                    pafile=pafile+'.gz'
                    palink=palink+'.gz'
                endif
                if(NOT file_test(atfile)) then begin
                    atfile=atfile+'.gz'
                    atlink=atlink+'.gz'
                endif

                spawn, 'ln -sf '+jpfile+' '+jplink
                if(jpz) then $
                  spawn, 'gzip -df '+jplink
                spawn, 'ln -sf '+pafile+' '+palink
                spawn, 'ln -sf '+atfile+' '+atlink
                
            endif
        endif
    endif
endfor

end
