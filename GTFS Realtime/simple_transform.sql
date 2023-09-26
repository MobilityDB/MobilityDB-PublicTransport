DROP TABLE IF EXISTS trips_mdbrt;
CREATE TABLE trips_mdbrt (
    trip_id TEXT NOT NULL,
    vehicle_id TEXT NOT NULL,
    trip TGEOMPOINT,
    traj GEOMETRY,
    PRIMARY KEY (trip_id, vehicle_id)
);
DELETE FROM proto_vals
WHERE (tripid, id, timestamp) IN (
        SELECT tripid,
            id,
            timestamp
        FROM proto_vals
        GROUP BY tripid,
            id,
            timestamp
        HAVING COUNT(*) > 1
    )
    AND ctid NOT IN (
        SELECT MIN(ctid)
        FROM proto_vals
        GROUP BY tripid,
            id,
            timestamp
        HAVING COUNT(*) > 1
    );
INSERT INTO trips_mdbrt(trip_id, vehicle_id, trip)
SELECT tripid,
    id,
    tgeompoint_seq(
        array_agg(
            tgeompoint_inst(
                point,
                (
                    TO_TIMESTAMP(timestamp) AT TIME ZONE 'time/zone'
                )
            )
            ORDER BY timestamp
        )
    )
FROM proto_vals
GROUP BY tripid,
    id;
UPDATE trips_mdbrt
SET traj = trajectory(trip);