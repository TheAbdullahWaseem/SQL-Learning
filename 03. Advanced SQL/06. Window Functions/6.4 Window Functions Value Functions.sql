SECTION A4 — Value Functions
Module A4.1 — LAG() and LEAD()

PART 1 — The Problem That LAG() and LEAD() Solve
Imagine a monthly revenue table:

| Month | Revenue |
| ----- | ------: |
| Jan   |   10000 |
| Feb   |   12000 |
| Mar   |   15000 |
| Apr   |   14000 |

--Business asks:
--How much did revenue change compared to the previous month?

--To answer that:

--For March:

--Current Revenue = 15000
--Previous Revenue = 12000
--Difference = +3000

--SQL processes one row at a time.
--When SQL is looking at March:
--Current row = March
--How does it access February?

--That is exactly why LAG() exists.

--Mental Model of LAG()

--Think of:
--LAG(column)

--as:

--Look behind me.
--Give me a value from a previous row.

--Visual Model

| Month | Revenue |
| ----- | ------: |
| Jan   |   10000 |
| Feb   |   12000 |
| Mar   |   15000 |
| Apr   |   14000 |

--Using:
--LAG(revenue)

--Result:
| Month | Revenue | Previous Revenue |
| ----- | ------: | ---------------: |
| Jan   |   10000 |             NULL |
| Feb   |   12000 |            10000 |
| Mar   |   15000 |            12000 |
| Apr   |   14000 |            15000 |

--Now every row can see its previous row.
--This is incredibly powerful.

--Why Was This Difficult Before Window Functions?

--Before LAG() existed, analysts used:

--self joins
--correlated subqueries

--Example:

SELECT ...
FROM sales s1
JOIN sales s2

--These solutions were:

--harder to write
--harder to maintain
--often slower

--LAG() made row-to-row analysis simple.

PART 2 — Basic Syntax

LAG(expression)
OVER (
    PARTITION BY ...
    ORDER BY ...
)

--First Important Observation

--Unlike ranking functions:

ROW_NUMBER()
RANK()
DENSE_RANK()

which create new values,

LAG() retrieves an existing value from another row.

--This is a major conceptual shift.

--First Professional Query

--Let's use payments.

select
	customer_id,
	payment_date,
	amount,
	
	lag(amount) over (
		partition by customer_id
		order by payment_date
	) as previous_payment

from payment;
/*
Internal Execution

For each customer:
Step 1

Build partition.

Customer 1
Customer 2
Customer 3

Step 2

Sort rows.

Oldest payment
→
Newest payment

Step 3

For every row:
Look backward one row.
Current Row
↑
Fetch Previous Row Value

Example
*/
| Date   | Amount |
| ------ | -----: |
| Jan 1  |      5 |
| Jan 5  |      8 |
| Jan 10 |      6 |

--result
| Date   | Amount | Previous |
| ------ | -----: | -------: |
| Jan 1  |      5 |     NULL |
| Jan 5  |      8 |        5 |
| Jan 10 |      6 |        8 |

/*Business Interpretation

This allows questions like:

Did the customer's payment increase?
Is spending growing?
Is spending declining?
These are real analytical questions.*/

PART 3 — Why ORDER BY Is Critical

--Consider:

LAG(amount) OVER (
    PARTITION BY customer_id
)
/*
This is invalid in PostgreSQL.

Why?
Because:
Previous relative to what?
Without ordering:

previous
next
earlier
later

have no meaning.
Key Rule

For value functions:
ORDER BY defines navigation.

For ranking functions:
ORDER BY defines ranking.

Different purpose.
Same importance.*/

PART 4 — The Most Common Use Case
Change Detection

--Business loves change metrics.

select
	customer_id,
	payment_date,
	amount,
	
	lag(amount) over (
		partition by customer_id
		order by payment_date
	) as previous_amount,
	
	amount - 
	lag(amount) over(
		partition by customer_id
		order by payment_date
	) as difference

	from payment;

--What This Produces
| Amount | Previous | Difference |
| -----: | -------: | ---------: |
|     10 |     NULL |       NULL |
|     15 |       10 |          5 |
|     20 |       15 |          5 |
|     18 |       20 |         -2 |

/*Business Meaning

Positive → growth
Negative → decline
Zero → no change
*/

PART 5 — Percentage Growth Analysis
--Very common professionally.

select
	customer_id, 
	payment_date,
	amount,
	
	lag(amount) over (
			partition by customer_id
			order by payment_date
		) as previous_amount,
		
	amount -
	lag(amount) over (
			partition by customer_id
			order by payment_date
					 ) as difference,
	
	round(
		(
			amount -
			lag(amount) over (
				partition by customer_id
				order by payment_date
							 )
		)
		/
		lag(amount) over (
			partition by customer_id
			order by payment_date
		)
		* 100,
		2
		) as growth_pct
		
