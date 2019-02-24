Libname nyc 'C:\Users\pvaradarajan\Documents\Business reporting tools\BusinessReportingTools-master\Group_assignment';

***/Evaluating the delays for the different airlines****/;
*/Finding the airline that had the maximum arrival delay/;
proc sql;
create table nyc.maxairline as
select name,avg(dep_delay) as Avgdep_delay,avg(arr_delay) as Avgarr_delay
from nyc.Airlines A, nyc.flights B
where A.carrier = B.carrier
AND Arr_delay > 0
group by 1
order by Avgarr_delay desc;
quit;

*/Finding the airline that arrived earlier/*;
proc sql;
create table nyc.fastairline as
select name,dep_delay,arr_delay
from nyc.Airlines A, nyc.flights B
where A.carrier = B.carrier
AND dep_delay NE .
AND arr_delay NE .
AND arr_delay < 0
order by 3;
quit;

*/Checking the departure delays for airlines that arrived on time/*;
proc sql;
create table nyc.airlineontime as
select name,dep_delay,arr_delay
from nyc.Airlines A, nyc.flights B
where A.carrier = B.carrier
AND Arr_delay = 0
AND dep_delay > 0
group by 1;
quit;

****/Evaluating the delays depending on the destination airports and distances/****;
*/Checking the relationship between destination and delays*/;
proc sql;
create table nyc.destdelay as
select dest,avg(arr_delay) as Avgarr_delay,avg(dep_delay) as Avgdep_delay
from  nyc.flights
group by 1
order by Avgarr_delay desc;
quit;

*/Checking the relationship between distance and delays*/;
proc sql;
create table nyc.distance as
select Distance,case when Distance <= 613 then "less than 614 km"
     when Distance between 614 and 1226 then "less than 1227 km"
     when Distance between 1227 and 1839 then "less than 1840 km"
     when Distance between 1840 and 2452 then "less than 2453 km"
            when Distance between 2453 and 3065 then "less than 3066 km"
            when Distance between 3066 and 3678 then "less than 3679 km"
            when Distance between 3679 and 4291 then "less than 4292 km"
          else  "less than 4984 km"   
          END as Distgroup,arr_delay,(dep_delay - arr_delay) as meddelay
from  nyc.flights
where Arr_delay > 0
group by 1;
quit;

****/Evaluating reasons for delays over Month,day and timeofday****/; 
*/Evaluating delays by Month*/; 
proc sql;
create table nyc.monthdelay as
select month,origin,arr_delay,dep_delay
from nyc.flights
order by 1 desc,2 desc;
quit;

*/Evaluating delays by day*/;
proc sql;
create table nyc.daydelay as
select day,arr_delay,dep_delay,origin 
from nyc.flights
order by 1 desc,2 desc;
quit;

*/Evaluating delays by timeofday/;
proc sql; 
create table nyc.hourdelay as
select hour, case when hour >= 5 and  hour <= 11 then 'morning' 
 when hour >= 12 and  hour <= 16 then 'noon'
 when hour >= 17 and  hour <= 21 then 'evening'
 else 'night' end as hour_cl, 
 arr_delay,dep_delay
from nyc.flights
group by hour_cl
order by 2;
run;
****/Finding the best and worst routes****/;
*/To find the top 5 worst routes*/;
proc sql outobs = 5;
create table nyc.worstroute as
select catx('-',origin,dest) as route,avg(arr_delay) as avg_delay
from nyc.flights
group by 1
order by 2 desc;
quit;
*/To find the top 5 best routes*/;
proc sql outobs = 5;
create table nyc.bestroute as
select catx('-',origin,dest) as route,avg(arr_delay) as avg_delay
from nyc.flights
group by 1
having avg(arr_delay)^= .
order by 2;
quit;

****Evaluating delays based on Aiports; 
proc sql ;
create table nyc.merg_airp as 
select distinct flight, origin, lat, lon, alt, month, day,dep_time, dep_delay ,arr_delay, distance, (dep_delay - arr_delay) as delay_diff
from nyc.airports as air Right outer join  nyc.flights as fl 
on air.faa = fl.origin
order by  9 descending ;
quit;

****Evaluating the reasons for delays based on weather conditions/; 
**Creating base table from weather data*/;
proc sql;
create Table NYC.weatheranalyse as 
select fl.origin, carrier, flight, temp , humid, wind_speed, precip, pressure, visib, arr_delay, dep_delay, fl.time_hour
from nyc.flights fl LEFT JOIN nyc.weather  w
on fl.origin = w.origin
AND fl.time_hour = w.time_hour
where temp ^= . ;
quit;

**Grouping the departure delay and evaluating weather conditions*;
proc sql; 
create Table NYC.weather_an_dep_delay as 
select case when dep_delay = 0 then 'on time'
 when dep_delay< 0 then 'early depature'
 when dep_delay between 1 and 30 then 'short delay'
 when dep_delay between 31 and 240 then 'medium delay'
 when dep_delay between 240 and 480 then 'long delay'
 when dep_delay between 480 and 720 then 'very long delay'
 ELSE  'delay for more than 1 day' End as Delay_Range,
	fl.origin, dep_delay,temp , humid, wind_speed,
	precip ,visib
 from nyc.flights fl LEFT JOIN nyc.weather  w
 on fl.origin = w.origin
 AND fl.time_hour = w.time_hour;
 quit;

*Evaluating weather conditions based on month*;
proc sql; _ done
create Table NYC.weather_an_month as 
select fl.month ,fl.origin, dep_delay,arr_delay,temp , humid, wind_speed,
precip ,visib
 from nyc.flights fl LEFT JOIN nyc.weather  w
 on fl.origin = w.origin
 AND fl.time_hour = w.time_hour
 group by  fl.origin, 1 ;
 quit;

***Evaluating delays based on planes***/;
*Basetable for planes and flights*;
proc sql; 
create table nyc.merged_planes as 
select pl.tailnum, pl.year, type, manufacturer, model, engine, seats,fl.carrier, arr_delay 
from nyc.planes pl inner join nyc.flights fl 
on pl.tailnum = fl.tailnum;

*Delays based on manufacturer*;
proc sql; 
create table nyc.merged_plan_manuf as 
select  manufacturer, avg(arr_delay) as avg_arr_delay
from nyc.planes pl inner join nyc.flights fl 
on pl.tailnum = fl.tailnum
group by manufacturer
order by 2 desc;

*Delays based on engine*;
proc sql; 
create table nyc.merged_plan_eng as 
select  engine, avg(arr_delay) as avg_arr_delay
from nyc.planes pl inner join nyc.flights fl 
on pl.tailnum = fl.tailnum
group by 1
order by 2 desc;

*Delays based on years of manufacture;
proc sql ; 
create table nyc.merged_plan_year_m as 
select  pl.year, avg(arr_delay) as avg_arr_delay
from nyc.planes pl inner join nyc.flights fl 
on pl.tailnum = fl.tailnum 
where pl.year ^= .
group by 1
having avg(arr_delay) >0 
order by 2 desc;

*Delays based on seats in the plane;
proc sql; 
create table nyc.merged_plan_SEATS as 
select  seats, case when seats <=15 then "less than 15" 
	  when seats >15 and seats<=50 then "less than 50"
	  when seats >50 and seats<=150 then "less than 150"
	when seats >150 and seats<=250 then "less than 250"
	when seats >250 and seats<=350 then "less than 350"
	when seats >350 and seats<=450 then "less than 450" end as SeatClass,
avg(arr_delay) as avg_arr_delay
from nyc.planes pl inner join nyc.flights fl 
on pl.tailnum = fl.tailnum
group by 1;

 