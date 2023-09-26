package main

import (
    "fmt"
    "net/http"
	"io/ioutil"
	"database/sql"
	_ "github.com/lib/pq"

	"time"

	"github.com/golang/protobuf/proto"
	gtfs "gtfs/catcher/transit_realtime" // Import gtfs.pb.go
)


const (
    host     = "host"
    port     = 'port'
    user     = "user"
    password = "password"
    dbname   = "dbname"
)

func main() {

	dbinfo := fmt.Sprintf("host=%s port=%d user=%s password=%s dbname=%s sslmode=disable",
        host, port, user, password, dbname)
    db, err := sql.Open("postgres", dbinfo)
    if err != nil {
        panic(err)
    }
    defer db.Close()

	// Create table if not exists
    _, err = db.Exec(`
	CREATE TABLE IF NOT EXISTS proto_vals (
		tripId text,
		startTime text,
		startDate text,
		routeId text,
		id text,
		label text,
		licensePlate text,
		latitude float,
		longitude float,
		directionId text,
		bearing float,
		speed float,
		odometer float,
		currentStatus text,
		stopId text,
		timestamp bigint,
		congestionLevel text,
		occupancyStatus text,
		currentStopSequence int,
		point geometry
);`)

	for i := 0; i < 20; i++ {
		fmt.Println("Query %v/40:", i+1)
		// Create new GET request
		//req, err := http.NewRequest("GET", "HTTP GET URL", nil)
		
		if err != nil {
			fmt.Println("Error while creating the request:", err)
			return
		}
		// Set API Key header if needed
		//req.Header.Set("API KEY HEADER", "API KEY")
		
		
		// Send GET request
		client := &http.Client{}
		resp, err := client.Do(req)
		if err != nil {
			fmt.Println("Error while sending request:", err)
			return
		}
		defer resp.Body.Close()

		// Read response
		body, err := ioutil.ReadAll(resp.Body)
		if err != nil {
			fmt.Println("Error while reading the response:", err)
			return
		}

		// Decode message
		feed := &gtfs.FeedMessage{}
		err = proto.Unmarshal(body, feed)
		if err != nil {
			fmt.Println("Error while decoding protobuf message:", err)
			return
		}

		
		//Data insertion loop
		for _, p := range feed.Entity {
			
			if p.Vehicle != nil && p.Vehicle.Trip != nil && p.Vehicle.Vehicle != nil {
				
				vehicle := p.GetVehicle()
				// Check if a position with the same values already exists in the Positions table
				var count int		
				err := db.QueryRow("SELECT COUNT(*) FROM proto_vals WHERE id=$1 AND tripid=$2 AND timestamp=$3 AND latitude=$4 AND longitude=$5 AND bearing=$6 AND speed=$7 AND odometer=$8 AND currentstatus=$9 AND stopid=$10 AND congestionlevel=$11 AND occupancystatus=$12 AND currentstopsequence=$13",
					*vehicle.Vehicle.Id, *vehicle.Trip.TripId,  *vehicle.Timestamp, vehicle.Position.Latitude, vehicle.Position.Longitude, vehicle.Position.Bearing, vehicle.Position.Speed, vehicle.Position.Odometer, vehicle.CurrentStatus, vehicle.StopId, vehicle.CongestionLevel, vehicle.OccupancyStatus, vehicle.CurrentStopSequence).Scan(&count)
				if err != nil {
					panic(err)
				}
				if count > 0 {
					// line already exists
					continue
				}
		
		
				// If a position with the same values doesn't exist, insert the new position into the Positions table
				_, err = db.Exec(`INSERT INTO proto_vals(tripId, startTime, startDate, routeId, id, label, licensePlate, latitude, longitude, bearing, speed, odometer, currentStatus, stopId, timestamp, congestionLevel, occupancyStatus, currentStopSequence, point) 
					VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, ST_SetSRID(ST_MakePoint($9, $8), 4326))`,
					vehicle.Trip.TripId, vehicle.Trip.StartTime, vehicle.Trip.StartDate, vehicle.Trip.RouteId, vehicle.Vehicle.Id, vehicle.Vehicle.Label, vehicle.Vehicle.LicensePlate, vehicle.Position.Latitude, vehicle.Position.Longitude, vehicle.Position.Bearing, vehicle.Position.Speed, vehicle.Position.Odometer, vehicle.CurrentStatus, vehicle.StopId, vehicle.Timestamp, vehicle.CongestionLevel, vehicle.OccupancyStatus, vehicle.CurrentStopSequence)
				if err != nil {
					panic(err)
				}
			}		
		}
		
		time.Sleep(15 * time.Second)
	}
}
