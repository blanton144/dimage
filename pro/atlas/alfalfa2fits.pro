;+
; NAME:
;   alfalfa2fits
; PURPOSE:
;   Converts ALFALFA catalog to FITS
; CALLING SEQUENCE:
;   alfalfa2fits
; REVISION HISTORY:
;   15-Aug-2010  Fixed for atlas, MRB NYU
;-
;------------------------------------------------------------------------------
pro alfalfa2fits, version=version

infile=atlas_rootdir(version=version)+'/catalogs/alfalfa/alfalfa3.txt'
nlines=numlines(infile)-13L

str0={agc:0L, $
      catnum:' ', $
      other:' ', $
      ra:0.D, $
      dec:0.D, $
      ora:0.D, $
      odec:0.D, $
      cz:0., $
      e_cz:0., $
      w50:0., $
      e_w50:0., $
      fc:0., $
      e_fc:0., $
      sn:0., $
      rms:0., $
      code:0, $
      dis:0., $
      logm:0., $
      grid:' ' }
str=replicate(str0, nlines)

line=''
openr, unit, infile, /get_lun
for i=0L, 12L do readf, unit, line
for i=0L, nlines-1L do begin
    readf, unit, line
    line=' '+line
    str[i].agc=long(strmid(line, 1, 6))
    str[i].catnum=(strmid(line, 7, 8))
    str[i].other=(strmid(line, 15, 10))

    rah=strmid(line, 27, 2)
    ram=strmid(line, 29, 2)
    ras=strmid(line, 31, 4)
    ded=strmid(line, 35, 3)
    dem=strmid(line, 38, 2)
    des=strmid(line, 40, 2)
    string2radec, rah, ram, ras, ded, dem, des, ra, dec
    str[i].ra=ra
    str[i].dec=dec

    rah=strmid(line, 27+17, 2)
    ram=strmid(line, 29+17, 2)
    ras=strmid(line, 31+17, 4)
    ded=strmid(line, 35+17, 3)
    dem=strmid(line, 38+17, 2)
    des=strmid(line, 40+17, 2)
    string2radec, rah, ram, ras, ded, dem, des, ra, dec
    str[i].ora=ra
    str[i].odec=dec

    str[i].cz=float(strmid(line, 59, 7))
    str[i].e_cz=float(strmid(line, 66, 3))
    str[i].w50=float(strmid(line, 69, 5))
    str[i].e_w50=float(strmid(line, 74, 4))
    str[i].fc=float(strmid(line, 78, 7))
    str[i].e_fc=float(strmid(line, 85, 5))
    str[i].sn=float(strmid(line, 90, 7))
    str[i].rms=float(strmid(line, 97, 5))
    str[i].code=(strmid(line, 102, 3))
    str[i].dis=float(strmid(line, 105, 8))
    str[i].logm=float(strmid(line, 113, 7))
    str[i].grid=(strmid(line, 120))

endfor
free_lun, unit

mwrfits, str, atlas_rootdir(version=version)+ $
         '/catalogs/alfalfa/alfalfa3.fits', /create

end
