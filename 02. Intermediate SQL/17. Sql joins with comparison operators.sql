select * from customer c;

select c.customer_id, p.amount
from customer c
join payment p
	on p.amount > 5;

select distinct c.customer_id, p.amount
from customer c
join payment p
	on c.customer_id = p.customer_id 
	and p.amount > 5;

select c.customer_id, p.amount
from customer c
join payment p
	on c.customer_id = p.customer_id 
	and p.amount > (select avg(amount) from payment);

--Return: customer_id, first_name, amount, Only include payments greater than the average payment
--Preserve customers with no payments
select c.customer_id, c.first_name, p.amount
from customer c
left join payment p
	on c.customer_id = p.customer_id 
	where p.amount > (select avg(amount) from payment) or p.amount is null;

--Return: customer_id, first_name, amount
--Payments between 5 and 10
--Only include customers whose first name starts with 'A'
--Preserve customers with no payments
select c.customer_id, c.first_name, p.amount
from customer c
left join payment p
	on c.customer_id = p.customer_id 
	and c.first_name like 'A%'
	where p.amount between 5 and 10 or p.amount is null;

--Return: customer_id, rental_date, return_date
--Only include rentals before '2006-01-01'
--Compare rental_date < '2006-01-01' in the JOIN
select c.customer_id, r.rental_date, r.return_date
from customer c
left join rental r
	on c.customer_id =r.customer_id 
	and r.rental_date < '2006-01-01';

--Return: customer_id, first_name, total_payment, total_rentals
--Only include customers whose total payments > 50 AND total rentals > 5
select c.customer_id, c.first_name, sum(p.amount) as total_payment, count(r.rental_id) as total_rentals
from customer c
left join rental r 
	on c.customer_id = r.customer_id
left join payment p
	on c.customer_id = p.customer_id
	group by c.customer_id, c.first_name
	having sum(p.amount) > 50 and count(r.rental_id) > 5;

select c.customer_id, c.first_name, sum(p.total_payment) , count(r.total_rentals)
from customer c
left join ( select customer_id, sum(amount) as total_payment
		 from payment
		 group by customer_id) p
	on c.customer_id = p.customer_id 
left join (select customer_id, count(rental_id) as total_rentals
		from rental
		group by customer_id) r
	on c.customer_id = r.customer_id
	WHERE p.total_payment > 50
  	AND r.total_rentals > 5
group by c.customer_id;
		





--Return: customer_id, amount, payment_date
--Find all customers whose payments do not match their rental month (example: payment month != rental month)
--Use non-equi join with comparison operators (!=)
--Preserve customers with no payments or no rentals
select c.customer_id, p.amount, p.payment_date
from customer c
left join payment p
	on c.customer_id = p.customer_id
left join rental r
	on p.customer_id = r.customer_id
	and (Extract(month from p.payment_date)) != (extract(month from r.rental_date))
	where (p.payment_id is null or r.rental_id is null or r.rental_id is not null);
