SELECT * FROM db_assignment.attendances;
SELECT * FROM db_assignment.sessions;

SELECT * FROM db_assignment.users;



-- 1.Calculate the average rating given by students to each teacher for each session created.
-- Also, provide the batch name for which session was conducted.
select info.name, r.avg_ra, b.name
from db_assignment.sessions s
join
	(select session_id, round(avg(rating), 2) as avg_ra
		from db_assignment.attendances 
		group by session_id) r
on r.session_id = s.id
join
	(select id, name
		from db_assignment.users) info
on info.id = s.conducted_by
join
	(select id, name
		from db_assignment.batches) b
on s.batch_id = b.id;

 
-- 2.Find the attendance percentage for each session for each batch. Also mention the batch name and users name who has conduct that session

with re_table as(
	select re.session_id, s.batch_id, re.total
	from db_assignment.sessions s 
	join 
		(select session_id, count(student_id) as total
			from db_assignment.attendances
			group by session_id) re
	on s.id = re.session_id
)


select session_id, b.name as batch_name, total as total_student
	, PERCENT_RANK() OVER ( ORDER BY total) * 100 as percent
from re_table
join db_assignment.batches b 
on re_table.batch_id = b.id;


-- 3.What is the average marks scored by each student in all the tests the student had appeared?
select u.name, avg_tb.avg_tb
from db_assignment.users u 
join 
	(select user_id, round(avg(score), 2) as avg_tb
		from db_assignment.test_scores t
		group by user_id) avg_tb
on u.id = avg_tb.user_id;



-- 4.A student is passed when he scores 40 percent of total marks in a test. 
-- Find out how many students passed in each test. Also mention the batch name for that test.

select test_id, user_id, score, t.total_mark, round((score/t.total_mark)*100, 2) as percent_scrore
from db_assignment.test_scores s
join  db_assignment.tests t
on s.test_id = t.id
where round((score/t.total_mark)*100, 2) >= 40;
 
/*
5.A student can be transferred from one batch to another batch. If he is transferred from batch a to batch b. 
batch b’s active=true and batch a’s active=false in student_batch_maps.
At a time, one student can be active in one batch only. One Student can not be transferred more than four times. 
Calculate each students attendance percentage for all the sessions created for his past batch. 
Consider only those sessions for which he was active in that past batch.
*/

with cte_x as (
	select student_id, s.batch_id as bat_id, count(s.batch_id) as cou_atten_bybatId
	from db_assignment.attendances a
	join db_assignment.sessions s
	on a.session_id = s.id
	group by student_id, s.batch_id
)

select student_id, bat_id
	, cte_x.cou_atten_bybatId
    , total_session_by_batchId
	, round(cte_x.cou_atten_bybatId / total_session_by_batchId *100) percent_attend
from cte_x
join 
	(select batch_id, count(id) as total_session_by_batchId
	from db_assignment.sessions
	group by batch_id) x
on cte_x.bat_id = x.batch_id ;


-- 6. What is the average percentage of marks scored by each student in all the tests the student had appeared?
select user_id, test_id, avg(score)
from db_assignment.test_scores
group by user_id, test_id;


/*
7. A student is passed when he scores 40 percent of total marks in a test. 
Find out how many percentage of students have passed in each test. Also mention the batch name for that test.
*/

with cte_total_above_40 as (
	select test_id, count(user_id) as total_above_40
	from db_assignment.test_scores
	where score > 40 
	group by test_id
),
cte_total_user_by_user as (
		select test_id, count(user_id) as total_users
		from db_assignment.test_scores
		group by test_id 
),
cte_getBatchName as (
	select t.id as testId, batch_id, name
	from db_assignment.tests t
	join db_assignment.batches b
	on t.batch_id = b.id
)

select 
	cte_total_above_40.test_id as test_id
    , cte_getBatchName.name
	, total_above_40 as passed_stu
    , total_users
    , round(total_above_40/total_users*100, 2) as percent_stu_passed
from cte_total_above_40 
join cte_total_user_by_user
on cte_total_above_40.test_id = cte_total_user_by_user.test_id
join cte_getBatchName 
on cte_total_above_40.test_id = cte_getBatchName.batch_id;



/*
	8. A student can be transferred from one batch to another batch. 
    If he is transferred from batch a to batch b. batch b’s active=true and batch a’s active=false in student_batch_maps.
    At a time, one student can be active in one batch only. One Student can not be transferred more than four times.
    Calculate each students attendance percentage for all the sessions.

*/





















