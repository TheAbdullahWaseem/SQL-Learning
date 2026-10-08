--1. WHAT IS A SUBQUERY IN SELECT?

--A SELECT subquery is:
--
--a calculation done for each row of the outer query
--
--So instead of filtering rows (WHERE), we are:
--
--ADDING NEW INFORMATION TO EACH ROW

--SELECT subquery means:
--“Show me a column that is calculated from another query”

--3. BASIC STRUCTURE
SELECT
    column1,
    column2,
    (subquery) AS calculated_column
FROM table;

--Problem:
--Show each customer with their total spending.

select 
	c.customer_id,
	c.first_name,
	(
		select sum(p.amount) as total_spending
		from payment p
		where c.customer_id = p.customer_id
	) as total_spending
from customer c
order by customer_id;

--IMPORTANT TRUTH
--SELECT subquery =
--loop over rows + compute value per row

--5. CORRELATED SUBQUERY
--This is ALWAYS:
--subquery depends on outer query
--Example:
--WHERE p.customer_id = c.customer_id
--WHY THIS IS IMPORTANT
--Because:
--each row gets its own calculation


--Show customers + number of rentals
select
	c.customer_id,
	c.first_name,
	(
		select count(*)
		from rental r
		where c.customer_id = r.customer_id 
	) as rental_count
from customer c;

--7. IMPORTANT RULE: WHEN TO USE SELECT SUBQUERY?

/*
Use SELECT subquery when:
1. You want extra column per row

Example:
total spending per customer
number of rentals per film

2. You cannot get value from simple JOIN

Example:
aggregate per row
conditional calculation

3. You want quick analytical metric

Example:
“show each customer with their score”

DO NOT use SELECT subquery when:
you need filtering → 			use WHERE
you need grouping → 			use GROUP BY
you need full dataset → 		use JOIN
*/


--SELECT SUBQUERY vs WHERE SUBQUERY
--
--Clause				Purpose

--WHERE					filter rows
--SELECT				add computed column

--PROFESSIONAL THINKING MODEL

--STEP 1
--Do I want to FILTER or ENRICH rows?
--
--FILTER 	→ 		WHERE
--ENRICH 	→ 		SELECT

--STEP 2
--Is value per row needed?

--If YES 	→ 		SELECT subquery

/*
LIMITATION

SELECT subqueries:

run once per row

So:

easy to write
but can be slow on large datasets

This is where later you will learn:

JOIN optimization
window functions (much faster)


SELECT SUBQUERY PATTERN TYPES

You must recognize these 3:

1. Scalar value per row
(SELECT SUM(...))

2. Count per row
(SELECT COUNT(*))

3. Conditional per row
(SELECT MAX(...))

*/

select
	customer_id,
	sum(amount) as total_spending
from payment
group by customer_id
order by customer_id;

--This returns
--ONE ROW PER CUSTOMER
--
--Meaning:
--dataset becomes aggregated
--detail rows disappear
--
--You now ONLY have:
--customer_id
--total_spending


--SELECT SUBQUERY PURPOSE
--
--SELECT subquery is used when:
--
--you want to KEEP original rows
--AND add extra analytics
--
--This is VERY important.

/*
EXAMPLE (VERY IMPORTANT)

Suppose business asks:

Show:

customer_id
first_name
email
total spending

Now your GROUP BY query fails.

Because:

first_name and email are not grouped


THIS IS WHERE SELECT SUBQUERY BECOMES POWERFUL

Now we do:
**/

SELECT
    c.customer_id,
    c.first_name,
    c.email,
    (
        SELECT SUM(p.amount)
        FROM payment p
        WHERE p.customer_id = c.customer_id
    ) AS total_spending
FROM customer c;

--WHAT HAPPENED HERE?
--
--We kept:
--
--original customer rows
--
--AND added:
--
--analytical metric
--
--without collapsing rows.

