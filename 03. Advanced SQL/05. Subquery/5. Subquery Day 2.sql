--IN
--Check if a value exists in another query

--IN (Value Matching)
select 
	first_name
from customer 
where customer_id in
	(select customer_id from payment);

/*
IN → Works like a LIST
Executes subquery first
Stores results as a list
Then compares
 */


--EXISTS (Row Existence)
select first_name
from customer c
where exists (
			select 1
			from payment p
			where p.customer_id = c.customer_id
			);
--“Run subquery → If it returns any row → TRUE”
--EXISTS = Yes/No check
--SELECT 1 = meaningless placeholder
--You can use anything instead of 1 like 'abc' or * etc


--IN = list matching
--EXISTS = “does it exist?”

--PART 3 — Performance Intuition
/*
IN Behavior
Subquery runs once
Builds full list
Then compares

Can be slow if subquery is large


EXISTS Behavior
Runs per row
Stops at first match

Faster for large datasets

REAL RULE 
Situation			Use
Small dataset		IN
Large dataset		EXISTS 
Correlated logic	EXISTS 
*/


--IN with NULL problem
--WHERE customer_id IN (1, 2, NULL)
--Result becomes unpredictable

--EXISTS handles NULL safely
--It only checks existence, not values

--“Find customers who made at least one payment”
select 
	first_name
from customer c
where exists
	(select 1
	from payment p
	where p.customer_id = c.customer_id);

select 
	first_name
from customer c
where exists
	(select 1
	from payment p
	where p.customer_id = c.customer_id
	and c.customer_id = 5);


--Very Important 


/*
Using IN
SELECT first_name
FROM customer
WHERE customer_id IN (
    SELECT customer_id FROM payment
);
🧠 What happens here?
SELECT customer_id FROM payment;

👉 SQL builds a list like:

1, 2, 3, 5, 8, ...

Then:

WHERE customer_id IN (1,2,3,5,8...)
*/


--Customers with NO payments
SELECT first_name
FROM customer c
WHERE NOT EXISTS (
    SELECT 1
    FROM payment p
    WHERE p.customer_id = c.customer_id
);

select first_name
from customer c
where exists
	(select 1
	from payment p
	where c.customer_id = p.customer_id
		and p.amount > 10);

--Topic 2: ANY and ALL

/*
Both ANY and ALL are used to compare:

 One value with a set of values (subquery)

 Syntax
value operator ANY (subquery)
value operator ALL (subquery)

ANY → “at least one”
amount > ANY (subquery)

 Means:

“greater than at least one value from subquery”

 ALL → “every value”
amount > ALL (subquery)

 Means:

“greater than every value from subquery”

ANY
amount > ANY (2,5,10)

 Means:

2 OR >5 OR >10

 So condition becomes easy:

True if greater than 2

 ALL
amount > ALL (2,5,10)

 Means:

2 AND >5 AND >10

So:

Must be greater than 10

*/
select * from payment
where amount > any(
	select amount from payment where customer_id = 1 		
);


SELECT *
FROM payment
WHERE amount > ALL (
    SELECT amount FROM payment WHERE customer_id = 1
);

--If subquery returns NO rows
/*
ANY
amount > ANY (empty)
FALSE

ALL
amount > ALL (empty)
TRUE (IMPORTANT!)

*/


/*
ALL
amount > ALL (subquery)

Equivalent:

amount > (SELECT MAX(...) )

ANY
amount > ANY (subquery)

Equivalent:

amount > (SELECT MIN(...) )

*/

/*
IN
customer_id IN (1,2,3)

Exact match

ANY
customer_id = ANY (1,2,3)

SAME as IN

KEY RULE
ANY → same as IN
*/


--PROFESSIONAL TIP
--In real-world:

--Use aggregates instead (clearer)
--BUT know ANY/ALL for interviews

--Find payments greater than ALL payments of customer 2
select * from payment
where amount > all(
	select amount from payment
	where customer_id = 2
);

select * from payment 
where amount > (
	select max(amount) 
	from payment where customer_id = 5
	);


--Topic 3: Subqueries with Aggregates
/*
BASIC PATTERN (MEMORIZE THIS)
WHERE column OPERATOR (
    SELECT AGG_FUNCTION(column)
    FROM table
)
*/

--“Find payments greater than average”
SELECT *
FROM payment
WHERE amount > (
    SELECT AVG(amount) FROM payment
);
/*
Step 1:
SELECT AVG(amount) FROM payment;

Suppose result = 4.5

Step 2:
WHERE amount > 4.5
Meaning

Return all payments above average*/

SELECT *
FROM payment
WHERE amount = (
    SELECT MAX(amount) FROM payment
);

SELECT *
FROM payment
WHERE amount > (
    SELECT MAX(amount)
    FROM payment
    WHERE customer_id = 1
);

--Very Important

--Find customers whose total spending is greater than
--the average spending of all customers
SELECT customer_id, sum(amount)
FROM payment
GROUP BY customer_id
HAVING SUM(amount) > (
    SELECT AVG(total)
    FROM (
        SELECT SUM(amount) AS total
        FROM payment
        GROUP BY customer_id
    ) t
);



--SQL does not allow nested aggregates like this
--So we use subquery to solve it

--Break above query into 3 SIMPLE STEPS
--STEP 1 — Calculate total per customer
select customer_id, sum(amount) as total
from payment

--STEP 2 — Find average of those totals
select avg(total)
from (
	select sum(amount) as total
	from payment
	group by customer_id
	) t;
group by customer_id;

/*
 Always ask:

“What am I comparing?”


Situation			Query Style

Row vs global		Subquery + aggregate
Group vs global		HAVING + subquery
Row vs group		Subquery with filter
 */

