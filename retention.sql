
/**DATASET 
https://www.youtube.com/watch?v=6hfsRqmyvog&ab_channel=AnkitBansal

(1, 'Jon', STR_TO_DATE('02/14/2020', '%m/%d/%Y')), 

create table transactions(
order_id int,
cust_id int,
order_date date,
amount int
);
insert into transactions values 
(1,1,'2020-01-15',150)
,(2,1,'2020-02-10',150)
,(3,2,'2020-01-16',150)
,(4,2,'2020-02-25',150)
,(5,3,'2020-01-10',150)
,(6,3,'2020-02-20',150)
,(7,4,'2020-01-20',150)
,(8,5,'2020-02-20',150)
;
insert into transactions values 
(9,1,'2020-03-10',150)
,(10,1,'2020-04-20',150)
,(11,4,'2020-04-20',150)
,(12,2,'2020-05-20',150)
,(15,5,'2020-03-10',150)
*/

-- RETENTION
select 
	month(this_month.order_date) as month_date
	, count(distinct last_month.cust_id) 
from transactions this_month 
left join transactions last_month
on this_month.cust_id = last_month.cust_id and (month(this_month.order_date) - month(last_month.order_date) = 1)
group by month(this_month.order_date);

/*
DATASET
create table transactions_test(
order_id int,
cust_id int,
order_date date,
amount int
);

insert into transactions_test values (9,1,'2020-05-20',150)
(1,1,'2020-01-15',150)
,(2,1,'2020-02-10',150)
,(3,2,'2020-01-16',150)
,(4,2,'2020-02-25',150)
,(5,3,'2020-01-10',150)
,(6,3,'2020-02-20',150)
,(7,4,'2020-01-20',150)
,(8,5,'2020-02-20',150)
,(9,1,'2020-05-20',150);
*/

-- Churn Customer
select  
	month(current.order_date) + 1 as month_
	, count(current.cust_id) as cnt
from transactions_test current
left join transactions_test next
on current.cust_id = next.cust_id and month(next.order_date) - month(current.order_date) = 1
where next.cust_id is null
group by month(current.order_date) + 1
order by month(current.order_date) + 1;

/*
DATASET
CREATE TABLE login(
login_date DATE, user_id INT,
id INT not null AUTO_INCREMENT,
    PRIMARY KEY (id)
);

INSERT INTO login(login_date,user_id)
VALUES('2022-01-01',10),('2022-01-02',12),('2022-01-03',15),
('2022-01-04',11),('2022-01-05',13),('2022-01-06',9),
('2022-01-07',21),('2022-01-08',10),('2022-01-09',10),
('2022-01-10',2),('2022-01-11',16),('2022-01-12',12),
('2022-01-13',10),('2022-01-14',18),('2022-01-15',15),
('2022-01-16',12),('2022-01-17',10),('2022-01-18',18),
('2022-01-19',14),('2022-01-20',16),('2022-01-21',12),
('2022-01-22',21),('2022-01-23',13),('2022-01-24',15),
('2022-01-25',20),('2022-01-26',14),('2022-01-27',16),
('2022-01-28',15),('2022-01-29',10),('2022-01-30',18);

Question: Find retention customer through week based on data
*/
use db_assignment;

select first
	, SUM(CASE WHEN week_number = 0 THEN 1 ELSE 0 END) AS week_0
    , SUM(CASE WHEN week_number = 1 THEN 1 ELSE 0 END) AS week_1
    , SUM(CASE WHEN week_number = 2 THEN 1 ELSE 0 END) AS week_2
	, SUM(CASE WHEN week_number = 3 THEN 1 ELSE 0 END) AS week_3
    , SUM(CASE WHEN week_number = 4 THEN 1 ELSE 0 END) AS week_4
    /*
    , SUM(CASE WHEN week_number = 0 THEN 1 ELSE 0 END) AS week_0
    , SUM(CASE WHEN week_number = 1 THEN 1 ELSE 0 END) / SUM(CASE WHEN week_number = 0 THEN 1 ELSE 0 END) * 100 AS week_1
    , SUM(CASE WHEN week_number = 2 THEN 1 ELSE 0 END) / SUM(CASE WHEN week_number = 0 THEN 1 ELSE 0 END) * 100 AS week_2
	, SUM(CASE WHEN week_number = 3 THEN 1 ELSE 0 END) / SUM(CASE WHEN week_number = 0 THEN 1 ELSE 0 END) * 100 AS week_3
    , SUM(CASE WHEN week_number = 4 THEN 1 ELSE 0 END) / SUM(CASE WHEN week_number = 0 THEN 1 ELSE 0 END) * 100 AS week_4*/
	
from (select 
		distinct user_id -- coi chừng dính bẫy bởi vì một user có thể đăng nhập 2 lần trong một tuần nên sử dụng distinct
		, week(login_date) + 1 as login_week
		, min(week(login_date) + 1) over(partition by user_id) as first
		, (week(login_date) +1 ) - (min(week(login_date) + 1) over(partition by user_id)) as week_number
		from login) x
group by first
order by first;



-- test 
select 
month(last_month.order_date) as month_
, count(this_month.cust_id) 
from transactions last_month
left join transactions this_month
on last_month.cust_id = this_month.cust_id  and month(last_month.order_date) - month(this_month.order_date) = 1
-- where last_month.cust_id = 1
group by month(last_month.order_date)

