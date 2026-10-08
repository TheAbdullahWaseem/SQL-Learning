/*
1. WHAT DOES A WHERE SUBQUERY REALLY DO?

A WHERE subquery answers this question:

"Which rows should survive?"

The subquery helps the outer query decide:

keep row 
remove row */

--STEP 1 → subquery produces value(s)
--STEP 2 → outer query uses them to filter rows



--FIRST TYPE — SCALAR SUBQUERY IN WHERE
--return ONE VALUE

--Find payments above global average payment.
select *
from payment
where amount >
	(
		select avg(amount)
		from payment
	);
--STEP 1 — Inner Query Runs
--Suppose result is:
--4.20

--STEP 2 — Outer Query Becomes

--SELECT *
--FROM payment
--WHERE amount > 4.20;



--MULTI-ROW SUBQUERY — IN
--Now the subquery returns MULTIPLE rows.

--Customers Who Rented Action Films

--Step 1 — Inner Query
--Find action films.

select film_id
from film_category fc
join category c
	on fc.category_id = c.category_id
where c.name = 'Action';

--Step 2 — Outer Query
--Use IN.

select * 
from inventory i 
where film_id in
	(
		select film_id
		from film_category fc
		join category c
			on fc.category_id = c.category_id
		where c.name = 'Action'
	);
	
--WHY IN EXISTS
--Because:
--film_id = MANY POSSIBLE VALUES


--EXISTS — PROFESSIONAL FILTERING
--EXISTS checks:
--"Does related data exist?"
--It does NOT care about actual values.
--Only:
--found row?
--no row?

--Customers Who Made Payments
select * 
from customer c
where exists
	(
		select 1 
		from payment p
		where c.customer_id = p.customer_id
	);


--NOT EXISTS — ANTI-JOIN THINKING
--One of the MOST important professional skills.

--Customers Without Rentals
select *
from customer c
where not exists
	(
		select 1 
		from rental r
		where c.customer_id = r.customer_id 
	);

--This is called:
--anti-join logic


--ANY — COMPARE AGAINST ANY VALUE
--Find payments greater than ANY payment made by customer 1.

select * 
from payment p
where amount > any
	(
		select amount
		from payment 
		where customer_id = 1
	);

--greater than at least ONE value
--Equivalent idea:
--amount > MIN(values)
--approximately.


--ALL — COMPARE AGAINST ALL values
--Find payments greater than ALL payments by customer 1.

SELECT *
FROM payment
WHERE amount > ALL
(
    SELECT amount
    FROM payment
    WHERE customer_id = 1
);

--greater than every value
--Equivalent idea:
--amount > MAX(values)
--approximately.


--CORRELATED SUBQUERY IN WHERE
--Now inner query depends on outer row.

--Customers Spending Above Their City Average
select *
from customer c
where
	(
		select sum(p.amount)
		from payment p
		where c.customer_id = p.customer_id
	)
	>
	(
		select avg(city_total)
		from
			(
				select
					sum(p2.amount) as city_total
				from customer c2
				join address a
					on c2.address_id = a.address_id 
				join city ci
					on a.city_id = ci.city_id
				join payment p2
					on p2.customer_id = c2.customer_id 
				group by ci.city_id				
			) t
	);



--NESTED SUBQUERY (2 LEVELS MAX)select *
--Films in High-Revenue Categories

select *
from film
where film_id in
	(
		select film_id
		from inventory 
		where store_id in
		(
			select store_id 
			from payment
			group by store_id
			having sum(amount ) > 1000
		)
	);

/*
1. Is this ONE value or MANY values?
Situation		Use
one value		=
many values		IN

2. Am I checking existence?

Use:

EXISTS / NOT EXISTS
 
3. Is inner query dependent on outer row?

If YES:

correlated subquery

4. Am I filtering rows or groups?
Filtering		Clause
rows			WHERE
groups			HAVING*/



--Find payments whose amount is greater than the average payment amount.

select *
from payment
where amount >
	(
		select avg(amount) as avg_payment
		from payment
	);

--Find all films that belong to the Comedy category.
SELECT *
FROM film
WHERE film_id IN
(
    SELECT film_id
    FROM film_category
    WHERE category_id = (
        SELECT category_id
        FROM category
        WHERE name = 'Comedy'
    )
);
/*
INNERMOST QUERY
SELECT category_id FROM category WHERE name='Comedy'

produces ONE value

MIDDLE QUERY
SELECT film_id FROM film_category WHERE category_id = ...

produces MANY film_ids

OUTER QUERY
SELECT * FROM film WHERE film_id IN (...)

filters films*/

/*
Number of layers ≈ number of hops between tables

Example:

Relationship							Layers
film → category directly				1
film → bridge → category				2
customer → address → city → country		3


THINK LIKE A MAP (VERY IMPORTANT)

Imagine DVDRental like a map:

film ---- film_category ---- category

Now ask:

“How many jumps to reach category?”

Answer:

2 jumps

So SQL must reflect those jumps.

Subquery layers are not chosen — they are discovered from table relationships.
*/

--Find all customers who live in the city of “London”.

select *
from customer
where address_id in 
	(
		select address_id
		from address 
		where city_id in
		(
			select city_id
			from city
			where city = 'London'
		)
	);

--Find all customers whose total payments are greater than the average payment per customer.
	
select 
	customer_id, 
	sum(amount) as total_spending
from payment 
group by customer_id
having sum(amount) >
	(
		select avg(total_payment) from
			(
				select customer_id, sum(amount) as total_payment
				from payment
				group by customer_id
			) t
	);

--below query is same as above with same logic but better structure

SELECT customer_id, total_spending
FROM (
    SELECT 
        customer_id, 
        SUM(amount) AS total_spending
    FROM payment 
    GROUP BY customer_id
) t
WHERE total_spending >
(
    SELECT AVG(total_spending)
    FROM (
        SELECT customer_id, SUM(amount) AS total_spending
        FROM payment
        GROUP BY customer_id
    ) x
);


--Find all films that have been rented at least once.
SELECT *
FROM film f
WHERE EXISTS
(
    SELECT 1
    FROM inventory i
    JOIN rental r
        ON i.inventory_id = r.inventory_id
    WHERE i.film_id = f.film_id
);

--here we used join because we cannot extract the rented films without using joins
--as they can only be extracted by combining rental and inventiry, only in that way we can 
--know that which films are rented

--IN
--I only need VALUES
--
--EXISTS
--I need to verify RELATED ROWS
--
--JOIN
--I need rows from tables to work together


/*
Need columns from both tables?
        ↓ YES
      JOIN

        ↓ NO
Need to check existence?
        ↓ YES
      EXISTS

Need list of values?
        ↓ YES
        IN*/


--Find all customers whose total spending is greater than the average spending
--of customers who made at least one rental.

select customer_id, sum(amount) as total_spending
from payment
group by customer_id
having sum(amount) >
		(
			select avg(total_spending)
			from
				(
					select customer_id, sum(amount) as total_spending
					from payment p
					where exists 
						(
							select 1 
							from rental r
							where p.customer_id = r.customer_id
						) 
					group by customer_id
				) t
		);
		
select * from rental;
select * from payment;