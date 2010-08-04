;+
; NAME:
;   reorg_fakes
; PURPOSE:
;   Reorganize Eyal's fake data mosaics
; CALLING SEQUENCE:
;   reorg_fakes, indir, name
; COMMENTS:
;   Takes smosaics from indir and reorganizes into directory under:
;      /global/data/scr/mb144/skyfake/[name]
; REVISION HISTORY:
;   2-Aug-2010 MRB, NYU
;-
pro reorg_fakes, indir, name

files= file_search(indir+'/smosaic_stamp*fake-?.fits.gz')

outdir= '/global/data/scr/mb144/skyfake'
file_mkdir, outdir+'/'+name
for i=0L, n_elements(files)-1L do begin
    num= (stregex(files[i], '.*smosaic_stamp(.*)fake-(.)\.fits\.gz', $
                  /sub, /extr))[1]
    band= (stregex(files[i], '.*smosaic_stamp(.*)fake-(.)\.fits\.gz', $
                  /sub, /extr))[2]
    file_mkdir, outdir+'/'+name+'/'+name+'-'+num
    infile=files[i] 
    outfile=outdir+'/'+name+'/'+name+'-'+num+'/'+ $
      name+'-'+num+'-'+band+'.fits'
    im= mrdfits(infile, 0, hdr)
    ivar= im*0.+1./dsigma(im,sp=4)^2
    mwrfits, im, outfile, hdr,/create
    mwrfits, ivar, outfile
    spawn, /nosh, ['gzip', '-vf', outfile]
    
endfor


end

