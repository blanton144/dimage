function dcgrad, gmeas, rmeas

if(n_elements(gmeas) gt 1) then begin
    cgrad=fltarr(n_elements(gmeas))
    for i=0L, n_elements(gmeas)-1L do $
      cgrad[i]= dcgrad(gmeas[i], rmeas[i])
    return, cgrad
endif

coresize=1.0
outsize=1.0

interp_profmean, gmeas.nprof, gmeas.profmean, $
  rmeas.petror50*coresize, gcore
interp_profmean, rmeas.nprof, rmeas.profmean, $
  rmeas.petror50*coresize, rcore

interp_profmean, gmeas.nprof, gmeas.profmean, $
  rmeas.petror50*outsize, g50
interp_profmean, rmeas.nprof, rmeas.profmean, $
  rmeas.petror50*outsize, r50

interp_profmean, gmeas.nprof, gmeas.profmean, $
  rmeas.petror90*outsize, g90
interp_profmean, rmeas.nprof, rmeas.profmean, $
  rmeas.petror90*outsize, r90

gout= g90- g50
rout= r90- r50

gmrout= -2.5*alog10(gout/rout)
gmrcore= -2.5*alog10(gcore/rcore)

cgrad= gmrcore- gmrout

return, cgrad


end
