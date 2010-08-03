;+
; NAME:
;   biggal_look
; PURPOSE:
;   Bring up images from DIMAGE and MONTAGE from biggal measuremnts
; CALLING SEQUENCE:
;   biggal_look, indx 
; REVISION HISTORY:
;   2-Aug-2010 MRB, NYU
;-
pro biggal_look, indx, filter=filter

if(n_elements(filter) eq 0) then $
  filter='r'

ifilter= (filternum(filter))[0]
filtername= filtername(filter)

fcomp=mrdfits(getenv('GOOGLE_DIR')+'/biggals/flux-compare.fits', 1)
fcomp= fcomp[indx]

dfile= strtrim(repstr(fcomp.filename, '-r', '-'+filtername),2)
print,'A'+dfile+'A'
dim= mrdfits(dfile, 0, hdr)
nx= (size(dim,/dim))[0]
ny= (size(dim,/dim))[1]
th= (findgen(100)/99L)*!DPI*2.
xc= (nx/2L)+cos(th)*fcomp.radius[ifilter]
yc= (ny/2L)+sin(th)*fcomp.radius[ifilter]

atv, dim, head=hdr
atvplot, xc, yc

mfile= repstr(dfile, 'dimage', 'montage')
mim= mrdfits(mfile, 0, hdr)
nx= (size(mim,/dim))[0]
ny= (size(mim,/dim))[1]
th= (findgen(100)/99L)*!DPI*2.
xc= (nx/2L)+cos(th)*fcomp.radius[ifilter]
yc= (ny/2L)+sin(th)*fcomp.radius[ifilter]

atv2, mim, head=hdr
atv2plot, xc, yc

splog, 'Radius= '+strtrim(string(fcomp.radius[ifilter],f='(f40.4)'),2)+' pixels'
splog, 'dimage flux= '+strtrim(string(fcomp.dflux[ifilter],f='(f40.4)'),2)+ $
  ' nmgy'
splog, 'montage flux= '+strtrim(string(fcomp.mflux[ifilter],f='(f40.4)'),2)+ $
  ' nmgy'

end
