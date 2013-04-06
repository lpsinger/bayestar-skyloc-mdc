ALL_INJECTIONS = H1L1V1-ALL-966383960-971614865-LLOID-1_injections

all: $(ALL_INJECTIONS)_min_far.sqlite count_coincs.txt mdc.dag

.INTERMEDIATE: $(ALL_INJECTIONS)_min_far.sqlite.tmp count_coincs.txt

$(ALL_INJECTIONS)_min_far.sqlite.tmp: $(ALL_INJECTIONS).sqlite
	cp $< $@

$(ALL_INJECTIONS)_min_far.sqlite: $(ALL_INJECTIONS)_min_far.sqlite.tmp prune_min_far.sql
	lalapps_run_sqlite --tmp-space /tmp --verbose $< --sql-file prune_min_far.sql
	mv $< $@

count_coincs.txt: $(ALL_INJECTIONS)_min_far.sqlite count_coincs.sql
	sqlite3 $< < count_coincs.sql > $@

mdc.dag: count_coincs.txt make_dag.py
	python make_dag.py $(shell cat count_coincs.txt) $(ALL_INJECTIONS)_min_far.sqlite > $@
