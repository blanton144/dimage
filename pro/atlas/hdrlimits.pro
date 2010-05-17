function hdrlimits, hdr

nx= long(sxpar(hdr, 'NAXIS1'))
ny= long(sxpar(hdr, 'NAXIS2'))
xc= [-0.5, nx-0.5, -0.5, ny-0.5]
yc= [-0.5, -0.5, nx-0.5, ny-0.5]

xyad, hdr, xc, yc, ra, dec

limits={ramin:min(ra), $
        ramax:max(ra), $
        decmin:min(dec), $
        decmax:max(dec)}

return, limits

end
