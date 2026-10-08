SELECT * FROM payment WHERE customer_id IN (1, 2, 3);

SELECT * FROM film WHERE rating IN ('PG', 'R');

SELECT * FROM film WHERE rating NOT IN ('PG', 'R');

--This returns ZERO rows.
--Why?
--Because SQL logic with NULL is UNKNOWN.
--Any comparison with NULL is not TRUE or FALSE — it’s UNKNOWN.
--So the whole condition fails.
SELECT * FROM customer WHERE customer_id NOT IN (1, 2);
--If using NOT IN, make sure:
--The list does NOT contain NULL
--Or filter NULL explicitly
SELECT * FROM customer WHERE customer_id NOT IN (1, 2) AND customer_id IS NOT NULL;
--IN with Logical Operators
SELECT * FROM payment WHERE customer_id IN (1, 2, 3) AND amount > 5;

--Find payments where amount is 0.99, 2.99, or 4.99.
select * from payment where amount in (0.99, 2.99, 4.99);
--Find customers with first name in ('MARY', 'PATRICIA', 'LINDA').
select * from customer where first_name IN ('Mary', 'Patricia', 'Linda');
--Find films where rating is NOT in ('PG', 'G').
select * from film  where rating not in ('PG', 'G');
--Find payments where: customer_id is 1, 2, or 3 AND amount > 5
select  * from payment where customer_id in (1, 2, 3) and amount > 5;
--Find payments where: amount is 2.99 or 4.99, OR customer_id is 10
select * from payment where amount in (2.99, 5.99) or customer_id = 10;