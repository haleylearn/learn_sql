create table product(product_id int, category varchar(100), brand varchar(100), name varchar(100), price int);

insert into product( product_id, category , brand , name , price )
values(6,'Phone', 'Apple', '7s Plus', 500 );

select * from product;

DROP TABLE product;
DELETE FROM product WHERE product_id = 6  ;

/* FIRST VALUE, LAST VALUE

NOTES: LAST VALUE
RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW (default frame in sql)
It means that the frame starts at the first row and ends at the current row of the result set.

RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
This indicates that the frame starts at the first row and ends at the last row of the result set.
*/

-- Question: Display the most expensive  and the lowest roduct under each category (correcsponding to each record)

select * 
	, first_value(name) over(partition by category order by price desc) as most_exp_pri
    , last_value(name) over(partition by category order by price desc
		ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
		-- RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        -- ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING 
		-- RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
		) as lowest_ROWS
	, last_value(name) over(partition by category order by price desc
		RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
		) as lowest_pri_RANGE
	, last_value(name) over(partition by category order by price desc
		RANGE BETWEEN 1 PRECEDING AND 1 FOLLOWING
		) as lowest_pri_custom
from product
where category = 'Phone';


select name, category, number_,
    sum(number_) over w rows_
    , sum(number_) over(partition by category ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW ) rows_and_cur
from product
where category = 'Phone'

-- WINDOW ALIAS;
 window w as (partition by category ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING);


-- NTH VALUE
-- Question: Query display  the second most expensive product under each category

select name, category, price
    , nth_value(name, 2) over w as nth_
from product
-- WINDOW ALIAS
 window w as (partition by category order by price desc RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING);



/* 
Hàm NTILE là một hàm rất có ích nếu bạn chỉ muốn trả lại một nhóm cụ thể trong các bản ghi. 
Đồng nghĩa với việc bạn muốn chia các dữ liệu bảng ghi theo các phân cụm nhóm cụ thể theo ý bạn muốn.
Dưới đây là một ví dụ khi tôi muốn trả lại chỉ nhóm người có độ tuổi trung bình (Nhóm Age 2) từ ví dụ trên.

SELECT FirstName, Age, Age AS [Age Group]
FROM
  (SELECT FirstName, Age, NTILE(3) OVER (ORDER BY Age) AS AgeGroup
	FROM Person) A
WHERE AgeGroup = 2

SELECT
  account_id, standard_qty
  , NTILE(4) OVER (PARTITION BY account_id ORDER BY standard_qty) AS standard_quartile
FROM demo.orders
*/

-- Question: Query to segregate all the expensive phone, mid range and cheap phone
select * 
	, case 
		when x.ntile_ = 1 then 'Exp'
        when x.ntile_ = 2 then 'Mid'
        when x.ntile_ = 3 then 'Cheap'
        end as segregate
from (
	select name, category, price
		, ntile(3) over (order by price desc ) as ntile_
	from product
	where category = 'Phone') x;



/* CUME_DIST() Tính phần trăm và xếp hạng
Used to indentify the distribution percentage of each record with all record in the table
cume_dist()	(Số bản ghi trong window <= hàng hiện tại) / tổng bản ghi
Value -> 0 < cum_dist() <= 1
Formula = Current Row no. (or Row No with value same as current row) / Total no of row


For the first row, the function finds the number of rows in the result set, which have value less than or equal to 55. 
The result is 2. Then CUME_DIST() function divides 2 by the total number of rows which is 10: 2/10. 
The result is 0.2 or 20%. The same logic is applied to the second row.
*/

-- Question: Query to fetch all products which are consituting the first 30% of the data in product table base on price
select name, cume_dist_percent
from 
	(select *
    , round(cume_dist() over (order by price desc) * 100, 2) cume_dist_percent
	from product) x
where x.cume_dist_percent > 30;


/* PERCENT_ RANK() Relative rank of the current row / Percentage Ranking
Used to indentify the distribution percentage of each record with all record in the table
Value -> 0 < percent_rank() <= 1
Formula = (Current row no - 1) / (total_rows - 1)

The PERCENT_RANK() function always returns zero for the first row in a partition or result set. 
The repeated column values will receive the same PERCENT_RANK() value.

Both PARTITION BY and ORDER BY clauses are optional. 
However, the PERCENT_RANK() is an order sensitive function, therefore, you should always use the ORDER BY clause.

Here are some analyses from the output:

The order values of Trains were not better than any other product lines, which was represented with a zero.
Vintage Cars performed better than 50% of other products.
Classic Cars performed better than any other product lines so its percent rank is 1 or 100%

*/

select * 
	, round(percent_rank() over(partition by category order by price) * 100 , 2)
from product;











