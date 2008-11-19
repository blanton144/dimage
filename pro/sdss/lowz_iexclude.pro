;+
; NAME:
;   lowz_iexclude
; PURPOSE:
;   return the indices of lowz entries excluded
; CALLING SEQUENCE:
;   iexclude= lowz_iexclude()
; REVISION HISTORY:
;   1-Aug-2008  MRB, NYU
;-
;------------------------------------------------------------------------------
function lowz_iexclude

iexclude=[8601, 51865, 66964, 140408, 141293, 18279]
return, iexclude

end
