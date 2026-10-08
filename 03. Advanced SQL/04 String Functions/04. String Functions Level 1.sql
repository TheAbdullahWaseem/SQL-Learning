create table string_practice (
	id serial primary key,
	full_name text,
	email text,
	phone text,
	address text
	);

INSERT INTO string_practice (full_name, email, phone, address) VALUES
('  ABDULLAH waseem  ', 'ABDULLAH@GMAIL.COM', '0312-345-6789', '  abbottabad '),
('mArY sMiTh', 'Mary.Smith@Yahoo.COM', '0300 123 4567', 'New york'),
('JOHN DOE', 'JOHNDOE@OUTLOOK.COM', '(0333)-999-8888', 'los angeles'),
('aLi khAn', 'ali.khan@GMAIL.com', '0345.777.6666', '  karachi'),
('sara   lee', 'SARA.LEE@EMAIL.COM', '0311/222/3333', 'lahore');

select * from string_practice;


--Topic 1 Case Conversion:

--1. Upper():

select full_name, upper(full_name) from string_practice;

select upper('abdullah');

SELECT *
FROM string_practice
WHERE upper(full_name) = '  ABDULLAH WASEEM  '; --Case - Sensitive
-- There are space before and after name Abdullah Waseem in above query
--SQL comparisons are case-sensitive (in many systems)
--WHERE full_name = 'abdullah waseem'
--Might NOT match
--That’s why we use:
--WHERE UPPER(full_name) = 'ABDULLAH WASEEM'


-- 2. LOWER():

select email, lower(email) from string_practice;
--Emails should ALWAYS be lowercase
-- Why?
--John@gmail.com
--john@gmail.com
select * from string_practice
where lower(email) = 'abdullah@gmail.com';

--Always convert:
--Emails → lowercase
--URLs → lowercase

--3. INITCAP(): - Capitalize First Letters

select initcap('abduulah waseem');

select full_name, initcap(full_name)
from string_practice;

--Problem
SELECT INITCAP(full_name)
FROM string_practice;

--Might give:
--Mary smith   (wrong) Smith s is small

--Pro Combination
select initcap(lower(trim(full_name)))
from string_practice;

--Professional Query
select id,
	   initcap(lower(trim(full_name))) as clean_name,
	   lower(trim(email)) as clean_email,
	   initcap(trim(address)) as clean_address
from string_practice;

--Professionals combine functions with logic

--Topic 2: Length & Size Functions:
--LENGTH()
--CHAR_LENGTH()

-- 1. Length():
-- Returns the number of bytes in a string

select length('abdullah');
-- Each character = 1 byte (for normal English)

select full_name, length(full_name) as name_length
from string_practice;
-- Spaces are ALSO counted

-- 2. CHAR_LENGTH():
--Returns number of actual characters

select char_length('abdullah');

select full_name, char_length(full_name) as char_count
from string_practice;

--If string = normal English text
--→ LENGTH() = CHAR_LENGTH()
--They differ Only when string contains multi-byte characters like emojis etc
SELECT 
    LENGTH('عبدالله'),
    CHAR_LENGTH('عبدالله');
--PROFESSIONAL USE CASES
--1. Data Validation

--Find invalid phone numbers
select * from string_practice
where length(phone) < 11; --Different formats exist → may fail
-- They include: -,  spaces, (), .

--Better Approach
select * from string_practice
where char_length(phone) < 19;

--2. Detect Dirty data
--Find names with extra spaces
select full_name
from string_practice
where length(full_name) != length(trim(full_name));

--3. Find Short / Suspicious Names
select *
from string_practice
where char_length(full_name) < 5;

--4. Length-Based Analysis
select full_name, char_length(full_name) as name_length
from string_practice
order by name_length desc;

select full_name, char_length(trim(full_name)) as clean_length
from string_practice;

--Find records with extra spaces
select * from string_practice
where full_name != trim(full_name);

--Find shortest name
select full_name, length(trim(full_name)) as length_name
from string_practice
order by length_name asc
limit 1;
-- Find rows where:
-- original length ≠ trimmed length

select * from string_practice
where length(full_name) != length(trim(full_name));

select  id,
		full_name,
		length(email) as len_email,
		char_length(full_name) as original_length,
		char_length(trim(full_name)) as clean_length
