select * from customer;

select c.customer_id, c.first_name, p.amount
from customer c
full outer join payment p 
	on c.customer_id = p.customer_id;

select  coalesce (a.customer_id, p.customer_id) as customer_id,
       a.first_name,
       p.amount
from customer a
full outer join payment p
	on a.customer_id = p.customer_id;

select  coalesce (a.customer_id, p.customer_id) as customer_id,
       a.first_name,
       sum(p.amount)
from customer a
full outer join payment p
	on a.customer_id = p.customer_id
	group by coalesce (a.customer_id, p.customer_id),a.first_name;



--Show all customers and all payments, including customers with no payments and payments with no customer.
select coalesce(c.customer_id, p.customer_id) as customer_id , p.amount 
from customer c
full outer join payment p 
	on c.customer_id = p.customer_id;

--Show all films and all rentals, including films never rented and rentals without a valid film_id.
select * from film;
select * from rental;
select * from inventory;

select f.film_id, ir.rental_id
from film f
full outer join (
	inventory i
		left join rental r
			on i.inventory_id = r.inventory_id) ir
	on f.film_id = ir.film_id;

--more professional approach and valid
SELECT 
    f.film_id,
    r.rental_id
FROM film f
LEFT JOIN inventory i 
    ON f.film_id = i.film_id
LEFT JOIN rental r 
    ON i.inventory_id = r.inventory_id

UNION

SELECT 
    i.film_id,
    r.rental_id
FROM rental r
LEFT JOIN inventory i
    ON r.inventory_id = i.inventory_id
WHERE i.film_id IS NULL;


--Compare stores vs payments: list all stores and total revenue including stores with no payments.
select s.store_id, coalesce (sum(p.amount), 0)
from store s
left join staff st
	on s.store_id =st.store_id 
left join payment p
	on p.staff_id = st.staff_id
	group by s.store_id;

--Show categories vs films: list all categories and revenue, including categories with zero revenue.
select * from category;
select * from film_category;
select * from film;
select * from inventory;
select * from rental;
select * from payment;

select c.name, coalesce(sum(p.amount),0) as revenue
from category c 
left join film_category fc
	on c.category_id = fc.category_id
left join film f
	on f.film_id = fc.film_id
left join inventory i
	on f.film_id = i.film_id 
left join rental r
	on r.inventory_id = i.inventory_id
left join payment p
	on p.rental_id = r.rental_id
	group by c.name;


--Join customer, rental, and payment: include all rows even if rentals or payments are missing.
select coalesce(c.customer_id, r.customer_id, p.customer_id) as customer_id, r.rental_id, p.payment_id
from customer c
full outer join rental r
	on c.customer_id = r.customer_id
full outer join payment p 
	on coalesce(c.customer_id, r.customer_id) = p.customer_id;
