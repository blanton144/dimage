pro card_images, indx

common com_card_images, nsa

if(n_tags(nsa) eq 0) then $
  nsa= read_nsa(version='v0_1_2')

isort= sort(indx)
iuniq= uniq(indx[isort])
if(n_elements(iuniq) ne n_elements(indx)) then $
  message, 'NOT ALL UNIQUE'

for i=0L, n_elements(indx)-1L do begin
    icard= string(f='(i4.4)', i)
    ii=where(nsa.nsaid eq indx[i], nii)
    atcd, indx[i], version='v0_1_2'
    spawn, /nosh, 'pwd', cwd
    base=(file_basename(cwd))[0]
    cutfile=base+'-'+'irg'+'.cutout.jpg'
    file_copy, cutfile, '~/tmp/cutout-'+icard+'.jpg', /overwrite, /force

    if(nsa[ii].plate eq 0) then $
      message, 'No plate!'

    topdir= getenv('SPECTRO_REDUX')
    pmjd=string(nsa[ii].plate, f='(i4.4)')+'-'+string(nsa[ii].mjd, f='(i5.5)')
    run2d= '26'
    run1d= ''
    fiber=nsa[ii].fiberid
    specdir=topdir+'/images/'+run2d+'/'+run1d+'/'+pmjd
    pmjdf= pmjd+'-'+string(f='(i4.4)', fiber)
    currbase='spec-image-'+pmjdf
    specfile= specdir+'/'+currbase+'.png'
    file_copy, specfile, '~/tmp/spec-'+icard+'.png', /overwrite, /force
endfor

end
