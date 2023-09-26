WITH trainlines AS (
	SELECT routes.route_id, trip_id, route_long_name 
	FROM routes JOIN trips ON routes.route_id = trips.route_id
)
SELECT NOW() AS "time", bl.route_long_name AS metric,
  AVG(EXTRACT(EPOCH FROM timespan(rt.trip))/60 - EXTRACT(EPOCH FROM timespan(st.trip))/60) as value
FROM trips_mdbrt as rt
  join trips_mdb as st on rt.trip_id = st.trip_id
  join trainlines as bl on rt.trip_id = bl.trip_id
GROUP BY route_long_name
ORDER BY value DESC;