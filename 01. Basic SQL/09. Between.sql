select * from rental;
select rental_date as between_ from rental where rental_date between '2005-05-25' and '2005-05-27';

select rental_date as not_between from rental where rental_date >= '2005-05-25' and rental_date <= '2005-05-27';

select * from payment;
select * from payment where amount between 5  and 7;

select * from customer where first_name between 'A' and 'D';

select * from payment where amount between 7 and 5; --not work because order matters

select * from customer where address_id between 5 and 10 and 
create_date in ('2006-02-14', '2006-02-16') and (first_name like 'B%');

select * from payment  where amount between 4 and 6 and customer_id in (342,340,333);

--1️⃣ Find payments where amount is between 3 and 6.
select * from payment where amount between 3 and 6;

--2️⃣ Find payments made between '2007-02-01' and '2007-02-15'.
select * from payment where payment_date between  '2007-02-01' and '2007-02-15';
select * from payment where payment_date >= '2007-02-01' and payment_date <= '2007-02-16';

--3️⃣ Find customers whose customer_id is between 10 and 20.
select * from customer where customer_id between 10 and 20;
--4️⃣ Find payments where: amount BETWEEN 2 AND 5 AND customer_id IN (1,2,3)
select * from payment where amount between 2 and 5  and customer_id in (1,2,3);

--5️⃣ Tricky Find payments where: amount NOT BETWEEN 2 AND 5 AND payment_date BETWEEN '2007-01-01' AND '2007-02-27'
select * from payment where amount not between 2 and 5 and  payment_date >= '2007-02-01' AND  payment_date <= '2007-02-28';