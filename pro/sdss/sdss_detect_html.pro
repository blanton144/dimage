;+
; NAME:
;   sdss_detect_html
; PURPOSE:
;   take a directory with detect output from SDSS/GALEX, build QA web page
; CALLING SEQUENCE:
;   sdss_detect_html
; REVISION HISTORY:
;   11-Mar-2008  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro make_images_for_sdh, base, uim, gim, rim, iim, zim, fim, nim, shdr, ghdr

snx=(size(zim,/dim))[0]
sny=(size(zim,/dim))[1]

gnx=(size(fim,/dim))[0]
gny=(size(fim,/dim))[1]

scales=[4.,5.,6.]
djs_rgb_make, iim, rim, gim, $
  name=base+'-irg.jpg', $
  scales=scales, $
  nonlinearity=nonlinearity, satvalue=satvalue, $
  quality=100.

scales=[3.,5.,6.]
djs_rgb_make, zim, rim, gim, $
  name=base+'-zrg.jpg', $
  scales=scales, $
  nonlinearity=nonlinearity, satvalue=satvalue, $
  quality=100.

scales=[5.,6.,10.]
djs_rgb_make, rim, gim, uim, $
  name=base+'-rgu.jpg', $
  scales=scales, $
  nonlinearity=nonlinearity, satvalue=satvalue, $
  quality=100.

xyad, shdr, 0., 0., c1ra, c1dec
adxy, ghdr, c1ra, c1dec, c1x, c1y
xyad, shdr, 0., 10., c2ra, c2dec
adxy, ghdr, c2ra, c2dec, c2x, c2y
pscale= (c2y-c1y)/10.

tnx=long(snx*pscale)
tny=long(sny*pscale)

lc1y=long(c1y)
lc1x=long(c1x)
if(lc1y lt 0L) then begin
    tny=tny+lc1y
    lc1y=0L
endif
if(lc1x lt 0L) then begin
    tnx=tnx+lc1x
    lc1x=0L
endif

rims=fltarr(gnx, gny)

maxx= (long(tnx/pscale)-1L)<(snx-1L)
maxy= (long(tny/pscale)-1L)<(sny-1L)
rims[lc1x:lc1x+tnx-1L, $
     lc1y:lc1y+tny-1L]= $
  congrid(dsmooth(rim[0:maxx, 0:maxy], 6.27), tnx, tny)

scales=[4.,13.,17.]
djs_rgb_make, rims, nim, fim, $
  name=base+'-rnf.jpg', $
  scales=scales, $
  nonlinearity=nonlinearity, satvalue=satvalue, $
  quality=100.

end
;
pro sdss_detect_html

if(NOT keyword_set(satvalue)) then satvalue=30.
if(NOT keyword_set(nonlinearity)) then nonlinearity=3.

spawn, 'pwd', cwd
words=strsplit(cwd[0], '/',/extr)
base=words[n_elements(words)-1]
bands=['u', 'g', 'r', 'i', 'z', 'nd', 'fd']


;; first make big image
uim= mrdfits(base+'-u.fits.gz',0,shdr)
gim= mrdfits(base+'-g.fits.gz')
rim= mrdfits(base+'-r.fits.gz')
iim= mrdfits(base+'-i.fits.gz')
zim= mrdfits(base+'-z.fits.gz')
fim= mrdfits(base+'-fd.fits.gz',0,ghdr)
nim= mrdfits(base+'-nd.fits.gz')
make_images_for_sdh, base, uim, gim, rim, iim, zim, fim, nim, shdr, ghdr


;; then make center galaxy image

pim= gz_mrdfits(base+'-pimage.fits', 0)
pnx=(size(pim,/dim))[0]
pny=(size(pim,/dim))[1]
snx=(size(uim,/dim))[0]
sny=(size(uim,/dim))[1]

parent=pim[pnx/2L, pny/2L]

xyad, shdr, snx/2L, sny/2L, racen, deccen

subdir='atlases'

acat= gz_mrdfits(subdir+'/'+strtrim(string(parent),2)+'/'+ $
                 base+'-'+strtrim(string(parent),2)+'-acat.fits',1)
if(n_tags(acat) eq 0) then return

ii=where(acat.type eq 0, nii) ;; find galaxies
m2=-1L
if(nii gt 0) then $
  spherematch,racen, deccen, acat[ii].racen, acat[ii].deccen, 10., m1, m2