/*
THIS IS THE CORE DIFFERENCE
GROUP BY			SELECT Subquery

collapses rows		keeps rows
aggregate dataset	enrich rows
summary query		reporting query

Use GROUP BY when:

you want summarized dataset

Use SELECT subquery when:

you want detailed rows with extra analytics

ANOTHER HUGE INSIGHT

Later…

Window functions will replace MANY SELECT subqueries because:

cleaner
faster
scalable

BUT:

you MUST understand SELECT subqueries first

otherwise window functions become confusing.

GROUP BY
Transform dataset into summary

SELECT SUBQUERY
Keep dataset and attach analytics
*/

/*
RULE OF ALIASING SUBQUERIES
🟢 CASE 1 — SUBQUERY IN FROM → MUST HAVE ALIAS

Example:

SELECT *
FROM (
    SELECT customer_id, SUM(amount)
    FROM payment
    GROUP BY customer_id
) t;

❌ Without t → ERROR in SQL

✔ Reason:
Because SQL needs a name for the temporary table.

🟡 CASE 2 — SUBQUERY IN WHERE → NO ALIAS NEEDED

Example:

SELECT *
FROM customer
WHERE address_id IN (
    SELECT address_id FROM address
);

✔ No alias needed

✔ Because result is just a value list

🟡 CASE 3 — SUBQUERY IN SELECT → NO ALIAS INSIDE, BUT MUST ALIAS OUTPUT

Example:

SELECT
    customer_id,
    (
        SELECT COUNT(*)
        FROM rental
        WHERE rental.customer_id = customer.customer_id
    ) AS total_rentals
FROM customer;

✔ The subquery itself has no alias
✔ BUT the result column MUST have alias (total_rentals)

🧠 SIMPLE MEMORY SYSTEM
🔵 If subquery acts like a TABLE → NEED alias
FROM (subquery) AS t
🟢 If subquery acts like a VALUE → NO alias needed
WHERE column IN (subquery)
🟡 If subquery is in SELECT → alias ONLY for output column
(SELECT ...) AS column_name

*/


--Problem: 1
--
--Show each customer with:
--
--customer_id
--first_name
--total number of rentals

select 
	c.customer_id,
	c.first_name,
	(
		select count(*) as total_rentals
		from rental r
		where c.customer_id = r.customer_id
	) as total_rentals
from customer c;

--Problem
--Find all customers who live in cities where the country is 'India'.

select *
from customer c
where address_id in
	(
		select address_id
		from address a 
		where city_id in
			(
				select c3.city_id
				from country c2
				join city c3
					on c2.country_id = c3.country_id
				where country = 'India'
			) 
	);

--Problem 3
--Find all films that have never been rented.

select * from
film f
where not exists
	(
		select 1
		from inventory i
		where f.film_id = i.film_id
			and i.inventory_id in
			(
				select inventory_id 
				from rental
			)
	);

--Above query is correct in both logic and result
--but below one is more cleaner and more standard one.

SELECT *
FROM film f
WHERE NOT EXISTS
(
    SELECT 1
    FROM inventory i
    JOIN rental r
        ON i.inventory_id = r.inventory_id
    WHERE i.film_id = f.film_id
);

--Instead of:
--IN (SELECT ...)
--we directly express:
--
--inventory → rental relationship

--More readable
--More scalable in real systems
--JOIN inside EXISTS is usually optimized better than nested IN in many engines.



--Problem: 4
--Show each customer with:
--
--customer_id
--first_name
--total spending
--
--BUT only include customers whose total spending is greater
--than the average customer spending.


select
	c.customer_id,
	c.first_name,
	t.total_spending
from customer c
join
		(
	select 
		customer_id,
		sum(amount) as total_spending
	from payment
	group by customer_id
		) t
	on c.customer_id = t.customer_id 
where t.total_spending > 
			(
		select avg(total_spending)
		from
				(
			select
				customer_id,
				sum(amount) as total_spending
			from payment
			group by customer_id
				) x
			);

--Why this version is better
--✔ Separation of logic
--inner query → builds dataset
--outer query → filters dataset
--✔ No conflict between GROUP BY and SELECT subquery
--You are no longer mixing two styles.


