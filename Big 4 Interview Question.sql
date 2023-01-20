/*
	https://www.youtube.com/watch?v=dWHSt0BVlv0
	Practice SQL Interview Query | Big 4 Interview Question
    Question: Write a query to fetch the record of brand whose amount is increasing every year.
*/
with cte as 
(
	select * 
	, LAG(amount) OVER (partition by brand) AS near_last_event_name
    , LAG(amount) OVER (partition by brand) - amount as value_check
	from brands
	order by brand
)

select *
from brands
where brand not in (
	select brand
	from cte
	where value_check <= 0
);

select *
    , lead(amount, 1, amount+1)
                                over(partition by brand order by year)
              
from brands;


