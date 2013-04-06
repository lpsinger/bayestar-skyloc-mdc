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

CREATE TEMPORARY TABLE to_delete_coincs AS SELECT
    coinc_event_id FROM coinc_event
    WHERE coinc_event_id NOT IN (SELECT coinc_event_id FROM to_keep_coincs)
    AND coinc_def_id IN (SELECT coinc_def_id FROM coinc_definer
    WHERE description = 'sim_inspiral<-->coinc_event coincidences (exact)');

DELETE FROM coinc_inspiral
    WHERE coinc_inspiral.coinc_event_id IN (SELECT * FROM to_delete_coincs);

DELETE FROM coinc_event
    WHERE coinc_event.coinc_event_id IN (SELECT * FROM to_delete_coincs);

DELETE FROM coinc_event_map
    WHERE coinc_event_map.coinc_event_id IN (SELECT * FROM to_delete_coincs)
    OR coinc_event_map.event_id IN (SELECT * FROM to_delete_coincs);
