;; run simplexy on a run
pro simplexy_run, run

cd, '/global/data/scr/mb145/simplexy'
spawn, 'mkdir -p '+strtrim(string(run),2)
cd, strtrim(string(run),2)
runlist=sdss_runlist(run)
for camcol=1L, 6L do $
  for field=runlist.field_ref, runlist.lastfield do $
  sdss_xy, run, camcol, field

end
