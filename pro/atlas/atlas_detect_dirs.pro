;+
; NAME:
;   atlas_detect_dirs
; PURPOSE:
;   create atlas detection directories
; CALLING SEQUENCE:
;   atlas_detect_dirs [, /sample, /sdss ]
; REVISION HISTORY:
;   3-Aug-2004  MRB, NYU
;-
;------------------------------------------------------------------------------
pro atlas_detect_dirs, sample=sample, sdss=sdss, justjpg=justjpg

if(keyword_set(sdss)) then begin
    galex=0
    twomass=0
    sdss=1
    jpg=1
    subname='detect-sdss'
endif else if(keyword_set(justjpg)) then begin
    galex=0
    twomass=0
    sdss=0
    jpg=1
    subname='detect-sdss'
endif else begin
    galex=1
    twomass=1
    sdss=1
    jpg=1
    subname='detect'
endelse

rootdir='/mount/hercules5/sdss/atlas/v0'
if(NOT keyword_set(infile)) then $
  infile=getenv('DIMAGE_DIR')+'/data/atlas/atlas.fits'
if(keyword_set(sample)) then begin
    infile= getenv('DIMAGE_DIR')+'/data/atlas/atlas_sample.fits'
    rootdir= '/mount/hercules5/sdss/atlas/sample'
endif

atlas= gz_mrdfits(infile, 1)

for i=0L, n_elements(atlas)-1L do begin
    if((i mod 1000) eq 0) then $
      splog, i
    subdir=image_subdir(atlas[i].ra, atlas[i].dec, $
                        prefix=prefix, rootdir=rootdir, $
                        subname=subname)
    
    file_mkdir, subdir
    cd, subdir

    sdsssub= 'sdss'
    sdssdir=image_subdir(atlas[i].ra, atlas[i].dec, $
                         prefix=prefix, rootdir='../../../..', $
                         subname=sdsssub)

    if(keyword_set(jpg)) then begin
        jpgfile=prefix+'.jpg'
        if(file_test(sdssdir+'/'+jpgfile)) then begin
            file_delete, subdir+'/'+jpgfile, /allow
            file_link, sdssdir+'/'+jpgfile, subdir+'/'+jpgfile
        endif
    endif
    
    if(keyword_set(sdss)) then begin
        imfiles=prefix+'-'+['u', 'g', 'r', 'i', 'z']+'.fits.gz'
        for iband=0L, n_elements(imfiles)-1L do begin
            if(file_test(sdssdir+'/'+imfiles[iband])) then begin
                file_delete, subdir+'/'+imfiles[iband], /allow
                file_link, sdssdir+'/'+imfiles[iband], subdir+'/'+imfiles[iband]
            endif
        endfor
    endif

    if(keyword_set(galex)) then begin
        galexsub= 'galex'
        galexdir=image_subdir(atlas[i].ra, atlas[i].dec, $
                              prefix=prefix, rootdir='../../../..', $
                              subname=galexsub)
        imfiles=prefix+'-'+['nd', 'fd']+'.fits.gz'
        for iband=0L, n_elements(imfiles)-1L do begin
            if(file_test(galexdir+'/'+imfiles[iband])) then begin
                file_delete, subdir+'/'+imfiles[iband], /allow
                file_link, galexdir+'/'+imfiles[iband], '.'
            endif
        endfor
    endif

    if(keyword_set(twomass)) then begin
        twomasssub= '2mass'
        twomassdir=image_subdir(atlas[i].ra, atlas[i].dec, $
                                prefix=prefix, rootdir='../../../..', $
                                subname=twomasssub)
        imfiles=prefix+'-'+['J', 'H', 'K']+'.fits.gz'
        for iband=0L, n_elements(imfiles)-1L do begin
            if(file_test(twomassdir+'/'+imfiles[iband])) then begin
                file_delete, subdir+'/'+imfiles[iband], /allow
                file_link, twomassdir+'/'+imfiles[iband], '.'
            endif
        endfor
    endif
    
endfor
 
end
