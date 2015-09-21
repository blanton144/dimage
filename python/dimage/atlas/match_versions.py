import os
import numpy as np
from astropy.coordinates import ICRS
from astropy import units as u

"""
Utilities for handling the NSA.

  match_versions() - matches one version of NSA to another
  
"""

def match_versions(nsa, match, tolerance=1.):
    """
    Match two versions of the 

    Parameters:
    ==========
    @param[in] nsa: [N] record array with RA, DEC, NSAID
    @param[in] match: [M] record array with RA, DEC, NSAID
    @return nsaid: [M] ndarray of int32, NSAID of each match, or -1
    """
    
    nsa_radec = ICRS(nsa['ra'], nsa['dec'], unit=(u.degree, u.degree))
    match_radec = ICRS(match['dec'], match['dec'], unit=(u.degree, u.degree))
    idx, d2d, d3d = nsa_radec.match_to_catalog_sky(match_radec)
    nsaid= match['NSAID'][idx]
    nsaid[nonzero(d2d > tolerance/3600.)]= -1
    return nsaid


