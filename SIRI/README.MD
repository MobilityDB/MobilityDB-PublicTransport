# SIRI


To import SIRI data in MobilityDB, we first have to catch the data. We will use a script written in Golang to catch them, due to its efficiency.

## Requirements
- Golang >= 1.18
- (Optional but recommended) Having NeTEx data in the database matching the dates of the realtime data.

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

Then, fill correctly the URL and necessary headers to get the SIRI feed.

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

Run the script <code>simple_transform.sql</code> to build trajectories based on the positions only.

If a corresponding NeTEx feed is available in the database, a more precise trajectory can be built. But depending on how the data is imported (raw NeTEx or NeTEx convert to GTFS), the modus operandi can be different. 

In the case the imported NeTEx is from a conversion into GTFS, the matching is done on the GTFS field <code>trip_id</code> with the SIRI field <code>DatedVehicleJourneyRef</code>.

Just run the script <code>precise_transform.sql</code> in the case of having a NeTEx converted into GTFS Static feed in the database.