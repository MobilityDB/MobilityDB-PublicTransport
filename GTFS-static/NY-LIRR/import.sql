CREATE EXTENSION IF NOT EXISTS MobilityDB CASCADE;

COPY agency(agency_id, agency_name, agency_url, agency_timezone, agency_lang, agency_phone)
FROM '/tmp/Preparatory-work/GTFS-static/NY-LIRR/new-york-gtfs/agency.txt' DELIMITER ',' CSV HEADER;

COPY calendar_dates(service_id, date, exception_type)
FROM '/tmp/Preparatory-work/GTFS-static/NY-LIRR/new-york-gtfs/calendar_dates.txt' DELIMITER ',' CSV HEADER;

COPY feed_info(feed_publisher_name, feed_publisher_url, feed_timezone, feed_lang, feed_version)
FROM '/tmp/Preparatory-work/GTFS-static/NY-LIRR/new-york-gtfs/feed_info.txt' DELIMITER ',' CSV HEADER;

COPY routes(route_id, route_short_name, route_long_name, route_type, route_color, route_text_color)
FROM '/tmp/Preparatory-work/GTFS-static/NY-LIRR/new-york-gtfs/routes.txt' DELIMITER ',' CSV HEADER;

COPY shapes(shape_id, shape_pt_lat, shape_pt_lon, shape_pt_sequence)
FROM '/tmp/Preparatory-work/GTFS-static/NY-LIRR/new-york-gtfs/shapes.txt' DELIMITER ',' CSV HEADER;

COPY stop_times(trip_id, arrival_time, departure_time, stop_id, stop_sequence)
FROM '/tmp/Preparatory-work/GTFS-static/NY-LIRR/new-york-gtfs/stop_times.txt' DELIMITER ',' CSV HEADER;

COPY stops(stop_id, stop_code, stop_name, stop_desc, stop_lat, stop_lon, stop_url, wheelchair_boarding)
FROM '/tmp/Preparatory-work/GTFS-static/NY-LIRR/new-york-gtfs/stops.txt' DELIMITER ',' CSV HEADER;

COPY trips(route_id, service_id, trip_id, trip_headsign, trip_short_name, direction_id, shape_id)
FROM '/tmp/Preparatory-work/GTFS-static/NY-LIRR/new-york-gtfs/trips.txt' DELIMITER ',' CSV HEADER;
