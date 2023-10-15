create extension postgis;

create schema mapa;

--budynki, drogi, pkt info
create table mapa.budynki(id int primary key, geometria geometry, nazwa varchar(30));
create table mapa.drogi(id int primary key, geometria geometry, nazwa varchar(30)); 
create table mapa.pkt_info(id int primary key, geometria geometry, nazwa varchar(30)); 

--wstawianie danych do tabel

insert into mapa.budynki values
(1, st_geomfromtext('polygon((1 2, 2 2, 2 1, 1 1, 1 2))'), 'BuildingF'),
(2, st_geomfromtext('polygon((8 4, 10.5 4, 10.5 1.5, 8 1.5, 8 4))'), 'BuildingA'),
(3, st_geomfromtext('polygon((9 9, 10 9, 10 8, 9 8, 9 9))'), 'BuildingD'),
(4, st_geomfromtext('polygon((3 8, 5 8, 5 6, 3 6, 3 8))'), 'BuildingC'),
(5, st_geomfromtext('polygon((4 7, 6 7, 6 5, 4 5, 4 7))'), 'BuildingB');

insert into mapa.drogi values
(1, st_geomfromtext('linestring(7.5 10.5, 7.5 0)'), 'RoadY'),
(2, st_geomfromtext('linestring(0 4.5, 12 4.5)'), 'RoadX');

insert into mapa.pkt_info values
(1, st_geomfromtext('point(1 3.5)'), 'G'),
(2, st_geomfromtext('point(5.5 1.5)'), 'H'),
(3, st_geomfromtext('point(9.5 6)'), 'I'),
(4, st_geomfromtext('point(6.5 6)'), 'J'),
(5, st_geomfromtext('point(6 9.5)'), 'K');

--select * from mapa.pkt_info;

--1. calkowita dlugosc drog
select sum(st_length(geometria)) from mapa.drogi;

--2. wypisz geometrie, pole, obwod dla budynku BuildingA
select st_astext(geometria), st_area(geometria), st_perimeter(geometria) from mapa.budynki where nazwa = 'BuildingA';

--3. wypisz nazwy i pola wszystkich poligonow, posortuj alfabetycznie
select nazwa, st_area(geometria) from mapa.budynki
order by nazwa asc;

--4. wypisz nazwy i obwody, 2 budynkow o najwiekszych polach
select nazwa, st_perimeter(geometria) from mapa.budynki 
order by st_area(geometria) desc limit 2;

--5. 
select st_distance(budynki.geometria,pkt_info.geometria) from mapa.budynki, mapa.pkt_info
where budynki.nazwa = 'BuildingC' and pkt_info.nazwa='G';

--6. 
select st_area(budC.geometria)-st_area(st_intersection(st_buffer(budB.geometria, 0.5), budC.geometria))
from mapa.budynki budC, mapa.budynki budB
where budB.nazwa='BuildingB' and budC.nazwa='BuildingC';

--7.
select nazwa from mapa.budynki 
where st_y(st_centroid(geometria))>(select st_y(st_pointn(geometria,1)) 
from mapa.drogi where nazwa='RoadX');

--8. 
select
	st_area(st_difference(bud.geometria, st_geomfromtext('polygon((4 7, 6 7, 6 8, 4 8, 4 7))')))
	+st_area(st_difference(st_geomfromtext('polygon((4 7, 6 7, 6 8, 4 8, 4 7))'), bud.geometria))
from mapa.budynki bud
where bud.nazwa='BuildingC';
