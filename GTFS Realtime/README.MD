# GTFS Realtime


To import GTFS Realtime data in MobilityDB, we first have to catch the data. We will use a script written in Golang to catch them, due to its efficiency.

## Requirements
- Golang >= 1.18
- (Optional but recommended) Having GTFS Static data in the database matching the dates of the realtime data.
- (Optional) Protobuf library for Go

## User guide

### Run server

First, adapt the <code>main.go</code> to ensure the connection to the database. Fill correctly the <code>const</code> with the database information.

```go
const (
    host     = "host"
    port     = port
    user     = "user"
    password = "password"
    dbname   = "dbname"
)
```

Then, fill correctly the URL and necessary headers to get the GTFS realtime feed.

```go
// Create new GET request
req, err := http.NewRequest("GET", "HTTP API GET URL", nil)
.
.
.
// Set API Key header if needed
// req.Header.Set("API KEY HEADER", "API KEY")
```

Finally the server can be run to catch realtime data.

```bash
go run main.go
```

### Transform to MobilityDB

Once the database is full of realtime positions, we can transform them for MobilityDB.

If the database is not populated by a corresponding GTFS Static feed, run <code>simple_transform.sql</code>. it will just connect all the positions ordered by the timestamp. This will lead to convenient but not precise results as described by the following picture. 

![Map matching problem](img/map%20matching%20problem.png)

In red are the catched positions of a train in New York, in blue the trajectory extracted from the static feed. And in orange the constructed trajectory. The built trajectory is not map-matched.

In the other case, if the GTFS Static feed is available in the database, run <code>precise_transform.sql</code>, it will use the static feed to create a precise trajectory. The light yellow trajectory in the next image corresponds to the realtime feed matched to the static.

![Solved map matching](img/solved%20map%20match.png)

Do not forget to replace the time zone in the scripts with the one you are observing.

The following visualisation shows the journey of a realtime catched train, and its theoretical trip extracted from the GTFS Static feed. In blue the theoretical train, and in red the train catched in realtime.

![](img/new%20york%20lirr%20run.gif)


## (Optional) Protobuf file

The current GTFS Realtime Protobuf specification schema is provided, as well as its compiled version for our Go server.

The compiled version can be obtained by running the proto compiler.
```
protoc -I=$SRC_DIR --go_out=$DST_DIR $SRC_DIR/gtfs.proto
```