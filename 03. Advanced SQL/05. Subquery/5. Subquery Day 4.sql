select * from customer;
select * from payment;
select * from rental;


--Subquery vs JOIN (VERY IMPORTANT)
--This is the heart of optimization.

--Subquery
select * 
from payment p1
where amount > 
			(select avg(amount)
			 from payment p2
			 where p1.customer_id = p2.customer_id
			);

--Join using above subquery
select 
	p1.customer_id,
	p1.amount,
	p2.avg_amt
from payment p1
join
	(select customer_id, avg(amount) as avg_amt
	 from payment
	 group by customer_id) p2
on p1.customer_id = p2.customer_id
where p1.amount > p2.avg_amt;

--Why JOIN is Often Faster

--Correlated Version
--Compute AVG repeatedly


--JOIN Version
--Compute AVG once per customer
--Reuse results

--THIS is optimization.
--Optimization often means:
--Move repeated work OUTSIDE the row loop



--My question
--I am cnfused that subquery also comput avg once per customer like for 
--customer_id 4 it computes it's average one time and join also computes customer_id 4 
--average one time, so what is the difference

--CORE 					DIFFERENCE
--Correlated Subquery		JOIN
--Recomputes per row		Computes once
--Repeated AVG scans		Reuses precomputed result
--Expensive on big tables	Much more scalable


--for detailed answer refere to word document



--Part 5: Derived Tables (Optimization Gold)

--Derived Table

--FROM (
--    SELECT ...
--) t

--Why professionals love them
--
--They:
--
--modularize logic
--avoid repeated work
--simplify debugging
--improve readability

SELECT AVG(total_payments)
FROM (
    SELECT customer_id,
           COUNT(*) AS total_payments
    FROM payment
    GROUP BY customer_id
) t

--What happened?
--Instead of recomputing counts repeatedly:
--
--✔ Compute once
--✔ Reuse

--Part 6: Anti-join Optimization
--Not Exists

select *
from customer c
where not exists
			(select 1
			 from payment p
			 where p.customer_id = c.customer_id
			);
--Meaning
--Customers with no payments.

--Why professionals prefer this
--Compared to:
--
--LEFT JOIN ...
--WHERE payment_id IS NULL
--
--NOT EXISTS is often:
--cleaner
--safer
--semantically stronger

--PART 7 — Red Flags Professionals Watch
--🚩 Red Flag 1
--Correlated aggregate on huge table
--🚩 Red Flag 2
--Repeated subquery in SELECT
--🚩 Red Flag 3
--Nested subqueries inside nested subqueries
--🚩 Red Flag 4
--Using subquery when JOIN is simpler

select 
	p1.*,
	p2.max_amt
from payment p1
join (
	 select customer_id, max(amount) as max_amt 
	 from payment
	 group by customer_id) p2 
on p1.customer_id = p2.customer_id 
where p1.amount = p2.max_amt;

--Why better?
--MAX computed once per customer
--instead of per row.

--PART 9 — Real Professional Thinking
--🧠 Beginners ask:
--
--“Does query work?”
--
--🧠 Professionals ask:
--How many scans?
--Repeated work?
--Can it scale?
--Is it readable?
--Can optimizer optimize it?


--PART 10 — Most Important Optimization Principle
--💥 SQL Performance = Avoid Repetition
--
--Main Causes of Slowness
--Cause						Why Slow
--Correlated aggregates		Repeated execution
--Large IN lists			Memory/comparison
--Deep nesting				Complex execution
--Repeated calculations		Wasteful



--PROFESSIONAL CHECKLIST

--Before finalizing query ask:

--✔ Is subquery repeated?
--✔ Can JOIN precompute?
--✔ Is EXISTS better?
--✔ Is logic modular?
--✔ Is table scanned multiple times?