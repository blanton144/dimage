;+
; NAME:
;   biggal_measure
; PURPOSE:
;   Measure FITS images of a number of big galaxies from NED
; CALLING SEQUENCE:
;   biggal_measure 
; COMMENTS:
;   Finds galaxies with both:
;     $GOOGLE_DIR/biggals/montage/[name]/[name]-[ugriz].fits.gz
;     $GOOGLE_DIR/biggals/dimage/[name]/[name]-[ugriz].fits.gz
;   and measures them in apertures.
; REVISION HISTORY:
;   25-Oct-2007 MRB, NYU
;-
pro biggal_measure

common com_biggal_measure, lowz

if(n_tags(lowz) eq 0) then begin
    lowz= mrdfits(getenv('DATA')+'/lowz-sdss/lowz_plus_ned.dr6.fits',1)
   ;; glactc, lowz.ra, lowz.dec, 2000., gl, gb, 1, /deg
    ;;ikeep= where(lowz.ned gt 0 and lowz.icomb ge 0 and gb gt 20. and $
    ;;             (lowz.petroflux[2] gt 1000. OR lowz.ned_mag lt 15.))
    ;;lowz=lowz[ikeep]
endif
nlowz= n_elements(lowz)

files= file_search(getenv('GOOGLE_DIR')+'/biggals/dimage/*/*-r.fits.gz')

radius=200.

outstr0= {filename:' ', $
          radius:fltarr(5), $
          mflux:fltarr(5), $
          dflux:fltarr(5)}

outstr= replicate(outstr0, n_elements(files))

for i=0L, n_elements(files)-1L do begin
    words= strsplit(files[i], '/', /extr,/preserve_null)
    idim= where(words eq 'dimage')
    words[idim]='montage'
    mfile= strjoin(words, '/')
    dbase= strmid(files[i], 0, strlen(files[i])-10L)
    mbase= strmid(mfile, 0, strlen(mfile)-10L)

    outstr[i].filename= files[i]

    splog, mbase
    if(file_test(mbase+'-u.fits.gz') gt 0 AND $
       file_test(dbase+'-u.fits.gz') gt 0 AND $
       file_test(mbase+'-g.fits.gz') gt 0 AND $
       file_test(dbase+'-g.fits.gz') gt 0 AND $
       file_test(mbase+'-r.fits.gz') gt 0 AND $
       file_test(dbase+'-r.fits.gz') gt 0 AND $
       file_test(mbase+'-i.fits.gz') gt 0 AND $
       file_test(dbase+'-i.fits.gz') gt 0 AND $
       file_test(mbase+'-z.fits.gz') gt 0 AND $
       file_test(dbase+'-z.fits.gz') gt 0) then begin
        
        bands=['u', 'g', 'r', 'i', 'z']
        
        for iband= 0L, n_elements(bands)-1L do begin
            dim= mrdfits(dbase+'-'+bands[iband]+'.fits.gz',0, dhdr, /silent)
            mim= mrdfits(mbase+'-'+bands[iband]+'.fits.gz',0, mhdr, /silent)

            dxcen= (size(dim, /dim))[0]/2L
            dycen= (size(dim, /dim))[1]/2L
            xyad, dhdr, dxcen, dycen, ra, dec
            spherematch, ra, dec, lowz.ra, lowz.dec, 10./3600., m1, m2
            if(m2[0] ge 0) then $
              radius= ((lowz[m2].petroth90[2]*1.3)/0.396) > 20. $
            else $
              radius=50.
            
            dflux= djs_phot(dxcen, dycen, radius, [0,0], dim, calg='none', $
                            salg='none')
            
            mxcen= (size(mim, /dim))[0]/2L
            mycen= (size(mim, /dim))[1]/2L
            mflux= djs_phot(mxcen, mycen, radius*0.396/0.400, $
                            [0,0], mim, calg='none', $
                            salg='none')
            
            outstr[i].radius[iband]= radius
            outstr[i].mflux[iband]= mflux
            outstr[i].dflux[iband]= dflux
        endfor
    endif
    
endfor

mwrfits, outstr, getenv('GOOGLE_DIR')+'/biggals/flux-compare.fits', /create

end
