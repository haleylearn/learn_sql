
/* User purchase platform.

create table spending 
(
user_id int,
spend_date date,
platform varchar(10),
amount int
);

insert into spending values
(1,'2019-07-01','mobile',100)
,(1,'2019-07-01','desktop',100)
,(2,'2019-07-01','mobile',100)
,(2,'2019-07-02','mobile',100)
,(3,'2019-07-01','desktop',100)
,(3,'2019-07-02','desktop',100);

-- The table logs the spendings history of users that make purchases from an online shopping website which has a desktop 
and a mobile application.
-- Write an SQL query to find the total number of users and the total amount spent using mobile only, desktop only 
and both mobile and desktop together for each date.
*/
use db_assignment;
select * from spending;

-- Solution 1: Find user from separate on each platfrom, find mobile, find desktop, find both and then union all
-- Find user_id both platfrom
select 
	spend_date
	, count(user_id) over(partition by spend_date )
	from spending s1
	where platform = 'desktop' and user_id in (
		select user_id
		from spending s2
		where platform = 'mobile' and s1.spend_date = s2.spend_date
	);



with cte_getUserBothPlat as 
	(
		-- Find and count user_id both platfrom
		select distinct s1.user_id, s1.spend_date, sum(s1.amount) as total
		from spending s1
		join spending s2
		on s1.spend_date = s2.spend_date and s1.user_id = s2.user_id and s1.platform <> s2.platform
		group by s1.user_id, s1.spend_date
    )

select 
	spend_date
	, 'both' as platform
	, total as total_amount
	, count(user_id) over(partition by spend_date) as total_users
from 
	cte_getUserBothPlat
union all
select 
	spend_date 
    , platform
    , sum(amount) over (partition by spend_date , platform)as total_amount
    , count(user_id) over (partition by spend_date , platform) as total_users
from spending
where user_id not in (select user_id from cte_getUserBothPlat)
order by spend_date;

-- Solution 2: Find user from separate on each platfrom, find mobile, find desktop, find both and then union all
-- Find and count user_id both platfrom
with cte_getCntBothPla as
(
		select 
			distinct spend_date
            , user_id
			, sum(amount) as total_amount
            , count(distinct platform) as cnt_both_plat
		from spending
		group by spend_date, user_id
		having count(distinct platform) > 1

)

-- Get table distinct date and join with cte_getCntBothPla 
select
	c1.spend_date
    , 'both' as platform
    , case when c2.total_amount is null then 0 else c2.total_amount end as total_amount
	, count(user_id) over(partition by c1.spend_date) as total_users
from 
(
	select distinct spend_date
	from spending
) c1
left join cte_getCntBothPla c2
on c1.spend_date = c2.spend_date

union all

-- Get table with not include platform both
select 
	spend_date 
    , platform
	, sum(amount) as total_amount
	, count(user_id) as total_users
from spending
where user_id not in (select user_id from cte_getCntBothPla)
group by spend_date , platform
order by spend_date, platform desc;

-- Solution 3:
select count(distinct user_id) as total_users, spend_date
, sum(amount) as total_amount 
, case when count(distinct platform) = 2 then 'both' else max(platform) end as platform
-- Trick chèn max(platform) bởi vì nếu chỉ ghi platform không thì nó không biết lấy dòng nào để ghi, và bởi vì có group by nên cần có agg function.
from spending
group by user_id,spend_date
union
select 0,spend_date,0,'both'
from spending
group by spend_date
having count(distinct user_id) = count(user_id)
order by spend_date, total_users desc;

-- Solution 4: Use group concat and then use if on select 
with cte1 as (
		select user_id, spend_date, group_concat(platform separator ',') platform, sum(amount) amount
		from spending
		group by 1,2)
select spend_date, if(platform = 'mobile,desktop','both',platform) platform, sum(amount) total_amount, count(user_id) total_users
from cte1 group by 1,2
union
select distinct spend_date, 'both' platform, 0 total_amount, 0 total_users
from spending where spend_date not in (select spend_date from cte1 where platform = 'mobile,desktop');

-- Solution 5:
select spend_date,user_id,min(platform) platform,sum(amount) total_amount,count(distinct user_id) no_of_users
from spending group by spend_date,user_id having count(distinct platform)=1
union all
select spend_date,user_id,'both' platform,sum(amount) total_amount,count(distinct user_id) no_of_users
from spending group by spend_date,user_id having count(distinct platform)=2
order by spend_date,platform desc;
