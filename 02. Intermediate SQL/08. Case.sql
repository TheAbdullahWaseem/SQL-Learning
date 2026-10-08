select payment_id, amount,
case amount
	when 5 then 'Low'
	when 10 then 'Medium'
	when 15 then 'High'
	else 'other'
end as payment_category
from payment;

select payment_id, amount,
case 
	when amount < 5 then 'very Low'
	when amount >= 5 and amount < 10 then 'Low'
	when amount >= 10 and amount < 15 then 'Medium'
	else 'High'
end as payment_category
from payment;

select customer_id,
	sum(case when amount < 5 then 1 else 0 end) as low_payments,
	sum(case when amount >= 10 then 1 else 0 end) as high_payments
from payment
group by customer_id;

select customer_id,
	avg(case when amount < 5 then 0
			 when amount >= 5 and amount < 10 then 1
			 else 2
		end) as payment_score
from payment
group by customer_id

select payment_id, amount
from payment
order by case
		when amount < 5 then 1
		when amount between 5 and 10 then 2
		else 3
	end;

select customer_id,
	count(*) as total_payments,
	sum(case when amount >= 10 then 1 else 0 end) as high_payments
from payment
group by customer_id 
having sum(case when amount >= 10 then 1 else 0 end) > 5;

--Case Nested
select payment_id,
case
	when amount < 5 then 'Very Low'
	when amount < 10 then 'Low'
	else
		case when amount < 15 then 'Medium'
		else 'High'
		end
end as payment_category
from payment;
end

select customer_id,
	count(*) as total_payments,
	sum(case when amount < 5 then 1 else 0 end) as low_payments,
	sum(case when amount between 5 and 10 then 1 else 0 end) as medium_payment,
	sum(case when amount > 10 then 1 else 0 end) as high_payments,
	case
		when avg(amount) < 5 then 'Low Value Customer'
		when avg(amount) between 5 and 10 then 'Medium value Customer'
		else 'High Value Customer'
	end as customer_segment
from payment
group by customer_id
order by avg(amount) desc;

--1️⃣ Write a query to show: payment_id, amount
--a new column payment_type where: amount < 3 → 'Small' amount between 3 and 7 → 'Medium' amount > 7 → 'Large'
select payment_id, amount,
case 
	when amount < 3 then 'Small'
	when amount between 3 and 7 then 'Medium'
	when amount > 7 then 'Large'
end as payment_type
from payment;

--2️⃣ Display: payment_id, amount
--Sort results so: Large payments first, Medium payments second, Small payments last

select payment_id, amount,
case 
	when amount < 3 then 'Small'
	when amount between 3 and 7 then 'Medium'
	when amount > 7 then 'Large'
end as payment_type
from payment
order by
case
	when amount > 7 then 1
	when amount between 3 and 7 then 2
	else 3
end;

--3️⃣ For each customer: customer_id, total_amount, spending_level
--Where: total < 100 → 'Low', 100–200 → 'Medium', 200 → 'High'
select customer_id, sum(amount) as total_amount,
case 
	when sum(amount) < 100 then 'Low'
	when sum(amount) between 100 and 200 then 'Medium'
	else 'High'
end as spending_level
from payment
group by customer_id;

--4️⃣ For each customer calculate: customer_id, average_risk_score
--Where each payment: amount < 2 → 0, 2–5 → 1, 5 → 2
select customer_id, 
avg(
case 
	when amount < 2 then 0
	when amount between 2 and 5 then 1
	when amount > 5 then 2
end) as average_risk_score
from payment
group by customer_id;

--5️⃣ For each customer: customer_id, number_of_large_payments
--Where large payment = amount > 6
select customer_id,
sum(
	case
		when amount > 6 then 1
		else 0
	end) as number_of_large_payments
from payment
group by customer_id;

