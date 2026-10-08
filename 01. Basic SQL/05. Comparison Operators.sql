--Write a query to show all films that have: rental_rate greater than 4
select * from film where rental_rate > 4;

--Write a query to find all rentals that happened: on or after 2005-08-01
select * from rental where rental_date >= '2005-08-01';

--Write a query to find all rentals that have NOT been returned yet.
select * from rental where return_date is null;

--Write a query to find films that: have rating 'PG' or 'PG-13' AND rental_rate less than 3
select * from film where (rating in ('PG', 'PG-13')) and (rental_rate < 3);

--Write a query to list all films, ordered by: rental_rate from highest to lowest
select * from film order by rental_rate desc;

--Write a query to show the top 5 most expensive films by rental_rate.
select * from film order by rental_rate desc limit 5;

-- Write a query to find rentals that: happened after 2005-07-01 AND are already returned
select * from rental where rental_date > '2005-07-01' and return_date is not null;

--Write a query to list customers whose: first name starts with 'A' results should be ordered alphabetically by last name
select * from customer where first_name like 'A%' order by last_name asc;