ALL_INJECTIONS = FILL_ME_IN
EVENTS_PER_JOB = 100
METHODS = toa_phoa_snr

all: tmp/$(ALL_INJECTIONS)_min_far.sqlite tmp/count_coincs.txt mdc.dag

.INTERMEDIATE: tmp/$(ALL_INJECTIONS)_min_far.sqlite.tmp

tmp/$(ALL_INJECTIONS)_min_far.sqlite.tmp: $(ALL_INJECTIONS).sqlite
	mkdir -p tmp
	cp $< $@
	chmod u+w $@

tmp/$(ALL_INJECTIONS)_min_far.sqlite: tmp/$(ALL_INJECTIONS)_min_far.sqlite.tmp prune.sql
	lalapps_run_sqlite --tmp-space /tmp --verbose $< --sql-file prune.sql
	mv $< $@

tmp/count_coincs.txt: tmp/$(ALL_INJECTIONS)_min_far.sqlite count_coincs.sql
	sqlite3 $< < count_coincs.sql > $@

mdc.dag: tmp/count_coincs.txt make_dag.py tmp/$(ALL_INJECTIONS)_min_far.sqlite
	mkdir -p fits
	mkdir -p log
	./make_dag.py $(shell cat tmp/count_coincs.txt) $(EVENTS_PER_JOB) tmp/$(ALL_INJECTIONS)_min_far.sqlite $(METHODS) > $@
