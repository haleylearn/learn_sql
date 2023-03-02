/*
DATASET

create table players
(player_id int,
group_id int);

insert into players values (15,1);
insert into players values (25,1);
insert into players values (30,1);
insert into players values (45,1);
insert into players values (10,2);
insert into players values (35,2);
insert into players values (50,2);
insert into players values (20,3);
insert into players values (40,3);

create table Matches
(
match_id int,
first_player int,
second_player int,
first_score int,
second_score int);

insert into record values (1,15,45,3,0);
insert into record values (2,30,25,1,2);
insert into record values (3,30,15,2,0);
insert into record values (4,40,20,5,2);
insert into record values (5,35,50,1,1);

The winner in each group is the player who scored the maximum total points within the group. In the case of a tie, the lowest player_id wins.

Write an SQL query to find the winner in each group.
Result table:
+-----------+------------+
| group_id  | player_id  |
+-----------+------------+ 
| 1         | 15         |
| 2         | 35         |
| 3         | 40         |
+-----------+------------+
*/

-- Solution 1: Use row_number

select group_id, player_id
from (
		select *
		, row_number() over(partition by x.group_id order by score desc) as rank_
		from (
				select
					p.group_id as group_id
					, r.first_player as player_id
					, r.first_score as score
				from players p
				join record r
				on p.player_id = r.first_player

				union all

				select
					p.group_id as group_id
					, r.second_player as player_id
					, r.second_score as score
				from players p
				join record r
				on p.player_id = r.second_player
			) x) re
where rank_ = 1;

-- Solution 2: Use min function and window function
SELECT group_id,MIN(PLAYER_ID) PLAYER_ID FROM (
                  SELECT BB.*, P.group_id, MAX(TOTAL_PLAYER_SCORE) OVER (PARTITION BY group_id) SCORE_MAX_GROUP
                  FROM (
                           SELECT player_id, SUM(PLAYER_SCORE) TOTAL_PLAYER_SCORE
                           FROM (
                                    SELECT first_player PLAYER_ID, first_score PLAYER_SCORE
                                    FROM record
                                    UNION ALL
                                    SELECT second_player PLAYER_ID, second_score PLAYER_SCORE
                                    FROM record
                                ) AA
                           GROUP BY player_id
                       ) BB
                           JOIN PLAYERS P ON P.player_id = BB.PLAYER_ID
              )CC
WHERE TOTAL_PLAYER_SCORE=SCORE_MAX_GROUP
GROUP BY group_id



















