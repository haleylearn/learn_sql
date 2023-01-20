select * from employee;

/*
1. Declaration of Single CTE

	WITH <CTE NAME><COLUMN LIST > AS
	<	QUERY STATEMENT >
	SELECT * FROM <CTE NAME>;

*/

-- Question: Fetch employees who earn more than avg salary of all employees
with avg_salary (avg_sal) as (select avg(salary) from employee)

select *
from employee e, avg_salary
where e.salary > avg_salary.avg_sal;


/* Question: Find stores who's sales where better than the average sales accross all stores
	1. Find total sale per each store
	2. Find avg all stores
	3. Compare total_sales each store > average sales
*/

select * from sales;
-- 	1. Find total sale per each store
select store_id, sum(quantity * price) total_sales
from sales
group by store_id;

-- 2. Find avg all stores
select avg(total_sales)
from (select store_id, sum(quantity * price) total_sales
		from sales
		group by store_id) as x;
        
-- 	3. Compare total_sales each store > average sales
select *
from 	(select store_id, sum(quantity * price) total_sales
		from sales
		group by store_id) re1
cross join  
		(select avg(total_sales) avg_total_sales
		from 	(select store_id, sum(quantity * price) total_sales
				from sales
				group by store_id) as x
		) re2
on re1.total_sales > re2.avg_total_sales;

-- Fix with CTE
with	sum_by_store (store_id, total_sales) as
			(select store_id, sum(quantity * price) total_sales
			from sales
			group by store_id),
		avg_all_store (avg_sal) as
			(select avg(total_sales) avg_sal
            from sum_by_store)

select *
from sum_by_store s
join avg_all_store a
on s.total_sales > a.avg_sal;

/*
Recursive WITH
Recursive WITH or Hierarchical queries, is a form of CTE where a CTE can reference to itself, i.e., a WITH query can refer to its own output, hence the name recursive.

*/
WITH RECURSIVE t AS (
   SELECT SALARY FROM data
   UNION ALL
   SELECT SALARY FROM data WHERE SALARY < 50000
)
SELECT * FROM t;









