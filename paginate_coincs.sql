CREATE TEMPORARY TABLE to_keep_coincs AS SELECT
    ce.coinc_event_id
    FROM coinc_definer AS cd
    INNER JOIN coinc_event AS ce
    ON (cd.coinc_def_id = ce.coinc_def_id)
    WHERE cd.description =
    'sngl_inspiral<-->sngl_inspiral coincidences'
    ORDER BY ce.coinc_event_id
    LIMIT %limit%
    OFFSET %offset%;

CREATE TEMPORARY TABLE to_delete_coincs AS SELECT
    coinc_event_id FROM coinc_event
    WHERE coinc_event_id NOT IN (SELECT coinc_event_id FROM to_keep_coincs)
    AND coinc_def_id IN (SELECT coinc_def_id FROM coinc_definer);

DELETE FROM coinc_inspiral
    WHERE coinc_inspiral.coinc_event_id IN (SELECT * FROM to_delete_coincs);

DELETE FROM coinc_event
    WHERE coinc_event.coinc_event_id IN (SELECT * FROM to_delete_coincs);

DELETE FROM coinc_event_map
    WHERE coinc_event_map.coinc_event_id IN (SELECT * FROM to_delete_coincs)
    OR coinc_event_map.event_id IN (SELECT * FROM to_delete_coincs);

VACUUM;
