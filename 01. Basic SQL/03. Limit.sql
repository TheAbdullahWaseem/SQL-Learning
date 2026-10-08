select table_name from information_schema.tables
where table_schema = 'public'
order by table_name;

select * from rental limit 5;
SELECT inventory_id, film_id FROM inventory LIMIT 5;
SELECT rental_id, inventory_id FROM rental LIMIT 5;
SELECT film_id, title FROM film LIMIT 5;