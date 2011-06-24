;+
; NAME:
;   atlas_thumbs
; PURPOSE:
;   Makes thumbnail images for atlas based on sizes
; CALLING SEQUENCE:
;   atlas_thumbs
; COMMENTS:
;   Clips out r50*10-sized images and thumbnails at 3x3 bin
; REVISION HISTORY:
;   15-Aug-2010  MRB, NYU
;-
;------------------------------------------------------------------------------
pro atlas_thumbs, version=version

atlas= read_atlas(/notrim, measure=measure, version=version)
rootdir=atlas_rootdir(version=version)

for i=0L, n_elements(atlas)-1L do begin
   help, i, atlas[i].subdir
   atcd, i, version=version
   iauname=strtrim(atlas[i].iauname,2)

   hdr= headfits(atlas[i].iauname+'-r.fits.gz')
   if(keyword_set(hdr) gt 0 and $
      file_test(iauname+'.jpg') gt 0 and $
      (measure[i].racen ne 0. or measure[i].deccen ne 0.)) then begin

      adxy, hdr, measure[i].racen, measure[i].deccen, xcen, ycen
      
      spawn, /nosh, ['identify',iauname+'.jpg'], outstr
      words= strsplit(outstr, /extr)
      words2= strsplit(words[2], 'x', /extr)
      nx= long(words2[0])
      ny= long(words2[1])
      sz= ((long(measure[i].sersic_r50*9.)>100L)<nx)<ny
      xmin= long(xcen-0.5*sz)
      xmax= long(xcen+0.5*sz)
      ymin= long(float(ny)-ycen-0.5*sz)
      ymax= long(float(ny)-ycen+0.5*sz)
      xsz= xmax-xmin+1L
      ysz= ymax-ymin+1L
      border= sz
      xst= xmin+border
      yst= ymin+border
      
      spawn, /nosh, ['convert', '-bordercolor', 'black', '-border', $
                     strtrim(string(border),2)+'x'+strtrim(string(border),2), $
                     '-crop', strtrim(string(xsz),2)+'x'+strtrim(string(ysz),2)+ $
                     '+'+strtrim(string(xst),2)+'+'+strtrim(string(yst),2), $
                     iauname+'.jpg', iauname+'.cutout.jpg']
      
      nxsz= (xsz/3L)>100L
      nysz= (ysz/3L)>100L
      spawn, /nosh, ['convert', '-resize', strtrim(string(nxsz),2)+'x'+strtrim(string(nysz),2), $
                     iauname+'.cutout.jpg', iauname+'.thumb.jpg']
      
   endif
endfor

   
end
