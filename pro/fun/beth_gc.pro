function beth_gc_select, pobj, count

indx= where(pobj.pm_match gt 0, count)
return, indx

end
;
pro beth_gc

name=['M5', 'M13', 'M92']

ra=[229.64060D, 250.42313D, 259.28086D]
dec=[2.0830890D, 36.460278D, 43.136479D]
radius=1.

for i=0L, n_elements(name)-1L do begin
    pobj=photoobj_circle(ra[i], dec[i], radius, rerun=301, $
                         extcat=['PM'], select='beth_gc_select', /verbose)
    mwrfits, pobj, '/global/data/scr/mb144/beth_gc/'+name[i]+'.fits', /create
endfor

end
