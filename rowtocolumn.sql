create table icc_world_cup
(
Team_1 Varchar(20),
Team_2 Varchar(20),
Winner Varchar(20)
);
INSERT INTO icc_world_cup values('India','SL','India');
INSERT INTO icc_world_cup values('SL','Aus','Aus');
INSERT INTO icc_world_cup values('SA','Eng','Eng');
INSERT INTO icc_world_cup values('Eng','NZ','NZ');
INSERT INTO icc_world_cup values('Aus','India','India');

select * from icc_world_cup;


select team, count(team) no_of_matches, sum(score) as no_of_win, count(team) - sum(score) as no_of_losses
from
(select team_1 as team, case when winner = team_1 then 1 else 0 end as score from icc_world_cup
union all
select team_2 as team, case when winner = team_2 then 1 else 0 end as score from icc_world_cup) x
group by team


use db_assignment
create table entries ( 
name varchar(20),
address varchar(20),
email varchar(20),
floor int,
resources varchar(10));


insert into entries 
values ('A','Bangalore','A@gmail.com',1,'CPU'),('A','Bangalore','A1@gmail.com',1,'CPU'),('A','Bangalore','A2@gmail.com',2,'DESKTOP')
,('B','Bangalore','B@gmail.com',2,'DESKTOP'),('B','Bangalore','B1@gmail.com',2,'DESKTOP'),('B','Bangalore','B2@gmail.com',1,'MONITOR');


select x1.name, x1.type_visit, x2.floor as most_of_floor_visit, x2.total_visit
from (select name, group_concat( distinct resources) as type_visit from entries group by name) x1
join (select name, floor
    , count(name) cnt_as_visit
    , row_number() over(partition by name order by count(name)) as rank_
    , sum(count(name)) over(partition by name) as total_visit
	from entries     
	group by name, floor) x2
on x1.name = x2.name and x2.rank_ = 1;

/*DATASET

create table orders_complex_13
(
order_id int,
customer_id int,
product_id int
);

insert into orders_complex_13 VALUES 
(1, 1, 1),
(1, 1, 2),
(1, 1, 3),
(2, 2, 1),
(2, 2, 2),
(2, 2, 4),
(3, 1, 5);

create table products_complex_13 (
id int,
name varchar(10)
);
insert into products_complex_13 VALUES 
(1, 'A'),
(2, 'B'),
(3, 'C'),
(4, 'D'),
(5, 'E');
*/

with cte_getTabOri as (
	select o.*, p.name
    , row_number() over(partition by order_id order by name) as rn
	from orders_complex_13 o
	join products_complex_13 p
	on o.product_id = p.id
),
cte_getTabWithSecondProduct as (
	select c1.*, c2.name as second_product
	from cte_getTabOri c1
	join cte_getTabOri c2
	on c1.order_id = c2.order_id and c1.rn < c2.rn
	order by c1.order_id, c1.name
)

select pair, count(pair) as purchase_freg
from (
	select concat(name, ' ', second_product) as pair
	from cte_getTabWithSecondProduct) x
group by pair;



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
*/

-- RETENTION
select 
	month(this_month.order_date) as month_date
	, count(distinct last_month.cust_id) 
from transactions this_month 
left join transactions last_month
on this_month.cust_id = last_month.cust_id and (month(this_month.order_date) - month(last_month.order_date) = 1)
group by month(this_month.order_date);


-- CHURN
select 
	 month(last_m.order_date) as month_date
	, count(distinct last_m.cust_id) 
from transactions last_m
left join transactions this_m
on last_m.cust_id = this_m.cust_id and (month(last_m.order_date) - month(this_m.order_date) = 1)
where this_m.cust_id is null
group by month(last_m.order_date);


with temp1 as(
select * , lead(order_date,1,order_date) over (partition by cust_id order by order_date) as lastdate from transactions
)
select month(order_date), sum(case when month(order_date)-month(lastdate)=0 then 1 else 0 end) as custtt from temp1 group by month(order_date)


with table1 as(
Select cust_id, max(order_date) as ordered_date , max(order_date) over () as maxdate,
rank() over(
partition by cust_id order by order_date desc) as rn
from transactions
group by cust_id, (order_date)
)
Select * from table1
where rn =1 and month(ordered_date) != month(maxdate)
order by cust_id



use db_assignment
drop table user_retention

create table user_retention(
uid int,
login_date date
);
insert into user_retention values(1,'2021-02-01'),(1,'2021-02-02'),(1,'2021-02-03'),(1,'2021-02-05')
insert into user_retention values (2,'2021-02-01'), (2,'2021-02-02'), (2,'2021-02-05'), (2,'2021-02-06')
insert into user_retention values (3,'2021-02-01'), (3,'2021-02-02'), (3,'2021-02-03'), (3,'2021-02-06')
insert into user_retention values (4,'2021-02-06')
insert into user_retention values (5,'2021-02-05')

select u1.login_date, count(distinct u2.uid) as cnt_retention_cus
from user_retention u1 left join user_retention u2 
on u1.uid = u2.uid and datediff(u1.login_date,u2.login_date) = 1
group by u1.login_date


select login_date, count(distinct uid)
from user_retention
group by login_date