from payment;

--Business Question
--By what percentage did spending change?
--This is a classic BI metric.

PART 6 — Offset Parameter

--Now we move deeper.
Default behavior:

LAG(amount)

--means:
--Look back 1 row.

Explicit version

LAG(amount, 1)
--Same result.

Offset = 2

LAG(amount, 2)

--means:

Look back two rows.

--Example
| Amount |
| -----: |
|     10 |
|     15 |
|     20 |
|     18 |

--LAG(amount, 2)

| Amount | Lag 2 |
| -----: | ----: |
|     10 |  NULL |
|     15 |  NULL |
|     20 |    10 |
|     18 |    15 |

--Offset = navigation distance.

--Business Uses

--Compare:

--today vs yesterday
--today vs last week
--today vs last month
--current quarter vs previous quarter

--All use offsets.

select 
	customer_id,
	payment_date,
	amount,
	
	lag(amount, 2) over (
		partition by customer_id
		order by payment_date
	) as previous_2nd_row

from payment;

PART 7 — Default Value Parameter

--Now another important feature.

--Problem
--When no previous row exists:
--LAG(amount)
--returns:
--NULL

| Amount | Previous |
| -----: | -------: |
|     10 |     NULL |
|     15 |       10 |

--Sometimes business wants:
0
instead.

--Syntax

LAG(amount, 1, 0)

--Meaning:
--Look back 1 row.
--If unavailable return 0.

| Amount | Previous |
| -----: | -------: |
|     10 |        0 |
|     15 |       10 |


select 
	customer_id,
	payment_date,
	amount,
	
	lag(amount, 2) over (
		partition by customer_id
		order by payment_date
	) as previous_2nd_row

from payment;

--Full Syntax

LAG(
    expression,
    offset,
    default_value
)
/*
Remember

Argument			Meaning
expression			value to retrieve
offset				how far back
default				value if row missing*/

PART 8 — LEAD()
/*
Now we move to the sister function.

If:
LAG()

means:
Look backward.

Then:
LEAD()

means:
Look forward.

Mental Model
LAG  ← current row → LEAD*/

--Example

| Month | Revenue |
| ----- | ------: |
| Jan   |     100 |
| Feb   |     120 |
| Mar   |     150 |
| Apr   |     140 |

--Using:
--LEAD(revenue)

| Month | Revenue | Next Revenue |
| ----- | ------: | -----------: |
| Jan   |     100 |          120 |
| Feb   |     120 |          150 |
| Mar   |     150 |          140 |
| Apr   |     140 |         NULL |

--Syntax

LEAD(expression)
OVER (...)

--Almost identical to LAG().

SELECT
    customer_id,
    payment_date,
    amount,

    LEAD(amount) OVER (
        PARTITION BY customer_id
        ORDER BY payment_date
    ) AS next_payment

FROM payment;
/*
Business Interpretation
Answers:

What happens after this event?
This is huge in behavioral analytics.*/

PART 9 — LEAD offset

LEAD(amount, 2)
--means:
--Look ahead two rows.

| Amount |
| -----: |
|     10 |
|     15 |
|     20 |
|     18 |

--Result:

| Amount | Lead 2 |
| -----: | -----: |
|     10 |     20 |
|     15 |     18 |
|     20 |   NULL |
|     18 |   NULL |

PART 10 — LEAD Default Value

LEAD(amount, 1, 0)
--Meaning:
--
--Look ahead 1 row.
--If unavailable return 0.

PART 11 — One Query Showing Everything

--Run this carefully.

SELECT
    customer_id,
    payment_date,
    amount,

    LAG(amount) OVER (
        PARTITION BY customer_id
        ORDER BY payment_date
    ) AS previous_payment,

    LEAD(amount) OVER (
        PARTITION BY customer_id
        ORDER BY payment_date
    ) AS next_payment

FROM payment;

PART 12 — Professional Analytics Patterns
--These are extremely important.
/*
Pattern 1 — Month-over-Month Growth
Current Month
Previous Month
Difference
Growth %

Uses LAG().

Pattern 2 — Churn Detection
Customer activity drops
Compared to previous period

Uses LAG().

Pattern 3 — Future Event Analysis
Current order
Next order

Uses LEAD().

Pattern 4 — Session Analytics
Current login
Next login
Time between logins

Uses both.

Pattern 5 — Gap Analysis
LEAD(event_date) - event_date

Used everywhere professionally.


One Extremely Important Professional Insight

Ranking functions answered:
Where is this row?

Value functions answer:

What happened before?
What happens next?
How did things change?

This is a completely different level of analytics.*/

