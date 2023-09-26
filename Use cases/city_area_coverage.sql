-- Creating a table to store circle geometry
DROP TABLE IF EXISTS circle_geometry;
CREATE TABLE circle_geometry (
    geom GEOMETRY(Polygon, 4326),
	surface float
);

-- Inserting circle geometry and area
INSERT INTO circle_geometry (geom, surface)
VALUES (
    ST_Buffer(ST_MakePoint(-73.949997, 40.650002), 7000),
    ST_Area(ST_Buffer(ST_MakePoint(-73.949997, 40.650002), 7000))
);


-- Filter trips by timestamp
DROP TABLE IF EXISTS filtered_table;
CREATE TABLE filtered_table AS (
	--select trip_id, atTime(trip, tstzspan '[2023-04-08 09:50:00, 2023-04-08 09:51:00]') as subtrip from trips_mdb
	SELECT trip_id, atTime(trip, timestamp '2023-04-08 09:50:00') AS subtrip FROM trips_mdb
);
DELETE FROM filtered_table WHERE subtrip IS null;
ALTER TABLE filtered_table ADD column shape geometry;
UPDATE filtered_table SET shape=subtrip::geometry;


DROP TABLE IF EXISTS result_show;
CREATE TABLE result_show AS (
	SELECT st_union(st_buffer(shape, 400))
	FROM filtered_table
	WHERE ST_Intersects(shape, (SELECT geom FROM circle_geometry))
);

-- Calculation of the total area covered by points without overlap
WITH buffered_geoms AS (
    SELECT ST_Buffer(shape, 400) AS surface
    FROM filtered_table
    WHERE ST_Intersects(shape, (SELECT geom FROM circle_geometry))
)
SELECT ST_Area(ST_Union(buffered_geoms.surface)) AS surface_totale, ST_Area(ST_Union(buffered_geoms.surface))/circle_geometry.surface AS percentage
FROM buffered_geoms, circle_geometry
GROUP BY circle_geometry.surface;