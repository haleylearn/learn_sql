/*
DATASET
CREATE TABLE OLYMPICS_HISTORY
(
    id          INT,
    name        VARCHAR(100),
    sex         VARCHAR(100),
    age         VARCHAR(100),
    height      VARCHAR(100),
    weight      VARCHAR(100),
    team        VARCHAR(100),
    noc         VARCHAR(100),
    games       VARCHAR(100),
    year        INT,
    season      VARCHAR(100),
    city        VARCHAR(100),
    sport       VARCHAR(100),
    event       VARCHAR(100),
    medal       VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS OLYMPICS_HISTORY_NOC_REGIONS
(
    noc         VARCHAR(100),
    region      VARCHAR(100),
    notes       VARCHAR(100)
);
*/

use kaggle_assi;
select * from OLYMPICS_HISTORY where season = 'summer';
select * from OLYMPICS_HISTORY_NOC_REGIONS;

/*
	6. Identify the sport which was played in all summer olympics.
	Algorithm: 
	Step 1: Get table with condition where season = 'summer'
	Step 2: Find total distinct games have in Step 1 cnt_of_games
	Step 3: Find total distinct sport have in Step 1 cnt_of_sport
	Step 4: Compare cnt_of_games and cnt_of_sport if equal => will get this

*/
select sport, count(sport) as cnt
from (
	select distinct games, sport
	from OLYMPICS_HISTORY
	where season = 'summer'
	group by games, sport
) x
group by sport
having count(sport) = (
							select count(distinct(games)) as count_of_games
							from OLYMPICS_HISTORY
							where season = 'summer'
						);

/*
11. Fetch the top 5 athletes who have won the most gold medals.

Problem Statement: SQL query to fetch the top 5 athletes who have won the most gold medals.
*/

with cte_getListGold as (
	select name, count(name) as total_cnt_gold
	from OLYMPICS_HISTORY
	where Medal = 'gold'
	group by name
    order by count(1) desc
),
cte_getRanking as (
	select *
		, dense_rank() over(order by total_cnt_gold desc) as ranking
	from cte_getListGold
)  
select *
from cte_getRanking
where ranking < 6;

/*
14. List down total gold, silver and bronze medals won by each country.
*/
-- Solution 1:
select noc as country
	, sum(case when medal = 'Gold' then 1 else 0 end) as Gold
    , sum(case when medal = 'Silver' then 1 else 0 end) as Silver
    , sum(case when medal = 'Bronze' then 1 else 0 end) as Bronze
from OLYMPICS_HISTORY
group by noc
order by noc;


-- Solution 2: Using crosstab, tìm hiểu thêm về crosstab bởi vì mysql không hỗ trợ, giúp chuyển đổi hoặc làm pivot
-- https://stackoverflow.com/questions/15997090/crosstab-view-in-mysql
select noc, medal, count(1) as total_medal
from OLYMPICS_HISTORY
where medal <> 'NA'
group by noc, medal;


/*
16. Identify which country won the most gold, most silver and most bronze medals in each olympic games.*/

with cte_getTotalByNoc as (
	select games, noc
		, sum(case when medal = 'Gold' then 1 else 0 end) as cnt_gold
		, sum(case when medal = 'Silver' then 1 else 0 end) as cnt_silver
		, sum(case when medal = 'Bronze' then 1 else 0 end) as cnt_bronze
		from (
					select * 
					from OLYMPICS_HISTORY
					where medal <> 'NA'
				) x
	group by games, noc
	order by games
),
cte_getMaxlMedal as (
	select *
		, dense_rank() over(partition by games order by cnt_gold desc) as rank_gold
        , dense_rank() over(partition by games order by cnt_silver desc) as rank_silver
        , dense_rank() over(partition by games order by cnt_bronze desc) as rank_bronze
	from cte_getTotalByNoc
)

select t1.games, t1.max_gold, t2.max_silver, t3.max_bronze
from (select games, concat(noc, ' - ', cnt_gold) as max_gold from cte_getMaxlMedal where rank_gold < 2) t1
join (select games, concat(noc, ' - ', cnt_silver) as max_silver from cte_getMaxlMedal where rank_silver < 2) t2
join (select games, concat(noc, ' - ', cnt_bronze) as max_bronze from cte_getMaxlMedal where rank_bronze < 2) t3
on t1.games = t2.games and t1.games = t3.games;

-- 20. Break down all olympic games where India won medal for Hockey and how many medals in each olympic games

select 
	games, team, count(medal) as total_medals
from OLYMPICS_HISTORY
where team = 'India' and medal <> 'NA' and sport = 'Hockey'
group by games, team
order by count(medal) desc;













