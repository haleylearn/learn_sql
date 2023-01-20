
insert into cars values (5, 'Model S', 'Tesla', 'Silver', 2018);
insert into cars values (6, 'Ioniq 5', 'Hyundai', 'Green', 2021);
/* Scenario 1: Data duplicated based on SOME of the columns 
https://www.youtube.com/watch?v=h48xzQR3wNQ

drop table if exists cars;
create table if not exists cars
(
    id      int,
    model   varchar(50),
    brand   varchar(40),
    color   varchar(30),
    make    int
);
insert into cars values (1, 'Model S', 'Tesla', 'Blue', 2018);
insert into cars values (2, 'EQS', 'Mercedes-Benz', 'Black', 2022);
insert into cars values (3, 'iX', 'BMW', 'Red', 2022);
insert into cars values (4, 'Ioniq 5', 'Hyundai', 'White', 2021);
insert into cars values (5, 'Model S', 'Tesla', 'Silver', 2018);
insert into cars values (6, 'Ioniq 5', 'Hyundai', 'Green', 2021);


drop table if exists cars2;
create table if not exists cars
(
    id      int,
    model   varchar(50),
    brand   varchar(40),
    color   varchar(30),
    make    int
);
insert into cars2 values (1, 'Model S', 'Tesla', 'Blue', 2018);
insert into cars2 values (2, 'EQS', 'Mercedes-Benz', 'Black', 2022);
insert into cars2 values (3, 'iX', 'BMW', 'Red', 2022);
insert into cars2 values (4, 'Ioniq 5', 'Hyundai', 'White', 2021);
insert into cars2 values (1, 'Model S', 'Tesla', 'Blue', 2018);
insert into cars2 values (4, 'Ioniq 5', 'Hyundai', 'White', 2021);
*/

-- Requirement: Delete duplicate data from cars table. Duplicate record is identified based on the model and brand name.
select * from cars;
-- SOLUTION 1: Delete using Unique identifier
delete from cars
where cars.id in (
		select x.getIdDup 
        from (
			select max(id) as getIdDup
			from cars
			group by model, brand
			having count(*) > 1) x);
        
-- SOLUTION 2: Using SELF join
delete from cars
where cars.id in (
select x.getIdDup  
from (
		select c2.id as getIdDup
		from cars c1
		join cars c2
		on c1.brand = c2.brand and c1.model=c2.model and c2.id > c1.id) x);

-- SOLUTION 3: Using Window function
select x.id
from ( 
		select *
			, row_number() over(partition by model, brand) as rn
		from cars) x
where x.rn > 1;

-- SOLUTION 4: Using MIN function. This delete even multiple duplicate records.
select * 
from cars 
where id not in (
	select min(id)
	from cars
	group by model, brand
);
      
-- SOLUTION 5: Using backup table
create table cars_bk
as 
select * from cars where 1=2;
-- create backup table with empty data but have same structure as original table cars

insert into cars_bk
select * 
from cars 
where id in (
	select min(id)
	from cars
	group by model, brand
);

drop table cars;
alter table cars_bkp rename to cars;

-- SOLUTION 6: Using backup table without dropping the original table.
drop table if exists cars_bkp;
create table if not exists cars_bkp
as
select * from cars where 1=0;

insert into cars_bkp
select * from cars
where id in ( select min(id)
              from cars
              group by model, brand);

truncate table cars;

insert into cars
select * from cars_bkp;

drop table cars_bkp;



/* ##########################################################################
   <<<<>>>> Scenario 2: Data duplicated based on ALL of the columns <<<<>>>>
   ########################################################################## */

-- Requirement: Delete duplicate entry for a car in the CARS table.

select * from cars2;

-- SOLUTION 1: Delete using CTID / ROWID (in Oracle)
delete from cars2
where ctid in ( select max(ctid)
                from cars2
                group by model, brand
                having count(1) > 1);
                
-- SOLUTION 2: By creating a temporary unique id column
ALTER TABLE cars2
ADD row_temp_id int not null auto_increment primary key;

select max(row_temp_id)
from cars2
group by model, brand
having count(1) > 1;

alter table cars drop column row_num;


-- SOLUTION 3: By creating a backup table.
create table cars_bkp as
select distinct * from cars2;

drop table cars2;
alter table cars_bkp rename to cars2;


-- SOLUTION 4: By creating a backup table without dropping the original table.
create table cars_bkp as
select distinct * from cars2;

truncate table cars2;

insert into cars2
select distinct * from cars_bkp;

drop table cars_bkp;



