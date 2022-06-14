# Preparatory work for master thesis
This repository will store all the necessary code to reproduce the import/export for mobility data exchange standards
into MobilityDB.

## Requirements

* MobilityDB
* Python >= 3.0
* Protobuf Python version

## Raw data files

The files used in this tutorial are available on these links:
* GTFS static STIB : https://transitfeeds.com/p/mta/86
* GTFS static NY-LIRR : https://transitfeeds.com/p/mta/86
* GTFS realtime NY-LIRR : https://transitfeeds.com/p/mta/421
* NeTEx STIB : https://www.transportdata.be/fr/dataset/stib-mivb-netex/resource/4a733029-9ef9-4fd5-b3df-d4ab42ba1a9c

All the files are also directly available in the project, except for the NeTEx file, which is too large for being uploaded.

For this tutorial, we assume that all the content of this repository is extracted in <code>/tmp/Preparatory-work/</code>
## GTFS Static

To import GTFS static data, we only use SQL statements. This part is in three parts :

* Create the necessary tables to host the data by running <code>create_tables.sql</code>
* Import the data with <code>import.sql</code>
* Finally, we set up the geometries to visualize them with <code>set_up_geoms.sql</code>.

![image info](./GTFS-static/NY-LIRR/GTFS%20visualization.png)

## GTFS Real-time

To import GTFS-realtime raw data we have to generate the CSV file from the text file with the <code>generate_rt_csv.py</code> script.

Then to import into MobilityDB, we just have to follow the same steps as GTFS-static.
The visualization for the vehicle positions should look like this.

![image info](./GTFS-realtime/vehicle%20positions%20visualization.png)

## NeTEx

A first step of preprocessing is necessary to convert the XML NeTEx file into a collection of CSV files by running 
<code>generate_netex_csv.py</code>.

Then we create the tables, import the data and set up the geometries.

![image info](NeTEx/NeTEx%20visualization.png)
