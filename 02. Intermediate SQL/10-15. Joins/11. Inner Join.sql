select * from film;
select * from inventory;
select * from rental;
select * from customer;
select * from payment;

select c,first_name, p.amount
from customer c 
inner join payment p 
	on c.customer_id = p.customer_id;

select c.first_name, r.rental_date, f.title
from customer c 
join rental r 
	on c.customer_id  = r.customer_id
join inventory i
	on i.inventory_id  = r.inventory_id and i.store_id = 1
join film f 
	on f.film_id = i.film_id;

--Aggregations with INNER JOIN
select c.first_name || ' ' || c.last_name as full_name, sum(p.amount)
from customer c 
inner join payment p 
	on c.customer_id = p.customer_id 
	group by c.customer_id , c.first_name
	order by full_name;
	
select c.first_name, p.total_payment
from customer c 
inner join (
	select customer_id, sum(amount) as total_payment
	from payment group by customer_id
	)  p
		on c.customer_id = p.customer_id
		order by c.first_name;

select c.customer_id, c.first_name, p.total_payment, r.total_rentals
from customer c 
inner join 
	(select customer_id, sum(amount) as total_payment
	from payment
	group by customer_id
	) p
		on c.customer_id = p.customer_id 
inner join 
	(select customer_id, count(rental_id) as total_rentals
	from rental
	group by customer_id
	) r
		on r.customer_id =c.customer_id 
		group by c.customer_id ;

select c.customer_id,  sum(p.amount) as total_payment
from customer c 
inner join payment p 
	on c.customer_id  = p.customer_id 
	where p.amount > 10
	group by c.customer_id, p.amount;

--Show each customer’s full name and all their payments.
select c.first_name || ' ' || c.last_name as full_name, p.amount
from customer c 
inner join payment p 
	on c.customer_id = p.customer_id;

--Sum payments per customer.
select c.customer_id, c.first_name || ' ' || c.last_name as full_name, sum(p.amount) 
from customer c 
inner join payment p
	on c.customer_id = p.customer_id 
	group by c.customer_id, full_name
	order by full_name;

--Show customer and payment amount only for payments after '2007-01-01'.
select c.customer_id, c.first_name || ' ' || c.last_name as full_name, p.amount, p.payment_date 
from customer c
inner join payment p 
	on c.customer_id = p.customer_id 
	where p.payment_date  > '2007-01-01';

--Show customer full name, film title, rental date.
select c.customer_id, c.first_name || ' ' || c.last_name as full_name, f.title, r.rental_date
from customer c
inner join rental r 
	on c.customer_id = r.customer_id 
inner join inventory i
	on i.inventory_id = r.inventory_id 
inner join film f
	on i.film_id = f.film_id;

--Show only customers whose max payment > 10.
select c.customer_id,c.first_name || ' ' || c.last_name as full_name, max(p.amount) as max_payment
from customer c 
inner join payment p 
	on c.customer_id = p.customer_id 
	group by c.customer_id, full_name
	having max(p.amount) > 10;

--For each customer, label payment as 'Low', 'Medium', 'High'.
select c.customer_id,c.first_name || ' ' || c.last_name as full_name, p.amount,
case
	when p.amount < 5 then 'low'
	when p.amount between 5 and 7 then 'medium'
	else 'high'
end as label_payment
from customer c
inner join payment p
on c.customer_id = p.customer_id;

--Total payment and total rentals safely
select * from rental;
select c.customer_id,c.first_name || ' ' || c.last_name as full_name, p.total_payment, r.total_rentals
from customer c 
inner join (
			select customer_id, sum(amount) as total_payment
			from payment
			group by customer_id
	) p 
	on c.customer_id = p.customer_id 
inner join (
			select customer_id, count(rental_id) as total_rentals
			from rental
			group by customer_id
	) r
	on c.customer_id = r.customer_id
	order by c.customer_id;



--Show total payments per store.
select s.store_id, sum(amount) as total_payments
from  payment p 
inner join rental r
	on p.rental_id  = r.rental_id
inner join inventory i 
	on i.inventory_id = r.inventory_id
inner join store s
	on  s.store_id = i.store_id
	group by s.store_id;


--Show customer, film, count of rentals, only if count > 1.
select c.customer_id, f.title, count(r.rental_id) as total_rentals
from customer c 
inner join rental r
	on c.customer_id = r.customer_id 
inner join inventory i
	on i.inventory_id = r.inventory_id 
inner join film f
	on f.film_id = i.film_id
	group by c.customer_id , f.title
	having count(r.rental_id ) > 1;

--Average “risk score” per customer using INNER JOIN + CASE + AVG.
select c.customer_id,
AVG(
 case
	 when p.amount < 2 then 0
	 when p.amount between 2 and 5 then 1
	 when p.amount > 5 then 2
 end) as average_risk_score
 from customer c
 	inner join payment p
 	on c.customer_id = p.customer_id 
 	group by c.customer_id;