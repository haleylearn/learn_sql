
/*
// Table: Matches

// +-----------------+---------+
// | Column Name     | Type    |
// +-----------------+---------+
// | home_team_id    | int     |
// | away_team_id    | int     |
// | home_team_goals | int     |
// | away_team_goals | int     |
// +-----------------+---------+

// Each row of the result table should contain:
// Teams table:
// +---------+-----------+
// | team_id | team_name |
// +---------+-----------+
// | 1       | Ajax      |
// | 4       | Dortmund  |
// | 6       | Arsenal   |
// +---------+-----------+

// Matches table:
// +--------------+--------------+-----------------+-----------------+
// | home_team_id | away_team_id | home_team_goals | away_team_goals |
// +--------------+--------------+-----------------+-----------------+
// | 1            | 4            | 0               | 1               |
// | 1            | 6            | 3               | 3               |
// | 4            | 1            | 5               | 2               |
// | 6            | 1            | 0               | 0               |
// +--------------+--------------+-----------------+-----------------+

// Result table:
// +-----------+----------------+--------+----------+--------------+-----------+
// | team_name | matches_played | points | goal_for | goal_against | goal_diff |
// +-----------+----------------+--------+----------+--------------+-----------+
// | Dortmund  | 2              | 6      | 6        | 2            | 4         |
// | Arsenal   | 2              | 2      | 3        | 3            | 0         |
// | Ajax      | 4              | 2      | 5        | 9            | -4        |
// +-----------+----------------+--------+----------+--------------+-----------+

// Ajax (team_id=1) played 4 matches: 2 losses and 2 draws. Total points = 0 + 0 + 1 + 1 = 2.
// Dortmund (team_id=4) played 2 matches: 2 wins. Total points = 3 + 3 = 6.
// Arsenal (team_id=6) played 2 matches: 2 draws. Total points = 1 + 1 = 2.
// Dortmund is the first team in the table. Ajax and Arsenal have the same points,
 but since Arsenal has a higher goal_diff than Ajax, 
Arsenal comes before Ajax in the table.

// Write an SQL query to report the statistics of the league. 
The statistics should be built using the played matches where the winning team gets three points and the losing team gets no points. 
If a match ends with a draw, both teams get one point.



DATASET
use db_assignment;
create table Teams
(
    team_id         int,
    team_name   varchar(20)
   
);
insert into Teams values(1, 'Ajax');
insert into Teams values(4, 'Dortmund');
insert into Teams values(6, 'Arsenal');

create table Matches
(
    home_team_id   int,
    away_team_id   int,
    home_team_goals   int,
    away_team_goals   int
   
);
insert into Matches values(1,4,0,1);
insert into Matches values(1,6,3,3);
insert into Matches values(4,1,5,2);
insert into Matches values(6,1,0,0);
*/




select 
	team_name
	, count(re.team_id) as matches_played
	, sum(points) as points
    , sum(goal_for) as goal_for
    , sum(goal_against) as goal_against
    , sum(goal_diff) as goal_diff
from 
(
select *
		, goal_for - goal_against as goal_diff
		, case 
			when x.goal_for > x.goal_against then 3
			when x.goal_for < x.goal_against then 0
			when x.goal_for = x.goal_against then 1
			end as points
	from (
			select 
				home_team_id as team_id
				, home_team_goals as goal_for
                , away_team_id as away_team_id
				, away_team_goals as goal_against
			from Matches m1
			union all
			select 
				away_team_id as team_id
				, away_team_goals as goal_for
                , home_team_id as away_team_id
				, home_team_goals as goal_against
			from Matches m2
		)x) re
join Teams t on t.team_id = re.team_id
group by re.team_id, team_name
order by team_name desc



