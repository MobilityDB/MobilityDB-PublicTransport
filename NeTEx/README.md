# NeTEx


To import NeTEx data in MobilityDB, we apply an extra step allowing us to convert it to GTFS. 
Currently, only NeTEx feeds with the [nordic specification](https://enturas.atlassian.net/wiki/spaces/PUBLIC/pages/728891481/Nordic+NeTEx+Profile)

## Requirements
- (Nordic specifications) [netex-gtfs-converter-java](https://github.com/entur/netex-gtfs-converter-java)
- (All specifications (EPIP)) Python >= 3.0

## User guide

### Nordic Specifications
The first step is to use NeTEx GTFS Converter to convert the feed into a GTFS feed.
Then, simply follow the steps for [GTFS](../GTFS%20Static/).





### EPIP Specifications

Start by running the NeTEx parser on an EPIP XML file. This will preprocess the file and extract the data as CSVs.

```bash
python3 netex_parser.py netex_epip_file.xml output_directory/
```

Then, you can run SQL scripts in the following order : 
- <code>create_tables.sql</code>
- <code>import_sql.sql</code>
- <code>transform.sql</code>

Following image represents the [Ruter](https://ruter.no/en/) NeTEx feed visualised with QGIS.

![oslo ruter](img/oslo%20ruter%20netex.png)