Module A4.2 — FIRST_VALUE() and LAST_VALUE()
/*
This module is more important than most SQL learners realize.

At first glance, these functions look simple:

FIRST_VALUE()
LAST_VALUE()

Many people think:

"Oh, they just return the first and last value."

Technically true.

But professionally:

LAST_VALUE() is one of the most misunderstood window functions in SQL.

In fact, understanding why LAST_VALUE() often surprises people will prepare you for:

SECTION A5 — Window Frames
ROWS BETWEEN
CURRENT ROW
PRECEDING
FOLLOWING

which is one of the deepest topics in window functions.

So although these functions are small,
the concepts behind them are important.*/

PART 1 — The Core Problem They Solve
/*
You already learned:

LAG()
Look backward a few rows.

LEAD()
Look forward a few rows.

Now we ask a different question:
What is the first value in my entire window?

or

What is the last value in my entire window?
This is boundary analysis.

Example*/
Customer payments:

| Date | Amount |
| ---- | -----: |
| Jan  |     10 |
| Feb  |     15 |
| Mar  |     20 |
| Apr  |     18 |

/*
Business asks:
Show every payment together with the customer's first payment amount.
Desired result:*/

| Date | Amount | First Payment |
| ---- | -----: | ------------: |
| Jan  |     10 |            10 |
| Feb  |     15 |            10 |
| Mar  |     20 |            10 |
| Apr  |     18 |            10 |
--This is exactly what FIRST_VALUE() does.

PART 2 — Mental Model
/*
Think of:

FIRST_VALUE()

as:

Go to beginning of window.
Bring that value.
Repeat for every row.

And:

LAST_VALUE()

as:

Go to end of window.
Bring that value.
Repeat for every row.

At least that is what most people expect.

Later you'll see why LAST_VALUE() becomes tricky.*/

PART 3 — FIRST_VALUE()

Syntax

FIRST_VALUE(column)
OVER (
    PARTITION BY ...
    ORDER BY ...
)

--First Professional Query

SELECT
    customer_id,
    payment_date,
    amount,

    FIRST_VALUE(amount) OVER (
        PARTITION BY customer_id
        ORDER BY payment_date
    ) AS first_payment

FROM payment;

--Internal Execution
--Suppose customer history:

| Date | Amount |
| ---- | -----: |
| Jan  |     10 |
| Feb  |     15 |
| Mar  |     20 |
| Apr  |     18 |
/*
Database sorts rows:

Jan
Feb
Mar
Apr

Then remembers:
First amount = 10
Then attaches it to every row:*/

| Date | Amount | First |
| ---- | -----: | ----: |
| Jan  |     10 |    10 |
| Feb  |     15 |    10 |
| Mar  |     20 |    10 |
| Apr  |     18 |    10 |

/*
Business Meaning
This lets us compare:

Current value
vs
Starting value

Very useful professionally.*/

PART 4 — Common Business Uses
/*
First Purchase Analysis

FIRST_VALUE(payment_date)

Find:
customer acquisition date

Starting Revenue

FIRST_VALUE(revenue)
Compare growth from start.

Initial Product Price

FIRST_VALUE(price)
Track price evolution.

Portfolio Analytics

Initial stock price
Current stock price
Very common.
*/

PART 5 — Powerful Pattern
--Growth Since First Event
--This is a real analytics pattern.

SELECT
    customer_id,
    payment_date,
    amount,

    FIRST_VALUE(amount) OVER (
        PARTITION BY customer_id
        ORDER BY payment_date
    ) AS first_amount,

    amount -
    FIRST_VALUE(amount) OVER (
        PARTITION BY customer_id
        ORDER BY payment_date
    ) AS growth_since_first

FROM payment;

--Business Question
--How much has spending changed since the customer's first payment?
--Extremely useful.

PART 6 — FIRST_VALUE() with DESC Ordering
/*
Important.

Suppose:
ORDER BY payment_date DESC

Now:
First row changes.
Because ordering changes.

Example:*/

| Date |
| ---- |
| Apr  |
| Mar  |
| Feb  |
| Jan  |

/*
Now:

FIRST_VALUE()

returns:

Apr value

not Jan.

Key Rule

For value functions:

ORDER BY defines window navigation.

Always remember this.*/

--in this query we changed the order

SELECT
    customer_id,
    payment_date,
    amount,

    FIRST_VALUE(amount) OVER (
        PARTITION BY customer_id
        ORDER BY payment_date desc
    ) AS first_amount
 
from payment;

PART 7 — Now the Dangerous Function
LAST_VALUE()
/*
This is where many SQL developers become confused.

Let's start with what people EXPECT.

Suppose:*/

| Date | Amount |
| ---- | -----: |
| Jan  |     10 |
| Feb  |     15 |
| Mar  |     20 |
| Apr  |     18 |

