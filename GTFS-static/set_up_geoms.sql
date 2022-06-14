CREATE EXTENSION IF NOT EXISTS MobilityDB CASCADE;

INSERT INTO shape_geoms
SELECT shape_id, ST_MakeLine(array_agg(
ST_SetSRID(ST_MakePoint(shape_pt_lon, shape_pt_lat),4326) ORDER BY shape_pt_sequence))
FROM shapes
GROUP BY shape_id;

UPDATE stops
SET stop_geom = ST_SetSRID(ST_MakePoint(stop_lon, stop_lat),4326);
