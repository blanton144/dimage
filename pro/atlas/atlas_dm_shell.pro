;+
; NAME:
;   atlas_dm_shell
; PURPOSE:
;   Create html file with data model
; CALLING SEQUENCE:
;   atlas_dm_shell [, version= , /init]
; COMMENTS:
;   Looks in $DIMAGE_DIR/data/atlas/atlas_dm.par 
;   for tag names, units, and comments. Derives types
;   from file itself.  Spawns error for any column 
;   not listed. Writes out html into:
;      $DIMAGE_DIR/data/atlas/atlas_dm.html
;   If /init is set, it just creates a blank atlas_dm.par file. 
; REVISION HISTORY:
;   3-Aug-2004  MRB, NYU
;-
;------------------------------------------------------------------------------
pro atlas_dm_shell, version=version, init=init

nsa= read_nsa(version=version, row=1)

dmbase= getenv('DIMAGE_DIR')+'/data/atlas/atlas_dm_'+version
dmparfile= dmbase+'.par'
dmhtmlfile= dmbase+'.html'

if(keyword_set(init)) then begin
    if(file_test(dmparfile)) then $
      file_copy, dmparfile, dmparfile+'.old.'+strtrim(string(long(randomu(seed)*1000L)),2)
    
    dm0={ATLAS_DM, tag:'', arrsize:'', type:'', unit:'', description:''}
    dm= replicate(dm0, n_tags(nsa))
    dm.tag= tag_names(nsa)
    for i=0L, n_tags(nsa)-1L do begin

        ;; deal with arrays
        if(n_elements(nsa[0].(i)) gt 1) then begin
            ndim= size(nsa[0].(i),/n_dim)
            dsize= size(nsa[0].(i), /dim)
            dimstr='['+strtrim(string(dsize[0]),2)
            for j=1L, ndim-1L do $
              dimstr=dimstr+','+strtrim(string(dsize[j]),2)
            dimstr=dimstr+']'
            dm[i].arrsize= dimstr
        endif

        ;; deal with types
        idltype=(size(nsa[0].(i)[0], /tname))
        case idltype of 
            'BYTE': dm[i].type='int8'
            'INT': dm[i].type='int16'
            'LONG': dm[i].type='int32'
            'FLOAT': dm[i].type='float32'
            'DOUBLE': dm[i].type='float64'
            'STRING': dm[i].type='string'
            'UINT': dm[i].type='uint16'
            'ULONG': dm[i].type='uint32'
            'LONG64': dm[i].type='int64'
            'ULONG64': dm[i].type='uint64'
            default: message, 'Not allowed type: '+idltype
        endcase
        
    endfor
    pdata= ptr_new(dm)
    hdr=["# Data model parameters for NSA"]
    yanny_write, dmparfile, pdata, hdr=hdr, /align
    
    return
endif

if(NOT file_test(dmparfile)) then $
  message, 'Run /init and fill in data first!'

dm= yanny_readone(dmparfile)

names= tag_names(nsa)
infile= bytarr(n_elements(dm))
for i=0L, n_elements(names)-1L do begin
    idm= where(names[i] eq dm.tag, ndm)
    if(ndm ne 1) then $
      message, 'Should be exactly one entry in data model for each tag: '+names[i]
    infile[idm]=1
    if(strtrim(dm[idm].type,2) eq '') then $
      message, 'No data type listed for '+names[i]
    if(strtrim(dm[idm].description,2) eq '') then $
      message, 'No description listed for '+names[i]
endfor
inot= where(infile eq 0, nnot)
if(nnot gt 0) then $
  message, 'Tags in datamodel that are not in file'

openw, unit, dmhtmlfile, /get_lun

printf, unit, '<table>'
printf, unit, '<thead>'
printf, unit, '<tr>'
printf, unit, '<td><b>Column name</b></td>'
printf, unit, '<td><b>Data type</b></td>'
printf, unit, '<td><b>Units</b></td>'
printf, unit, '<td><b>Description</b></td>'
printf, unit, '</tr>'
printf, unit, '</thead>'
printf, unit, '<tbody>'
for i=0L, n_elements(dm)-1L do begin
    printf, unit, '<tr>'
    printf, unit, '<td>'+dm[i].tag+dm[i].arrsize+'</td>'
    printf, unit, '<td>'+dm[i].type+'</td>'
    printf, unit, '<td>'+dm[i].unit+'</td>'
    printf, unit, '<td>'+dm[i].description+'</td>'
    printf, unit, '</tr>'
endfor
printf, unit, '</tbody>'
printf, unit, '</table>'

free_lun, unit

end
