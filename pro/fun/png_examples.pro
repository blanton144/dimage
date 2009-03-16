pro png_examples

rootdir= getenv('GOOGLE_DIR')+'/pngtests'

names=[ 'm87', $
        'm101', $
        'm5', $
        'ism', $
        'lsb-blue', $
        'lsb-red']


ra= [187.7059304 , $
     210.802458, $
     229.640634, $
     244.00000, $
     221.18417, $
     149.26292]

dec= [12.3911231, $
      54.349094, $
      2.082683, $
      23.00000, $
      55.588889, $
      68.591944]

rerun=[137, 161]

for i=0L, n_elements(names)-1L do begin
    currdir= rootdir+'/'+names[i]
    spawn, 'mkdir -p '+currdir
    cd, currdir
    
    smosaic_make, ra[i], dec[i], 0.1, 0.1, $
                  /global, rerun=rerun, /dropweights, /dontcrash, $
                  prefix=names[i], minscore=0.5, /ignoreframesstatus, $
                  /processed
    
endfor
    
end