/*
Most people expect:
LAST_VALUE(amount)
to produce:*/

| Date | Amount | Last |
| ---- | -----: | ---: |
| Jan  |     10 |   18 |
| Feb  |     15 |   18 |
| Mar  |     20 |   18 |
| Apr  |     18 |   18 |

--Seems logical.
--Right?
--But PostgreSQL Usually Does NOT Do That
--This is the famous surprise.

Run:

SELECT
    customer_id,
    payment_date,
    amount,

    LAST_VALUE(amount) OVER (
        PARTITION BY customer_id
        ORDER BY payment_date
    ) AS last_amount

FROM payment;

You may see:

| Date | Amount | Last |
| ---- | -----: | ---: |
| Jan  |     10 |   10 |
| Feb  |     15 |   15 |
| Mar  |     20 |   20 |
| Apr  |     18 |   18 |

--And students think:
--LAST_VALUE is broken!
--But it isn't.

PART 8 — Why This Happens

--This is your first introduction to:

--Window Frames
--When you write:

ORDER BY payment_date

--PostgreSQL automatically creates a default frame.

Conceptually:

Start of partition
→
Current row

NOT:

Start of partition
→
End of partition

So for:

Jan row
window frame is:
Jan
Last value = Jan

For:

Feb row
window frame becomes:
Jan
Feb
Last value = Feb

For:

Mar row
window frame becomes:
Jan
Feb
Mar
Last value = Mar

Suddenly the behavior makes sense.
/*
IMPORTANT
This is not really a LAST_VALUE() problem.
This is a:
frame problem.
And frames are our next section.*/

PART 9 — The Correct Professional Pattern

--When analysts truly want:
--last row of partition
--they write:

SELECT
    customer_id,
    payment_date,
    amount,

	LAST_VALUE(amount)
	OVER (
    	PARTITION BY customer_id
    	ORDER BY payment_date
    	ROWS BETWEEN
        	UNBOUNDED PRECEDING
        	AND UNBOUNDED FOLLOWING
		 )
		 
FROM payment;

/*
Now the frame becomes:
First row
→
Last row

for every row.
Result:*/

| Date | Amount | Last |
| ---- | -----: | ---: |
| Jan  |     10 |   18 |
| Feb  |     15 |   18 |
| Mar  |     20 |   18 |
| Apr  |     18 |   18 |

--This is usually what business wants.

PART 10 — do not Panic About Frames

--Right now:

--You do NOT need to master:

ROWS BETWEEN
UNBOUNDED PRECEDING
UNBOUNDED FOLLOWING

--We will study them deeply in A5.

--For now remember:

FIRST_VALUE()
--usually behaves as expected.

LAST_VALUE()
--often requires explicit frame definition.

--This is the key takeaway.

PART 11 — Professional Business Uses
/*
Latest Customer Activity
LAST_VALUE(payment_date)
Find latest payment date.

Latest Revenue
LAST_VALUE(revenue)
Compare current vs latest.

Final Stock Price
LAST_VALUE(price)
Financial analytics.

Lifecycle Analysis
Compare:

first value
last value

for growth tracking.
*/

PART 12 — FIRST_VALUE vs LAG
/*
Many learners confuse them.
LAG
Returns:
previous row

FIRST_VALUE
Returns:
first row in window

Completely different purpose.
Example:*/

| Date | Amount |
| ---- | -----: |
| Jan  |     10 |
| Feb  |     15 |
| Mar  |     20 |

For Mar:

LAG(amount)
= 15
FIRST_VALUE(amount)
= 10

--Huge difference.

PART 13 — FIRST_VALUE vs LAST_VALUE
/*
Think:

FIRST_VALUE
=
starting point

LAST_VALUE
=
ending point

Boundary analytics.*/

PART 14 — Extremely Powerful Pattern
Start vs End Comparison

SELECT
    customer_id,
    payment_date,
    amount,

    FIRST_VALUE(amount) OVER (
        PARTITION BY customer_id
        ORDER BY payment_date
    ) AS first_amount,

    LAST_VALUE(amount) OVER (
        PARTITION BY customer_id
        ORDER BY payment_date
        ROWS BETWEEN
            UNBOUNDED PRECEDING
            AND UNBOUNDED FOLLOWING
    ) AS last_amount

FROM payment;

--This creates:

--Starting state
--Ending state

--on every row.

PART 15 — Professional Summary

--Use FIRST_VALUE() when:

--You need:

--starting value
--initial state
--first event
--earliest value

--Use LAST_VALUE() when:

--You need:

--latest value
--final state
--ending value

--BUT remember:

LAST_VALUE()
--often requires explicit frame definition.



