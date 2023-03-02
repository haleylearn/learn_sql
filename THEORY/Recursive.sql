/*
https://builtin.com/data-science/recursive-sql
Defination: A recursive SQL common table expression (CTE) is a query that continuously references a previous result until it returns an empty result. 

Syntax:
with recursive cte_name as (
	select query (non recursive query or base query)
    union all
    select query (recursive query using cte_name with a termination condition)
)

Notes:
with recursive R as (
	base query
    union all
    recursive query
)
- It’s important to note that the base query doesn’t involve R, however, the recursive query does reference R.  
It seems like an infinite loop.
- R doesn’t reference itself, it just references the previous result. And when the previous result is an empty table, the recursion stops.

HOW TO WORK?
 The base query executes first, taking whatever it needs to compute the result R0. 
 The second recursive query is executed taking R0 as input — that is R references R0 in the recursive query when first executed. 
 The recursive query produces the result R1, and that is what R will reference at the next invocation, 
 and so on until a recursive query returns an empty result. 
 At that point, all intermediate results are combined together.
*/

/*
EXAMPLE 1: COUNT UP UNTIL THREE
The base query returns number 1, the recursive query takes it under the countUp name and produces number 2, 
which is the input for the next recursive call. 
When the recursive query returns an empty table n >= 3, the results from the calls are stacked together.
*/
with recursive countUp as(
	select 1 as n
    union all
    select n+1
	from countUp
	where n<3
)
select * from countUp;

/*
EXAMPLE 2: FINDING ANCESTOR
use db_assignment;
create table parent_child
(
    id         int,
    parent varchar(50),
    child varchar(50)
);

insert into parent_child values(1, 'Alice','Carol');
insert into parent_child values(2, 'Bob','Carol');
insert into parent_child values(3, 'Carol','Dave');
insert into parent_child values(3, 'Carol','Geogre');
insert into parent_child values(4, 'Dave','Mary');
insert into parent_child values(5, 'Eve','Mary');
insert into parent_child values(6, 'Mary','Frank');
insert into parent_child values(7, 'David','John');
insert into parent_child values(8, 'Haley','John');

Finding the ancestor of Frank
*/


select * from parent_child;

with recursive cte_r as (
	select parent, child, 0 as level
    from parent_child
    where child = 'Frank'
    union 
    select p.parent, p.child, level + 1
    from parent_child p, cte_r c
    where p.child = c.parent
)

select * from cte_r;

/*
Leetcode : 1384
create table sales (
product_id int,
period_start date,
period_end date,
average_daily_sales int
);
insert into sales values(1,'2019-01-25','2019-02-28',100),(2,'2018-12-01','2020-01-01',10),(3,'2019-12-01','2020-01-31',1);
Question: 
Write an SQL query to report the Total sales amount of each item for each year, 
with corresponding product name, product_id, product_name and report_year.
Dates of the sales years are between 2018 to 2020. Return the result table ordered by product_id and report_year.
*/

select * from sales;
-- Solution 1:
with recursive getSeparateDay as(
	select min(period_start) as dates, max(period_end) as max_date from sales 
    union all
    select date_add(dates, interval 1 day) as dates, max_date
    from getSeparateDay g
    where dates < g.max_date
)

select year(g.dates) as year, product_id, sum(average_daily_sales) as total
from sales s
join getSeparateDay g
on g.dates between s.period_start and s.period_end
group by year(g.dates), product_id
order by product_id asc;

-- Solution 2:
with recursive dt_cte as (
select period_start,period_end,product_id,average_daily_sales from sales
union all
select date_add(period_start, interval 1 day),period_end,product_id,average_daily_sales
from dt_cte 
where period_start<period_end
)

select distinct(year(period_start)), product_id, sum(average_daily_sales)
from dt_cte
group by year(period_start), product_id;

-- Solution 3:
select * from sales;

select s.product_id, '2018' as report_year, 
               case when year(period_end) = 2018 then average_daily_sales * (dayofyear(period_end)-dayofyear(period_start) + 1)
                    when year(period_end) >= 2019 then average_daily_sales * (365 - dayofyear(period_start) + 1)
                    end as total_amount
from Sales s 
where year(period_start) = 2018

union all 

select s.product_id, '2019' as report_year, 
               case when year(period_start) = 2018 and year(period_end) = 2019 then average_daily_sales * dayofyear(period_end)
                    when year(period_start)=2018 and year(period_end) = 2020 then average_daily_sales * 365
                    when year(period_start) = 2019 and year(period_end) = 2019 then average_daily_sales * (dayofyear(period_end) - dayofyear(period_start) + 1)
                    when year(period_start) = 2019 and year(period_end) = 2020 then average_daily_sales * (365 - dayofyear(period_start) + 1)
                    end as total_amount
from Sales s 
where year(period_start) < 2020 and year(period_end) > 2018

union all
select s.product_id, '2020' as report_year, 
               case when year(period_start) < 2020 then average_daily_sales * dayofyear(period_end)
                    when year(period_start) = 2020 then average_daily_sales * (dayofyear(period_end) - dayofyear(period_start) + 1)
                    end as total_amount
from Sales s 
where year(period_end) = 2020;


-- Solution 4:
SELECT
    s.product_id,
    x.yr AS report_year,
    CASE 
        WHEN x.yr=YEAR(s.period_start) AND YEAR(s.period_start)=YEAR(s.period_end) THEN DATEDIFF(s.period_end,s.period_start)+1
        WHEN x.yr=YEAR(s.period_start) THEN DATEDIFF(DATE_FORMAT(s.period_start,'%Y-12-31'),s.period_start)+1
        WHEN x.yr=YEAR(s.period_end) THEN DAYOFYEAR(s.period_end) 
        WHEN x.yr>YEAR(s.period_start) AND x.yr<YEAR(s.period_end) THEN 365
        ELSE 0
    END * average_daily_sales AS total_amount
from (
	SELECT product_id,'2018' AS yr FROM Sales
    UNION
	SELECT product_id,'2019' AS yr FROM Sales
    UNION
	SELECT product_id,'2020' AS yr FROM Sales
) x
JOIN 
    Sales s
    ON x.product_id=s.product_id 
HAVING total_amount > 0
ORDER BY s.product_id,x.yr;




