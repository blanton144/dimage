pro test_sdss_gal_field

runs=[4388]
basedir='/global/metal2/sdss-gal-field'

for i=0L, n_elements(runs)-1L do begin
    runinfo= sdss_runlist(runs[i], rerun=9137)
    for camcol=1L, 6L do begin
        for field= runinfo.startfield, runinfo.endfield do begin
            outdir=basedir+'/'+strtrim(string(runinfo.rerun),2)+'/'+ $
              strtrim(string(runs[i]),2)+'/'+ $
              strtrim(string(camcol),2)+'/'+ $
              strtrim(string(field),2)
            spawn, 'mkdir -p '+outdir
            sdss_gal_field, runs[i], camcol, field, rerun=runinfo.rerun, $
              outdir=outdir, base=base, /nocl
            cd, outdir
            detect_sdss_gal, base, /all
        endfor
    endfor
endfor

end
