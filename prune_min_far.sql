-- For each sim_inspiral record, for each 'sim_inspiral<-->coinc_event'
-- association, select the one with the lowest false alarm rate.
CREATE TEMPORARY TABLE to_keep_coincs AS SELECT
    MIN(ci.combined_far) AS min_combined_far,
    cem1.event_id AS simulation_id,
    cem2.event_id AS coinc_event_id
    FROM coinc_definer AS cd
    INNER JOIN coinc_event AS ce
    ON (cd.coinc_def_id = ce.coinc_def_id)
    INNER JOIN coinc_event_map AS cem1
    ON (cem1.coinc_event_id = ce.coinc_event_id)
    INNER JOIN coinc_event_map AS cem2
    ON (cem2.coinc_event_id = ce.coinc_event_id)
    INNER JOIN coinc_inspiral AS ci
    ON (ci.coinc_event_id = cem2.event_id)
    WHERE cd.description =
    'sim_inspiral<-->coinc_event coincidences (exact)'
    AND cem1.table_name = 'sim_inspiral'
    AND cem2.table_name='coinc_event'
    GROUP BY cem1.event_id;

-- Make a list of all 'sim_inspiral<-->coinc_event' associations but those.
CREATE TEMPORARY TABLE to_delete_coincs AS SELECT
    coinc_event_id FROM coinc_event
    WHERE coinc_event_id NOT IN (SELECT coinc_event_id FROM to_keep_coincs);

-- Delete those 'sim_inspiral<-->coinc_event' associations that do not have
-- the minimum FAR for that sim_inspiral record.
DELETE FROM coinc_event
    WHERE coinc_event.coinc_event_id IN (SELECT * FROM to_delete_coincs);

-- Delete orphaned coinc_event_map records.
DELETE FROM coinc_event_map
    WHERE coinc_event_map.coinc_event_id IN (SELECT * FROM to_delete_coincs);

    -- Delete orphaned coinc_event_map records.
DELETE FROM coinc_event_map
    WHERE coinc_event_map.event_id IN (SELECT * FROM to_delete_coincs);

-- Delete orphaned sngl_inspiral records.
DELETE FROM sngl_inspiral WHERE event_id NOT IN
    (SELECT event_id FROM coinc_event_map WHERE table_name = 'sngl_inspiral');

-- Delete orphaned process records.
DELETE FROM process WHERE process_id NOT IN
    (SELECT process_id FROM sngl_inspiral);

-- Delete orphaned process_params records.
DELETE FROM process_params WHERE process_id NOT IN
    (SELECT process_id FROM process);

-- Delete tables that we won't need.
DROP TABLE filter;
DROP TABLE coinc_inspiral;
DROP TABLE sim_inspiral;
DROP TABLE search_summary;
DROP TABLE segment;
DROP TABLE search_summvars;
DROP TABLE segment_definer;
DROP TABLE summ_value;
DROP TABLE time_slide;

-- Clean up unused space.
VACUUM;
