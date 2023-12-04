create extension postgis;
create extension postgis_raster;

select count(rid) from uk_250k;

drop table national_parks;

--6. Utwórz nową tabelę o nazwie uk_lake_district, gdzie zaimportujesz mapy rastrowe z
--punktu 1., które zostaną przycięte do granic parku narodowego Lake District.

create table uk_lake_district as
select ST_Clip(a.rast, b.geom, true)
from  uk_250k as a, national_parks as b
where ST_Intersects(a.rast, b.geom) 
and b.gid  = 1;

select st_srid(geom) from national_parks;

select * from uk_lake_district;

--7. Wyeksportuj wyniki do pliku GeoTIFF

SET postgis.gdal_enabled_drivers = 'ENABLE_ALL';

SELECT oid, lowrite(lo_open(oid, 27700), tiff) As num_bytes
FROM
( VALUES (lo_create(0),
ST_Astiff( (SELECT st_clip FROM uk_lake_district) )
) ) As v(oid,tiff);

SELECT lo_export(oid,'D:\PostgreSQL\zad8\my.tiff');

create table tmp_out as
SELECT lo_from_bytea(0,
ST_AsGDALRaster(ST_Union(st_clip), 'GTiff', ARRAY['COMPRESS=DEFLATE',
'PREDICTOR=2', 'PZLEVEL=9'])
) AS loid
FROM uk_lake_district;

SELECT lo_export(loid, 'D:\PostgreSQL\zad8\eksport.tiff')
FROM tmp_out;

drop table tmp_out;

select count(rid) from sentinel2_band3_1;

--#####################################################################################
--tu sie zacznie dziac
select * from sentinel2_band3_1;

create table green as SELECT ST_Union(ST_SetBandNodataValue(rast, NULL), 'MAX') rast
                      FROM (SELECT rast FROM sentinel2_band3_1
                        UNION ALL
                         SELECT rast FROM sentinel2_band3_2) foo;

create table nir as SELECT ST_Union(ST_SetBandNodataValue(rast, NULL), 'MAX') rast
                      FROM (SELECT rast FROM sentinel2_band8_1  
                        UNION ALL
                         SELECT rast FROM sentinel2_band8_2) foo;
select * from nir;

WITH r1 AS (
(SELECT ST_Union(ST_Clip(a.rast, ST_Transform(b.geom, 32630), true)) as rast
			FROM green AS a, national_parks AS b
			WHERE ST_Intersects(a.rast, ST_Transform(b.geom, 32630)) AND b.gid=1))
,
r2 AS (
(SELECT ST_Union(ST_Clip(a.rast, ST_Transform(b.geom, 32630), true)) as rast
	FROM nir AS a, national_parks AS b
	WHERE ST_Intersects(a.rast, ST_Transform(b.geom, 32630)) AND b.gid=1))

SELECT ST_MapAlgebra(r1.rast, r2.rast, '([rast1.val]-[rast2.val])/([rast1.val]+[rast2.val])::float', '32BF') AS rast
INTO ndwi FROM r1, r2;

CREATE TABLE tmp_out AS
SELECT lo_from_bytea(0,
       ST_AsGDALRaster(ST_Union(rast), 'GTiff',  ARRAY['COMPRESS=DEFLATE', 'PREDICTOR=2', 'PZLEVEL=9'])
        ) AS loid
FROM ndwi;

SELECT lo_export(loid, 'D:\PostgreSQL\zad8\ndwi.tiff')
FROM tmp_out;