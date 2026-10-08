
select  i.film_id, i.store_id, COUNT(i.inventory_id) AS copies_available
from inventory i
group by i.film_id , i.store_id
order by i.film_id;

select a.first_name || ' ' || a.last_name as full_name, f.title
from actor a
join film_actor fa
	on a.actor_id = fa.actor_id
join film f
	on f.film_id = fa.film_id
	

select p.customer_id, r.inventory_id, r.rental_date, p.amount
from rental r
join payment p
	on r.customer_id = p.customer_id
	and r.rental_id = p.rental_id;

select i.store_id, date(r.rental_date) as rental_day,  count(r.rental_id)
from inventory i
join rental r
	on i.inventory_id = r.inventory_id
	group by i.store_id, rental_day;

--Find customers who rented movies from store 1 or store 2 during June–July 2005.

select c.customer_id, i.store_id, count(r.rental_id) as number_of_rentals
from customer c
join rental r
	on c.customer_id = r.customer_id
join inventory i
	on i.inventory_id = r.inventory_id
	where r.rental_date >= '2005-06-01' and r.rental_date < '2005-07-31' and i.store_id in (1,2)
	group by c.customer_id , i.store_id
	having count(rental_id) > 3
	order by number_of_rentals desc
	limit 10;
	
--Return: film_id, store_id, total number of rentals
--Show how many times each film was rented from each store
--Only include rentals that happened during 2005
--Only include films that were rented more than 10 times from the same store
--Sort the results from highest to lowest number of rentals
--Return only the first 15 rows

select f.film_id, i.store_id, count(r.rental_id) as total_rentals
from film f
join inventory i
	on f.film_id = i.film_id 
join rental r
	on r.inventory_id = i.inventory_id 
	where Extract(year from r.rental_date) = 2005
	group by f.film_id, i.store_id
	having count(r.rental_id) > 10
	order by total_rentals desc limit 15

--Return: customer_id, store_id, total amount spent
--Calculate how much each customer spent at each store
--Only include payments made before '2008-01-01'
--Only include customers whose total spending at a store is greater than 40
--Sort the results by total spending in descending order
select c.customer_id, i.store_id, sum(p.amount) as total_amount
from customer c
join payment p 
	on c.customer_id = p.customer_id
join rental r
	on r.rental_id = p.rental_id
join inventory i
	on r.inventory_id = i.inventory_id
	where p.payment_date < '2008-01-01'
	group by c.customer_id, i.store_id 
	having sum(p.amount) > 40
	order by total_amount desc;

--Return: actor_id, category_name, total_films
--Show how many films each actor has appeared in within each film category
--Only include categories whose names start with the letter 'A' or 'C'
--Only include results where an actor has appeared in more than 2 films in that category
--Sort results by total_films from highest to lowest
select  a.actor_id, c.name AS category_name, count(f.film_id) AS total_films
from  actor a
join film_actor fa
    on a.actor_id = fa.actor_id
join film f
    on fa.film_id = f.film_id
join film_category fc
    on f.film_id = fc.film_id
join category c
    on fc.category_id = fc.category_id
	where c.name like 'A%' or c.name like 'C%'
	group by a.actor_id, c.name
	having count(f.film_id) > 2
	order by total_films desc;

