
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