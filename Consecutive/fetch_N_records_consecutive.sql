/*
https://www.youtube.com/watch?v=8p_OzqIJ_p4&ab_channel=techTFQ
https://techtfq.com/blog/learn-how-to-write-sql-queries-practice-complex-sql-queries
*/

use db_assignment;

select * from weather;

/*
10. SQL Query to fetch “N” consecutive records from a table based on a certain condition
Note: Write separate queries to satisfy following scenarios:

10a. when the table has a primary key -- SQL Query to fetch N consecutive records when emperature below 0

10b. When table does not have a primary key

10c. Query logic based on data field

*/

-- 10a. when the table has a primary key -- SQL Query to fetch N consecutive records when emperature below 0
with t1 as (
	select *
		, row_number() over(order by id) as rn
		, id - row_number() over(order by id) as difference
	from weather 
	where temperature < 0
)
	, t2 as (
    select *
		, count(*) over(partition by difference) as no_of_record
    from t1
)

select * 
from t2
where no_of_record = 3;

-- Query 10b: Finding n consecutive records where temperature is below zero. And table does not have primary key.
with 
	t1w2 as (
		select *
			, row_number() over(order by day asc) as id
        from weather2
    ),
	t2w2 as (
		select *
			, row_number() over(order by id) as rn
			, id - row_number() over(order by id) as difference
		from t1w2 
		where temperature < 0
	),
	t3w2 as (
		select *
			, count(*) over(partition by difference) as no_of_record
		from t2w2
	)

select * 
from t3w2
where no_of_record = 3;


-- Query 10c: Finding n consecutive records with consecutive date value.
with 
	cte1 as (
		select * 
			, row_number() over(order by order_id) as rn
			, date_sub(order_date, interval row_number() over(order by order_id) day) as difference
		from order_test
    ),
    cte2 as (
		select * 
			, count(*) over(partition by difference) as no_of_records
		from cte1
    )
select * 
from cte2
where no_of_records = 3;
    
/*
create table login_details(
login_id int primary key,
user_name varchar(50) not null,
login_date date);

insert into login_details values
(101, 'Michael', current_date),
(102, 'James', current_date),
(103, 'Stewart', current_date+1),
(104, 'Stewart', current_date+1),
(105, 'Stewart', current_date+1),
(106, 'Michael', current_date+2),
(107, 'Michael', current_date+2),
(108, 'Stewart', current_date+3),
(109, 'Stewart', current_date+3),
(110, 'James', current_date+4),
(111, 'James', current_date+4),
(112, 'James', current_date+5),
(113, 'James', current_date+6);

From the login_details table, fetch the users who logged in consecutively 3 or more times.
*/

use db_assignment;

select distinct x.repeat_user
from (
	select *
		, case
			when user_name = lead(user_name,1) over(order by login_id) and user_name = lead(user_name,2) over(order by login_id)
				then user_name else null
			end as repeat_user
	from login_details
) x
where x.repeat_user is not null;

/*
create table weather3
(
id int,
city varchar(50),
temperature int,
day date
);    

insert into weather3 values
(1, 'London', -1, cast('2021-01-01' as date)),
(2, 'London', -2, cast('2021-01-02'as date)),
(3, 'London', 4, cast('2021-01-03'as date)),
(4, 'London', 1, cast('2021-01-04'as date)),
(5, 'London', -2, cast('2021-01-05'as date)),
(6, 'London', -5, cast('2021-01-06'as date)),
(7, 'London', -7, cast('2021-01-07'as date)),
(8, 'London', 5, cast('2021-01-08'as date));

From the weather table, fetch all the records when London had extremely cold temperature for 3 consecutive days or more.
*/
select *
from (
	select 
		*
		, case
			when temperature < 0 and lead(temperature,1) over() and lead(temperature,2) over() < 0 then 'Yes'
			when temperature < 0 and lag(temperature,1) over() and lead(temperature,1) over() < 0 then 'Yes' 
			when temperature < 0 and lag(temperature,1) over() and lag(temperature,2) over() < 0 then 'Yes'
			end as flag
	from weather3 ) x
where flag = 'Yes';



/*
create table tasks (
date_value date,
state varchar(10)
);
insert into tasks  values ('2019-01-01','success'),('2019-01-02','success'),('2019-01-03','success'),('2019-01-04','fail'),('2019-01-05','fail'),('2019-01-06','success');

use db_assignment;
*/
select 
    state
	, min(date_value) as min_date
    , max(date_value) as max_date
from (
select *
	, row_number() over(partition by state order by date_value) as rn
    , date_sub(date_value, interval row_number() over(partition by state order by date_value) day) as group_date
from tasks ) x1
group by group_date, state
order by max(date_value) asc, min(date_value) asc















    