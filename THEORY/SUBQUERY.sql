-- Sub Query
select * from client.department;
select * from client.employee;

select avg(salary) from client.employee;

/* How many type of subquery ?
	1. Scalar Subquery 
		-> It's always return 1 row and 1 column.
    2. Mutiple Row Subquery 
		-> It's returns multiple columns and multiple rows.
		-> It's returns only 1 column and multiple rows.
    3. Correlated Subquery
		-> A subquery which is related to the outer query
	4. Nested Subquery (Subquery in Subquery in Subquery)

*/ 

-- 1.Scalar Subquery
/* Question: Find the employee who's salary is more than avg salary all employee 
	1. Find value avg salary
	2. Find employee base on above result
*/ 
select * -- outer query/ main query
from client.employee
where salary > (select avg(salary) from client.employee); -- inner query/ sub query

select * 
from employee e 
join (select avg(salary) avg_sal from client.employee) re_sult
	 on e.salary > re_sult.avg_sal;


-- 2. Mutiple Row Subquery 
/* Question: Find the employee who's earn the highest salary in each department 
			-> It's returns multiple columns and multiple rows. */ 
select dept_id, max(salary) max_sal from employee group by dept_id;
 
select *
from employee e 
join (select dept_id, max(salary) max_sal from employee group by dept_id) max_tb
	on e.dept_id = max_tb.dept_id and e.salary = max_tb.max_sal;

select * 
from employee e  
where (dept_id, salary) in (select dept_id, max(salary) max_sal from employee group by dept_id);

/* Question: Find the department not have any employee 
			-> It's returns multiple only 1 column and multiple rows.*/ 

select dept_id
from client.department
where dept_id not in (select distinct(dept_id) from client.employee);


-- 3. Correlated Subquery 
/* Question: Find the employee in each department who's salary is more than avg salary in that department
			-> A subquery which is related to the outer query */ 
select dept_id, round(avg(salary),2)
from employee e 
group by dept_id;

select * 
from employee e 
join (select dept_id, round(avg(salary),2) avg_sal from employee e group by dept_id) avg_tb
	on e.dept_id = avg_tb.dept_id and e.salary > avg_tb.avg_sal;

select * 
from employee e1 
where salary > (select avg(salary)
					from employee e2 
					where e1.dept_id = e2.dept_id
					);
/* Question: Find the department not have any employee */
select * 
from department d
where not exists (select 1 from employee e where e.dept_id = d.dept_id);


-- 4.Nested Subquery
/* Question: Find store who's sales where better than the avg sales accross the store
	1. Find total sales of each store
	2. Find avg sales for all the store
    3. Compare 1 & 2
*/ 
select * from client.sales;

select store_id, store_name, sum(price*quantity) total_sales
from client.sales
group by store_id, store_name
having total_sales > (select avg(price*quantity) from client.sales);

select * 
from (
	select store_id, store_name, sum(price*quantity) total_sales
	from client.sales
	group by store_id, store_name
) sales
join (
	select avg(total_sales) as avg_sales
		from (
			select store_id, store_name, sum(price*quantity) total_sales
			from client.sales
			group by store_id, store_name
		) x -- Chỗ này phải có tên gọi bí danh x do xuất hiện mã lỗi Eror Code: 1248 : Every derived table must have its own alias
) avg_tb -- Chỗ này phải có tên gọi bí danh avg_tb do xuất hiện mã lỗi Eror Code: 1248 : Every derived table must have its own alias
on sales.total_sales > avg_tb.avg_sales;


-- Working with WITH
with sales as (
	select store_id, store_name, sum(price*quantity) total_sales
	from client.sales
	group by store_id, store_name
)

select * 
from sales
join (
	select avg(total_sales) as avg_sales
		from sales
) avg_tb
on sales.total_sales > avg_tb.avg_sales;

/* Where can write subquery
1. SELECT 
2. FROM - example above
3. WHERE - example above
4. HAVING 
5. INSERT
6. UPDATE
7. DELETE
*/

-- 1. SELECT - Using subquery on select => Scalary subquery 
/* Question: Fetch all employee details and add remarks to those employees who earn more than avg pay */
select *, 
	(case 
		when salary > (select round(avg(salary),2) from employee) then "greater than"
        else "no"
		end
    ) remarks
from employee;
-- => Avoid using because every single record your query will process this whole sql query that you have mention in your select class will also get process
-- => Fix as below

select *, 
	(case 
		when salary > avg_sal.sal then "greater than"
        else "no"
		end
    ) remarks
from employee
cross join (select round(avg(salary),2) sal from employee) avg_sal;


-- 4. HAVING - Using subquery on having
/* Question: Find the stores who have sold more unit than avarage units sold by all stores*/
select store_id, store_name, sum(quantity) totals
from client.sales
group by store_id, store_name
having totals > (select avg(quantity) from client.sales);


-- 5. INSERT - Using subquery on insert
/* Question: Insert data employee ihstory table. Make sure not insert duplicate records*/

select * from client.employee_his;

insert into client.employee_his
select e.emp_id, e.emp_name, d.dept_id, e.salary, d.dept_name
from client.employee e
join client.department d
on e.dept_id = d.dept_id
where not exists (select 1 
					from client.employee_his eh 
					where eh.emp_id = eh.emp_id
                    );

-- 6. UPDATE - Using subquery on update
/* Question: Give 10% increment to all employee in location is IT based on the maximum by salary they earn
by an emp in each dept. Only consider employees in employee_his table

UPDATE employee AS U1, employee_his AS U2 
SET U1.location = U2.location
WHERE U2.emp_id = U1.emp_id

insert into employee(emp_id, emp_name, dept_id, salary, location)
values('126','Hoang', 'D3', 8500, 'Finance')

 */
select * from employee;

select * from DEPARTMENT;
update client.employee e
set salary = ( select max(salary) + max(salary * 0.1)
				from employee_his eh
				where eh.dept_id = e.dept_id )
where e.location in (select dept_name from department where dept_name = 'IT')
and e.emp_id in (select emp_id from employee_his);


-- 7. DELETE - Using subquery on delete
/* Question: Delete all ç dont have any employee */
delete 
from department d
where d.dept_id not in (select distinct dept_id from employee);




