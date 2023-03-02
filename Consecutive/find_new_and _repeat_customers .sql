/*
DATASET
https://www.youtube.com/watch?v=MpAMjtvarrc
create table customer_orders (
order_id integer,
customer_id integer,
order_date date,
order_amount integer
);
insert into customer_orders values(1,100,cast('2022-01-01' as date),2000),(2,200,cast('2022-01-01' as date),2500),(3,300,cast('2022-01-01' as date),2100)
,(4,100,cast('2022-01-02' as date),2000),(5,400,cast('2022-01-02' as date),2200),(6,500,cast('2022-01-02' as date),2700)
,(7,100,cast('2022-01-03' as date),3000),(8,400,cast('2022-01-03' as date),1000),(9,600,cast('2022-01-03' as date),3000)
;
*/
use db_assignment;
/*
 Mindset: 
S1: Find min(order_date) of each customer_id
S2: Join table customer_orders with table of S1
S3: Using sum case at select
	+ sum(case when c.order_date = x.first_visit_date then 1 else 0 end ) as no_of_new
	+ sum(case when c.order_date <> x.first_visit_date then 1 else 0 end )as no_of_old
Notes: Other way to get table of S1 at below Solution 2: min(order_date) over(partition by customer_id) as first_order_date from customer_orders)
*/

-- Solution 1:
select 
	c.order_date
	, sum(case when c.order_date = x.first_visit_date then 1 else 0 end ) as no_of_new
	, sum(case when c.order_date <> x.first_visit_date then 1 else 0 end )as no_of_old
from customer_orders c
join (
	select customer_id, min(order_date) as first_visit_date 
	from customer_orders
	group by customer_id
) x
on c.customer_id = x.customer_id
group by c.order_date;

-- Update for solution 1
select 
c.order_date
	, sum(case when c.order_date = x.first_visit_date then 1 else 0 end ) as no_of_new
	, sum(case when c.order_date <> x.first_visit_date then 1 else 0 end )as no_of_old
from 
(	
	select customer_id, min(order_date) as first_visit_date
	from customer_orders2
	group by customer_id
) x
join 
(select distinct order_date, customer_id from customer_orders2) c -- Aim to avoid duplicate when 1 user has many order in on day
on x.customer_id = c.customer_id 
group by c.order_date;


-- Solution 2: 
select a.order_date,
	sum(case when a.order_date = a.first_order_date then 1 else 0 end) as new_customer
	, sum(case when a.order_date != a.first_order_date then 1 else 0 end) as repeat_customer
from(
select customer_id, order_date, min(order_date) over(partition by customer_id) as first_order_date from customer_orders) a 
group by a.order_date;


-- Solution 3:
with cte as(
select  
	order_date
    , dense_rank() over(partition by customer_id order by order_date asc) as rn_den -- wrong result
	, row_number() over(partition by customer_id order by order_date asc) as rn -- right result
from customer_orders2
)

select order_date
	, sum(case when rn_den>1 then 1 else 0 end) as repeat_customers -- wrong result
	, sum(case when rn=1 then 1 else 0 end) as new_customers
from cte
group by order_date;













