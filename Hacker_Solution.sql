/*

create table hackers (hacker_id int, name varchar(40));
create table submissions (submission_date date, submission_id int, hacker_id int, score int);


insert into hackers values (15758, 'Rose');
insert into hackers values (20703, 'Angela');
insert into hackers values (36396, 'Frank');
insert into hackers values (38289, 'Patrick');
insert into hackers values (44065, 'Lisa');
insert into hackers values (53473, 'Kimberly');
insert into hackers values (62529, 'Bonnie');
insert into hackers values (79722, 'Michael');

select * from submissions;
select * from hackers;

insert into submissions values ( ('2016-03-01'), 8494,      20703,	 0	);
insert into submissions values ( ('2016-03-01'), 22403, 	53473,	 15	);
insert into submissions values ( ('2016-03-01'), 23965, 	79722,	 60	);
insert into submissions values ( ('2016-03-01'), 30173, 	36396,	 70	);
insert into submissions values ( ('2016-03-02'), 34928, 	20703,	 0	);
insert into submissions values ( ('2016-03-02'), 38740, 	15758,	 60	);
insert into submissions values ( ('2016-03-02'), 42769, 	79722,	 25	);
insert into submissions values ( ('2016-03-02'), 44364, 	79722,	 60	);
insert into submissions values ( ('2016-03-03'), 45440, 	20703,	 0	);
insert into submissions values ( ('2016-03-03'), 49050, 	36396,	 70	);
insert into submissions values ( ('2016-03-03'), 50273, 	79722,	 5	);
insert into submissions values ( ('2016-03-04'), 50344, 	20703,	 0	);
insert into submissions values ( ('2016-03-04'), 51360, 	44065,	 90	);
insert into submissions values ( ('2016-03-04'), 54404, 	53473,	 65	);
insert into submissions values ( ('2016-03-04'), 61533, 	79722,	 45	);
insert into submissions values ( ('2016-03-05'), 72852, 	20703,	 0	);
insert into submissions values ( ('2016-03-05'), 74546, 	38289,	 0	);
insert into submissions values ( ('2016-03-05'), 76487, 	62529,	 0	);
insert into submissions values ( ('2016-03-05'), 82439, 	36396,	 10	);
insert into submissions values ( ('2016-03-05'), 90006, 	36396,	 40	);
insert into submissions values ( ('2016-03-06'), 90404, 	20703,	 0	);
*/

/* NOTE
medium.com/geekculture/15-days-of-learning-sql-hackerrank-a40ab17ae462 tham khảo thêm cách này có vẻ khá hay
và thêm cách đệ quy cte của tfq
*/

/* OLD
-- Update info @table_ori with checking the original info at 01, March 2016 on the next day
		update @table_ori
		set submission_date = x.submission_date
			, submission_id = x.submission_id
			, hacker_id = x.hacker_id
			, score = x.score
		from (select  s.submission_date, s.submission_id, s.hacker_id, s.score 
				from @table_ori o
				join submissions s
				on o.hacker_id = s.hacker_id and s.submission_date = dateadd(day,1,o.submission_date)) x


while @date_first < dateadd(day,1,@date_final)
	begin
		-- Get info into @table_finnal
		insert into @table_finnal
		select  s.submission_date, s.submission_id, s.hacker_id, s.score 
		from @table_ori o
		join submissions s
		on o.hacker_id = s.hacker_id and s.submission_date = dateadd(day,1,@date_first)

		-- Update @table_ori to get new input for while loop
		delete from @table_ori where hacker_id not in (select distinct hacker_id from @table_finnal)

		-- Set @date_first + 1 day
		set @date_first = dateadd(day,1,@date_first)
	end;
	
*/

select * from submissions;
select * from hackers;

use test 
-- Create table with original information start with March 01, 2016
declare @table_finnal table (submission_date date, submission_id int, hacker_id int, score int);
declare @table_ori table (submission_date date, submission_id int, hacker_id int, score int);

-- Get data for @table_ori 
insert into @table_ori
select submission_date, submission_id, hacker_id, score  from submissions where submission_date = (select min(submission_date) from submissions)

declare @date_first date
declare @date_final date

set @date_final = (select max(submission_date) from submissions)
set @date_first = (select min(submission_date) from submissions)

while @date_first < dateadd(day,1,@date_final)
	begin
		-- Get info into @table_finnal
		insert into @table_finnal
		select  s.submission_date, s.submission_id, s.hacker_id, s.score 
		from @table_ori o
		join submissions s
		on o.hacker_id = s.hacker_id and s.submission_date = dateadd(day,1,@date_first)

		-- Update @table_ori to get new input for while loop
		delete from @table_ori where hacker_id not in (select distinct hacker_id from @table_finnal)

		-- Set @date_first + 1 day
		set @date_first = dateadd(day,1,@date_first)
	end;

-- CTE with full infor needed
with cte_Get_Full_Infor as (	
-- Get table with start date at 01 March 2016
    select submission_date, submission_id, hacker_id, score
	from submissions where submission_date = (select min(submission_date) from submissions)

	union all 
	
	-- Get table @table_finnal
    select submission_date, submission_id, hacker_id, score score from @table_finnal
)

, cte_Cnt_Uni_Hacker_By_Date as(
-- Get submission_date and count no_of_hackers
		select submission_date, count( distinct hacker_id) as no_of_hackers from cte_Get_Full_Infor group by submission_date
)

, cte_Get_Hacker_First_Day as (
	select * 
	from submissions 
	where hacker_id in (select hacker_id 
						from submissions 
						where submission_date = (select min(submission_date) from submissions))
)

, cte_Cnt_Submit_By_Hacker as (
-- Get submission_date and count cnt_submit_by_hacker
	select submission_date, hacker_id, count(submission_id) as cnt_submit_by_hacker
	from cte_Get_Hacker_First_Day 
	group by submission_date, hacker_id
)
, cte_Get_Max_Submit_Partition_By_Date as (
-- Get table with rank by hacker_id and cnt_submit_by_hacker with max(cnt_submit_by_hacker)
	select *
		, max(cnt_submit_by_hacker) over(partition by submission_date) as cnt_Max_Submit_Partition_By_Date
		, row_number() over(partition by submission_date order by cnt_submit_by_hacker desc, hacker_id asc) as rank_by_cnt_submit
	from cte_Cnt_Submit_By_Hacker
)

-- Final result
select t1.submission_date, t1.no_of_hackers, t2.hacker_id, t3.name
from cte_Cnt_Uni_Hacker_By_Date t1
join (select submission_date, hacker_id from cte_Get_Max_Submit_Partition_By_Date where rank_by_cnt_submit = 1) t2
	on t1.submission_date = t2.submission_date
join hackers t3 
	on t2.hacker_id = t3.hacker_id
order by t1.submission_date











