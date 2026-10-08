--MODULE 1 — FORMATTING & STRUCTURE
-- Functions: LPAD() RPAD()
--Padding = adding extra characters to make strings a fixed length

--Real-world data often looks like:

1
23
456

--Ugly ❌
--Hard to read ❌
--We convert it into:

001
023
456

--1. LPAD() — Left Padding
--Syntax
--LPAD(string, total_length, fill_character)

SELECT LPAD('123', 5, '0');

SELECT 
    id,
    LPAD(id::text, 5, '0') AS formatted_id
FROM string_practice;

select 
	concat('cust-', lpad(id::text, 5, '0')) as customer_id
from string_practice;



--2. RPAD() — Right Padding
--Adds characters to the right side

select rpad('abc', 6, '*');

select full_name,
	rpad(full_name, 25, '.') as padded_name
from string_practice;
--WHEN TO USE WHAT?

--Functions	   Use
--LPAD	       IDs, numbers
--RPAD	       formatting display


select rpad(id::text, 5, '.') from string_practice;

--If string already longer than target
SELECT LPAD('abcdef', 4, '0');
--It truncates ❗

--Fill character can be anything
SELECT LPAD('7', 4, '*');

select rpad('INV-', 8, '0');

select 
	id, 
	concat('CUST-', lpad(id::text, 5, '0')) as customer_id,
	rpad(initcap(trim(full_name)), 25, ' ') as formatted_name
from string_practice;

--MODULE 2 — EXTRACTION & PARSING
--Functions: LEFT(), RIGHT(), SPLIT_PART()

-- Parsing = extracting meaningful pieces from raw text

--abdullah.waseem@gmail.com
We want:
--username → abdullah.waseem
--domain → gmail.com

--1. LEFT()
--Extract characters from the start (left side)
--LEFT(string, number_of_characters)
select left('abdullah', 4);

select 
	full_name,
	substring(initcap(trim(full_name)) from 1 for position(' ' in trim(full_name)) -1) as first_name
from string_practice;



select full_name,
	left(full_name, 5) as first_part
from string_practice;

SELECT 
    phone,
    LEFT(phone, 4) AS area_code
FROM string_practice;

--2. RIGHT()
--Extract from the end (right side)
select right('abdullah', 2);

SELECT 
    email,
    RIGHT(email, 10) AS last_part
FROM string_practice;

--Use Case — File Extensions
SELECT RIGHT('report.pdf', 3);

--3. SPLIT_PART()
--Split string using a delimiter and extract a part
--Syntax
--SPLIT_PART(string, delimiter, part_number)

select split_part('abdullah@gmail.com', '@', 1);
select split_part('abdullah@gmail.com', '@', 2);

select email,
	split_part(initcap(email), '@', 1) as username
from string_practice;

--Extract First Name
SELECT 
    full_name,
    SPLIT_PART(TRIM(full_name), ' ', 1) AS first_name
FROM string_practice;

--WHY SPLIT_PART IS SUPERIOR
--Old Method (SUBSTRING + POSITION)
--Complex 

--SPLIT_PART
--Simple , Readable ,Fast 

--Clean Email Structure
SELECT 
    LOWER(TRIM(email)) AS clean_email,
    SPLIT_PART(email, '@', 1) AS username,
    SPLIT_PART(email, '@', 2) AS domain
FROM string_practice;

--Parse Full Name
SELECT 
    INITCAP(TRIM(full_name)) AS clean_name,
    SPLIT_PART(initcap(TRIM(full_name)), ' ', 1) AS first_name,
    SPLIT_PART(TRIM(full_name), ' ', 2) AS last_name
FROM string_practice;

--MODULE 3 — TRANSFORMATION & CLEANING

--Functions:
-- REVERSE()
-- REPEAT()
-- TRANSLATE() 
-- Advanced REPLACE()

--Raw data is messy → You transform it into usable data

--1. REVERSE()
--Reverses the string
select reverse('Sana');

select
	reverse(split_part(email, '@', 1)) as domain
from string_practice;

select
	reverse(split_part(reverse(email), '@', 1)) as domain
from string_practice;

--2. REPEAT()

--Repeats a string multiple times

select repeat('*', 5);

select full_name || ' ' || repeat('-', 10) as formatted
from string_practice;

--3. TRANSLATE()
--Replace multiple characters in one go

