select avg(amount) from payment;
--Formula of Average
select sum(amount)/count(amount) from payment;
select customer_id, Avg(amount) as avg_payment from payment group by customer_id;
select customer_id, Avg(amount) as avg_payment from payment group by customer_id having avg(amount) > 7;

select avg(amount * 1.1) from payment;
select avg(cast(amount as decimal(10,3))) from payment;

--🔹 1️⃣ Basic Foundation Find the average payment amount in the entire table.
select avg(amount) from payment;
--🔹 2️⃣ Find the average payment amount after '2008-01-01'.
select avg(amount) from payment where payment_date > '2008-01-01';
--🔹 3️⃣ Grouped Average For each customer, find their average payment amount.
select customer_id, avg(amount) from payment group by customer_id;
--🔹 4️⃣ Find customers whose average payment is greater than 8.
select customer_id, avg(amount) from payment group by customer_id having avg(amount) > 8;
--🔹 5️⃣ For each customer, return: total payments, average payment Include only customers who made more than 20 payments.
select customer_id, count(*), avg(amount) from payment group by customer_id having count(*) > 20;
--🔹 6️⃣ Find customers whose average payment is greater than their smallest payment.
select customer_id, avg(amount), min(amount) from payment group by customer_id having avg(amount) > min(amount);
--🔹 7️⃣ Find customers whose average payment equals their maximum payment.
select customer_id, avg(amount), max(amount) from payment group by customer_id having avg(amount) = max(amount);
--🔹 8️⃣ For each customer, find the average payment after 2007-01-01.
select customer_id, avg(amount) from payment where payment_date >= '2007-01-01' group by customer_id;
--🔹 9️⃣ Find customers whose average payment is between 6 and 9 dollars AND whose total payments are greater than 15.
select customer_id,count(amount), avg(amount) from payment group by customer_id  having (avg(amount) between 6 and 9) and (count(amount) > 15); 
--🔟 Find customers whose average payment is higher than the overall average payment of the entire table.
select customer_id, avg(amount) from payment group by customer_id having avg(amount) > (select avg(amount) from payment) ;
--Find customers whose average payment is greater than the overall average, but whose maximum payment is less than 10.
select customer_id, avg(amount), max(amount) from payment  group by customer_id having avg(amount) > (select avg(amount) from payment) 
and max(amount) < 10 ;

