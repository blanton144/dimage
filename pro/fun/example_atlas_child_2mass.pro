;; show 2MASS images too
pro example_atlas_child_2mass, name

atcd, name=name, /sample

atlas_jpeg, /twomass, /galex

spawn, /nosh, 'pwd', cwd
base=(file_basename(cwd))[0]

dreadcen, measure=measure, acat=acat

posts= ['irg', 'Krg', 'rgn']

for i=0L, n_elements(posts)-1L do begin
    post=posts[i]

    pbase=base+'-parent-'+strtrim(string(acat[0].pid),2)
    jpgfile= 'atlases'+'/'+strtrim(string(acat[0].pid),2)+ '/'+pbase+'-'+post+'.jpg'

    file_mkdir, '~/tmp/examples/'+base+'-extra'
    file_copy, jpgfile, '~/tmp/examples/'+base+'-extra', /over
    
    abase= 'atlases'+'/'+ strtrim(string(acat[0].pid),2)+ $
      '/'+base+'-'+strtrim(string(acat[0].pid),2)+ $
      '-atlas-'+strtrim(string(measure.aid),2)
    jpgfile=abase+'-'+post+'.jpg'
    
    file_mkdir, '~/tmp/examples/'+base+'-extra'
    file_copy, jpgfile, '~/tmp/examples/'+base+'-extra', /over
endfor
    
end
