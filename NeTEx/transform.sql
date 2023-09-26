CREATE TABLE trip_positions(
    trip_id text,
    stop_sequence int,
    no_stops int,
    route_id text,
    service_id text,
    stop_id text,
    arrival_time interval,
    perc float
);

INSERT INTO trip_positions (trip_id, stop_sequence, no_stops, route_id, service_id,
  stop_id, arrival_time)
(SELECT sj.id AS trip_id,
        pis.pointOrder AS stop_sequence,
        MAX(pis.pointOrder) OVER (PARTITION BY sj.id) AS no_stops, 
        l.id AS route_id,
        sj.id AS service_id,
        sp.id AS stop_id,
        pt.arrival_time
    FROM
        ServiceJourneys sj
    JOIN
        pointsInSequence pis ON sj.id = pis.journeyPatternRef
    JOIN
        lines l ON sj.ServiceJourneyPatternRef = l.id
    JOIN
        ScheduledStopPoints ssp ON pis.ScheduledStopPointRef = ssp.id
    JOIN
        passingTimes pt ON sj.id = pt.serviceJourneyRef
    JOIN
        stop_places sp ON ssp.quayID = sp.quayID

);


