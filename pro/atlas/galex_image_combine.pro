;+
; NAME:
;   galex_image_combine
; PURPOSE:
;   For each atlas object, combine GALEX images
; CALLING SEQUENCE:
;   galex_image_combine [, version=, st=, nd=]
; OPTIONAL INPUTS:
;   version - version of atlas
;   st - Starting NSAID to process
;   nd - Ending NSAID to process
; REVISION HISTORY:
;   23-Apr-2010  MRB, NYU
;-
;------------------------------------------------------------------------------
pro galex_image_combine, version=version, st=st, nd=nd

rootdir=atlas_rootdir(version=version)

atlas= mrdfits(rootdir+'/catalogs/atlas.fits',1)

bands= ['fd', 'nd']
zp= [18.82, 20.08]

if(n_elements(st) eq 0) then $
  st=0L
if(n_elements(nd) eq 0) then $
  nd=n_elements(atlas)-1L 
for i=st, nd do begin
    splog, i
    
    indir= rootdir+'/detect/galex-ds/'+strmid(strtrim(atlas[i].subdir,2), 0, 2)
    outdir= rootdir+'/detect/galex/'+strtrim(atlas[i].subdir,2)
    file_mkdir, outdir
    print, outdir
    
    for j= 0L, n_elements(bands)-1L do begin
        files= file_search(indir+'/atlas_full_gr7_'+atlas[i].iauname+'*-'+ $
                           bands[j]+'-glxstamp.fits')
        if(keyword_set(files) gt 0) then begin
            hdrs= ptrarr(n_elements(files))
            ims= ptrarr(n_elements(files))
            skies= ptrarr(n_elements(files))
            rrhrs= ptrarr(n_elements(files))
            expt= fltarr(n_elements(files))

            for k=0L, n_elements(files)-1L do begin
                hdrs[k]= ptr_new(gz_headfits(files[k]))
                ims[k]= ptr_new(gz_mrdfits(files[k],0))
                skies[k]= ptr_new(gz_mrdfits(files[k],1))
                rrhrs[k]= ptr_new(gz_mrdfits(files[k],2))
                expt[k]= float(sxpar(*hdrs[k], 'EXPTIME'))
            endfor
            isort= reverse(sort(expt))
            hdrfinal= *hdrs[isort[0]]
            
            nx_orig= (size(*ims[0], /dim))[0]
            ny_orig= (size(*ims[0], /dim))[1]
            nx= long(atlas[i].size/(1.5/3600.))
            ny= nx
            
            cfinal= fltarr(nx, ny)
            rfinal= fltarr(nx, ny)
            imfinal= fltarr(nx, ny)
            ivar= fltarr(nx, ny)
            
            ist_orig= ((nx_orig-nx)/2L)>0L
            ind_orig= (((nx_orig-nx)/2L)+(nx-1L))<(nx_orig-1L)
            jst_orig= ((ny_orig-ny)/2L)>0L
            jnd_orig= (((ny_orig-ny)/2L)+(ny-1L))<(ny_orig-1L)
            
            ist= ((nx-nx_orig)/2L)>0L
            ind= (((nx-nx_orig)/2L)+(nx_orig-1L))<(nx-1L)
            jst= ((ny-ny_orig)/2L)>0L
            jnd= (((ny-ny_orig)/2L)+(ny_orig-1L))<(ny-1L)

            for k=0L, n_elements(ims)-1L do begin
                imfinal[ist:ind, jst:jnd]+= $
                  (*ims[isort[k]])[ist_orig:ind_orig, jst_orig:jnd_orig]* $
                  ((*rrhrs[isort[k]])[ist_orig:ind_orig, jst_orig:jnd_orig]>0.)
                rfinal[ist:ind, jst:jnd]+= $
                  ((*rrhrs[isort[k]])[ist_orig:ind_orig, jst_orig:jnd_orig]>0.)
                cfinal[ist:ind, jst:jnd]+= $
                  ((*ims[isort[k]])[ist_orig:ind_orig, jst_orig:jnd_orig]+ $
                   (*skies[isort[k]])[ist_orig:ind_orig, jst_orig:jnd_orig])* $
                  (*rrhrs[isort[k]])[ist_orig:ind_orig, jst_orig:jnd_orig]
                
                sxaddpar, hdrfinal, 'IM'+string(f='(i4.4)', k), file_basename(files[k])
            endfor
            imfinal= imfinal/ (rfinal+float(rfinal le 0))
            ivar= rfinal^2/((cfinal>1.)+float(rfinal le 0.))

            imfinal= imfinal*10.^(0.4*(22.5-zp[j]))
            ivar= ivar*10.^(-0.8*(22.5-zp[j]))
            
            sxaddpar, hdrfinal, 'EXPTIME', total(expt)
            crpix1= sxpar(hdrfinal, 'CRPIX1')
            crpix1= crpix1-ist_orig+ist
            sxaddpar, hdrfinal, 'CRPIX1', crpix1
            crpix2= sxpar(hdrfinal, 'CRPIX2')
            crpix2= crpix2-jst_orig+jst
            sxaddpar, hdrfinal, 'CRPIX2', crpix2

            outfile=outdir+'/'+strtrim(atlas[i].iauname,2)+'-'+bands[j]+'.fits'
            mwrfits, imfinal, outfile, hdrfinal, /create
            mwrfits, ivar, outfile
            mwrfits, cfinal, outfile
            mwrfits, rfinal, outfile
            spawn, /nosh, ['gzip', '-vf', outfile]

            heap_free, hdrs
            heap_free, ims
            heap_free, skies
            heap_free, rrhrs
        endif
    endfor
    
endfor

end
