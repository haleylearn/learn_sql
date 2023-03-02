/*
	-->> Problem Statement:
    https://www.youtube.com/watch?v=WhkNQ3g0U64&t=439s
    Solving SQL Interview Query using a "VERY IMPORTANT SQL concept"
-->> Dataset:
drop table src_dest_dist;
create table src_dest_dist
(
    src         varchar(20),
    dest        varchar(20),
    distance    float
);
insert into src_dest_distance_2 values ('A', 'B', 21);
insert into src_dest_distance_2 values ('B', 'A', 28);
insert into src_dest_distance_2 values ('A', 'B', 19);
insert into src_dest_distance_2 values ('C', 'D', 15);
insert into src_dest_distance_2 values ('C', 'D', 17);
insert into src_dest_distance_2 values ('D', 'C', 16.5);
insert into src_dest_distance_2 values ('D', 'C', 18);


Write a SQL query to convert the given input into the expected output as shown below:

-- INPUT:
SRC         DEST        DISTANCE
Bangalore	Hyderbad	400
Hyderbad	Bangalore	400
Mumbai	    Delhi	    400
Delhi	    Mumbai	    400
Chennai	    Pune	    400
Pune        Chennai	    400

-- EXPECTED OUTPUT:
SRC         DEST        DISTANCE
Bangalore	Hyderbad	400
Mumbai	    Delhi	    400
Chennai	    Pune	    400
*/
select * from src_dest_distance;

-- Solution 1:
with cte as 
	(
		select * 
		, ROW_NUMBER() OVER() AS row_num  
		from src_dest_distance
    )
select * 
from cte t1
join cte t2
on t1.row_num < t2.row_num and t1.source = t2.destination;

-- Solution 2:
select 
	 distinct least(source, destination) as source_
	, greatest(source, destination) as destination_
    , distance
from src_dest_distance;


-- Solution 3:
with cte1 as 
  (
	select * , LAG(Source,1,0) OVER() as comp
	from src_dest_distance
  ) 
select source, destination, distance
from cte1
where source not in (select source
                     from cte1 
                     where destination = comp);



/*
	-->> Problem Statement:
Write SQL Query to find the average distance between the locations?

-- INPUT:
SRC       DEST    DISTANCE
A	      B	      21
B	      A	      28
A	      B	      19
C	      D	      15
C	      D	      17
D	      C	      16.5
D	      C	      18

-- EXPECTED OUTPUT:
SRC       DEST    DISTANCE
A	      B	      22.66
C	      D	      16.62
*/

with cte3 as 
	(
		select src, dest
        , sum(distance) as total_distance
        , count(1) as no_group
        , row_number() over() as row_num
		from src_dest_dist_2
		group by src, dest
	)

select t1.src, t1.dest, round((t1.total_distance + t2.total_distance) / (t1.no_group + t2.no_group), 2) as avg_distance
from cte3 t1
join cte3 t2
on t1.row_num < t2.row_num and t1.src = t2.dest;


