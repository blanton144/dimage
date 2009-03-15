pro run_montage_qa

cd, getenv('GOOGLE_DIR')+'/montage-qas'

paths= file_search('../montage/*/*/*')
prefixs= strmid(paths, 19) 

bands=['u', 'g', 'r', 'i', 'z']
for i=0L, n_elements(paths)-1L do begin
  goahead= 1
   for ib=0L, 4L do $
     goahead= goahead AND (file_test(paths[i]+'/'+prefixs[i]+'-'+bands[ib]+'.fits.gz') gt 0)
   print, goahead
   if(goahead) then begin
    smosaic_qa, prefixs[i], path=paths[i], /local
    smosaic_qa, prefixs[i], path=paths[i]
   endif
endfor

files= file_search('J??????????????????-local-qa.fits')
all=0
for i=0L, n_elements(files)-1L do begin
  tmp= mrdfits(files[i],1)
  if(n_tags(tmp) gt 0) then begin
    if(n_tags(all) gt 0) then $
      all= [all, tmp] $
    else $
      all= tmp
  endif
endfor

mwrfits, all, 'montage-local-qa.fits', /create

files= file_search('J??????????????????-qa.fits')
all=0
for i=0L, n_elements(files)-1L do begin
  tmp= mrdfits(files[i],1)
  if(n_tags(tmp) gt 0) then begin
    if(n_tags(all) gt 0) then $
      all= [all, tmp] $
    else $
      all= tmp
  endif
endfor

mwrfits, all, 'montage-qa.fits', /create

smosaic_qastats, 'montage'
smosaic_qastats, 'montage-local'

spawn, 'cp *diff*.ps '+getenv('DIMAGE_DIR')+'/tex'

end
