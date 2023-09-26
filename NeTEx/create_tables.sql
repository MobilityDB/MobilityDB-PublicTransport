CREATE EXTENSION MobilityDB CASCADE;
-- Quays
Create Table Quays(
    id text,
    name text,
    centroid_val text,
    centroid_geom geometry('POINT', 2154),
    stop_place_ref text,
    CONSTRAINT quays_pkey PRIMARY KEY (id)
);
-- Lines
Create Table Lines(
    id text,
    name text,
    transportMode text,
    publicCode text,
    CONSTRAINT lines_pkey PRIMARY KEY (id)
);
-- Stop Places
Create Table StopPlaces(
    id text,
    name text,
    centroid_val text,
    transportMode text,
    stopPlaceType text,
    quayID text REFERENCES Quays(id),
    centroid_geom geometry('POINT', 2154),
    CONSTRAINT stop_places_pkey PRIMARY KEY (id)
);
-- ScheduledStopPoints
Create Table ScheduledStopPoints(
    id text,
    location_val text,
    location_geom geometry('POINT', 2154),
    CONSTRAINT sch_stop_points_pkey PRIMARY KEY (id)
);
-- StopAssignments
Create Table StopAssignments(
    id text,
    stopAssOrder text,
    ScheduledStopPointRef text REFERENCES ScheduledStopPoints(id),
    StopPlaceRef text REFERENCES StopPlaces(id),
    quayRef text
);
-- journeyPatterns
Create Table journeyPatterns(
    id text,
    distance integer,
    CONSTRAINT journey_pat_pkey PRIMARY KEY (id)
);
-- pointsInSequence
Create Table pointsInSequence(
    id text,
    pointOrder int,
    ScheduledStopPointRef text REFERENCES ScheduledStopPoints(id),
    forAlighting integer,
    forBoarding integer,
    journeyPatternRef text REFERENCES journeyPatterns(id)
);
-- operators
Create table Operators(
    id text,
    name text,
    phone text,
    url text,
    organisationType text,
    CONSTRAINT operators_pkey PRIMARY KEY (id)
);
-- Date Types
Create Table DayTypes(
    id text,
    CONSTRAINT daytypes_pkey PRIMARY KEY (id)
);
-- Service Journeys
Create Table ServiceJourneys(
    id text,
    dayTypeRef text REFERENCES DayTypes(id),
    ServiceJourneyPatternRef text,
    operatorRef text REFERENCES operators(id),
    CONSTRAINT serv_journ_pkey PRIMARY KEY (id)
);
-- Passing Times
Create Table passingTimes(
    arrival_time text,
    arrival_dayOffset integer,
    departure_time text,
    departure_dayOffset integer,
    serviceJourneyRef text REFERENCES ServiceJourneys(id)
);
-- Create a table to store the shape geometries
CREATE TABLE shape_geoms (shape_geom geometry('LINESTRING', 2154));