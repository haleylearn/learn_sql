use db_assignment;
/*

create table billing
(
      customer_id               int
    , customer_name             varchar(1)
    , billing_id                varchar(5)
    , billing_creation_date     date
    , billed_amount             int
);

insert into billing values (1, 'A', 'id1', str_to_date('10-10-2020','%d-%m-%Y'), 100);
insert into billing values (1, 'A', 'id2', str_to_date('11-11-2020','%d-%m-%Y'), 150);
insert into billing values (1, 'A', 'id3', str_to_date('12-11-2021','%d-%m-%Y'), 100);
insert into billing values (2, 'B', 'id4', str_to_date('10-11-2019','%d-%m-%Y'), 150);
insert into billing values (2, 'B', 'id5', str_to_date('11-11-2020','%d-%m-%Y'), 200);
insert into billing values (2, 'B', 'id6', str_to_date('12-11-2021','%d-%m-%Y'), 250);
insert into billing values (3, 'C', 'id7', str_to_date('01-01-2018','%d-%m-%Y'), 100);
insert into billing values (3, 'C', 'id8', str_to_date('05-01-2019','%d-%m-%Y'), 250);
insert into billing values (3, 'C', 'id9', str_to_date('06-01-2021','%d-%m-%Y'), 300);

*/


-- Solution 1:
with cte_getYearByCus as 
	(
		select * 
			, year(billing_creation_date) as year_by_cus
			, count(*) over(partition by customer_id) as cnt_by_cus
		from billing
		where year(billing_creation_date) between 2019 and 2021

	)
	, cte_getColToRo as 
	(
			select 
			customer_id
			, customer_name
			, cnt_by_cus
			, sum( case when year_by_cus = 2019 then billed_amount else 0 end) as y_2019
			, sum( case when year_by_cus = 2020 then billed_amount else 0 end) as y_2020
			, sum( case when year_by_cus = 2021 then billed_amount else 0 end) as y_2021
		from cte_getYearByCus
		group by customer_id, customer_name
	)
	, cte_getTotalCouByCus as
	(
			select 
			*
			, case
				when y_2019 = 0 then cnt_by_cus + 1 
				when y_2020 = 0 then cnt_by_cus + 1 
				when y_2021 = 0 then cnt_by_cus + 1 
				else cnt_by_cus
				end as total_cnt
		from cte_getColToRo
	)

select * 
, round((y_2019 + y_2020 + y_2021 ) / total_cnt, 2) as result
from cte_getTotalCouByCus;


-- Solution 2:
/*
				Giải thích tại sao chỗ này bằng 3, bởi vì count()
				Khi count(*) nó sẽ đếm tất cả các dòng, kể cả null => 3
				Khi count(1) nó sẽ count value, kể cả null => 3
                Khi count(0) nó sẽ count value, kể cả null => 3, vì vậy nếu câu lệnh là then billed_amount else 0 end => nó vẫn sẽ đếm giá trị 0
				Khi count(billed_amount) một giá trị cụ thể nó sẽ không count giá trị null
*/
with cte as 
	(
		select 
			customer_id
			, customer_name
			, sum(case when year(billing_creation_date) = 2019 then billed_amount else 0 end) as y_2019
			, sum(case when year(billing_creation_date) = 2020 then billed_amount else 0 end) as y_2020
			, sum(case when year(billing_creation_date) = 2021 then billed_amount else 0 end) as y_2021
            , count(case when year(billing_creation_date) = 2019 then billed_amount else null end) cnt_2019_wrong
            , count(case when year(billing_creation_date) = 2019 then billed_amount else null end) cnt_2019
            , count(case when year(billing_creation_date) = 2020 then billed_amount else null end) cnt_2020
            , count(case when year(billing_creation_date) = 2021 then billed_amount else null end) cnt_2021
		from billing
		group by customer_id, customer_name
	)
    
select 
    customer_name, customer_id
    , (y_2019+y_2020+y_2021) / 
			(case when cnt_2019 = 0 then 1 else cnt_2019 end 
			+ case when cnt_2020 = 0 then 1 else cnt_2020 end
            + case when cnt_2021 = 0 then 1 else cnt_2021 end) as avg_bill
		
from cte;
