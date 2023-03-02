/*
DATASET

create table patient_logs
(
  account_id int,
  date date,
  patient_id int
);

insert into patient_logs values (1, STR_TO_DATE('02 01 2020', "%d %m %Y"), 100);
insert into patient_logs values (1, STR_TO_DATE('27012020', "%d %m %Y"), 200);
insert into patient_logs values (2, STR_TO_DATE('01012020', "%d %m %Y"), 300);
insert into patient_logs values (2, STR_TO_DATE('21012020', "%d %m %Y"), 400);
insert into patient_logs values (2, STR_TO_DATE('21012020', "%d %m %Y"), 300);
insert into patient_logs values (2, STR_TO_DATE('01012020', "%d %m %Y"), 500);
insert into patient_logs values (3, STR_TO_DATE('20012020', "%d %m %Y"), 400);
insert into patient_logs values (1, STR_TO_DATE('04032020', "%d %m %Y"), 500);
insert into patient_logs values (3, STR_TO_DATE('20012020', "%d %m %Y"), 450);

Question: Find the top 2 accounts with the maximum number of unique patients on a monthly basis.
*/

select month, account_id, cnt_no_patient
from (
	select 
		* 
		, rank() over(partition by month order by cnt_no_patient desc, account_id) as rank_
	from 
	(
		select
			monthname(date) as month, account_id
			, count(distinct patient_id) as cnt_no_patient
		from patient_logs
		group by monthname(date), account_id
	) x) x2
where rank_<3




    









