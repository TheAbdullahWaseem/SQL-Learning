--Find customers whose first name starts with “J”.
select * from customer where first_name like 'J%';
--the below quesry is case insensitive using ILIKE
select * from customer where first_name ilike 'JA%';
--Find customers whose first name has exactly 5 letters.
select * from customer where first_name like '_____'
--Find customers whose last name contains “son” anywhere.
select * from customer where last_name like '%son%';
--Find customers whose: first name starts with ANY letter, second letter is “a”
select * from customer where first_name  like '_a%';
--Find customers whose: first name starts with “A”, AND last name does NOT end with “n”
select * from customer where first_name like 'A%' and last_name not like '%n';
--Find customers whose email: contains “.org”, but does NOT start with “admin”
select * from customer where email like '%.org%' and email not like 'admin%';