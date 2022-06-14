CREATE EXTENSION IF NOT EXISTS MobilityDB CASCADE;

update quays set centroid_geom = ST_GEOMFROMGML(concat('<gml:Point srsName="EPSG:2154"><gml:pos>',centroid_val,'</gml:pos></gml:Point>'));

update stopPlaces set centroid_geom = ST_GEOMFROMGML(concat('<gml:Point srsName="EPSG:2154"><gml:pos>',centroid_val,'</gml:pos></gml:Point>'));

update scheduledStopPoints set location_geom = ST_GEOMFROMGML(concat('<gml:Point srsName="EPSG:2154"><gml:pos>',location_val,'</gml:pos></gml:Point>'));


insert into shape_geoms 
select st_makeLine(array_agg(ssp.location_geom ORDER BY pis.pointorder)) from pointsInSequence pis join scheduledStopPoints ssp on pis.id = ssp.id group by journeyPatternRef;
