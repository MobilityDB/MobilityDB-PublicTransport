WITH trainlines AS (
	SELECT routes.route_id, trip_id, route_long_name 
	FROM routes JOIN trips ON routes.route_id = trips.route_id
),
trip_distances as (
	SELECT bl.route_long_name AS line, ST_Length(shortestLine(trip, ST_SetSRID(ST_MakePoint(-73.9851, 40.7589),4326))) AS distance
    FROM trips_mdb AS st JOIN trainlines AS bl ON st.trip_id = bl.trip_id
    WHERE ST_Length(shortestLine(trip, ST_SetSRID(ST_MakePoint(-73.9851, 40.7589),4326))) < 200
)
SELECT line AS line_name, AVG(distance) as distance
FROM trip_distances
GROUP BY line
ORDER BY distance ASC;
