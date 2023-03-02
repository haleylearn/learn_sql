use db_assignment;
/*
https://www.youtube.com/watch?v=ueOUSjdAZY8&t=607s
Question: Write query show the second most recent activity of each user
Note: If user only has one return one
CREATE TABLE useractivity
  (
     username  VARCHAR(20),
     activity  VARCHAR(20),
     startdate DATE,
     enddate   DATE
  );
INSERT INTO useractivity
VALUES      ('Amy','Travel','2020-02-12','2020-02-20'),
            ('Amy','Dancing','2020-02-21','2020-02-23'),
            ('Amy','Travel','2020-02-24','2020-02-28'),    
            ('Adam','Travel','2020-02-12','2020-02-20'),  
            ('Adam','Dancing','2020-02-21','2020-02-23'), 
            ('Adam','Singing','2020-02-24','2020-02-28'), 
            ('Adam','Travel','2020-03-01','2020-03-28'),
            ('Joe','Travel','2020-02-11','2020-02-18');
*/
             

select * from useractivity;

-- Solution 1:
with cte_getRowPartByUser as 
		(
			select *
			, row_number() over(partition by username order by enddate desc) as row_part_by_user
			from useractivity
        )
        , cte_getRowSecondDate as (
			select *
			from cte_getRowPartByUser
			where row_part_by_user = 2
        )
       
select * from cte_getRowSecondDate

union 
       
select *
from cte_getRowPartByUser
where username not in (select username from cte_getRowSecondDate);


-- Solution 2:
with cte_countWithRow as 
	(
		select 
			*
			, count(*) over(partition by username) as ct -- Big problem when i write count(*) over(partition by username order by enddate)
            , row_number() over(partition by username order by enddate) as row_part_by_user 
		from useractivity
    )
    
select *
from cte_countWithRow
where row_part_by_user = case 
							when ct = 1 then ct = 1
                            else ct - 1
							end;

-- Fix big problem when i write count(*) over(partition by username order by enddate)
with cte_countWithRowFix as 
	(
		select 
			*
			, count(*) over(partition by username order by enddate
						range between unbounded preceding and current row) as default_frame
			, count(*) over(partition by username order by enddate
						range between unbounded preceding and unbounded following) as ct
            , row_number() over(partition by username order by enddate) as row_part_by_user 
		from useractivity
    )
    
select *
from cte_countWithRowFix
where row_part_by_user = case 
							when ct = 1 then ct = 1
                            else ct - 1
							end 












