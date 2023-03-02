/*DATASET

create table tasks (
date_value date,
state varchar(10)
);
insert into tasks  values ('2019-01-01','success'),('2019-01-02','success'),('2019-01-03','success'),('2019-01-04','fail')
,('2019-01-05','fail'),('2019-01-06','success');

create table tasks_test (
date_num int,
state varchar(10)
);
insert into tasks_test  values (1, 'Y'), (2, 'N'), (3, 'N'), (4, 'Y') ,(7, 'Y') ,(9, 'N'), (11, 'N') ;
*/


select * from tasks_test;
select * from tasks;


-- Solution 1:
with cte1 as 
(
	select date_num,state,leaded
		,sum(case when state <> leaded then 1 else 0 end) over (order by date_num) as grouped 
	from
		(select date_num,state,lag(state,1,state) over(order by date_num) as leaded
		from tasks_test) x
)

select min(date_num) as start_date,max(date_num) as end_date,state 
from cte1 
group by grouped, state;


-- Solution 2:
select min(date_value) as start_date,max(date_value) as end_date,state 
from cte 
group by grouped, state;

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
order by max(date_value) asc, min(date_value) asc;

