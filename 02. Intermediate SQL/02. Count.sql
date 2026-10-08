--count(*)
select count(*) from payment;
select count(*) from payment where amount > 5;
--count(column_name)
select count(amount) from payment;
--count(Distinct column_name)
select count(distinct amount) from payment;

select customer_id, count(*) from payment group by customer_id;

--1️⃣ Count all payments greater than 8
select count(*) from payment where amount > 8;
--2️⃣ Count how many customers are inactive
select count(*) from customer where active = 0;
--3️⃣ Count how many films are NOT between 60 and 120 minutes
select count(*) from film where length not between 60 and 120;
--4️⃣ Count how many customers have a NULL email
select count(*) from customer where email is null;
--5️⃣ Count how many DISTINCT customers made payments
select count(distinct customer_id) from payment;
--6️⃣ For each customer, count how many payments they made
select customer_id, count(*) from payment group by customer_id;
--7️⃣ Show customers who made more than 5 payments
select customer_id, count(*) from payment group by customer_id having count(*) > 5;
--8️⃣ Count payments between 5 and 10 dollars AND made by customers with id < 50
select count(*) from payment where amount between 5 and 10 and customer_id < 50;
--9️⃣ Count how many payments have NULL in amount (Trick Question)
select count(*) from payment where amount is null;
--🔟 Find the top 3 customers who made the most payments
select customer_id, count(*) from payment group by customer_id order by count(*) desc limit 3;
