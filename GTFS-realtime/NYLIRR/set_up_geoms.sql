CREATE EXTENSION IF NOT EXISTS MobilityDB CASCADE;

ALTER TABLE vehicle_positions add column point geometry;
Update vehicle_positions SET point = ST_SetSRID(ST_MakePoint(longitude, latitude),4326);