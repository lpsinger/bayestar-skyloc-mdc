#!/usr/bin/env python

# Command line interface.
from optparse import Option, OptionParser
opts, args = OptionParser(
    option_list = [
    ]
).parse_args()

dbfilename = args[0]
fitsfilenames = args[1:]

# Imports.
import os
import numpy as np
import healpy as hp
import sqlite3
from pylal.progress import ProgressBar
import bayestar.fits

def find_injection(sky_map, true_ra, true_dec):
    """
    Given a sky map and the true right ascension and declination (in radians),
    find the smallest area in deg^2 that would have to be searched to find the
    source, the smallest posterior mass, and the angular offset in degrees from
    the true location to the maximum (mode) of the posterior.
    """

    # Compute the HEALPix lateral resolution parameter for this sky map.
    npix = len(sky_map)
    nside = hp.npix2nside(npix)

    # Convert from ra, dec to conventional spherical polar coordinates.
    true_theta = 0.5 * np.pi - true_dec
    true_phi = true_ra

    # Find the HEALPix pixel index of the mode of the posterior and of the
    # true sky location.
    mode_pix = np.argmax(sky_map)
    true_pix = hp.ang2pix(nside, true_theta, true_phi)

    # Compute the Cartesian unit vector of the mode and true locations.
    mode_vec = np.asarray(hp.pix2vec(nside, mode_pix))
    true_vec = np.asarray(hp.ang2vec(true_theta, true_phi))

    # Sort the pixels in the sky map by descending posterior probability and
    # form the cumulative sum.  Record the total value.
    indices = np.argsort(sky_map)[::-1]
    cum_sky_map = np.cumsum(sky_map[indices])

    # Find the index of the true location in the cumulative distribution.
    idx = (i for i, pix in enumerate(indices) if pix == true_pix).next()

    # Find the smallest area that would have to be searched to find the true
    # location.
    searched_area = (idx + 1) * hp.nside2pixarea(nside, degrees=True)

    # Find the smallest posterior mass that would have to be searched to find
    # the true location.
    searched_prob = cum_sky_map[idx]

    # Permute the cumulative distribution so that it is indexed the same way
    # as the original sky map.
    cum_sky_map[indices] = cum_sky_map

    # Find the angular offset between the mode and true locations.
    offset = np.rad2deg(np.arccos(np.dot(true_vec, mode_vec)))

    # Done.
    return searched_area, searched_prob, offset

pb = ProgressBar()
pb.update(-1, 'opening database')
db = sqlite3.connect(dbfilename)

outdata = np.empty((len(fitsfilenames), 4))
pb.max = len(fitsfilenames)
for i, fitsfilename in enumerate(fitsfilenames):
    pb.update(i, fitsfilename.replace('coinc_event:', '...:'))
    sky_map = bayestar.fits.read_map(fitsfilename)
    coinc_event_id, _, _ = fitsfilename.partition('.')

    true_ra, true_dec, far = db.execute("""
    SELECT DISTINCT sim.longitude AS ra, sim.latitude AS dec, ci.combined_far AS far
    FROM coinc_event_map AS cem1 INNER JOIN coinc_event_map AS cem2
    ON (cem1.coinc_event_id = cem2.coinc_event_id)
    INNER JOIN sim_inspiral AS sim ON (cem1.event_id = sim.simulation_id)
    INNER JOIN coinc_inspiral AS ci ON (cem2.event_id = ci.coinc_event_id)
    WHERE cem1.table_name = 'sim_inspiral' AND cem2.table_name = 'coinc_event'
    AND cem2.event_id = ?""", (coinc_event_id,)).fetchone()
    searched_area, searched_prob, offset = find_injection(sky_map, true_ra, true_dec)
    outdata[i, :] = [far, searched_area, searched_prob, offset]
np.savetxt('outdata.txt', outdata)
