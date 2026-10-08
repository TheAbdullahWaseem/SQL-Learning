--Topic 1: Correlated Subqueries

--A correlated subquery is a subquery that depends on the 
--outer query and is executed once for each row of the outer query

--Normal subquery → runs once
--Correlated subquery → runs for EVERY row

--See the Difference Clearly

--Normal (Independent) Subquery

select * 
from payment
where amount > (
				select avg(amount) from payment
				);
--Inner query runs once
--Result reused

--Correlated Subquery

--Find payments higher than the customer’s own average
select *
from payment p1
where amount > (
			select avg(amount)
			from payment p2
			where p2.customer_id = p1.customer_id 
				);


--This part:
--p2.customer_id = p1.customer_id
--This connects inner query to outer query

/*Problem
Correlated subqueries can be:
VERY SLOW on large datasets
Because:
Outer rows × Inner query execution

Example
1000 rows → inner query runs 1000 times


Identify Correlated Subquery
Ask this:

“Does inner query use outer query column?”

YES → Correlated
NO → Independent


*/

--Find customers whose payment is greater than their own average
select customer_id
from payment p1
where amount > (
				select avg(amount)
				from payment p2
				where p1.customer_id = p2.customer_id 
				);

--Find payments that are the maximum for each customer
select *
from payment p1
where amount = (select max(amount) from payment p2
				where p1.customer_id = p2.customer_id) 
				
				
				
--Topic 2: Exists with Correlation:
				
--Combine:

--EXISTS (check if something exists)
--Correlation (use outer query data)			

				
--MASTER DEFINITION
--“For each row, check if a related row exists”

--Basic Pattern
/*				
SELECT *
FROM table1 t1
WHERE EXISTS (
    SELECT 1
    FROM table2 t2
    WHERE t2.col = t1.col
);			
*/

--“Find customers who made at least one payment”
select *
from customer c
where exists (select 1 from payment p
			  where c.customer_id = p.customer_id);


/*
Why EXISTS + Correlation is Powerful

It answers:

“Has at least one…”
“Does there exist…”
“Check condition per entity”
This is used everywhere:
Customers with orders
Users with activity
Products with sales
*/

--“Find customers who made payment > 10”
select *
from customer c
where exists (select 1 from payment p
			  where c.customer_id = p.customer_id
			  and p.amount > 10);

--Meaning
--For each customer:
--“Does there exist a payment > 10?”

--NOT exists

--“Find customers with NO payments”

SELECT *
FROM customer c
WHERE NOT EXISTS (
    SELECT 1
    FROM payment p
    WHERE p.customer_id = c.customer_id
);

--Meaning
--Include only those customers:
--for whom NO payment exists

--THIS IS CALLED
--Anti-Join Logic (very important in real work)

--“Find all payments of customers who made at least one payment > 10”

SELECT *
FROM payment p1
WHERE EXISTS (
    SELECT 1
    FROM payment p2
    WHERE p2.customer_id = p1.customer_id
      AND p2.amount > 10
);

--It returns all payments of the customer who made at least one high payment

/*
Ask this:

“Am I checking existence per row?”

YES → use EXISTS + correlation

PART 10 — Performance Awareness
Correlated EXISTS runs per row

BUT:

It stops early (very important)

Why it's efficient
As soon as 1 row is found → stop checking

FINAL 			SUMMARY
Concept			Meaning
EXISTS			Check if row exists
Correlated		Uses outer row
Together		Per-row existence check
NOT EXISTS		Find missing data

*/

--Find customers who made at least one payment less than 2
select *
from customer c
where exists (select 1 from payment p 
			  where c.customer_id = p.customer_id 
			  and p.amount < 2);

select *
from payment p1
where exists (select 1 from payment p2 
			  where p1.customer_id = p2.customer_id 
			  and p2.amount < 2);

select * from payment
where amount < 2;

--The difference in above query with the prevous queries is this that
--this above query returns only customers having amount < 2
--and previous queries returns customers having one amount less than 2
--but also return those amounts of the customers that are greater than
--2 but the condition is they must have at least one amount < 2/

--Find customers who NEVER made payment > 10
select *
from customer c 
where not exists (select 1 from payment p
			      where c.customer_id = p.customer_id 
			      and p.amount > 10)


--Find payments of customers who have at least one payment above average
		      
select customer_id, amount
from payment p1
where exists (select 1 
			  from payment p2
			  where p1.customer_id = p2.customer_id
					and p2.amount > (
						select avg(amount)
						from payment));

--Topic 3: Real Patterns

--PATTERN 1 — “FOR EACH …”
--Meaning
--Do something row-by-row / entity-by-entity

--Example
--“For each customer, check something about their payments”

--Query Pattern
SELECT *
FROM customer c
WHERE ... (
    SELECT ...
    FROM payment p
    WHERE p.customer_id = c.customer_id
);


--This is ALWAYS:
--Correlated subquery


--PATTERN 2 — “CHECK IF EXISTS”
--Meaning
--Does at least one row satisfy condition?

WHERE EXISTS (
    SELECT 1
    FROM table2 t2
    WHERE t2.key = t1.key
      AND condition
);

/*
Combine Both → MOST POWERFUL PATTERN

Master Pattern
SELECT *
FROM table1 t1
WHERE EXISTS (
    SELECT 1
    FROM table2 t2
    WHERE t2.key = t1.key
      AND condition
);
Translation
“For each row in table1, check if a related row exists in table2”
*/


