ALTER TABLE proto_vals
ADD COLUMN no_seq INT DEFAULT 0;
UPDATE proto_vals AS p
SET no_seq = subquery.row_num
FROM (
        SELECT tripID,
            startdate,
            timestamp,
            ROW_NUMBER() OVER (
                PARTITION BY tripID,
                startdate
                ORDER BY timestamp
            ) AS row_num
        FROM proto_vals
    ) AS subquery
WHERE p.tripID = subquery.tripID
    AND p.startdate = subquery.startdate
    AND p.timestamp = subquery.timestamp;
DROP TABLE IF EXISTS trip_positions;
CREATE TABLE trip_positions (
    trip_id text,
    start_date date,
    stop_sequence integer,
    no_stops integer,
    route_id text,
    service_id text,
    shape_id text,
    stop_id text,
    arrival_time interval,
    perc float,
    point_geom geometry
);
INSERT INTO trip_positions (
        trip_id,
        start_date,
        stop_sequence,
        no_stops,
        route_id,
        service_id,
        shape_id,
        arrival_time,
        point_geom
    ) (
        SELECT t.tripid,
            to_date(startdate, 'YYYYMMDD'),
            no_seq,
            MAX(no_seq) OVER (PARTITION BY t.tripid),
            static_routes.route_id,
            service_id,
            shape_id,
            TO_CHAR((TO_TIMESTAMP(timestamp))::time, 'HH24:MI:SS')::interval,
            point
        FROM proto_Vals t
            JOIN (
                SELECT distinct trip_id,
                    route_id,
                    service_id,
                    shape_id
                FROM trips
            ) as static_routes on static_routes.trip_id = t.tripid
    );
UPDATE trip_positions t
SET perc = ST_LineLocatePoint(shape_geom, point_geom)
FROM shape_geoms g
WHERE t.shape_id = g.shape_id;
DELETE FROM trip_positions
WHERE (trip_id, start_date, stop_sequence) IN (
        SELECT trip_id,
            start_date,
            stop_sequence
        FROM trip_positions
        GROUP BY trip_id,
            start_date,
            stop_sequence
        HAVING COUNT(*) > 1
    )
    AND ctid NOT IN (
        SELECT MIN(ctid)
        FROM trip_positions
        GROUP BY trip_id,
            start_date,
            stop_sequence
        HAVING COUNT(*) > 1
    );
DROP TABLE IF EXISTS trip_segs;
CREATE TABLE trip_segs (
    trip_id text,
    route_id text,
    start_date date,
    service_id text,
    stop1_sequence integer,
    stop2_sequence integer,
    no_stops integer,
    shape_id text,
    stop1_arrival_time interval,
    stop2_arrival_time interval,
    perc1 float,
    perc2 float,
    seg_geom geometry,
    seg_length float,
    no_points integer,
    PRIMARY KEY (trip_id, stop1_sequence)
);
INSERT INTO trip_segs (
        trip_id,
        route_id,
        start_date,
        service_id,
        stop1_sequence,
        stop2_sequence,
        no_stops,
        shape_id,
        stop1_arrival_time,
        stop2_arrival_time,
        perc1,
        perc2
    ) WITH temp AS (
        SELECT t.trip_id,
            t.route_id,
            t.start_date,
            t.service_id,
            t.stop_sequence,
            LEAD(stop_sequence) OVER w AS stop_sequence2,
            MAX(stop_sequence) OVER (PARTITION BY trip_id),
            t.shape_id,
            t.arrival_time,
            LEAD(arrival_time) OVER w,
            t.perc,
            LEAD(perc) OVER w
        FROM trip_positions t WINDOW w AS (
                PARTITION BY trip_id
                ORDER BY stop_sequence
            )
    )
SELECT *
FROM temp
WHERE stop_sequence2 IS NOT null;
UPDATE trip_segs t
SET seg_geom = (
        CASE
            WHEN perc1 > perc2 THEN seg_geom
            ELSE ST_LineSubstring(shape_geom, perc1, perc2)
        END
    )
