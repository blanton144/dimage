;+
; NAME:
;   atlas_rootdir
; PURPOSE:
;   return root name directory of atlas
; CALLING SEQUENCE:
;   rootdir= atlas_rootdir()
; REVISION HISTORY:
;   3-Aug-2007  MRB, NYU
;-
;------------------------------------------------------------------------------
function atlas_rootdir, version=version, cdir=cdir, mdir=mdir, ddir=ddir, $
                        subname=subname

if(NOT keyword_set(version)) then $
   version=atlas_default_version()

words= strsplit(version, '_', /extr)
vtop= words[0]
vmeas= words[0]+'_'+words[1]

rootdir=getenv('ATLAS_DATA')+'/'+vtop

cdir= rootdir+'/catalogs'
mdir= rootdir+'/measure/'+vmeas
ddir= rootdir+'/derived/'+version
subname= 'detect/'+vmeas

return, rootdir

end
