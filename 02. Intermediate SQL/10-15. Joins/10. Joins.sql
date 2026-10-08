select * from customer;
select * from payment;
--simple join
select  first_name, last_name, amount from 
customer c 
join payment p 
	on c.customer_id = p.customer_id 
	where amount between 5 and 7
	order by c.first_name asc;
--Show: customer full name, payment amount, payment date, Only for customers who made payments.
select c.first_name || ' ' || c.last_name as full_name , amount, payment_date
from customer c
join payment p 
	on c.customer_id  = p.customer_id;

--Find: customer full name, total number of rentals, Sort by highest rentals.
select c.first_name || ' ' || c.last_name as full_name , count(rental_id) as total_rentals
from customer c
join rental r 
	on c.customer_id = r.customer_id
	group by c.customer_id ,c.first_name, c.last_name
	order by count(rental_id) desc;
--Find:film title, customer full name, rental date
select  f.title, c.first_name || ' ' || c.last_name as full_name, r.rental_date
from customer c
join rental r
	on c.customer_id  = r.customer_id
join inventory i
	on i.inventory_id = r.inventory_id 
join film f
	on f.film_id = i.film_id;

select * from film;
select * from inventory;
select * from rental;
select * from customer;
select * from payment;

--Find: customer full name, total payment amount, total number of rentals
select customer_id, sum(amount) as total_payment
from payment
group by customer_id;

select customer_id, count(rental_id) as total_rentals
from rental
group by customer_id;

select c.first_name || ' ' ||c.last_name as full_name, p.total_payment, r.total_rentals
from customer c
left join(
	select customer_id, sum(amount) as total_payment
	from payment
	group by customer_id
	) p
	on c.customer_id = p.customer_id
left join(
	select customer_id, count(rental_id) as total_rentals
	from rental
	group by customer_id
) r 
on c.customer_id = r.customer_id;