from string_practice
where char_length(full_name) != char_length(trim(full_name));
	
-- Topic 3: CONCATENATION (Joining Strings)
-- Concatenation = joining multiple strings into one
-- 1. Concat() Function

select concat('Abdullah', ' ', 'Waseem');

select full_name, email,
	concat(initcap(trim(full_name)), ' : ', lower(trim(email))) as combined_info
from string_practice;

--What if NULL exists?
SELECT CONCAT('Abdullah', NULL, 'Waseem');
--Output: AbdullahWaseem
-- NULL is treated as empty string

-- 2. || OPERATOR (PostgreSQL)

select 'Abdullah' || ' ' || 'Waseem'; 

select full_name ||  ' | ' || email as combined_info
from string_practice;

--Using CONCAT()
SELECT CONCAT('Abdullah', NULL, 'Waseem');
--Output: AbdullahWaseem

--Using ||
SELECT 'Abdullah' || NULL || 'Waseem';
--Output: NULL

--CONCAT() ----> ignores NULL

--1. Creating Full Name
SELECT 
    CONCAT(
        INITCAP(LOWER(TRIM(full_name)))
    ) AS clean_name
FROM string_practice;


-- 2. Creating Labels
SELECT 
    CONCAT('Customer: ', full_name) AS label
FROM string_practice;

-- 3. Combining Multiple Fields
select 
	concat(full_name,  ' : ', email, ' | ',  address) as full_record
from string_practice;

--4. Generating Emails (VERY IMPORTANT)
select
	lower(replace(full_name, ' ', '.')) || '@company.com' as generated_email
from string_practice;

select 
	concat
		(initcap(lower(trim(full_name))),
		' (', lower(trim(email)), ') ') as formatted_output
from string_practice;

--Task 1
-- Create full info: Name - Email
select concat(full_name , ' - ', email) from string_practice;

-- Task 2
-- Create: Customer: Abdullah (Abbottabad)
select concat('Customer', ' : ', Initcap(trim(full_name)), ' (', Initcap(address), ')' ) as formatted
from string_practice;

--Task 3 
--Generate clean email: abdullah.waseem@company.com

