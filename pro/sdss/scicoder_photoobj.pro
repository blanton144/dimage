;+
; NAME:
;   scicoder_photoobj
; PURPOSE:
;   Create photoObj and photoField files for SciCoder
; CALLING SEQUENCE:
;   scicoder_photoobj
; REVISION HISTORY:
;   26-Apr-2009  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro scicoder_photoobj, clobber=clobber

rootdir='/global/data/scicoder/photoobj'

spawn, 'mkdir -p '+rootdir

;; get list of runs
rundirs= file_search('/global/data/sdss/redux/40/*')
runs= lonarr(n_elements(rundirs))
for i=0L, n_elements(rundirs)-1L do begin
    words=strsplit(rundirs[i], '/', /extr)
    runs[i]= long(words[n_elements(words)-1])
endfor
ii=where(runs ne 3565 AND $
         runs ne 5637 AND $ ;; missing fils
         runs ne 5670 AND $ ;; missing fils
         runs ne 5847 AND $  ;; id==-1??? in 4-603
         runs ne 5882 AND $  ;; no calibs camcol 1
         runs ne 5889 AND $  ;; no calibs camcol 1
         runs ne 5895 AND $  ;; no calibs camcol 1
         runs ne 5909 AND $  ;; missing fields camcol 3
         runs ne 6408 AND $  ;; missing calibs camcol 6
         runs ne 6508 AND $  ;; weird failure
         runs ne 6924 AND $
         runs ne 6925 AND $
         runs ne 6930 AND $
         runs ne 7043 AND $
         runs ne 7045 AND $
         runs ne 7202 AND $
         runs ne 6952)
runs=runs[ii]
runs=runs[sort(runs)]

help,runs

for i=0L, n_elements(runs)-1L do begin
    help,runs[i]
    fields= file_search(sdss_path('fpObjc', runs[i], 1L, rerun=40)+ $
                        '/fpObjc*.fit*')
    for camcol=1L, 6L do begin 
        outrundir= rootdir+'/'+strtrim(string(runs[i]),2)
        outfieldfile= outrundir+'/photoField-'+ $
          string(f='(i6.6)', runs[i])+'-'+ $
          string(f='(i1.1)', camcol)+'.fits'
        if(file_test(outfieldfile) eq 0 OR $
           keyword_set(clobber) gt 0) then begin
            outdir= outrundir+'/'+ strtrim(string(camcol),2)
            spawn, 'mkdir -p '+outdir
            photofield=0
            for ifield=0L, n_elements(fields)-1L do begin
                str= stregex(fields[ifield], $
                             '.*\-([0-9][0-9][0-9][0-9])\.fit.*', $
                             /sub, /extr)
                field= long(str[1])
                post=string(f='(i6.6)', runs[i])+'-'+ $
                  string(f='(i1.1)', camcol)+'-'+ $
                  string(f='(i4.4)', field)+'.fits'

                pfield= photofield_create(runs[i], camcol, field, $
                                          rerun=40L, /noflist, $
                                          /nofieldstat)

                outobjfile= outdir+'/photoObj-'+post
                if(file_test(outobjfile) eq 0 OR $
                   keyword_set(clobber) gt 0) then begin
                    
                    obj= sdss_readobj(runs[i], camcol, field, rerun=40L, $
                                      except=['texture'])
                    photoobj= photoobj_table(obj, /unsafenan)
                    mwrfits, photoobj, outobjfile, /create
                    if(n_tags(photofield) eq 0) then $
                      photofield=pfield $
                    else $
                      photofield=[pfield, photofield]
                endif
            endfor
            mwrfits, photofield, outfieldfile, /create
        endif
    endfor
endfor


end
