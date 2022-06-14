CREATE EXTENSION IF NOT EXISTS MobilityDB CASCADE;

CREATE TABLE vehicle_positions (
  trip_id text,
  vehicle_id text NOT NULL,
  latitude float NOT NULL,
  longitude float NOT NULL
);