FROM shape_geoms g
WHERE t.shape_id = g.shape_id;
UPDATE trip_segs t
SET seg_length = ST_Length(seg_geom),
    no_points = ST_NumPoints(seg_geom);
DROP TABLE IF EXISTS trip_points;
CREATE TABLE trip_points (
    trip_id text,
    route_id text,
    start_date date,
    service_id text,
    stop1_sequence integer,
    point_sequence integer,
    point_geom geometry,
    point_arrival_time interval,
    PRIMARY KEY (trip_id, stop1_sequence, point_sequence)
);
INSERT INTO trip_points (
        trip_id,
        route_id,
        start_date,
        service_id,
        stop1_sequence,
        point_sequence,
        point_geom,
        point_arrival_time
    ) WITH temp1 AS (
        SELECT trip_id,
            route_id,
            start_date,
            service_id,
            stop1_sequence,
            stop2_sequence,
            no_stops,
            stop1_arrival_time,
            stop2_arrival_time,
            seg_length,
            (dp).path [1] AS point_sequence,
            no_points,
            (dp).geom as point_geom
        FROM trip_segs,
            ST_DumpPoints(seg_geom) AS dp
    ),
    temp2 AS (
        SELECT trip_id,
            route_id,
            start_date,
            service_id,
            stop1_sequence,
            stop1_arrival_time,
            stop2_arrival_time,
            seg_length,
            point_sequence,
            no_points,
            point_geom
        FROM temp1
        WHERE (
                point_sequence <> no_points
                OR stop2_sequence = no_stops
            )
            and temp1.seg_length <> 0
    ),
    temp3 AS (
        SELECT trip_id,
            route_id,
            start_date,
            service_id,
            stop1_sequence,
            stop1_arrival_time,
            stop2_arrival_time,
            point_sequence,
            no_points,
            point_geom,
            ST_Length(ST_Makeline(array_agg(point_geom) OVER w)) / seg_length AS perc
        FROM temp2 WINDOW w AS (
                PARTITION BY trip_id,
                service_id,
                stop1_sequence
                ORDER BY point_sequence
            )
    )
SELECT trip_id,
    route_id,
    start_date,
    service_id,
    stop1_sequence,
    point_sequence,
    point_geom,
    CASE
        WHEN point_sequence = 1 then stop1_arrival_time
        WHEN point_sequence = no_points then stop2_arrival_time
        ELSE stop1_arrival_time + ((stop2_arrival_time - stop1_arrival_time) * perc)
    END AS point_arrival_time
FROM temp3;
DROP TABLE IF EXISTS trips_input;
CREATE TABLE trips_input (
    trip_id text,
    route_id text,
    service_id text,
    date date,
    point_geom geometry,
    t timestamptz
);
INSERT INTO trips_input
SELECT trip_id,
    route_id,
    t.service_id,
    start_date,
    point_geom,
    start_date + point_arrival_time AS t
FROM trip_points t;
CREATE INDEX idx_trips_input ON trips_input (trip_id, route_id, t);
DROP TABLE IF EXISTS trips_mdb;
CREATE TABLE trips_mdbrt (
    trip_id text NOT NULL,
    route_id text NOT NULL,
    date date NOT NULL,
    trip tgeompoint,
    PRIMARY KEY (trip_id, date)
);
INSERT INTO trips_mdbrt(trip_id, route_id, date, trip)
SELECT trip_id,
    route_id,
    date,
    tgeompoint_seq(
        array_agg(
            tgeompoint_inst(point_geom, t at time zone 'time/zone')
            ORDER BY T
        )
    )
FROM trips_input
GROUP BY trip_id,
    route_id,
    date;
ALTER TABLE trips_mdbrt
ADD COLUMN traj geometry;
UPDATE trips_mdbrt
SET Traj = trajectory(Trip);
ALTER TABLE trips_mdbrt
ADD COLUMN starttime timestamp;
UPDATE trips_mdbrt
SET starttime = startTimestamp(trip);