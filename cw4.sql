create extension postgis;

select *, ST_Astext(geom) from t2019_kar_buildings
where polygon_id = '793349190';

--1. rozna wysokosc, rozna geometria
create table nowe_bud as
select bud2019.* from t2019_kar_buildings bud2019
left join t2018_kar_buildings bud2018 on bud2019.polygon_id = bud2018.polygon_id
where bud2019.height != bud2018.height
or ST_Equals(bud2019.geom, bud2018.geom) = false;

--2.
select type, count(poi_id) from t2019_kar_poi_table bud2019
group by type;
--where poi_name = 'Turmberg';

create table nowe_bud_poi as
select poi2019.* from t2019_kar_poi_table poi2019
left join t2018_kar_poi_table poi2018 on poi2019.poi_id = poi2018.poi_id
where ST_Equals(poi2019.geom, poi2018.geom) = false;

select nowe_poi.type, count(nowe_poi.poi_id) from nowe_bud_poi nowe_poi, nowe_bud 
where ST_DWithin(nowe_poi.geom, nowe_bud.geom, 500) = TRUE --st_dwithin szybciej niz within
group by nowe_poi.type;

select nowe_poi.type, count(nowe_poi.poi_id) from nowe_bud_poi nowe_poi, nowe_bud 
where ST_Within(nowe_poi.geom, ST_Buffer(nowe_bud.geom, 500))
group by nowe_poi.type;

--3.
create table streets_reprojected as
select
    ST_Transform(geom, 3068), -- 3068 to kod dla DHDN.Berlin/Cassini
    * from T2019_KAR_STREETS;
	
select st_srid(st_transform) from streets_reprojected;

--4.
create table input_points (
    id int primary key,
    geom geometry
);

insert input_points values
    ('1', ST_SetSRID(ST_MakePoint(8.36093, 49.03174), 4326)), --podobna funkcja to st_point, szybciej dzialaja niz st_geomfromtext
    ('2', ST_SetSRID(ST_MakePoint(8.39876, 49.00644), 4326));
	
select st_astext(geom) from input_points;

--5.
update input_points
set geom = ST_Transform(geom, 3068);

-- Wyświetlenie zaktualizowanych współrzędnych za pomocą funkcji ST_AsText()
select id, ST_AsText(geom) from input_points;

--6.
select st_srid(geom) from input_points;
--For geometry: The distance is specified in units defined by the spatial reference system of the geometries. 
--For this function to make sense, the source geometries must be in the same coordinate system (have the same SRID).

update input_points
set geom = ST_Transform(geom, 4326);

--select * from t2019_kar_street_node where st_buffer(ST_MakeLine(geom), 200);

select count(gid) from t2019_kar_street_node street
where ST_DWithin(street.geom, ST_MakeLine(
	(select geom from input_points where id='1'), (select geom from input_points where id='2')), 200, true);
	
--7.
select * from t2019_kar_land_use_a;

select count(sportshop.gid) from
t2019_kar_poi_table as sportshop,
t2019_kar_land_use_a as parks
where sportshop.type = 'Sporting Goods Store'
and parks.type = 'Park (City/County)'
and ST_DWithin(sportshop.geom, parks.geom, 300, true);

--8.

create table t2019_kar_bridges as
select ST_Intersection(woda.geom, tory.geom) as geom
from t2019_kar_water_lines woda, t2019_kar_railways tory
where
st_intersects(woda.geom, tory.geom);--&&(woda.geom, tory.geom); nie znajduje tego operatora
									-- && = to samo co st_intersects()
select count(geom) from t2019_kar_bridges;