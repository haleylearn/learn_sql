
/*
DATASET
create table warehouse
(
ID varchar(10),
OnHandQuantity int,
OnHandQuantityDelta int,
event_type varchar(10),
event_datetime timestamp
);

insert into warehouse values
('SH0013', 278, 99 , 'OutBound', '2020-05-25 0:25'),
('SH0012', 377, 31 , 'InBound', '2020-05-24 22:00'),
('SH0011', 346, 1 , 'OutBound', '2020-05-24 15:01'),
('SH0010', 346, 1 , 'OutBound', '2020-05-23 5:00'),
('SH009', 348, 102, 'InBound', '2020-04-25 18:00'),
('SH008', 246, 43 , 'InBound', '2020-04-25 2:00'),
('SH007', 203, 2 , 'OutBound', '2020-02-25 9:00'),
('SH006', 205, 129, 'OutBound', '2020-02-18 7:00'),
('SH005', 334, 1 , 'OutBound', '2020-02-18 8:00'),
('SH004', 335, 27 , 'OutBound', '2020-01-29 5:00'),
('SH003', 362, 120, 'InBound', '2019-12-31 2:00'),
('SH002', 242, 8 , 'OutBound', '2019-05-22 0:50'),
('SH001', 250, 250, 'InBound', '2019-05-20 0:45');

*/
use faag;


with cte_getSeriesDay as 
		(select 
			OnHandQuantity
			, DATE_SUB(event_datetime, INTERVAL 90 DAY ) as day90
			, DATE_SUB(event_datetime, INTERVAL 180 DAY ) as day180
			, DATE_SUB(event_datetime, INTERVAL 270 DAY ) as day270
			, DATE_SUB(event_datetime, INTERVAL 365 DAY ) as day365
		from warehouse 
		limit 1),
    cte_getInv90d as
		(select 
				coalesce(sum(OnHandQuantityDelta), 0) as sum_series_90days
		from warehouse w, cte_getSeriesDay c
		where event_type= 'InBound' and w.event_datetime >= c.day90),
    cte_finalInv90d as 
		(select 
				case when ct2.OnHandQuantity > ct1.sum_series_90days
						then ct1.sum_series_90days else ct2.OnHandQuantity end as sum_series_90days
		from cte_getInv90d ct1, cte_getSeriesDay ct2),
	cte_getInv180d as
		(select 
			coalesce(sum(OnHandQuantityDelta), 0) as sum_series_180days
		from warehouse w, cte_getSeriesDay c
		where event_type= 'InBound' and event_datetime between c.day180 and c.day90),
	cte_finalInv180d as 
		(select 
				case when ct1.OnHandQuantity - ct2.sum_series_90days > ct3.sum_series_180days
				then ct3.sum_series_180days else ct1.OnHandQuantity - ct2.sum_series_90days end as sum_series_180days
		from cte_getSeriesDay ct1, cte_finalInv90d ct2, cte_getInv180d ct3),
	cte_getInv270d as
		(select 
			coalesce(sum(OnHandQuantityDelta), 0) as sum_series_270days
		from warehouse w, cte_getSeriesDay c
		where event_datetime between c.day270 and c.day180),
	cte_finalInv270d as 
		(select 
				case when ct1.OnHandQuantity - ct2.sum_series_180days - ct4.sum_series_90days > ct3.sum_series_270days
				then ct3.sum_series_270days else ct1.OnHandQuantity - ct2.sum_series_180days - ct4.sum_series_90days  end as sum_series_270days
		from cte_getSeriesDay ct1, cte_finalInv180d ct2, cte_getInv270d ct3, cte_finalInv90d ct4)


select 
	t1.sum_series_90days as '0-90 days old'
    , t2.sum_series_180days as '91-180 days old'
    , t3.sum_series_270days as '181-270 days old'
from cte_finalInv90d t1
cross join cte_finalInv180d t2
cross join cte_finalInv270d t3;



 