--“Customers who made both small (<2) AND large (>10) payments”
SELECT *
FROM customer c
WHERE EXISTS (
    SELECT 1 FROM payment p
    WHERE p.customer_id = c.customer_id
      AND p.amount < 2
)
AND EXISTS (
    SELECT 1 FROM payment p
    WHERE p.customer_id = c.customer_id
      AND p.amount > 10
);


/*
PART 8 — PROFESSIONAL THINKING FRAMEWORK
When you see a question, ask:
1️⃣ “For each WHAT?”
customer?
payment?
product?
2️⃣ “Check WHAT condition?”
exists?
greater than?
equal to max?
3️⃣ “Return WHAT?”
entity?
all rows?
filtered rows?
PART 9 — MOST COMMON INTERVIEW PATTERNS
 Exists pattern

 Has at least one

 Not exists

 Missing data

 Correlated aggregate

 Compare with group

 Entity filtering

 Select all rows of qualified group
*/

--Customers whose ALL payments are greater than 3
select * from
customer c
where not exists (select 1 from payment p
				  where c.customer_id = p.customer_id 
				  	and p.amount < 3)
				   
--Payments of customers who NEVER made a payment below average
select *
from customer c
where not exists (select 1 from payment p
			  where c.customer_id = p.customer_id
			  and p.amount < (select avg(amount)
			  						from payment));

--Customers who made more payments than the average number of payments per customer
select customer_id, count(*)
from payment p1
group by customer_id
having count(*) > (select avg(total) from
					(select count(*) as total
					from payment p2
					group by customer_id)
		t);
	
--Topic 4: Performance Awareness

--CORE IDEA
--Not all correct queries are good queries

--Why Subqueries Can Be Slow
--Biggest Reason
--Repeated execution

/*Correlated Subquery Problem
What actually happens
For each row in payment:
    Run subquery AGAIN
Example
10,000 rows
Subquery runs 10,000 times

VERY slow 

PART 2 — Complexity Thinking (IMPORTANT)
 Normal query
O(n)
 Correlated subquery
O(n × m)

 Can explode quickly
 PART 3 — EXISTS vs IN Performance
EXISTS (FAST)
WHERE EXISTS (...)

 Stops when first match is found

 IN (SLOWER sometimes)
WHERE id IN (SELECT ...)

 Builds full list first

 Rule
EXISTS → better for large datasets
IN → fine for small datasets

*/

--PART 4 — Subquery vs JOIN
--❌ Correlated subquery
SELECT *
FROM payment p1
WHERE amount > (
    SELECT AVG(amount)
    FROM payment p2
    WHERE p2.customer_id = p1.customer_id
);

--Better using JOIN (or window later)

SELECT p1.*
FROM payment p1
JOIN (
    SELECT customer_id, AVG(amount) AS avg_amt
    FROM payment
    GROUP BY customer_id
) t
ON p1.customer_id = t.customer_id
WHERE p1.amount > t.avg_amt;


--Why JOIN is faster?

--Compute once → reuse
--Not repeated per row
/*
PART 5 — When to AVOID Correlated Subqueries
 Avoid when:
Large tables
Millions of rows
Repeated aggregation
Same calculation per row

  Use when:
Logic is complex
Small datasets
EXISTS checks*/



/*
PART 6 — Red Flags (Professional Level)

If you see:

subquery inside WHERE using outer column

Think:

“Can this be rewritten using JOIN?”
PART 7 — Smart Optimization Thinking
Step 1

Identify repeated work

Step 2

 Move it outside (precompute)

Step 3

 Join results
*/


--PART 8 — Example Optimization


--Slow
SELECT *
FROM payment p1
WHERE amount = (
    SELECT MAX(amount)
    FROM payment p2
    WHERE p2.customer_id = p1.customer_id
);


--Faster
SELECT p1.*
FROM payment p1
JOIN (
    SELECT customer_id, MAX(amount) AS max_amt
    FROM payment
    GROUP BY customer_id
) t
ON p1.customer_id = t.customer_id
WHERE p1.amount = t.max_amt;

/*
PART 9 — Real Professional Rules
RULE 1

Avoid repeated calculations

RULE 2

Prefer JOIN for aggregation reuse

RULE 3

Use EXISTS for existence checks

RULE 4

Think about data size


PART 10 — When Correlated Subqueries are GOOD
Best Use Case
WHERE EXISTS (...)

Because:

Stops early
No full scan needed


FINAL SUMMARY
Situation				Best Approach
Per-row logic			Correlated
Existence check			EXISTS
Large dataset			JOIN
Repeated aggregation	Avoid subquery
*/



when to use exists and when to Not



/*
EXAMPLES (IMPORTANT)
“Customers with at least one payment > 10”

EXISTS

“Customers with NO payments”

NOT EXISTS

“Customers whose ALL payments > 5”

NOT EXISTS (amount <= 5)

“Payments greater than average”

> (comparison)*/



--Question

--“Customers who made ONLY payments less than 10”

/*We will use not exists + amount >= 10

Why NOT EXISTS?

Because:

You are checking absence of a condition, not comparing values



❌ Why NOT < ?
WHERE amount < 10

This checks only one row, not ALL rows

Why NOT EXISTS alone?
EXISTS (amount < 10)

This means:

“At least one payment < 10”

*/