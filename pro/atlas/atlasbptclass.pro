;+
; Name: atlasbptclass
;
; Purpose: provide a BPT classification for only the classifiable objects.
;
; Calling Sequence:
;    class = atlasbptclass(sloan)
;  
; Input:  
;     sloan: structure array read from sdssline_atlas.fits 
;            or a catalog with the same columns and flag values. 
; Output: 
;     returns the classification defined in the following way
; 	unclassified =-1
; 	Quiescent    = 0
; 	SF           = 1
; 	Composite    = 2
; 	AGN          = 3
; 	ambiguous    = 4
; Waring:
;     The classification is incomplete: none of the category gives
;     a complete sample.  
;    
; History:
;     Created Apr 20, 2011. RY 
;-
function atlasbptclass,sloan

    s2cov = sloan.s2fluxerr gt -999.
    n2cov = sloan.n2fluxerr gt -999.
    hacov = sloan.hafluxerr gt -999.
    o1cov = sloan.o1fluxerr gt -999.
    o3cov = sloan.o3fluxerr gt -999.
    hbcov = sloan.hbfluxerr gt -999.
    o2cov = sloan.o2fluxerr gt -999.

    s2det = s2cov and sloan.s2flux gt 3*sloan.s2fluxerr
    n2det = n2cov and sloan.n2flux gt 3*sloan.n2fluxerr
    hadet = hacov and sloan.haflux gt 3*sloan.hafluxerr
    o1det = o1cov and sloan.o1flux gt 3*sloan.o1fluxerr
    o3det = o3cov and sloan.o3flux gt 3*sloan.o3fluxerr
    hbdet = hbcov and sloan.hbflux gt 3*sloan.hbfluxerr
    o2det = o2cov and sloan.o2flux gt 3*sloan.o2fluxerr

    o3hblow = sloan.o3flux/(3*sloan.hbfluxerr)
    o3hbhi = 3*sloan.o3fluxerr/sloan.hbflux
    
    bpt1cov = hbcov and o3cov and n2cov and hacov
    bpt1det = hbdet and o3det and n2det and hadet 
    bpt1nondet  = bpt1cov and hbdet eq 0 and o3det eq 0 and n2det eq 0 and hadet eq 0
    bpt1above = alog10(sloan.n2ha) gt 0.47 or alog10(sloan.o3hb) gt 0.61/(alog10(sloan.n2ha)-0.47)+1.19
    bpt1below = alog10(sloan.n2ha) lt 0.05 and alog10(sloan.o3hb) lt 0.61/(alog10(sloan.n2ha)-0.05)+1.3

; unclassified =-1
; Quiescent    = 0
; SF           = 1
; Composite    = 2
; AGN          = 3
; ambiguous    = 4

    class=intarr(n_elements(sloan))-1
    t = where(bpt1cov and bpt1nondet)
    class[t] = 0
    t = where(bpt1det and bpt1below)
    class[t] = 1
    t = where(bpt1det and bpt1above eq 0 and bpt1below eq 0)
    class[t] = 2
    t = where(bpt1det and bpt1above)
    class[t] = 3

    bpt1det_hb = hbcov and hbdet eq 0 and o3det and n2det and hadet
    bpt1above_hb = alog10(sloan.n2ha) gt 0.47 or alog10(o3hblow) gt 0.61/(alog10(sloan.n2ha)-0.47)+1.19
    bpt1det_o3 = hbdet and o3cov and o3det eq 0 and n2det and hadet
    bpt1below_o3 = alog10(sloan.n2ha) lt 0.05 and alog10(o3hbhi) lt 0.61/(alog10(sloan.n2ha)-0.05)+1.3
    
    t = where(bpt1det_hb and bpt1above_hb)    
    class[t] = 3
    t = where(bpt1det_o3 and bpt1below_o3)
    class[t] = 1

    return,class
end
