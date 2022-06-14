CREATE EXTENSION IF NOT EXISTS MobilityDB CASCADE;

COPY calendar(service_id,monday,tuesday,wednesday,thursday,friday,saturday,sunday,
start_date,end_date) FROM '/tmp/Preparatory-work/GTFS-static/STIB/stib-gtfs/calendar.txt' DELIMITER ',' CSV HEADER;
COPY calendar_dates(service_id,date,exception_type)
FROM '/tmp/Preparatory-work/GTFS-static/STIB/stib-gtfs/calendar_dates.txt' DELIMITER ',' CSV HEADER;
COPY stop_times(trip_id,arrival_time,departure_time,stop_id,stop_sequence,
pickup_type,drop_off_type) FROM '/tmp/Preparatory-work/GTFS-static/STIB/stib-gtfs/stop_times.txt' DELIMITER ','
CSV HEADER;
COPY trips(route_id,service_id,trip_id,trip_headsign,direction_id,block_id,shape_id)
FROM '/tmp/Preparatory-work/GTFS-static/STIB/stib-gtfs/trips.txt' DELIMITER ',' CSV HEADER;
COPY agency(agency_id,agency_name,agency_url,agency_timezone,agency_lang,agency_phone)
FROM '/tmp/Preparatory-work/GTFS-static/STIB/stib-gtfs/agency.txt' DELIMITER ',' CSV HEADER;
COPY routes(route_id,route_short_name,route_long_name,route_desc,route_type,route_url,
route_color,route_text_color) FROM '/tmp/Preparatory-work/GTFS-static/STIB/stib-gtfs/routes.txt' DELIMITER ','
CSV HEADER;
COPY shapes(shape_id,shape_pt_lat,shape_pt_lon,shape_pt_sequence)
FROM '/tmp/Preparatory-work/GTFS-static/STIB/stib-gtfs/shapes.txt' DELIMITER ',' CSV HEADER;
COPY stops(stop_id,stop_code,stop_name,stop_desc,stop_lat,stop_lon,zone_id,stop_url,
location_type,parent_station) FROM '/tmp/Preparatory-work/GTFS-static/STIB/stib-gtfs/stops.txt' DELIMITER ','
CSV HEADER;