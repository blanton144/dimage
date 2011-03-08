pro westdr2tofits

ngals= numlines('west-dr2.csv')-1L

openr, unit, 'west-dr2.csv', /get_lun

line=' '
readf,unit, line

obj0={objid:' ', $
      ra:0.D, $
      dec:0.D, $
      type:' ', $
      umag:0., $
      gmag:0., $
      rmag:0., $
      imag:0., $
      zmag:0., $
      r50:0., $
      r90:0.}

obj=replicate(obj0, ngals)

for i=0L, ngals-1 do begin
    readf,unit,line
    words=strsplit(line, ',', /extr)
    obj[i].objid= words[0]
    obj[i].ra= double(words[1])
    obj[i].dec= double(words[2])
    obj[i].type= words[3]
    obj[i].umag= float(words[4])
    obj[i].gmag= float(words[5])
    obj[i].rmag= float(words[6])
    obj[i].imag= float(words[7])
    obj[i].zmag= float(words[8])
    obj[i].r50= float(words[9])
    obj[i].r90= float(words[10])
endfor

free_lun, unit

mwrfits, obj, 'west-dr2.fits', /create

end
