package main

import (
	"fmt"
	"net/http"
	"io/ioutil"
	"database/sql"
	_ "github.com/lib/pq"
	"encoding/xml"
	"time"
)

const (
	host     = "localhost"
	port     = 5432
	user     = "postgres"
	password = "postgres"
	dbname   = "sirinorway"
)

const createTableSQL = `
DROP TABLE IF EXISTS siri_data;
CREATE TABLE IF NOT EXISTS siri_data (
	id SERIAL PRIMARY KEY,
	line_ref TEXT,
	vehicle_ref TEXT,
	direction_ref TEXT,
	dataframe_ref TEXT,
	dated_vehicle_journey_ref TEXT,
	origin_ref TEXT,
	destination_ref TEXT,
	published_line_name TEXT,
	latitude FLOAT,
	longitude FLOAT,
	recorded_at_time TIMESTAMP,
	valid_until TIMESTAMP,
	monitored BOOL,
	delay TEXT,
	point_geom GEOMETRY(Point, 4326)
);
`

// Definitions of SIRI fields
type SiriVehicleMonitoring struct {
	XMLName xml.Name `xml:"Siri"`
	VehicleActivities []SiriVehicleActivity `xml:"ServiceDelivery>VehicleMonitoringDelivery>VehicleActivity"`
}

type SiriVehicleActivity struct {
	RecordedAtTime string `xml:"RecordedAtTime"`
	ValidUntil string `xml:"ValidUntilTime"`
	MonitoredVehicleJourney MonitoredVehicleJourney `xml:"MonitoredVehicleJourney"`
}

type MonitoredVehicleJourney struct {
	LineRef string `xml:"LineRef"`
	VehicleRef string `xml:"VehicleRef"`
	DirectionRef string `xml:"DirectionRef"`
	OriginRef string `xml:"OriginRef"`
	DestinationRef string `xml:"DestinationRef"`
	PublishedLineName string `xml:"PublishedLineName"`
	VehicleLocation VehicleLocation `xml:"VehicleLocation"`
	FramedVehicleJourneyRef FramedVehicleJourneyRef `xml:"FramedVehicleJourneyRef"`
	JourneyPatternRef string `xml:"JourneyPatternRef"`
	Monitored bool `xml:"Monitored"`
	Delay string `xml:"Delay"`
}

type VehicleLocation struct {
	Longitude float64 `xml:"Longitude"`
	Latitude float64 `xml:"Latitude"`
}

type FramedVehicleJourneyRef struct {
	DataFrameRef string `xml:"DataFrameRef"`
	DatedVehicleJourneyRef string `xml:"DatedVehicleJourneyRef"`
}

func main() {
	dbinfo := fmt.Sprintf("host=%s port=%d user=%s password=%s dbname=%s sslmode=disable",
		host, port, user, password, dbname)
	db, err := sql.Open("postgres", dbinfo)
	if err != nil {
		panic(err)
	}
	defer db.Close()

	// Create table siri_data if it does not exist
	_, err = db.Exec(createTableSQL)
	if err != nil {
		panic(err)
	}

	for i := 0; i < 40; i++ {
		fmt.Printf("Query %v/40:\n", i+1)

		resp, err := http.Get("HTTP API GET URL")
		if err != nil {
			fmt.Println("Error while receiving the request:", err)
			return
		}
		defer resp.Body.Close()

		body, err := ioutil.ReadAll(resp.Body)
		if err != nil {
			fmt.Println("Error while reading the response:", err)
			return
		}

		// Check if body not empty
		if len(body) == 0 {
			fmt.Println("Empty response body ")
			continue
		}

		// XML parsing
		var siriData SiriVehicleMonitoring
		err = xml.Unmarshal(body, &siriData)
		if err != nil {
			fmt.Println("Error while parsing XML message:", err)
			continue
		}

		// Insertion loop
		for _, activity := range siriData.VehicleActivities {
			vehicle := activity.MonitoredVehicleJourney

			// Convert timestamp to time.Time format
			var recordedAtTime, validUntil time.Time
			if activity.RecordedAtTime != "" {
				recordedAtTime, err = time.Parse(time.RFC3339, activity.RecordedAtTime)
				if err != nil {
					fmt.Println("Erreur while converting timestamp RecordedAtTime:", err)
					return
				}
			}

			if activity.ValidUntil != "" {
				validUntil, err = time.Parse(time.RFC3339, activity.ValidUntil)
				if err != nil {
					fmt.Println("Error while converting timestamp ValidUntil:", err)
					return
				}
			}

			// Check if line already exists in database
			var count int
			err := db.QueryRow("SELECT COUNT(*) FROM siri_data WHERE line_ref=$1 AND vehicle_ref=$2 AND direction_ref=$3 AND origin_ref=$4 AND destination_ref=$5 AND published_line_name=$6 AND latitude=$7 AND longitude=$8 AND recorded_at_time=$9 AND valid_until=$10 AND monitored=$11 AND delay=$12",
				vehicle.LineRef, vehicle.VehicleRef, vehicle.DirectionRef, vehicle.OriginRef, vehicle.DestinationRef, vehicle.PublishedLineName, vehicle.VehicleLocation.Latitude, vehicle.VehicleLocation.Longitude, recordedAtTime, validUntil, vehicle.Monitored, vehicle.Delay).Scan(&count)
			if err != nil {
				fmt.Println("Erreur while checking duplicate line:", err)
				return
			}

			if count > 0 {
				continue
			}


			// Create geometry from latitude and longitude
			pointGeom := fmt.Sprintf("ST_SetSRID(ST_MakePoint(%f, %f), 4326)", vehicle.VehicleLocation.Longitude, vehicle.VehicleLocation.Latitude)



			// Insertion
			_, err = db.Exec(`INSERT INTO siri_data (line_ref, vehicle_ref, direction_ref, dataframe_ref, dated_vehicle_journey_ref, origin_ref, destination_ref, published_line_name, latitude, longitude, recorded_at_time, valid_until, monitored, delay, point_geom) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14,` + pointGeom + `)`,
			vehicle.LineRef, vehicle.VehicleRef, vehicle.DirectionRef, vehicle.FramedVehicleJourneyRef.DataFrameRef, vehicle.FramedVehicleJourneyRef.DatedVehicleJourneyRef, vehicle.OriginRef, vehicle.DestinationRef, vehicle.PublishedLineName, vehicle.VehicleLocation.Latitude, vehicle.VehicleLocation.Longitude, recordedAtTime, validUntil, vehicle.Monitored, vehicle.Delay)
			if err != nil {
				fmt.Println("Error while inserting in database:", err)
				return
			}			
		}

		time.Sleep(15 * time.Second)
	}
}
