This repository will store all the necessary code to import, export and use mobility data exchange standards with MobilityDB.

This work is the result of the research for my master thesis that can be found [here](Master_thesis_Iliass_Public_Transports.pdf).

## Requirements

- MobilityDB 1.1
- Other requirements depending on the standard

## Public Transport Standards

A wide range of mobility standards exist, enabling the exchange of timetables and information on the topology of public transport networks.
These include the well-known GTFS Static and Realtime, as well as more local standards such as NeTEx and SIRI in Europe.

This repository first explains how to import these types of data into MobilityDB (refer to the READMEs available in the corresponding folders). This is followed by a Use Cases section which shows what uses can be made of this data using MobilityDB.

## Use Cases

The following are some examples of the Use Cases we have developed. More informations and details are provided in the master's thesis and in the [use cases' directory](Use%20Cases/). The visualisations are obtained using [MOVE](https://github.com/mschoema/move) but any other visualisation tool compatible with MobilityDB can be used. With MOVE, the moving objects are obtained with the following query :

```SQL
SELECT trip FROM trips_mdb;
```
Conditions can be added to extract any specific data depending on your study.

### Dynamic Visualisation of Delays by Line
Using a dynamic visualisation tool for MobilityDB like MOVE on QGIS allows to watch the different public transports runs. The following visualisation shows the journey of a realtime catched train, and its theoretical trip extracted from the GTFS Static feed. In blue the theoretical train, and in red the train catched in realtime.

![](GTFS%20Realtime/img/new%20york%20lirr%20run.gif)

### Compute Static and Realtime Arrival and Departure Times

This query compute the arrival and departure times at each stop for a given trip. The potential delays can be therefore estimated.

![](Use%20cases/img/arrival-departures.png)

### Average Speed of Vehicles by Day or Hour

This queries compute the average speed of our vehicles. Here average speed of New York buses.

![](./Use%20cases/img/grafana%20avg%20speed%20buses.png)
