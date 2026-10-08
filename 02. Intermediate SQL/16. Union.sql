select first_name, 'Customer' as role from customer
union
select first_name, 'Staff' as role from staff;

select customer_id, amount, 'Payment' as role from payment
where amount > 10
union
select customer_id, null as Amount, 'Rental' as role from rental;

SELECT customer_id, first_name FROM customer
UNION
SELECT staff_id, first_name FROM staff;

--Below query is same as above but not work because order different.
SELECT first_name, customer_id FROM customer
UNION
SELECT staff_id, first_name FROM staff;

