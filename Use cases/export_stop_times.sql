CREATE TABLE custom_stop_times AS (
    WITH line_stops AS (
        SELECT DISTINCT 
            st.trip_id,
            stops.stop_id,
            stop_name,
            st.stop_sequence,
            st.arrival_time,
            st.departure_time,
            stops.stop_geom
        FROM trips_mdbrt
        JOIN stop_times st ON st.trip_id = trips_mdbrt.trip_id
        JOIN stops ON st.stop_id = stops.stop_id
        ORDER BY st.stop_sequence
    ),
    train_points AS (
        SELECT
            (st_dumppoints(trip::geometry)).geom
        FROM trips_mdbrt
    ),
    distances AS (
        SELECT trip_id,
            stop_id,
            stop_name,
            arrival_time,
            departure_time,
            st_distance(train_points.geom, line_stops.stop_geom),
            train_points.geom
        FROM train_points, line_stops
    ),
    closest AS (
        SELECT d.trip_id,
            d.stop_id,
            d.stop_name,
            d.geom,
            d.st_distance,
            d.arrival_time,
            d.departure_time
        FROM distances d
        JOIN (
            SELECT stop_id,
                MIN(st_distance) AS min_distance
            FROM distances
            GROUP BY stop_id
        ) b ON d.stop_id = b.stop_id AND d.st_distance = b.min_distance
    )

    SELECT DISTINCT c.trip_id,
        stop_id,
        stop_name,
        startTimestamp(atGeometry(trip, c.geom)) AS arrival_time,
        endTimestamp(atGeometry(trip, c.geom)) AS departure_time
    FROM closest c JOIN (SELECT trip_id, trip from trips_mdbrt) t ON t.trip_id = c.trip_id 
    ORDER BY c.trip_id, arrival_time;
);

COPY custom_stop_times TO 'path/to/own/gtfs/stop_times.txt' DELIMITER ',' CSV HEADER;