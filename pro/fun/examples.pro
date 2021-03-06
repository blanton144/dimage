pro examples, clobber=clobber

names=[     'm101',   'ugc3974', 'ngc4656',        'm5', $
            'coma',    'merger']
ras=  [210.802458D,  115.48083D, 190.99053D, 229.640634D, $
        194.9531D,   209.658D]     
decs=[  54.349094D,  16.802500D, 32.168150D,   2.082683D, $
        27.9807D,     37.4245D ]
sizes= [      0.35,         0.2,    0.4,             0.3, $
              0.3,         0.3]
for i=0L, n_elements(names)-1L do begin
    name=names[i]
    ra=ras[i]
    dec=decs[i]
    size=sizes[i]

    outdir= getenv('DIMAGE_DIR')+'/data/examples/'+name
    spawn, 'mkdir -p '+outdir
    cd, outdir
    if(file_test(name+'-z.fits.gz') eq 0 OR $
       keyword_set(clobber) gt 0) then $
      smosaic_make, ra, dec, size, size, rerun=301, /global, $
      /dropweights, prefix=name, /ignoreframesstatus, $
      minscore=0.5, /processed
    simple_jpg, name= name+'.full.jpg'
    simple_jpg, rebin=5
endfor
    
end
