CREATE EXTENSION IF NOT EXISTS MobilityDB CASCADE;

CREATE TABLE agency (
    agency_id text DEFAULT '',
    agency_name text DEFAULT NULL,
    agency_url text DEFAULT NULL,
    agency_timezone text DEFAULT NULL,
    agency_lang text DEFAULT NULL,
    agency_phone text DEFAULT NULL,
    CONSTRAINT agency_pkey PRIMARY KEY (agency_id)
);

CREATE TABLE exception_types (
    exception_type int PRIMARY KEY,
    description text
);
CREATE TABLE calendar_dates (
    service_id text,
    date date NOT NULL,
    exception_type int REFERENCES exception_types(exception_type)
);
CREATE INDEX calendar_dates_dateidx ON calendar_dates (date);

CREATE TABLE feed_info (
    feed_publisher_name text DEFAULT '',
    feed_publisher_url text DEFAULT NULL,
    feed_timezone text DEFAULT NULL,
    feed_lang text DEFAULT NULL,
    feed_version text DEFAULT NULL
);

CREATE TABLE route_types (
    route_type int PRIMARY KEY,
    description text
);
CREATE TABLE routes (
    route_id text,
    route_short_name text DEFAULT '',
    route_long_name text DEFAULT '',
    route_type int REFERENCES route_types(route_type),
    route_color text,
    route_text_color text,
CONSTRAINT routes_pkey PRIMARY KEY (route_id)
);

CREATE TABLE shapes (
    shape_id text NOT NULL,
    shape_pt_lat double precision NOT NULL,
    shape_pt_lon double precision NOT NULL,
    shape_pt_sequence int NOT NULL
);
CREATE INDEX shapes_shape_key ON shapes (shape_id);
-- Create a table to store the shape geometries
CREATE TABLE shape_geoms (
    shape_id text NOT NULL,
    shape_geom geometry('LINESTRING', 4326),
    CONSTRAINT shape_geom_pkey PRIMARY KEY (shape_id)
);
CREATE INDEX shape_geoms_key ON shapes (shape_id);

CREATE TABLE stop_times (
    trip_id text NOT NULL,
    -- Check that casting to time interval works.
    arrival_time interval CHECK (arrival_time::interval = arrival_time::interval),
    departure_time interval CHECK (departure_time::interval = departure_time::interval),
    stop_id text,
    stop_sequence int NOT NULL,
    CONSTRAINT stop_times_pkey PRIMARY KEY (trip_id, stop_sequence)
);
CREATE INDEX stop_times_key ON stop_times (trip_id, stop_id);
CREATE INDEX arr_time_index ON stop_times (arrival_time);
CREATE INDEX dep_time_index ON stop_times (departure_time);

CREATE TABLE stops (
    stop_id text,
    stop_code text,
    stop_name text DEFAULT NULL,
    stop_desc text DEFAULT NULL,
    stop_lat double precision,
    stop_lon double precision,
    stop_url text,
    stop_geom geometry('POINT', 4326),
    wheelchair_boarding int,
    CONSTRAINT stops_pkey PRIMARY KEY (stop_id)
);

CREATE TABLE trips (
    route_id text NOT NULL,
    service_id text NOT NULL,
    trip_id text NOT NULL,
    trip_headsign text,
    trip_short_name text,
    direction_id int,
    shape_id text,
    CONSTRAINT trips_pkey PRIMARY KEY (trip_id)
);
CREATE INDEX trips_trip_id ON trips (trip_id);

INSERT INTO exception_types (exception_type, description) VALUES
(1, 'service has been added'),
(2, 'service has been removed');

INSERT INTO route_types(route_type, description) VALUES 
(0, 'tram, streetcar, light rail'),
(1, 'subway, metro'),
(2, 'rail'),
(3, 'bus'),
(4, 'ferry'),
(5, 'cable tram'),
(6, 'aerial lift, suspended cable car'),
(7, 'funicular'),
(11, 'trolleybus'),
(12, 'monorail');
