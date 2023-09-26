DROP TABLE IF EXISTS trips_mdbrt cascade;
CREATE TABLE trips_mdbrt (
		line_ref text NOT NULL,
		vehicle_ref text not null,
		trip tgeompoint,
        traj geometry
	);

INSERT INTO trips_mdbrt (
    line_ref,
	vehicle_ref,
    trip
)
SELECT 
    line_ref, 
    vehicle_ref, 
    tgeompoint_seq(array_agg(tgeompoint_inst(point_geom, recorded_at_time) ORDER BY recorded_at_time))
FROM siri_data
GROUP BY line_ref, vehicle_ref;

UPDATE trips_mdbrt
SET traj = trajectory(trip);