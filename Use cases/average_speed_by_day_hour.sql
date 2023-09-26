WITH th AS (
-- Average speed by starting hour (ST)
SELECT AVG(twavg(speed(trip))) AS static, date_trunc('hour',startTimestamp(trip)) AT time zone 'America/New_York' AS time
FROM Trips_mdb
GROUP BY time
ORDER BY time),

rt AS (
--Average speed by starting hour (RT)
SELECT AVG(twavg(speed(Trip))) as realtime, date_trunc('hour', startTimestamp(trip)) AT time zone 'America/New_York' AS time
FROM Trips_mdbrt
GROUP BY time
ORDER BY time)

SELECT realtime, static, rt.time FROM rt INNER JOIN th ON rt.time = th.time;

-- Average speed by starting day (ST)
WITH th AS (
  SELECT AVG(twavg(speed(Trip))) AS static, date_trunc('day',startTimestamp(Trip)) AT time zone 'America/New_York' AS time
FROM trips_mdb
GROUP BY time
ORDER BY time
),
rt AS (
--Average speed by starting day (RT)
SELECT AVG(twavg(speed(Trip))) AS realtime, date_trunc('day', starttime) AT time zone 'America/New_York' AS time
FROM Trips_mdbrt
WHERE starttime IS NOT null
GROUP BY time
ORDER BY time)

SELECT realtime, static, rt.time FROM rt INNER JOIN th ON rt.time = th.time;