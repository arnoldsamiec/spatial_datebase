create extension postgis;

create table obiekty(

	name varchar(30),
	geom geometry
);

insert into obiekty values(

'test', ST_GeomFromEWKT('SRID=4269;POLYGON((-71.1776585052917 42.3902909739571,-71.1776820268866 42.3903701743239,
-71.1776063012595 42.3903825660754,-71.1775826583081 42.3903033653531,-71.1776585052917 42.3902909739571))')
)

insert into obiekty values(

	'obiekt1', ST_GeomFromEWKT('SRID=0; CompoundCurve(LINESTRING(0 1,1 1),CIRCULARSTRING(1 1,2 0,3 1,4 2,5 1),LINESTRING(5 1,6 1))')
)

insert into obiekty values(

	'obiekt2', ST_GeomFromEWKT('SRID=0; CURVEPOLYGON(CompoundCurve(LINESTRING(10 2, 10 6, 14 6),CIRCULARSTRING(14 6, 16 4, 14 2, 12 0, 10 2)),CIRCULARSTRING(11 2, 13 2, 11 2))')
)--curvepolygon laczy dwa obiekty w jeden

insert into obiekty values(

	'obiekt3', ST_GeomFromEWKT('SRID=0; linestring(7 15, 10 17, 12 13, 7 15)')
) -- jest tez funkcja triangle

insert into obiekty values(

	'obiekt4', ST_GeomFromEWKT('SRID=0; linestring(20 20, 25 25, 27 24, 25 22, 26 21, 22 19, 20.5 19.5)')
)

insert into obiekty values(

	'obiekt5', ST_GeomFromEWKT('SRID=0; multipoint(30 30 59, 38 32 234)')
)

insert into obiekty values(

	'obiekt6', ST_GeomFromEWKT('GEOMETRYCOLLECTION(LINESTRING( 1 1, 3 2 ), POINT(4 2))')
)

select * from obiekty;

delete from obiekty
where name = 'test2';

--1.Wyznacz pole powierzchni bufora o wielkości 5 jednostek, który został utworzony wokół najkrótszej linii łączącej
--obiekt 3 i 4.
select name, st_curvetoline(geom) from obiekty
where name = 'obiekt3' or name = 'obiekt4';

select
ST_Area(ST_Buffer(ST_ShortestLine(obiekt3.geom, obiekt4.geom),5))
from obiekty as obiekt3, obiekty as obiekt4
where obiekt3.name = 'obiekt3' and obiekt4.name='obiekt4';

--2.Zamień obiekt4 na poligon. Jaki warunek musi być spełniony, aby można było wykonać to zadanie? Zapewnij te warunki.

select ST_IsClosed((ST_Dump(geom)).geom)
from obiekty
where name = 'obiekt4';

update obiekty
set
	geom = ST_MakePolygon(ST_LineMerge(ST_Union(geom, 'multilinestring((20.5 19.5, 20 20))')))
	where name = 'obiekt4';


--.3 W tabeli obiekty, jako obiekt7 zapisz obiekt złożony z obiektu 3 i obiektu 4.

insert into obiekty values

(
	'obiekt7', ST_Collect((select geom from obiekty where name = 'obiekt3'),(select geom from obiekty where name = 'obiekt4'))
);

--sprawdzenie
select name, st_curvetoline(geom) from obiekty

--4.Wyznacz pole powierzchni wszystkich buforów o wielkości 5 jednostek, które zostały utworzone wokół obiektów nie
--zawierających łuków.

select
sum(ST_Area(ST_Buffer(geom,5)))
from obiekty
where ST_HasArc(geom)=FALSE; -- - Returns true if a geometry or geometry collection contains a circular string.