select concat(Initcap(replace(trim(full_name), ' ', '.')), '@company.com') as generated
from string_practice; --(replace(trim(full_name) if I don't use
-- ) after full_name then trim doesn't work.

select full_name, email from string_practice;

--concat first_name and gmail
select 
	concat(
		split_part(Initcap(trim(full_name)), ' ', 1 ), '@',
		split_part(lower(trim(email)), '@', 2))
from string_practice;


-- TOPIC 4 — SUBSTRING / EXTRACTION

--SUBSTRING() = extract part of a string
--Think: “Cut a piece out of a string”

--1. SUBSTRING():
-- Syntax
-- SUBSTRING(string, start_position, length)
select substring('Abdullah Waseem', 9, 15);

select full_name,
	substring(Initcap(trim(full_name)), 1, 5) as first_part,
	char_length(substring(Initcap(trim(full_name)), 1, 5)) as name_length
from string_practice;

-- 2. SUBSTR() (same function, different name)
--SUBSTR() = alias of SUBSTRING()

SELECT SUBSTR('Abdullah Waseem', 1, 8);

-- 1. Extract First Name
select 
	full_name, 
	substring(full_name from 1 for position(' ' in full_name) - 1)
	as first_name
from string_practice; --Cut from start → until space

--2. Extract Email Username
select email,
	substring(initcap(email) from 1 for position('@' in email) -1) as username
from string_practice;

--3. Extract Domain from Email
select 
	email,
	substring(email from position('@' in email) +1) as domain
from string_practice;

--4. Extract Area Code from Phone
SELECT 
    phone,
    SUBSTRING(phone, 1, 4) AS area_code
FROM string_practice;

-- TOPIC 5 — TRIMMING FUNCTIONS
-- Data often contains unwanted spaces or characters
-- 1. TRIM(): Removes characters from both sides (left + right)

select trim('  abdullah   ');

select full_name, trim(full_name) as clean_name
from string_practice;
--TRIM does NOT touch middle spaces:

--2. LTRIM() — Left Trim
--Removes characters from start (left side)
select ltrim('    abdullah  ');

SELECT 
    full_name,
    LTRIM(full_name) AS left_clean
FROM string_practice;

--3. RTRIM() — Right Trim
--Removes characters from end (right side)

select rtrim('  abdullah  ');
 
SELECT 
    full_name,
    RTRIM(full_name) AS right_clean
FROM string_practice;

--ADVANCED — TRIM SPECIFIC CHARACTERS
select trim(both '.' from '..abdullah..');
select trim(leading '.' from '...abdllah..');
select trim(trailing '.' from '...abdllah..');
select trim(trailing '@' from '..abdullah..@')

select full_name,
	concat(initcap(replace(trim(full_name), ' ', '.')), ' : ', lower(email)) as cleaned
from string_practice;

--TOPIC 6 — REPLACE() (Modify Text)
--REPLACE() changes one part of a string into another
--REPLACE(string, from_text, to_text)
SELECT REPLACE('I love SQL', 'love', 'learn');


select full_name,
	replace(full_name, ' ', '_') as modified_name
from string_practice;

--Clean phone numbers:
select phone,
	replace(phone, '-', '') as clean_phone
from string_practice;

select phone from string_practice;


--2. Remove Multiple Characters (CHAINING)
select phone,
	replace(replace(replace(replace(phone, '-',''), ' ', ''), '(', ''), ')', '') as cleaned
from string_practice;

--3. Create Emails
select 
	lower(replace(trim(full_name), ' ', '.')) || '@company.com' as email
from string_practice;

--REPLACE works EXACT match only
SELECT REPLACE('Company', 'c', 'x'); --c ≠ C

select replace(lower('Company'), 'c', 'x'); 

--TOPIC 7 — POSITION / SEARCHING
--These functions find where something exists inside a string
--“At what position does this text appear?”

--1. POSITION()
--Syntax
--POSITION(substring IN string)

select position('a' in 'abdullah');
SELECT POSITION('d' IN 'abdullah');
--SQL indexing starts from 1 (not 0)

--2. STRPOS() (PostgreSQL)
--Same as POSITION(), just different syntax
select strpos('abdullah', 'd');

--1. Find Position of '@' in Email
SELECT 
    email,
    POSITION('@' IN email) AS at_position
FROM string_practice;

--2. Extract Username
select email,
	substring(initcap(email) from 1 for position('@' in email) -1) as username
from string_practice;

--3. Extract Domain
SELECT 
    SUBSTRING(email FROM POSITION('@' IN email) + 1) AS domain
FROM string_practice;

--4. Find Names with Space
select full_name,
	substring(full_name from 1 for position(' ' in full_name) -1) as named
from string_practice;
 
select * from string_practice 
where position(' ' in full_name) > 0;

--5. Detect Bad Emails
SELECT *
FROM string_practice
WHERE POSITION('@' IN email) = 0; --Emails without @ → invalid



SELECT 
    POSITION(' ' IN TRIM(full_name))
FROM string_practice;

--TOPIC 8 — PATTERN MATCHING (LIKE, ILIKE)
--LIKE is used to match patterns, not exact values

SELECT *
FROM string_practice
WHERE trim(full_name) LIKE 'A%';

SELECT *
FROM string_practice
WHERE full_name LIKE '%m';

SELECT *
FROM string_practice
WHERE full_name LIKE '%lee%';

--2. _ (Underscore)
-- Means: exactly ONE character
SELECT *
FROM string_practice
WHERE full_name LIKE '_a%';

--3. ILIKE (PostgreSQL Only)
--Same as LIKE, but case-insensitive
SELECT *
FROM string_practice
WHERE trim(full_name) ILIKE 'abd%';

SELECT *
FROM string_practice
WHERE trim(full_name) LIKE 'abd%'; --It won't work because of LIKE
-- is case sensitive


--Find Gmail Users
SELECT *
FROM string_practice
WHERE email iLIKE '%gmail.com';


SELECT *
FROM string_practice
WHERE email ILIKE '%yahoo%';

--Detect Invalid Emails
SELECT *
FROM string_practice
WHERE email NOT LIKE '%@%';

-- Find Names with Two Words
SELECT *
FROM string_practice
WHERE full_name LIKE '% %';
-- %% means % = any number of character ' ' a single space
-- % again any number of characters
-- % Space %