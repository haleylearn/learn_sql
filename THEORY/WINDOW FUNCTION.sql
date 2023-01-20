
-- RANKING
SELECT e.*
       , row_number() OVER (ORDER BY salary DESC) row_nb
       , rank() OVER (ORDER BY salary DESC) rank_
       , dense_rank() OVER (ORDER BY salary DESC) dense_rank_
FROM employee e;
/* 
-> Output: 
+--------+--------+------------+------+------------+
|  name  | salary |    row_nb  |rank_ |dense_rank_ |
+--------+--------+------------+------+------------+
| Jackob |  7000  |      1     |   1  |      1     |
| Peter  |  5000  |      2     |   2  |      2     |
| John   |  4000  |      3     |   3  |      3     |
| Shane  |  3000  |      4     |   4  |      4     |
| Rick   |  3000  |      5     |   4  |      4     |
| Sid    |  1000  |      6     |   6  |      5     |
+--------+--------+------------+------+------------+
Hàm ROW_NUMBER dùng để xếp hạng kết quả một cách tuần tự bắt đầu từ 1 và không quan tâm đến các giá trị giống nhau.
Hàm DENSE_RANK() dùng để xếp hạng các giá trị của một cột theo quy tắc các giá trị giống nhau thuộc cùng một hạng,
 giá trị nằm sau các giá trị giống nhau sẽ có hạng lớn hơn 1 đơn vị so với hạng của các giá trị ngay trước nó. 
*/


-- Question: Fetch the first 2 emps from each department to join the company
select x.* 
from (
	select e.*
		, row_number() over(partition by dept_id order by emp_id asc) as row_nb
	from employee e) x
where x.row_nb < 3;

-- Question: Fetch the top 3 emps from each department earning the max salary
select x.* 
from (
	select e.*
		, rank() over(partition by dept_id order by salary desc) as rank_
	from employee e) x
where x.rank_ < 4;

/*
AGGREGATES IN WINDOW
https://app.mode.com/editor/haley2401/reports/0c1741835230/queries/043f256d1a0f
explain SELECT * FROM demo.orders xuất thông tin truy vấn lệnh
*/

SELECT id,
       SUM(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS sum_std_qty,
       COUNT(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS count_std_qty,
       AVG(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS avg_std_qty,
       MIN(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS min_std_qty,
       MAX(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS max_std_qty
FROM demo.orders;
    

/* LAG & LEAD
	Hàm LAG là 1 window function cho phép bạn truy vấn một hoặc nhiều dòng trong 1 bảng mà không cần nối bảng với chính nó. 
	Vì dụ như bạn đang chọn 1 hàng, 
	-> Hàm LAG sẽ trả về giá trị hàng trước nó trong bảng. 
    -> Để trả về giá trị hàng tiếp theo trong bảng, chúng ta sử dụng hàm LEAD.
*/
select e.*
	, lag(salary,1,0) over(partition by dept_id order by emp_id) lag_sal
    -- lag(salary,1,0) 1 là số dòng tiếp theo muốn so sánh, 0 là giá trị dành cho những giá trị null sẽ chuyển về thành 0
    , lead(salary) over(partition by dept_id order by emp_id) lead_sal
from employee e;

-- Question: Fetch all query to display if the salary of an employee is higher, lower or equal to the previous emp
select e.*
	, lag(salary,1,0) over(partition by dept_id order by emp_id) lag_sal
	, case 
		when e.salary > lag(salary,1,0) over(partition by dept_id order by emp_id) then 'Higher'
        when e.salary = lag(salary,1,0) over(partition by dept_id order by emp_id) then 'Equal'
        else 'Lower'
		end compare_pre
from employee e






