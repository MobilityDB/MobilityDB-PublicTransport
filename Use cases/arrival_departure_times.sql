WITH train AS (
    SELECT *
    FROM trips_mdbrt
    WHERE trip_id = 'GO102_22_V4_1706' AND starttime = '2023-04-07 05:53:42'
    LIMIT 1
),
line_stops AS (
    SELECT DISTINCT stops.stop_id,
        stop_name,
        st.stop_sequence,
        st.arrival_time,
        st.departure_time,
        stops.stop_geom
    FROM train
    JOIN stop_times st ON st.trip_id = train.trip_id
    JOIN stops ON st.stop_id = stops.stop_id
    ORDER BY st.stop_sequence
),
train_points AS (
    SELECT
        (st_dumppoints(trip::geometry)).geom
    FROM train
),
distances AS (
    SELECT stop_id,
        stop_name,
        arrival_time,
        departure_time,
        st_distance(train_points.geom, line_stops.stop_geom),
        train_points.geom
    FROM train_points, line_stops
),
closest AS (
    SELECT d.stop_id,
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
SELECT DISTINCT stop_id,
    stop_name,
    startTimestamp(atGeometry(trip, c.geom)) AS real_arrival,
    endTimestamp(atGeometry(trip, c.geom)) AS real_departure,
    arrival_time,
    departure_time
FROM closest c, train
ORDER BY arrival_time;
