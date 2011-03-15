;+
; NAME:
;   absmk2sm
; PURPOSE:
;   Convert M_K to stellar mass
; REVISION HISTORY:
;   17-Mar-2010 
;-
;------------------------------------------------------------------------------
function absmk2sm, absmk

;; from Fig 2 of Bell et al (2003)
mtol= 10.^(-0.1) 

absmksolar= 3.32

lum= 10.^(-0.4*(absmk-absmksolar))

mass= mtol*lum
return, mass


end
;------------------------------------------------------------------------------
