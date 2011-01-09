;+
; NAME:
;   gather_fake_measure
; PURPOSE:
;   gather measurements of fakes
; CALLING SEQUENCE:
;   gather_fake_measure, name
; REVISION HISTORY:
;   2-Aug-2010 MRB, NYU
;-
pro gather_fake_measure, name

dirs= file_search('/global/data/scr/mb144/skyfake/'+name+'/'+name+'-*', $
                  /test_dir)
;;dirs=dirs[0:175]

for i=0L, n_elements(dirs)-1L do begin
    subdir= dirs[i]
    prefix= file_basename(subdir)
    num= (stregex(prefix, name+'-(.*)', /sub, /extr))[1]

    phdr= gz_headfits(subdir+'/'+prefix+'-r.fits')
    pim= gz_mrdfits(subdir+'/'+prefix+'-pimage.fits',0)
    if(keyword_set(pim)) then begin
        nx=(size(pim,/dim))[0]
        ny=(size(pim,/dim))[1]
        xyad, phdr, float(nx/2L), float(ny/2L), racen, deccen
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
        tmp_measure=gz_mrdfits(mfile,1)
        
        if(n_tags(tmp_measure) gt 0) then begin
            tmp_measure= struct_addtags(tmp_measure, {num:long(num)})
            
            acat=gz_mrdfits(subdir+'/'+sub+'/'+pstr+'/'+prefix+'-acat-'+$
                            pstr+'.fits',1)
            nkeep=0
            
            if(n_tags(acat) gt 0) then $
              ikeep=where(acat.good gt 0 and acat.type eq 0, nkeep)
            
            if(tag_exist(acat, 'RACEN') gt 0 AND $
               nkeep gt 0) then begin
                acat=acat[ikeep]
                spherematch, racen, deccen, acat.racen, $
                  acat.deccen, 3., m1, m2
                if (m1[0] eq -1) then $
                  message, 'no match?'
                aid=acat[m2].aid
                
                icen= where(aid eq tmp_measure.aid, ncen)
                if(ncen eq 0) then $
                  message, 'no measurement?'
                
                if(n_tags(measure) eq 0) then $
                  measure= tmp_measure $
                else $
                  measure= [measure, tmp_measure]
            endif
        endif
    endif
endfor

mwrfits, measure, '/global/data/scr/mb144/skyfake/'+name+'/'+name+'-'+ $
  'measure.fits', /create

end
