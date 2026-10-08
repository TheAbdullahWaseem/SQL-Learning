--1. What is a Subquery
--A query inside another query that produces a result used
--by the outer query

select 
	first_name, last_name
from customer 
where customer_id 
	in (
		select customer_id
		 from payment
	   );
		

select *
from payment
where amount > 
		(
		select avg(amount)
		from payment
		);

--Independent Subquery

SELECT *
FROM payment
WHERE amount > (
    SELECT AVG(amount) FROM payment
);

--Runs once

--Correlated Subquery (Preview)
SELECT c.first_name
FROM customer c
WHERE EXISTS (
    SELECT 1
    FROM payment p
    WHERE p.customer_id = c.customer_id
);

--Runs for each row

--Types of Subqueries
--1. Scalar Subquery (Single Value)

SELECT *
FROM payment
WHERE amount > (
    SELECT AVG(amount) FROM payment
);
--Returns ONE value

--2. Multi-row Subquery
SELECT *
FROM customer
WHERE customer_id IN (
    SELECT customer_id FROM payment
);

--Returns MANY values

select * 
from payment 
where (customer_id, staff_id) in (
		select customer_id, staff_id 
		from payment
		);

SELECT customer_id, amount
FROM payment
WHERE amount > (
    SELECT AVG(amount) FROM payment
)
AND customer_id IN (
    SELECT customer_id FROM payment WHERE amount < 3
);

SELECT *
FROM payment
WHERE amount < (
    SELECT MAX(amount) FROM payment
);

SELECT *
FROM payment
WHERE (customer_id, staff_id) IN (
    SELECT customer_id, staff_id
    FROM payment
    WHERE amount = (
        SELECT MAX(amount) FROM payment
    )
);

SELECT *
FROM payment
WHERE amount = (
    SELECT MAX(amount) FROM payment
);
