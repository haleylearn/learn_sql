/*
DATASET
create table drivers(id varchar(10), start_time time, end_time time, start_loc varchar(10), end_loc varchar(10));

insert into drivers values('dri_1', '09:00', '09:30', 'a','b'),('dri_1', '09:30', '10:30', 'b','c'),('dri_1','11:00','11:30', 'd','e');
insert into drivers values('dri_1', '12:00', '12:30', 'f','g'),('dri_1', '13:30', '14:30', 'c','h');
insert into drivers values('dri_2', '12:15', '12:30', 'f','g'),('dri_2', '13:30', '14:30', 'c','h');

QUESTION: 
- Write query to print total rides and profit rides for each driver
- profit ride is when the end location of current ride is same as start location on next ride
*/

-- Solution 1:
with cte as (
	-- get table with sure arrange by id, start_time, end_time 
	select 
		row_number() over() as rn
		, drivers.*
	from drivers
	order by id, start_time, end_time 
)

select x1.id, x1.total_rides, ifnull(x2.profit, 0) as profit
from (
	-- get count quantity of ride of each driver
	select cte.id as id, count(cte.id) as total_rides
	from cte
	group by cte.id
) x1
left join (
	-- get count quantity of ride of each driver when has profit
	select c1.id as id, count(c1.id) as profit
	from cte as c1
	join cte as c2
	on c1.id = c2.id and c1.start_loc = c2.end_loc and c1.rn > c2.rn
	group by c1.id
	having count(c1.id)
) x2
on x1.id = x2.id;


-- Solution 2: 
	with cte_2 as (
		-- get table with sure arrange by id, start_time, end_time 
		select *
			, lead(start_loc, 1, 0) over(partition by id order by start_time asc) as next_start
		from drivers
	)
	
select id
	, count(1) as total_rides
	, sum(if(next_start=end_loc,1, 0)) as profit_rides
from cte_2
group by id

