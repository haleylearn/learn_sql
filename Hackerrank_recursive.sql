/*
Julia conducted a  days of learning SQL contest. The start date of the contest was March 01, 2016 and the end date was March 15, 2016.
Write a query to print total number of unique hackers who made at least  submission each day (starting on the first day of the contest), 
and find the hacker_id and name of the hacker who made maximum number of submissions each day. 
If more than one such hacker has a maximum number of submissions, print the lowest hacker_id. 
The query should print this information for each day of the contest, sorted by the date.

Dataset
insert into hackers values (15758, 'Rose');
insert into hackers values (20703, 'Angela');
insert into hackers values (36396, 'Frank');
insert into hackers values (38289, 'Patrick');
insert into hackers values (44065, 'Lisa');
insert into hackers values (53473, 'Kimberly');
insert into hackers values (62529, 'Bonnie');
insert into hackers values (79722, 'Michael');


insert into submissions values (date_format('2016-03-01', '%y-%m-%d'), 8494,    20703,	 0	);
insert into submissions values (date_format('2016-03-01', '%y-%m-%d'), 22403, 	53473,	 15	);
insert into submissions values (date_format('2016-03-01', '%y-%m-%d'), 23965, 	79722,	 60	);
insert into submissions values (date_format('2016-03-01', '%y-%m-%d'), 30173, 	36396,	 70	);
insert into submissions values (date_format('2016-03-02', '%y-%m-%d'), 34928, 	20703,	 0	);
insert into submissions values (date_format('2016-03-02', '%y-%m-%d'), 38740, 	15758,	 60	);
insert into submissions values (date_format('2016-03-02', '%y-%m-%d'), 42769, 	79722,	 25	);
insert into submissions values (date_format('2016-03-02', '%y-%m-%d'), 44364, 	79722,	 60	);
insert into submissions values (date_format('2016-03-03', '%y-%m-%d'), 45440, 	20703,	 0	);
insert into submissions values (date_format('2016-03-03', '%y-%m-%d'), 49050, 	36396,	 70	);
insert into submissions values (date_format('2016-03-03', '%y-%m-%d'), 50273, 	79722,	 5	);
insert into submissions values (date_format('2016-03-04', '%y-%m-%d'), 50344, 	20703,	 0	);
insert into submissions values (date_format('2016-03-04', '%y-%m-%d'), 51360, 	44065,	 90	);
insert into submissions values (date_format('2016-03-04', '%y-%m-%d'), 54404, 	53473,	 65	);
insert into submissions values (date_format('2016-03-04', '%y-%m-%d'), 61533, 	79722,	 45	);
insert into submissions values (date_format('2016-03-05', '%y-%m-%d'), 72852, 	20703,	 0	);
insert into submissions values (date_format('2016-03-05', '%y-%m-%d'), 74546, 	38289,	 0	);
insert into submissions values (date_format('2016-03-05', '%y-%m-%d'), 76487, 	62529,	 0	);
insert into submissions values (date_format('2016-03-05', '%y-%m-%d'), 82439, 	36396,	 10	);
insert into submissions values (date_format('2016-03-05', '%y-%m-%d'), 90006, 	36396,	 40	);
insert into submissions values (date_format('2016-03-06', '%y-%m-%d'), 90404, 	20703,	 0	);
*/

USE db_assignment; -- Replace SYS with your database name

select * from hackers;

select * from submissions;

with recursive cte as
	-- Get distinct day and total base hacker_id through everyday
	(
    -- base query
		select distinct submission_date, hacker_id
		from submissions
		where submission_date = (select min(submission_date) from submissions)
        
        union 
        
	-- recursive query
		select s.submission_date, s.hacker_id
        from submissions s
        join cte c 
        on s.hacker_id = c.hacker_id
        where s.submission_date = (select min(submission_date) from submissions
										where submission_date > c.submission_date)
	)

	-- Count submit of each hacker
	, getMaxSubmitById as 
		(	
			select submission_date, hacker_id
			, count(hacker_id) as count_submitById
			from submissions
			group by submission_date, hacker_id
			order by submission_date, hacker_id
		)
    -- Count max submit of each day
	, getMaxSubmitByDate as
		(
			select submission_date, max(count_submitById) as max_submitByDate
			from getMaxSubmitById
            group by submission_date
		)
	-- Get all Hacker_id equal with getMaxSubmitByDate
	, getIdEqualMax as 
		(
			select i.submission_date, i.hacker_id, i.count_submitById , d.max_submitByDate
			from getMaxSubmitById i
			join getMaxSubmitByDate d
			on i.submission_date = d.submission_date and i.count_submitById = d.max_submitByDate
        )
	-- Get total hacker_id have total submit by day equal with getMaxSubmitByDate
]	, getTotalIdEqualMax as
		(
			select submission_date, count(hacker_id) as totalIdEqualMax
			from getIdEqualMax
			group by submission_date
		)
	, result as 
		(
			select distinct i.submission_date
				, case
					when t.totalIdEqualMax >= 2 then first_value(i.hacker_id) over(partition by i.max_submitByDate)
					else i.hacker_id
					end as hacker_id
			from getIdEqualMax i
			join getTotalIdEqualMax t
			on i.submission_date = t.submission_date
			order by i.submission_date

		)
select 
	r.submission_date
    , x.no_of_unique_hacker
    , r.hacker_id
    , h.name
from result r
join (
	select cte.submission_date, count(1) as no_of_unique_hacker
	from cte
	group by cte.submission_date
	order by 1) x
on r.submission_date = x.submission_date
join hackers h
on r.hacker_id = h.hacker_id









 



























