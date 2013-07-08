Batch sky localization for LIGO/Virgo CBC Mock Data Challenge
=============================================================

This repository contains code to generate a Condor DAG for localizing a
batch of LIGO/Virgo compact binary coalescence (CBC) events using the
rapid sky localization code BAYESTAR.

(The DAG will not be necessary for long, hopefully. This batch processing
should ultimately be totally automated by one or two scripts.)

Building BAYESTAR
-----------------

BAYESTAR is part of [LALSuite] [1]. Follow the instructions for building LALSuite. (FIXME: put instructions here.) Be sure to configure all LALSuite packages with the `--enable-swig-python` option because BAYESTAR depends on the SWIG Python bindings.

Optionally, when you build LALInference, also pass the `--enable-openmp` command line option to `./configure` to enable BAYESTAR's multicore acceleration with OpenMP.

Basic BAYESTAR commands
-----------------------

Once you have installed LALSuite, you will be able to run the following Python scripts:

1. `bayestar_localize_lvalert`:
   Listen for new events from lvalert and perform sky localization.
2. `bayestar_localize_coincs`:
   Produce GW sky maps for all coincidences in a LIGO-LW XML file.
3. `bayestar_aggregate_found_injections`:
   Tabulate results of localizing triggers that are coincident with simulated signals (injections).
4. `bayestar_plot_found_injections`:
   Plot injection-finding results from `bayestar_aggregate_found_injections`.
5. `bayestar_plot_allsky`:
   Plot a probability sky map on all-sky Mollweiede axes.

Running BAYESTAR in batch mode
------------------------------

BAYESTAR is designed to process CBC event candidates in the LIGO Lightweight XML (LIGO-LW) format and/or equivalent SQLite database format produced by LIGO/Virgo search pipelines. BAYESTAR has been tested mostly against the [GstLAL] [2] search pipeline. As a consequence, these instructions will focus on processing GstLAL's output, although the procedure could be easily adapted to other search pipelines (e.g. `ihope`).

[1]: https://www.lsc-group.phys.uwm.edu/daswg/projects/lalsuite.html
[2]: https://www.lsc-group.phys.uwm.edu/daswg/projects/gstlal.html
