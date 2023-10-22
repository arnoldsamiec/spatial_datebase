create extension postgis;
create schema shapefile;

select * from popp;

create table tableB AS
select p.* from popp p
join majrivers on st_dwithin(p.geom, majrivers.geom, 1000)
where p.f_codedesc = 'Building';

select count(f_codedesc)
from tableB;
--select * from tableB_n;

--5.
--A.
create table airportsnew as
select name, geom, elev
from airports;

select * from airportsnew;

select name, ST_X(geom) as zachod
from airportsnew
order by zachod asc
limit 1;

select name, ST_X(geom) as wschod
from airportsnew
order by wschod desc
limit 1;

--B.
select * from airportsNew
where name = 'airportB';

insert into airportsNew (name, geom, elev) values -- funkcja st_lineInterpolatePoint
('airportTest',(select ST_LineInterpolatePoint(ST_MakeLine(
	(select geom from airportsnew order by ST_X(geom) asc limit 1),
				(select geom from airportsnew order by ST_X(geom) desc limit 1)), 0.5)),1000)
				
insert into airportsNew (name, geom, elev) values
('airportB',(select st_centroid(st_makeline(
	(select geom from airportsnew order by ST_X(geom) asc limit 1),
				(select geom from airportsnew order by ST_X(geom) desc limit 1)))),1000)

--6.

select st_area(st_buffer(st_shortestline(l.geom, a.geom), 1000))
from lakes l, airports a
where 
a.name = 'AMBLER' and l.names = 'Iliamna Lake'; --jeziora maja inny tytul nazwy(names), lotniska maja name
	

select * from airports;


--7. tabele shapefile:		tundra, trees, swamp

-- typy drzew sa w kolumnie vegdesc
select * from tundra; --pole jako area_km2
select * from trees; --pole jako area_km2
select * from swamp; --swamp jako jedyne maja kolumne pola areakm2

--2min 45sekund, funkcja st_coveredby
select vegdesc, sum(st_area(trees.geom)) from trees, tundra, swamp
where ST_CoveredBy(trees.geom, tundra.geom) or ST_CoveredBy(trees.geom, swamp.geom)
group by vegdesc
--46sekund kompiluje
select vegdesc, sum(st_area(trees.geom))
from trees, tundra, swamp
where ST_Within(trees.geom, tundra.geom) or St_Within(trees.geom, swamp.geom)
group by vegdesc


select vegdesc, sum(trees.area_km2)
from trees, tundra, swamp
where ST_Within(trees.geom, tundra.geom) or St_Within(trees.geom, swamp.geom)
group by vegdesc