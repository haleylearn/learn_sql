/*
https://www.youtube.com/watch?v=90iK6gGvG_g
SQL Interview Problem asked by Product Based Company | Solving SQL Interview Query

-- Dataset
drop table emp_input;
create table emp_input
(
id      int,
name    varchar(40)
);
insert into emp_input values (1, 'Emp1');
insert into emp_input values (2, 'Emp2');
insert into emp_input values (3, 'Emp3');
insert into emp_input values (4, 'Emp4');
insert into emp_input values (5, 'Emp5');
insert into emp_input values (6, 'Emp6');
insert into emp_input values (7, 'Emp7');
insert into emp_input values (8, 'Emp8');

select * from emp_input;
*/

-- Solution 1:
select concat(x.id, x.name, ',', x.lead_id, x.lead_name) as result
from (
		select *
		, lead(id,1) over() as lead_id
		, lead(name,1) over() as lead_name
		from emp_input e1
) x
where mod(x.id, 2) <> 0;

-- Solution 2:
select concat(id,name, ',' , id+1,' Emp',id+1) as Output 
from emp_input
where mod(id,2) <> 0;  

-- Solution 3:
with cte as
    (select concat(id, ' ', name) as name
    , ntile(4) over(order by id) as buckets
    from emp_input)
    
select group_concat(name) as final_result
from cte
group by buckets
order by 1;





















