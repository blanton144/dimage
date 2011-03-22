;+
; NAME:
;   dreadcen
; PURPOSE:
;   read central image
; REVISION HISTORY:
;   31-July-2008
;-
;------------------------------------------------------------------------------
pro dreadcen, image, invvar, psf=psf, band=band, measure=measure, $
              hand=hand, acat=acat

if(NOT keyword_set(band)) then band=2
if(NOT keyword_set(subdir)) then subdir='.'
bandnames=['u', 'g', 'r', 'i', 'z']

spawn, /nosh, 'pwd', cwd
words=strsplit(cwd[0], '/',/extr)
prefix=words[n_elements(words)-1]

iau_to_radec, prefix, ra, dec

pim= gz_mrdfits(subdir+'/'+prefix+'-pimage.fits', /silent)
if(keyword_set(pim)) then begin
    nx=(size(pim,/dim))[0]
    ny=(size(pim,/dim))[1]
    pid=pim[nx/2L, ny/2L]
    pstr=strtrim(string(pid),2)

    if(arg_present(psf)) then begin
        psffile= prefix+'-'+bandnames[band]+'-vpsf.fits'
        if(file_test(psffile)) then $
          psf= dvpsf(float(nx/2L), float(ny/2L), psfsrc=psffile)
    endif
    
    sub='atlases'
    postfix=''
    if(gz_file_test('hand/'+pstr) gt 0 AND $
       keyword_set(hand) gt 0) then begin
        sub='hand'
        postfix='-hand'
    endif
    
    acat=gz_mrdfits(subdir+'/'+sub+'/'+pstr+'/'+prefix+ $
                    '-acat-'+pstr+'.fits',1, /silent)
    nkeep=0
    
    if(n_tags(acat) gt 0) then $
      ikeep=where(acat.good gt 0 and acat.type eq 0, nkeep)
    
    if(tag_exist(acat, 'RACEN') gt 0 AND $
       nkeep gt 0) then begin
        acat=acat[ikeep]
        spherematch, ra, dec, acat.racen, acat.deccen, 1., m1, m2
        if (m1[0] eq -1) then begin
            splog, 'no match?'
            return
        endif
        aid=acat[m2].aid
        astr=strtrim(string(aid),2)
        
        if(arg_present(image)) then $
          image=gz_mrdfits(subdir+'/'+sub+'/'+pstr+'/'+prefix+'-'+ $
                           pstr+'-atlas-'+astr+'.fits', band, hdr, /silent)
        if(arg_present(invvar)) then begin
            invvar=gz_mrdfits(subdir+'/parents/'+prefix+'-parent-'+ $
                              pstr+'.fits', band*2L+1L, hdr, /silent)
            invvar=invvar>0.
        endif

        if(arg_present(measure)) then begin
            measure=gz_mrdfits(subdir+'/'+sub+'/'+pstr+'/'+prefix+'-'+ $
                               pstr+'-measure'+postfix+'.fits',1, /silent)
        endif
    endif
endif

    
end
