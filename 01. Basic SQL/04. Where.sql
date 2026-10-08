--Get all columns for films that have a rating of 'PG'.
select * from film where rating = 'PG';

--Find films where the rental_rate is greater than 3.
select * from film where rental_rate > 3;

--Show customers whose first name is 'MARY'.
select * from customer where first_name = 'Mary';

--Find rentals that happened after July 1, 2005.
select * from rental where rental_date >= '2005-7-01';

--Find films that:
--have a rating of 'PG-13'
--AND rental_rate is less than 3
select * from film where rating = 'PG-13' and rental_rate < 3;

--Find films whose rating is PG, PG-13, or R.
select * from film where rating in ('PG', 'PG-13', 'R')

--Find rentals where the return_date is NULL.
select * from rental where return_date is null;

--Find films whose title starts with 'A'.
select * from film where title like 'A%';