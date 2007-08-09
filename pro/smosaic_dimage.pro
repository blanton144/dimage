pro smosaic_dimage, ra, dec, sz=sz, prefix=prefix, noclobber=noclobber, $
                    iau_name=iau_name, scales=scales, sub=sub, $
                    _EXTRA=extra_for_smosaic

if(n_elements(ra) eq 0) then begin
    iau_to_radec, iau_name, ra, dec
endif

if(NOT keyword_set(sz)) then sz=0.1

if(NOT keyword_set(prefix)) then begin
    prefix=(hogg_iau_name(ra,dec,''))[0]
    if(keyword_set(sub)) then begin
        spawn, 'mkdir -p '+prefix
        prefix=prefix+'/'+prefix
    endif
endif

redo=1
if(keyword_set(noclobber)) then begin
    redo=0
    filters=['u', 'g', 'r', 'i', 'z']
    for i=0L, n_elements(filters)-1L do $
      if(NOT file_test(prefix+'-'+filters[i]+'.fits.gz')) then $
      redo=1
endif

if(redo) then $
  smosaic_make, ra, dec, sz, sz, /fpbin, /global, rerun=[137, 161], $
  /dropweights, /ivarout, /sheldon, prefix=prefix, $
  _EXTRA=extra_for_smosaic

redo=1
if(keyword_set(noclobber)) then begin
    redo=0
    if(NOT file_test(prefix+'.jpg')) then redo=1
endif

if(NOT keyword_set(scales)) then scales=[3.,3.,3.]
if(redo) then $
  djs_rgb_make, prefix[0]+'-i.fits.gz', $
  prefix[0]+'-r.fits.gz', $
  prefix[0]+'-g.fits.gz', $
  name=prefix+'.jpg', $
  scales=scales, $
  nonlinearity=3., satvalue=50., $
  quality=100.

end
