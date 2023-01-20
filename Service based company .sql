/*
	https://www.youtube.com/watch?v=_suB8xV9aPc
    Solving SQL Interview Query | SQL Problem by Service based company
    
	Suppose you have a car travelling certain distance and the data is presented as follows:
	Day 1 - 50 km
	Day 2 - 100 km
	Day 3 - 200 km

	Now the distance is a cumulative sum as in
		row2 = (kms travelled on that day + row1 kms).

	How should I get the table in the form of kms travelled by the car on a given day and not the sum of the total distance?

*/
use db_assignment;

select cars, days
	, cumulative_distance - lag(cumulative_distance, 1, 0) over(partition by cars) as lead_travel
from car_travels
order by cars;
