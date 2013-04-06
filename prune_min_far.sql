CREATE TEMPORARY TABLE min_far_coincs AS SELECT
    MIN(coinc_inspiral.combined_far) AS min_combined_far,
    cem1.event_id AS simulation_id,
    cem2.event_id AS coinc_event_id
    FROM coinc_event AS ce INNER JOIN coinc_event_map AS cem1
    ON (ce.coinc_event_id = cem1.coinc_event_id)
    INNER JOIN coinc_event_map AS cem2
    ON (ce.coinc_event_id = cem2.coinc_event_id)
    INNER JOIN coinc_definer
    ON (coinc_definer.coinc_def_id = ce.coinc_event_id)
    INNER JOIN coinc_inspiral
    ON (coinc_inspiral.coinc_event_id = cem2.event_id) 
    WHERE description = 'sim_inspiral<-->coinc_event coincidences (exact)'
    AND cem1.table_name = 'sim_inspiral'
    AND cem2.table_name = 'coinc_event'
    GROUP BY cem1.event_id;

CREATE TEMPORARY TABLE not_min_far_coincs AS SELECT
    coinc_event_id FROM coinc_event
    WHERE coinc_event_id NOT IN (SELECT coinc_event_id FROM min_far_coincs)
    AND coinc_def_id IN (SELECT coinc_def_id FROM coinc_definer
    WHERE description = 'sim_inspiral<-->coinc_event coincidences (exact)');

DELETE FROM coinc_inspiral
    WHERE coinc_inspiral.coinc_event_id IN (SELECT * FROM not_min_far_coincs);

DELETE FROM coinc_event
    WHERE coinc_event.coinc_event_id IN (SELECT * FROM not_min_far_coincs);

DELETE FROM coinc_event_map
    WHERE coinc_event_map.coinc_event_id IN (SELECT * FROM not_min_far_coincs)
    OR coinc_event_map.event_id IN (SELECT * FROM not_min_far_coincs);
