use test 

/*
-- CREATE TABLE
create table scoretable
	( event_id int not null,
		participant_name varchar(255),
		score int not null )

-- INSERT DATA
insert into scoretable ( event_id, participant_name, score )
   values
     ( 1434, 'Duyen', 72 ),  
	 ( 1434, 'Hoa', 60), 
	 ( 1434, 'Nashi', 90 ),
	 ( 1434, 'Thanh', 80 ),
	 ( 1434, 'Ha', 90 ), 

	 ( 1770, 'Duyen', 10 ),  
	 ( 1770, 'Hoa', 20), 
	 ( 1770, 'Nashi', 35 ),
	 ( 1770, 'Thanh', 80 ),

	 ( 1889, 'Duyen', 50 ),  
	 ( 1889, 'Linh', 30), 
	 ( 1889, 'Nashi', 90 ),
	 ( 1889, 'Nashi', 80 )
	 ( 1889, 'Duyen', 80 );
	 
*/


with cte as (
	select *
		, dense_rank() over(partition by event_id order by score desc) as rank_desc
	from scoretable)

select t_first.event_id,  t_first.first, t_second.second, t_third.third
from  (select event_id, STRING_AGG(participant_name,',') as first from cte where rank_desc = 1 group by event_id) as t_first
join (select event_id, STRING_AGG(participant_name,',') as second from cte where rank_desc = 2 group by event_id) as t_second
on t_first.event_id = t_second.event_id
join (select event_id, STRING_AGG(participant_name,',') as third from cte where rank_desc = 3 group by event_id) as t_third
on t_first.event_id = t_third.event_id

select * from scoretable order by event_id

