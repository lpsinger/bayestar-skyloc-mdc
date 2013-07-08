Batch sky localization for LIGO/Virgo CBC Mock Data Challenge
=============================================================

This repository contains code to generate a Condor DAG for localizing a
batch of LIGO/Virgo compact binary coalescence (CBC) events using the
rapid sky localization code BAYESTAR.

(The DAG will not be necessary for long, hopefully. This batch processing
should ultimately be totally automated by one or two scripts.)

Building BAYESTAR
-----------------

BAYESTAR is part of [LALSuite] [1]. Follow the instructions for building
LALSuite. (FIXME: put instructions here.) Be sure to configure all
LALSuite packages with the `--enable-swig-python` option because BAYESTAR
depends on the SWIG Python bindings.

Optionally, when you build LALInference, also pass the `--enable-openmp`
command line option to `./configure` to enable BAYESTAR's multicore
acceleration with OpenMP.

Basic BAYESTAR commands
-----------------------

Once you have installed LALSuite, you will be able to run the following Python scripts:

1. `bayestar_localize_lvalert`:
   Listen for new events from lvalert and perform sky localization.

2. `bayestar_localize_coincs`:
   Produce GW sky maps for all coincidences in a LIGO-LW XML file.

3. `bayestar_aggregate_found_injections`:
   Tabulate results of localizing triggers that are coincident with
   simulated signals (injections).

4. `bayestar_plot_found_injections`:
   Plot injection-finding results from
   `bayestar_aggregate_found_injections`.

5. `bayestar_plot_allsky`:
   Plot a probability sky map on all-sky Mollweiede axes.

Running BAYESTAR in batch mode
------------------------------

BAYESTAR is designed to process CBC event candidates in the LIGO
Lightweight XML (LIGO-LW) format and/or equivalent SQLite database format
produced by LIGO/Virgo search pipelines. BAYESTAR has been tested mostly
against the [GstLAL] [2] search pipeline. As a consequence, these
instructions will focus on processing GstLAL's output, although the
procedure could be easily adapted to other search pipelines (e.g. `ihope`).

The BAYESTAR DAG does the following tasks:

1. For each injection, select the matching detection candidate that has
   the lowest combined false alarm rate (and delete all other candidates).
   This models the concept that in a real search, all events above a given
   false alarm rate within an advancing time window would be followed up.

2. Split all of the detection candidates into smaller batches (of 100
   events each) so that multiple event can be handled in parallel on
   different computers.

3. Generate sky maps for all events.

Setup
-----

Let's say that you have some output from GstLAL in the directory `~/gstlal_out`. Follow these steps:

1. Pick a new directory for the BAYESTAR output. It doesn't matter where,
   but let's say for example that you put it in `~/gstlal_bayestar_out`.
   Obtain the DAG source code by cloning it from GitHub, like this:

    $ git clone https://github.com/lpsinger/bayestar-skyloc-mdc.git ~/gstlal_bayestar_out

2. Look inside the gstlal output for an SQLite database whose name looks
   like `H1L1V1-ALL_LLOID_1_injections-966383960-100000.sqlite`. The
   substring `H1L1V1` denotes which detectors were used in the search, and
   the string `1_injections` denotes that this data file comprises
   triggers resulting from simulating signals from the first injection
   set. (We'll assume that there is only one injection set.) Copy or
   symlink this file into the directory that you just created,
   `~/gstlal_bayestar_out`.

[1]: https://www.lsc-group.phys.uwm.edu/daswg/projects/lalsuite.html
[2]: https://www.lsc-group.phys.uwm.edu/daswg/projects/gstlal.html
