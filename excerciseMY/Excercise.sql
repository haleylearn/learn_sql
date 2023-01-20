
-- https://techtfq.com/blog/solving-3-tricky-sql-interview-queries
select 
	case 
		when translation is null then comment
        else translation
        end as output
from comments_and_translations;

select * 
from comments_and_translations;


select coalesce(translation, comment) as output
from comments_and_translations;



select * 
from target;

select * 
from source;

-- Question: Using the Source and Target table. Provide the solution without using subqueries.
-- Solution 1:
with recursive_ as (
	select s.id as id1, s.name as name1, t.id as id2, t.name as name2
	from source s left join target t on s.id = t.id
	union 
	select s.id as id1, s.name as name1, t.id as id2, t.name as name2
	from source s right join target t on s.id = t.id
),
 resul as (
	select *
	, case
		when recursive_.id1 = recursive_.id2 and recursive_.name1 = recursive_.name2 then 'Old'
        when recursive_.id2 is null and recursive_.name2 is null then 'New in source'
        when recursive_.id1 is null and recursive_.name1 is null then 'New in target'
        when recursive_.id1 = recursive_.id2 and recursive_.name1 <> recursive_.name2 then 'Miss match'
        end as output
	from recursive_
)

select coalesce(id1, id2) as Id, output
from resul
where output <> 'Old';


-- Solution 2:
select s.id as Id, 'New in source' Comment 
from source s
left join target t
on s.id = t.id 
where t.id is null and t.name is null

UNION 

select t.id as Id, 'New in target' Comment 
from target t 
left join source s
on t.id = s.id 
where s.id is null and s.name is null

UNION 

select s.id as Id, 'Mismatch' Comment 
from source s
join target t
on s.id = t.id and s.name <> t.name;



/*
QUERY 3: IPL Matches

There are 10 IPL team. write an sql query such that each team play with every other team just once.

Also write another query such that each team plays with every other team twice
*/

with mark_id as 
	(select 
		row_number() over() as id
		, t.*
		from teams t
	)

select *
from mark_id t
join mark_id o on t.id < o.id;

-- Also write another query such that each team plays with every other team twice
with mark_id as 
	(select 
		row_number() over() as id
		, t.*
		from teams t
	)

select *
from mark_id t
join mark_id o on t.id <> o.id;


with recursive recur_fama as
(	
	select * from family_members
), 

base_query as (	
		select person_id, relative_id1 as relative, substring(person_id,1, 3) as fam_gr
		from family_members 
		where relative_id1 is not null
		union
		select person_id, relative_id2 as relative, substring(person_id,1, 3) as fam_gr
		from family_members 
		where relative_id2 is not null
	)
	
select relative_id1, relative_id2
from family_members ;













