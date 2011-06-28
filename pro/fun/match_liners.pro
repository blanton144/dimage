pro match_liners

liners=mrdfits('/global/data/scr/yan/sliner/vagcgal7_liner_catalog.fits',1)

galex= galex_match(liners.ra, liners.dec, /trim)

mwrfits, galex, '/global/data/scr/mb144/sliner-galex.fits', /create

end