if(m2[0] ne -1) then begin
    icen=ii[m2]
    atfile= (subdir+'/'+strtrim(string(parent),2)+'/'+ $
             base+'-'+strtrim(string(parent),2)+ $
             '-atlas-'+strtrim(string(icen),2)+'.fits')[0]
    uim= gz_mrdfits(atfile, 0, uhdr)
    gim= gz_mrdfits(atfile, 1, ghdr)
    rim= gz_mrdfits(atfile, 2, rhdr)
    iim= gz_mrdfits(atfile, 3, ihdr)
    zim= gz_mrdfits(atfile, 4, zhdr)
    nim= gz_mrdfits(atfile, 5, nhdr)
    fim= gz_mrdfits(atfile, 6, fhdr)


    make_images_for_sdh, base+'-cen', uim, gim, rim, iim, zim, fim, nim, $
      uhdr, nhdr

    pafile= (subdir+'/'+strtrim(string(parent),2)+'/'+ $
             base+'-'+strtrim(string(parent),2)+ $
             '-parent.fits')[0]
    uim= gz_mrdfits(pafile, 0, uhdr)
    gim= gz_mrdfits(pafile, 1, ghdr)
    rim= gz_mrdfits(pafile, 2, rhdr)
    iim= gz_mrdfits(pafile, 3, ihdr)
    zim= gz_mrdfits(pafile, 4, zhdr)
    nim= gz_mrdfits(pafile, 5, nhdr)
    fim= gz_mrdfits(pafile, 6, fhdr)

    make_images_for_sdh, base+'-par', uim, gim, rim, iim, zim, fim, nim, $
      uhdr, nhdr
    
endif

openw, unit, 'deblend.html', /get_lun
printf, unit, '<html>'
printf, unit, '<head>'
printf, unit, '<title>'+base+'-'+strtrim(string(parent),2)+'</title>'
printf, unit, '</head>'
printf, unit, '<body>'
printf, unit, '<font size=8><b>'+base+'-'+strtrim(string(parent),2)+ $
  '</b></font>'
printf, unit, '<hr>'
printf, unit, '<table border=0>'
width    = '300'

printf, unit, '<tr>'
printf, unit, '<td>'
imname=base+'-irg.jpg'
printf, unit, '<a href="'+imname+'">' + $
  '<img src="'+imname+'" width='+width+'></a>'
printf, unit, '</td>'
printf, unit, '<td>'
imname=base+'-rgu.jpg'
printf, unit, '<a href="'+imname+'">' + $
  '<img src="'+imname+'" width='+width+'></a>'
printf, unit, '</td>'
printf, unit, '<td>'
imname=base+'-rnf.jpg'
printf, unit, '<a href="'+imname+'">' + $
  '<img src="'+imname+'" width='+width+'></a>'
printf, unit, '</td>'
printf, unit, '<td>'
imname=base+'-zrg.jpg'
printf, unit, '<a href="'+imname+'">' + $
  '<img src="'+imname+'" width='+width+'></a>'
printf, unit, '</td>'

printf, unit, '<tr>'
printf, unit, '<td>'
imname=base+'-cen-irg.jpg'
printf, unit, '<a href="'+imname+'">' + $
  '<img src="'+imname+'" width='+width+'></a>'
printf, unit, '</td>'
printf, unit, '<td>'
imname=base+'-cen-rgu.jpg'
printf, unit, '<a href="'+imname+'">' + $
  '<img src="'+imname+'" width='+width+'></a>'
printf, unit, '</td>'
printf, unit, '<td>'
imname=base+'-cen-rnf.jpg'
printf, unit, '<a href="'+imname+'">' + $
  '<img src="'+imname+'" width='+width+'></a>'
printf, unit, '</td>'
printf, unit, '<td>'
imname=base+'-cen-zrg.jpg'
printf, unit, '<a href="'+imname+'">' + $
  '<img src="'+imname+'" width='+width+'></a>'
printf, unit, '</td>'

printf, unit, '<tr>'
printf, unit, '<td>'
imname=base+'-par-irg.jpg'
printf, unit, '<a href="'+imname+'">' + $
  '<img src="'+imname+'" width='+width+'></a>'
printf, unit, '</td>'
printf, unit, '<td>'
imname=base+'-par-rgu.jpg'
printf, unit, '<a href="'+imname+'">' + $
  '<img src="'+imname+'" width='+width+'></a>'
printf, unit, '</td>'
printf, unit, '<td>'
imname=base+'-par-rnf.jpg'
printf, unit, '<a href="'+imname+'">' + $
  '<img src="'+imname+'" width='+width+'></a>'
printf, unit, '</td>'
printf, unit, '<td>'
imname=base+'-par-zrg.jpg'
printf, unit, '<a href="'+imname+'">' + $
  '<img src="'+imname+'" width='+width+'></a>'
printf, unit, '</td>'

printf, unit, '</tr>'

printf, unit, '</table>'
printf, unit, '</font>'
printf, unit, '</body>'
printf, unit, '</html>'
free_lun, unit

end
;------------------------------------------------------------------------------
