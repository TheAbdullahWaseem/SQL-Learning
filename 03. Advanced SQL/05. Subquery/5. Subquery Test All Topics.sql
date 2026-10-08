--Q1 — Show each customer with:

--customer_id
--first_name
--number of rentals

select
	c.customer_id,
	c.first_name,
	(
		select count(*)
		from rental r
		where c.customer_id = r.customer_id
	)
from customer c;



--Q2 — Find customers whose:

--total payments > average payment across all customers

select 
	c.customer_id,
	c.first_name || ' ' || c.last_name as full_name,
	sum(p.amount) as total_spending
from payment p
join customer c
	on c.customer_id = p.customer_id
group by c.customer_id
having sum(p.amount) > 
	(
		select avg(total_spending) 
		from
			(
				select customer_id, sum(p2.amount) as total_spending
				from payment p2 
				group by customer_id
			) t
	);

--Comparison between Q2 and Q6

--In above question GROUP BY → then filter, Filtering happens AFTER aggregation

--Q3 — Find all films that belong to category = 'Action'

select *
from film 
where film_id in
	(
		select film_id 
		from film_category
		where category_id in
			(
				select category_id 
				from category
				where name = 'Action'
			)
	);

--Same query with different but more professional style

select *
from film 
where film_id in
	(
		select f.film_id
		from film_category f
		join category c
			on f.category_id = c.category_id
		where c.name = 'Action'
	);

--Q4 — Find customers who have made at least one payment.

select *
from customer c 
where exists
	(
		select 1
		from payment p
		where c.customer_id = p.customer_id
	);

--Q5 — Find films that have never been rented.

select *
from film f
where not exists
	(
		select 1
		from inventory i
		join rental r
			on i.inventory_id  = r.inventory_id
		where f.film_id = i.film_id
	);
	
--Q6 — Show:

--customer_id
--total_spending

--Then filter:
--Only include customers whose spending > average spending of all customers.

select 	
	customer_id, total_spending
from 
	(
		select p.customer_id, sum(p.amount) as total_spending
		from payment p
		group by customer_id
	) t
where total_spending >
	(
		select avg(total) from
		(
			select customer_id, sum(amount) as total
			from payment p group by customer_id
		) x
	);


--Comparison between Q2 and Q6

--In above query, First build a clean dataset,
--then treat it like a table then filter it

--When to write query like Q6?

--KEY SIGNAL
--Use derived table when you see:
--
--“aggregation of aggregation”
--Example:
--
--AVG(SUM(amount))
--MAX(COUNT(*))
--
--THIS automatically means derived table


--Use HAVING when:
--
--one aggregation level
--simple filter after group

--Use DERIVED TABLE when:
--
--multiple aggregation steps
--comparison between aggregated results
--“average of totals”
--“max of sums”
--layered business logic

--If the problem has “layers of aggregation” → use derived table
--If it is “single aggregation filter” → use HAVING


--Q7 — Find customers whose total payment is greater than ANY single customer’s total payment.
select *
from customer c
where 
	(
	select sum(amount)
	from payment p
	where p.customer_id = c.customer_id
	) > any 
		(
		select sum(amount)
		from payment
		group by customer_id
	);

--Q8 — Find films whose rental rate is greater than ALL films in category “Comedy”.

select *
from film f
where f.rental_rate > all
	(
		select f2.rental_rate
		from film f2
		join film_category fc
			on f2.film_id = fc.film_id 
		join category c
			on fc.category_id = c.category_id
		where c.name = 'Comedy'
	);

--Q9 — Find customers who:

--live in cities where country = 'Afghanistan'
--AND
--have made payments above average customer payment

select 
	cu.customer_id,
	cu.first_name,
	sum(p.amount) as total_spending
from payment p 
join customer cu
	on cu.customer_id = p.customer_id
join address a
	on a.address_id = cu.address_id
join city c
	on c.city_id = a.city_id 
join country ct 
	on ct.country_id = c.country_id 
where ct.country = 'Austria'
group by cu.customer_id, cu.first_name
having sum(p.amount) > 
	(
	select avg(customer_total) 
	from
		(
		select 
			customer_id,
			sum(p.amount) as customer_total
		from payment
		group by customer_id
		) t
	);


--Q10 — Explain briefly:
--Why this is wrong: 

SELECT * 
FROM customer 
WHERE 
	( 
	SELECT COUNT(*) 
	FROM payment 
	) > 5;

--why it is wrong


Answer
A subquery in WHERE must depend on the outer query, 
otherwise it becomes a constant and makes the condition meaningless.


--Correct Query

select * 
from customer c
where 
    ( 
    select COUNT(*) 
    from payment p
    where p.customer_id = c.customer_id  
    ) > 5;