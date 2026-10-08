select * from payment where customer_id = 1 OR customer_id = 2 OR customer_id = 3;
--Better way
select * from payment where customer_id in (1,2,3);
select * from customer where first_name like 'A%' or first_name like 'M%';
--OR with Null
select * from payment where amount <> 5 or amount is null;
--OR with subquery
select * from payment where customer_id = 1 or amount > (select avg(amount) from payment);
--Customers who are inactive OR email is NULL
select * from customer where active = 0 or email is null;
--Payments less than 3 OR greater than 7
select * from payment where amount < 3 or amount > 7;
--Films shorter than 60 OR rental_rate greater than 4
select * from film where length < 60 or rental_rate > 4;
--Customers whose name starts with 'J' OR 'K' OR 'L'
select * from customer where first_name like 'J%' or first_name like 'K%' or first_name like 'L%';
select * from customer where first_name ~ '^[JKL]';
--Payments where amount is 0 OR NULL
select * from payment where amount = 0 or amount is null;