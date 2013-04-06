-- Select a range of coincs.
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

-- Select all other coincs.
CREATE TEMPORARY TABLE to_delete_coincs AS SELECT
    coinc_event_id FROM coinc_event
    WHERE coinc_event_id NOT IN (SELECT coinc_event_id FROM to_keep_coincs)
    AND coinc_def_id IN (SELECT coinc_def_id FROM coinc_definer);

-- Delete them.
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

-- Clean up unused space.
VACUUM;
