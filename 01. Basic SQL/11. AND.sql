-- And with Between
select * from payment where amount between 2 and 5 and customer_id in (1,2,3);
-- And with Like
select * from customer where first_name like 'A%' and email is not null;
--And vs OR
select * from payment where customer_id = 1 or customer_id = 2 and amount > 5; -- this is wrong it will be interpreted as
--WHERE customer_id = 1 OR (customer_id = 2 AND amount > 5) where sql evaluates and first and then or
--correct statement is
select * from payment where (customer_id = 1 or customer_id = 2) and amount > 5;
--Payments where amount is between 3 and 7 AND customer_id is not 5
select * from payment where amount between 3 and 7 and customer_id <> 5;
--Customers whose name starts with 'M' AND are active
select * from customer where first_name like 'M%' and active = 1;
--Films longer than 120 minutes AND rental_rate less than 3
select * from film where length > 120 and rental_rate < 3;
--Payments greater than average amount AND customer_id = 1
select * from payment where amount > ( select avg(amount) from payment) and customer_id = 1;
--Customers where email IS NOT NULL AND email LIKE '%gmail%'
select * from customer where email like '%gmail%' and email is not null;