select translate('123-4/.56(78..9', '-./(', '');


select translate('123-456-789', '-','');

--Without TRANSLATE (ugly)
select replace(replace('123-456-789', '-', ''), '-', '');

--With Trasnlate
SELECT 
    phone,
    TRANSLATE(phone, '-()./ ', '') AS clean_phone
FROM string_practice;


--4. ADVANCED REPLACE()
SELECT 
    REPLACE(REPLACE(REPLACE(phone, '-', ''), '(', ''), ')', '') AS clean_phone
FROM string_practice;

SELECT 
    REPLACE(email, '..', '.') AS clean_email
FROM string_practice;

--Function			Best Use
--REPLACE			specific patterns
--TRANSLATE			multiple single characters

select 
	id,
	initcap(
			replace(trim(full_name), '  ', ' ')) as clean_name,
			
	lower(trim(email)) as clean_email,
	
	translate(phone, '-() ', '')as clean_phone
	
from string_practice;

--What is wrong with the data?

--Problem				Solution
--extra spaces		TRIM / REPLACE
--symbols				TRANSLATE
--formatting			LOWER / INITCAP
--duplicates chars	REPLACE


--MODULE 4 — ARRAYS & ADVANCED HANDLING
--Functions:
--STRING_TO_ARRAY() 
--ARRAY_TO_STRING()

--Convert between text ↔ structured list (array)


-- This is multiple values inside one column ❗
--"apple,banana,mango"
--"0312-1234567,0345-9876543"
--"SQL,Python,Excel"

--SQL prefers:
--one value per column
--But real data often contains:
--multiple values in one field

--SOLUTION
-- Convert string → array → process → convert back

--1. STRING_TO_ARRAY()

--Concept
--Split string into array()

--Syntax
--STRING_TO_ARRAY(string, delimiter)

select string_to_array('apple,banana,mango', ',');

select email, string_to_array(email, '@') from string_practice;

--How to access array elements
select email, (string_to_array(initcap(email), '@'))[1] as username,
			  (string_to_array(email, '@'))[2] as domain
from string_practice;

--2. ARRAY_TO_STRING()

--Convert array → string

--Syntax
--ARRAY_TO_STRING(array, delimiter)

select (array_to_string(array['Python','SQl','Excel'], ','));


select email, string_to_array(email, '@') from string_practice;

select email, array_to_string(string_to_array(initcap(email), '@'), ' ->')
from string_practice;


select email, 
	array_to_String(string_to_array(email, '@'), ' ->') as formatted
from string_practice;

--1. Handle CSV Data
select string_to_array('SQL, Python,Excel', ',') as skills;

--2. Extract Specific Value
select (string_to_array('SQL, Python,Excel', ','))[2] as skills;

--3. Reformat Data
select (array_to_string(string_to_array('SQL, Python,Excel', ','), ':'))

--4. Email Parsing (Advanced Alternative)
SELECT 
    (STRING_TO_ARRAY(email, '@'))[1] AS username,
    (STRING_TO_ARRAY(email, '@'))[2] AS domain
FROM string_practice;


--ARRAY vs SPLIT_PART

select split_part('abdullah@waseem@gmail@.com', '@', 1);
select string_to_array('abdullah@waseem@gmail@.com', '@');

--Feature				SPLIT_PART		STRING_TO_ARRAY
--Simple extraction		✅				❌
--Multiple values		❌				✅
--Flexible				❌				✅
--Professional usage	High		Very High

--Missing values
SELECT STRING_TO_ARRAY('a,,c', ',');

--Use SPLIT_PART when:
--You need one part only
--Simple parsing

--Use STRING_TO_ARRAY when:
--Multiple values
--Advanced processing
--Data transformation

--Convert skills string into array
select string_to_array('SQL, Python, NumPy', ',' );

--Extract 2nd value from CSV
select (string_to_array('SQL, Python, NumPy', ',' ))[2];

--Convert array back to string
select array_to_string(string_to_array('SQL, Python, NumPy', ',' ), '->');

select
	id,
	initcap(trim(full_name)) as clean_name,
	
	(string_to_array(initcap(email), '@'))[1] as username,
	(string_to_array(lower(email), '@'))[2] as domain,
	
	array_to_string(
					string_to_array(email, '@'),
					' | '
						) as formatted_email
from string_practice;
