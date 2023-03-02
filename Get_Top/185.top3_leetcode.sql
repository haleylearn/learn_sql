create table employee_test
(
    id         int,
    name   varchar(20),
    salary        int,
    departmentId  int
);

insert into employee_test values (1, 'Joe', 85000, 1);
insert into employee_test values (2, 'Henry', 80000, 2);
insert into employee_test values (3, 'Sam', 60000, 2);
insert into employee_test values (4, 'Max', 90000, 1);
insert into employee_test values (5, 'Janet', 69000, 1);
insert into employee_test values (6, 'Randy', 85000, 1);
insert into employee_test values (7, 'Will', 70000, 1);

use db_assignment;
select * from employee_test;

-- Solution 1:
-- Phải có dấu bằng bởi vì không hiểu sao nó không lấy giá trị count = 0, 
-- nên lấy thênm giá trị bằng để khi so sánh với giá trị cao nhất hoặc thấp nhất sẽ có giá trị 1
select e1.departmentId, e1.id, e1.name, e1.salary, count(distinct e2.salary)
from employee_test e1
join employee_test e2
	on e2.salary >= e1.salary and e1.departmentId = e2.departmentId
group by e1.departmentId, e1.id, e1.name, e1.salary
having count(distinct e2.salary) < 3
order by e1.departmentId desc;

-- Solution 2:
SELECT
    e1.DepartmentId, e1.Name AS 'Employee', e1.Salary
FROM
    employee_test e1
WHERE
    3 > (SELECT
            COUNT(DISTINCT e2.Salary)
        FROM
            employee_test e2
        WHERE
            e2.Salary >= e1.Salary
                AND e1.DepartmentId = e2.DepartmentId
        );

-- Solution 3:
select *
from employee_test e1
where salary >= (select min(salary)
						from (select *
									from employee_test e2
                                    where e1.DepartmentId = e2.DepartmentId
									order by salary desc
									limit 3) x);
					
-- Solution 4:
select *
from (
	select 
		departmentId, name, salary
		, row_number() over(partition by DepartmentId order by salary desc) as rn
	from employee_test) x
where x.rn <= 3


