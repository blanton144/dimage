;+
; NAME:
;   zcat2fits
; PURPOSE:
;   builds the ZCAT catalog for atlas
; CALLING SEQUENCE:
;   zcat2fits
; COMMENTS:
;   ZCAT documentation at:
;     https://www.cfa.harvard.edu/~huchra/zcat/zcom.htm
;   That document lists the length of the D2MIN column as 
;     5 characters, but it is only 4 (which makes all 
;     subsequent column listings wrong in the docs).
;   The actual file has both \ and % delimiting the INDEX at various 
;     points in the file, and sometimes nothing at all.
;   In addition, the 2008 file has several formatting errors in 
;     several lines:
;       39357 89080 126540 138569 206784 213793 216853 219851 224510
;       230637 403767 451451 475015 477973 487269 567693 574232 591745
;       691047 705112 752695 752909 766943 767076 767375 776654 810650
;       814521 817296 862591
; REVISION HISTORY:
;   18-Nov-2003  Written by Mike Blanton, NYU
;   15-Aug-2010  Fixed for atlas, MRB NYU
;-
;------------------------------------------------------------------------------
pro zcat2fits, version=version

rootdir=atlas_rootdir(sample=sample, version=version)

ngals= numlines(rootdir+'/catalogs/zcat/zcat-velocity.dat')

OPENR, unit, rootdir+'/catalogs/zcat/zcat-velocity.dat', /GET_LUN

zcat1={name:' ', $
       ra:0.D, $
       dec:0.D, $
       bmag:-99., $
       z:-99., $
       z_err:-99., $
       bsource:'-99', $
       vsource:-99, $
       more:-99, $
       ttype:-99, $
       bartype:'-99', $
       lumclass:-99, $
       struct:'-99', $
       d1min:-99., $
       d2min:-99., $
       btmag:-99., $
       dist:-99., $
       rfn:'-99', $
       flag:'-99', $
       comments:' ', $
       index:' '}
zcat=replicate(zcat1,ngals)
line=''
for i=0L, ngals-1L do begin
    if((i mod 2000) eq 0) then splog,i
    readf,unit, line
    if((strsplit(line,/extract))[0] eq 'NUMBER') then begin
        tmp=ngals
        ngals=i
        i=tmp
    endif else begin
        ipos=0 
        len=20 & name=strmid(line,ipos,len) & ipos=ipos+len
        len=2 & rahr=strmid(line,ipos,len) & ipos=ipos+len
        len=2 & ramin=strmid(line,ipos,len) & ipos=ipos+len
        len=5 & rasec=strmid(line,ipos,len) & ipos=ipos+len
        len=3 & decdeg=strmid(line,ipos,len) & ipos=ipos+len
        len=2 & decmin=strmid(line,ipos,len) & ipos=ipos+len
        len=4 & decsec=strmid(line,ipos,len) & ipos=ipos+len
        len=5 & bmag=strmid(line,ipos,len) & ipos=ipos+len
        len=7 & vorz=strmid(line,ipos,len) & ipos=ipos+len
        len=3 & v_err=strmid(line,ipos,len) & ipos=ipos+len
        len=1 & bsource=strmid(line,ipos,len) & ipos=ipos+len
        len=2 & vsource=strmid(line,ipos,len) & ipos=ipos+len
        len=2 & more=strmid(line,ipos,len) & ipos=ipos+len
        len=2 & ttype=strmid(line,ipos,len) & ipos=ipos+len
        len=1 & bartype=strmid(line,ipos,len) & ipos=ipos+len
        len=1 & lumclass=strmid(line,ipos,len) & ipos=ipos+len
        len=1 & struct=strmid(line,ipos,len) & ipos=ipos+len
        len=4 & d1min=strmid(line,ipos,len) & ipos=ipos+len
        len=4 & d2min=strmid(line,ipos,len) & ipos=ipos+len ;; or 5?
        len=6 & btmag=strmid(line,ipos,len) & ipos=ipos+len
        len=6 & ugceso=strmid(line,ipos,len) & ipos=ipos+len
        len=4 & dist=strmid(line,ipos,len) & ipos=ipos+len
        len=1 & space=strmid(line,ipos,len) & ipos=ipos+len
        len=2 & rahr1950=strmid(line,ipos,len) & ipos=ipos+len
        len=2 & ramin1950=strmid(line,ipos,len) & ipos=ipos+len
        len=5 & rasec1950=strmid(line,ipos,len) & ipos=ipos+len
        len=1 & decsign1950=strmid(line,ipos,len) & ipos=ipos+len
        len=2 & decdeg1950=strmid(line,ipos,len) & ipos=ipos+len
        len=2 & decmin1950=strmid(line,ipos,len) & ipos=ipos+len
        len=4 & decsec1950=strmid(line,ipos,len) & ipos=ipos+len
        len=1 & space=strmid(line,ipos,len) & ipos=ipos+len
        len=6 & rfn=strmid(line,ipos,len) & ipos=ipos+len
        len=1 & flag=strmid(line,ipos,len) & ipos=ipos+len
        len=0 & comments_and_index=strmid(line,ipos) 

        words= strsplit(comments_and_index, '[\%]', /extr)
        comments=strtrim(words[0],2)
        if(n_elements(words) gt 1) then begin
           index=strtrim(words[1],2) 
        endif else begin
           words= strsplit(comments_and_index, ' ', /extr)
           comments= strjoin(words[0:n_elements(words)-2], ' ')
           index= words[n_elements(words)-1]
        endelse
        
        string2radec, rahr, ramin, rasec, decdeg, decmin, decsec, ra, dec
        zcat[i].name=name
        zcat[i].ra=ra

        zcat[i].dec=dec
        zcat[i].bmag=float(strtrim(bmag,2))
        if(float(strtrim(vorz,2)) gt 20. OR $
           float(strtrim(vorz,2)) lt -1.) then $
          z=float(strtrim(vorz,2))/2.99792e+5 $
        else $
          z=float(strtrim(vorz,2))
        zcat[i].z=z
        zcat[i].z_err=float(strtrim(v_err,2))/2.99792e+5
        zcat[i].bsource=bsource
        if(strtrim(vsource,2) ne '') then $
          zcat[i].vsource=long(strtrim(vsource,2))
        if(strtrim(more,2) ne '') then $
          zcat[i].more=long(strtrim(more,2))
        if(strtrim(ttype,2) ne '') then $
          zcat[i].ttype=long(strtrim(ttype,2))
        zcat[i].bartype=bartype
        if(strtrim(lumclass,2) ne '') then $
          zcat[i].lumclass=float(strtrim(lumclass,2))
        zcat[i].struct=struct
        if(strtrim(d1min,2) ne '') then $
          zcat[i].d1min=float(strtrim(d1min,2))
        if(strtrim(d2min,2) ne '') then $
          zcat[i].d2min=float(strtrim(d2min,2))
        if(strtrim(btmag,2) ne '') then $
          zcat[i].btmag=float(strtrim(btmag,2))
        if(strtrim(dist,2) ne '') then $
          zcat[i].dist=float(strtrim(dist,2))
        zcat[i].rfn=rfn
        zcat[i].flag=flag
        zcat[i].comments=comments
        zcat[i].index=index

        if(!error_state.code eq -104) then begin
           print,i+1
           stop
           MESSAGE, /RESET_ERROR_STATE 
        endif
        
    endelse

endfor

free_lun, unit

zcat=zcat[0:ngals-1]
mwrfits,zcat,rootdir+'/catalogs/zcat/zcat-velocity.fits',/create

end
