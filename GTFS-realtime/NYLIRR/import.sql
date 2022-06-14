CREATE EXTENSION IF NOT EXISTS MobilityDB CASCADE;

COPY vehicle_positions(trip_id, vehicle_id, latitude, longitude
) FROM '/tmp/Preparatory-work/GTFS-realtime/NYLIRR/preprocessing/vehicle_positions.csv' DELIMITER ',' CSV HEADER;

