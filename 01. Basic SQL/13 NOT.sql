-- not A or not B
select * from payment where not (customer_id = 341 and amount > 5);
--not A and not B
select * from payment where not (customer_id = 341 or amount > 5);
--Payments where amount is NOT greater than 5
select * from payment where not amount > 5;
--Customers NOT active
select * from customer where not active = 1;
--Films NOT between 60 and 120 minutes
select * from film where length not between 60 and 120; 
--Customers whose name does NOT start with 'A'
select * from customer where first_name not like 'A%';
--Payments where customer_id NOT IN (1,2,3)
select * from payment where customer_id not in (1,2,3);