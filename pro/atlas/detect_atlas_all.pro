;+
; NAME:
;   detect_atlas_all
; PURPOSE:
;   run detect_atlas on everything
; CALLING SEQUENCE:
;   detect_atlas_all [, infile= ]
; REVISION HISTORY:
;   3-Aug-2004  MRB, NYU
;-
;------------------------------------------------------------------------------
pro detect_atlas_all, infile=infile, st=st, nd=nd, $
                      noclobber=noclobber, notrim=notrim, $
                      nodetect=nodetect, version=version, $
                      nojpeg=nojpeg, recoverfile=recoverfile

rootdir=atlas_rootdir(version=version, cdir=cdir, subname=subname)
info= atlas_version_info(version)

imagetypes= strsplit(info.imagetypes,/extr)
for i=0L, n_elements(imagetypes)-1L do begin
    case imagetypes[i] of
        'SDSS': sdss=1
        'GALEX': galex=1
        '2MASS': twomass=1
        'WISE': wise=1
        else: message, 'No such imagetype '+imagetypes[i]
    endcase
endfor

if(NOT keyword_set(infile)) then $
  infile=cdir+'/atlas.fits'

atlas= gz_mrdfits(infile, 1)

if(keyword_set(recoverfile)) then $
  recoverlist= mrdfits(recoverfile, 1)

if(NOT keyword_set(st)) then st=0L
if(NOT keyword_set(nd)) then nd=n_elements(atlas)-1L
nd= nd < (n_elements(atlas)-1)
for i=st, nd do begin
    
    help, i

    if(keyword_set(recoverfile)) then begin
        irecover=where(recoverlist.nsaid eq i, nrecover) 
        if(nrecover gt 0) then begin
            if(recoverlist[irecover[0]].why eq 3) then $
              atlas_dimages, st=i, nd=i
            atlas_detect_dirs, st=i, nd=i, version=version
        endif
    endif else begin
        nrecover=1
    endelse
    if(nrecover eq 0) then continue

    subdir=image_subdir(atlas[i].ra, atlas[i].dec, $
                        prefix=prefix, rootdir=rootdir, $
                        subname=subname)
    
    cd, subdir
    finfo= file_info('.')
    if(finfo.write eq 0) then begin
       splog, 'Directory not writable, skipping!'
       continue
    endif
    
    imfiles=prefix+'-'+['u', 'g', 'r', 'i', 'z']+'.fits.gz'
    if (keyword_set(galex) gt 0) then begin
        imfiles=[imfiles, prefix+'-'+['nd', 'fd']+'.fits.gz']
    endif 
    if (keyword_set(twomass) gt 0) then begin
        imfiles=[imfiles, prefix+'-'+['J', 'H', 'K']+'.fits.gz']
    endif 
    if (keyword_set(wise) gt 0) then begin
        imfiles=[imfiles, prefix+'-'+['w1', 'w2', 'w3', 'w4']+'.fits.gz']
    endif 
    allthere=1
    for j=0L, n_elements(imfiles)-1L do $
      if(file_test(imfiles[j]) eq 0) then $
      allthere=0
    
    print, imfiles
    print, allthere
    if(allthere gt 0) then begin
        if(NOT keyword_set(nodetect)) then begin
            detect_atlas, galex=galex, twomass=twomass, wise=wise, $
              noclobber=noclobber
        endif
        dmeasure_atlas, noclobber=noclobber
        if(NOT keyword_set(nojpeg)) then $
          atlas_jpeg, noclobber=noclobber, galex=galex, twomass=twomass, $
          wise=wise
        spawn, /nosh, ['find', '.', '-name', '*.fits', '-exec', 'gzip', '-vf', '{}', ';']
        
        if(NOT keyword_set(notrim)) then $
          dtrim_atlas
    endif
    heap_gc
    help,/mem
endfor
 
end
