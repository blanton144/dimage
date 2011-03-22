;; simple SDSS-only version of child
pro example_atlas_child, name

atcd, name=name, /sample
spawn, /nosh, 'pwd', cwd
base=(file_basename(cwd))[0]

dreadcen, measure=measure, acat=acat

pbase=base+'-parent-'+strtrim(string(acat[0].pid),2)
jpgfile= 'atlases'+'/'+strtrim(string(acat[0].pid),2)+ '/'+pbase+'-irg.jpg'

file_mkdir, '~/tmp/examples/'+base
file_copy, jpgfile, '~/tmp/examples/'+base, /over

abase= 'atlases'+'/'+ strtrim(string(acat[0].pid),2)+ $
       '/'+base+'-'+strtrim(string(acat[0].pid),2)+ $
       '-atlas-'+strtrim(string(measure.aid),2)
jpgfile=abase+'-irg.jpg'

file_mkdir, '~/tmp/examples/'+base
file_copy, jpgfile, '~/tmp/examples/'+base, /over

end
