--Left Join
select c.customer_id, p.amount
from customer c
left join payment p
	on c.customer_id = p.customer_id;

--Right Join
select c.customer_id, p.amount
from customer c
right join payment p
	on c.customer_id = p.customer_id;

--Write a query to return each customer’s customer_id, first_name, total_rentals, and total_amount_paid
-- including customers who never rented anything and showing 0 instead of NULL.
select c.customer_id, c.first_name, coalesce(r.total_rentals, 0) as total_rentals, coalesce(p.total_payment, 0) as total_payment
from customer c 
left join 
	(select customer_id, count(rental_id) as total_rentals
	from rental
	group by customer_id
	) r
	on c.customer_id  = r.customer_id
left join 
	(select customer_id, sum(amount) as total_payment
	from payment
	group by customer_id
	) p
	on c.customer_id = p.customer_id ;

--Write a query to return all customers who have never made a payment.
select c.customer_id
from customer c
left join payment p
	on c.customer_id = p.customer_id 
	where p.payment_id is null
	order by c.customer_id;

--Write a query to return each film title and total number of rentals including films that have never been rented.
select * from film;
select * from rental;
select * from inventory;

select f.title, count(distinct r.rental_id) as total_rentals
from film f
left join inventory i 
	on f.film_id = i.film_id 
left join rental r 
	on r.inventory_id  = i.inventory_id
	group by f.title;

--Write a query to return all customers and their rentals that occurred after
-- '2006-01-01' while still showing customers who never rented anything.
select c.customer_id, r.rental_id, r.rental_date
from customer c
left join rental r 
	on c.customer_id = r.customer_id
	and r.rental_date > '2006-01-01';

--Write a query to return each customer_id with total number of rentals and total amount paid
-- without overcounting rentals when multiple payments exist per rental.
select * from rental;
select * from payment;

select c.customer_id, c.first_name, total_rentals, total_payment
from customer c 
left join 
	(select customer_id, count(distinct rental_id) as total_rentals
	from rental
	group by customer_id
	) r
	on c.customer_id  = r.customer_id
left join 
	(select customer_id, sum(amount) as total_payment
	from payment
	group by customer_id
	) p
	on c.customer_id = p.customer_id 
	order by c.customer_id;

--Write a query using RIGHT JOIN to return all stores and the total number of customers
-- in each store including stores that have zero customers.
select * from store;
select * from customer;

select s.store_id, count(c.customer_id) as total_customers
from customer c
right join store s
	on s.store_id = c.store_id
	group by s.store_id;

--Write a query using at least one RIGHT JOIN to return each category name and total revenue generated
--from that category including categories that generated zero revenue.
select * from category;
select * from film_category;
select * from film;
select * from inventory;
select * from rental;
select * from payment;

select c.name, coalesce(sum(p.amount), 0) as total_revenue
from payment p
right join rental r 
	on r.rental_id = p.rental_id 
right join inventory i 
	on i.inventory_id  = r.inventory_id 
right join film_category fc 
	on fc.film_id = i.film_id 
right join category c 
	on c.category_id = fc.category_id
	group by c.name;
