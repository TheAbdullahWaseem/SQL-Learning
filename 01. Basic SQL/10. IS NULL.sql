--1️⃣ Find payments where amount IS NULL.
select * from payment where amount is null;
--2️⃣ Find payments where amount is greater than 5 OR amount is NULL.
select * from payment where amount > 5 or amount is null;
--3️⃣ Count how many payments have NULL amount.
select count(*) from payment where amount is null;
--4️⃣ Find customers where email IS NOT NULL.
select * from customer where email is not null;
--5️⃣ Tricky: Find payments where: amount NOT BETWEEN 2 AND 5 but also include rows where amount IS NULL
select * from payment where amount not between 2 and 5 or amount is null;

