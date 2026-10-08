/*
A5 — Frame Clause 

25. What is a Frame — Concept 
26. ROWS BETWEEN — Syntax and Structure 
27. UNBOUNDED PRECEDING — From First Row 
28. CURRENT ROW — Current Row Reference 
29. N PRECEDING — N Rows Before Current 
30. Running Total Using Frame Clause 
31. Moving Average — 7 Day and 30 Day 
32. Rolling Sum — Last N Rows

Recommended Plan

Session 1 (Deepest Session)
A5.1 — Frame Fundamentals
What is a frame?
Difference between partition and frame
ROWS BETWEEN
UNBOUNDED PRECEDING
CURRENT ROW
N PRECEDING
How the frame moves row-by-row
Why LAST_VALUE behaved strangely

Session 2
A5.2 — Running Totals
cumulative sums
cumulative counts
cumulative averages
financial reporting patterns

Session 3
A5.3 — Rolling Windows
moving averages
rolling sums
trailing windows
business analytics use cases
portfolio-quality examples*/

Session 1
Topic 1: What is a Frame:

/*
Before defining “frame”, we must first understand the environment where a frame even 
becomes necessary.

Because if you don’t understand the problem SQL is solving, the concept will always
feel artificial.*/
1. The Hidden Problem Behind Window Functions
1.1 Traditional SQL mindset (what you already know)
/*
In normal SQL:
Case 1: GROUP BY*/

SELECT customer_id, SUM(amount)
FROM payment
GROUP BY customer_id;

--What happens internally?
--SQL does this:

| Step | Behavior                |
| ---- | ----------------------- |
| 1    | Groups rows by customer |
| 2    | Collapses rows into one |
| 3    | Produces summary        |

--You lose row level detail


1.2 The limitation
/*
Now imagine a business requirement:
	“Show each payment AND also show cumulative total up to that payment.”

This cannot be solved with GROUP BY.
Because GROUP BY destroys row-level information.*/

1.3 Window function solves this problem

SUM(amount) OVER (ORDER BY payment_date)
/*
Now SQL says:
“Do NOT collapse rows — but still give aggregated insight per row.”
So now SQL must answer:
For each row, which other rows should I consider?
This is where FRAME is born.*/

2. What Problem Does a Frame Solve?
/*
A frame solves this exact problem:

	How does SQL decide which subset of rows should participate in the calculation
	for each individual row?

Not for the whole query.
Not for a group.
But for EACH ROW independently.*/

3. First Principles Definition of Frame
/*
Now we define it properly.
A FRAME is:
	The dynamically selected subset of rows that SQL uses as input for a window function
	for a specific row.

Let’s break this carefully:
*/
| Component            | Meaning                  |
| -------------------- | ------------------------ |
| subset of rows       | not full table           |
| dynamically selected | changes per row          |
| for a specific row   | row-by-row computation   |
| input for function   | SUM, AVG, LAST_VALUE etc |

4. dvdrental Mental Model (Concrete Thinking)
/*
We use:*/
payment(payment_id, customer_id, amount, payment_date)
--Imagine sorted data:

| Row | payment_date | amount |
| --- | ------------ | ------ |
| 1   | 10:00        | 10     |
| 2   | 10:05        | 20     |
| 3   | 10:10        | 30     |
| 4   | 10:15        | 40     |

--Now we run:
SUM(amount) OVER (ORDER BY payment_date)

select
	payment_id,
	payment_date,
	amount,
	SUM(amount) OVER (ORDER BY payment_date)
from payment;

5. What SQL is REALLY doing (internal behavior)
/*
SQL does NOT compute one SUM.

Instead, it repeats this process:

For each row:
Row 1:
Which rows should I include?

→ [10]

Row 2:
Which rows should I include?

→ [10, 20]

Row 3:
Which rows should I include?

→ [10, 20, 30]

Row 4:
Which rows should I include?

→ [10, 20, 30, 40]*/

6. The FRAME (visual representation)
We can represent frames like this:

| Current Row | Frame (rows used for calculation) | Result |
| ----------- | --------------------------------- | ------ |
| Row 1       | [10]                              | 10     |
| Row 2       | [10, 20]                          | 30     |
| Row 3       | [10, 20, 30]                      | 60     |
| Row 4       | [10, 20, 30, 40]                  | 100    |

7. Core Insight (THIS is the heart of frames)
/*
A frame is NOT:
the table
the partition
the query result

A frame IS:
A temporary “view of rows” created separately for each row during computation.*/

8. Mental Model (Most Important Section)
/*
If you remember only one thing, remember this:

SQL execution for window functions works like this:

FOR each row in result set:
    1. Identify current row
    2. Build a subset of rows (FRAME)
    3. Apply window function on that subset
    4. Store result for that row*/

9. Visualization (Critical Understanding)
/*
Think of a moving spotlight:

Row 1:  [●]
Row 2:  [● ●]
Row 3:  [● ● ●]
Row 4:  [● ● ● ●]

Each ● = row included in frame

The spotlight expands → that is frame behavior.
*/
10. Why FRAME EXISTS (Business Logic)
/*
Frames exist because businesses need:

Financial example:
“Show revenue up to each transaction date”

E-commerce example:
“Show cumulative sales trend”

Analytics example:
“Show user activity progression over time”

Without frames:

	you would need complex self-joins
	or subqueries for every row
	or lose performance

Frames make this efficient and declarative.*/

11. Key Misconception (VERY IMPORTANT)
/*
Many learners think:

“Window function runs once on full dataset”
This is wrong.

Correct model:
Window function runs repeatedly — once per row — on a different subset each time.

That subset = FRAME.*/
/*
If I ask you:
	“What is a frame?”

You should NOT say:
	“a window of rows”

Instead you should say:
	“It is the dynamically changing subset of rows used by a window function for each individual row.”*/

Topic 2: Partition vs Frame

1. First Principles: Why These Two Exist
/*
Window functions need to solve two different problems at the same time:

Problem A: “Where do I work?”
This defines the scope of data

	This is solved by: PARTITION

Problem B: “Which rows do I use for THIS specific row?”
This defines the calculation input per row

	This is solved by: FRAME*/

2. One-Line Core Difference (Must Lock This)

| Concept   | Meaning                                                                 |
| --------- | ----------------------------------------------------------------------- |
| Partition | Defines the full group of rows SQL considers                            |
| Frame     | Defines the subset of those rows used for the current row’s calculation |

3. dvdrental Context Setup (We anchor everything)

We use:

payment
(payment_id, customer_id, amount, payment_date)

4. PARTITION — What It REALLY Means
/*
4.1 Definition
A partition is:
	A fixed division of the dataset into logical groups before window calculations begin.

4.2 Example*/
SUM(amount) OVER (
    PARTITION BY customer_id
)

select 
	customer_id, 
	payment_date,
	amount,
	
	sum(amount) over (
		partition by customer_id
	) as partitioned
from payment;


4.3 What SQL does internally

--SQL first builds:

| customer_id | rows                       |
| ----------- | -------------------------- |
| 1           | all payments of customer 1 |
| 2           | all payments of customer 2 |
| 3           | all payments of customer 3 |

4.4 Key property of partition
/*
IMPORTANT:

Partition is STATIC
It does NOT change per row
It defines boundaries*/

4.5 Mental Model of Partition
/*
Think:

	Whole dataset
 	  	↓
	Split into rooms
 	    ↓
	Each room = partition

Each customer = one room*/

5. FRAME — What It REALLY Means
/*
5.1 Definition
A frame is:
	A dynamic subset of rows inside a partition that is recalculated for every row.
*/
5.2 Example

SUM(amount) OVER (
    PARTITION BY customer_id
    ORDER BY payment_date
)


select 
	customer_id, 
	payment_date,
	amount,
	
	sum(amount) over (
		partition by customer_id
		order by payment_date
	) as partitioned
from payment;

5.3 What SQL does internally
/*
Inside ONE partition:
SQL does NOT use all rows at once.

Instead:
For each row:*/

| Current row | Frame used            |
| ----------- | --------------------- |
| Row 1       | [Row 1]               |
| Row 2       | [Row 1, Row 2]        |
| Row 3       | [Row 1, Row 2, Row 3] |

5.4 Key property of Frame
/*
IMPORTANT:
Frame is DYNAMIC
It changes per row
It defines calculation input*/

5.5 Mental Model of Frame
/*
Think:

Inside a partition (room)
   ↓
A spotlight moves row by row
   ↓
What spotlight covers = frame
*/

6. Side-by-Side Comparison (Critical Table)

| Feature         | Partition         | Frame                 |
| --------------- | ----------------- | --------------------- |
| Level           | Group level       | Row level             |
| Behavior        | Static            | Dynamic               |
| Scope           | Entire subgroup   | Subset per row        |
| Defined by      | PARTITION BY      | ORDER BY + ROWS/RANGE |
| Changes per row | No                | Yes                   |
| Purpose         | Data segmentation | Calculation input     |

7. Combined Execution Model (MOST IMPORTANT)

Now we combine both:

SUM(amount) OVER (
    PARTITION BY customer_id
    ORDER BY payment_date
)

select 
	customer_id, 
	payment_date,
	amount,
	
	sum(amount) over (
		partition by customer_id
		order by payment_date
	) as partitioned
from payment;
/*
Step-by-step SQL engine thinking:

Step 1: Partition phase
SQL groups:

	Customer 1 → all its payments
	Customer 2 → all its payments
	
Step 2: Within each partition
SQL sorts rows by payment_date

Step 3: Frame creation per row
Now for EACH row:

| Row   | Frame                 |
| ----- | --------------------- |
| Row 1 | [Row 1]               |
| Row 2 | [Row 1, Row 2]        |
| Row 3 | [Row 1, Row 2, Row 3] |

Step 4: Function execution

SUM is applied on each frame individually.*/

8. Final Master Mental Model
/*
If you remember only one structure:
TABLE
  ↓
PARTITION (fixed group)
  ↓
ORDERED ROWS
  ↓
FRAME (moving subset per row)
  ↓
WINDOW FUNCTION RESULT
*/
9. One-Sentence Professional Distinction

--	Partition defines where the computation happens
--	Frame defines what data is used at each step of that computation


Topic 3: ROWS between
/*
1. Why ROWS BETWEEN Exists (First Principles)

Before syntax, understand the problem.

Earlier you learned:

	Partition = group of rows
	Frame = subset of rows per row

Now SQL faces a critical question:

	“How exactly should I define the frame for each row?”

Because without strict rules, frame is ambiguous.
So SQL introduces:

ROWS BETWEEN = a precise language to define frame boundaries*/

2. What ROWS BETWEEN Actually Is
/*
Definition:

	ROWS BETWEEN is a clause that defines the start and end boundaries of a frame
	for window functions using physical row positions.

Key idea:

It answers:

	“From which row to which row should I include data for this calculation?”
*/
3. Where ROWS BETWEEN fits in SQL execution

--When SQL processes:

SUM(amount) OVER (
    PARTITION BY customer_id
    ORDER BY payment_date
    ROWS BETWEEN ...
)
/*
Internally:

Step flow:
	Build partition (customer groups)
	Sort rows inside partition
	For each row:
		define frame using ROWS BETWEEN	
		compute function on that frame
*/
4. Critical Mental Model
/*
Think like this:

Partition (fixed universe)
    ↓
Sorted rows
    ↓
For EACH row:
    → draw a boundary window (ROWS BETWEEN)
    → run function inside it

So ROWS BETWEEN is:

	the “rule system” for drawing the window
*/
5. ROWS BETWEEN Syntax Structure

ROWS BETWEEN <start_boundary> AND <end_boundary>

--Example:
ROWS BETWEEN 2 PRECEDING AND CURRENT ROW

--Meaning:

| Part        | Meaning                         |
| ----------- | ------------------------------- |
| 2 PRECEDING | start 2 rows before current row |
| CURRENT ROW | end at current row              |


6. dvdrental Example Setup
/*
We use:
payment(payment_id, customer_id, amount, payment_date)

Let’s assume sorted data:
*/
| Row | payment_date | amount |
| --- | ------------ | ------ |
| 1   | 10:00        | 10     |
| 2   | 10:05        | 20     |
| 3   | 10:10        | 30     |
| 4   | 10:15        | 40     |

7. Example 1 — Basic ROWS between

SELECT
    payment_id,
    amount,
    SUM(amount) OVER (
        ORDER BY payment_date
        ROWS BETWEEN 1 PRECEDING AND CURRENT ROW
    ) AS rolling_sum
FROM payment;

7.1 How SQL evaluates EACH row
/*
Row 1:

Frame = [Row1]
→ 10

Row 2:

Frame = [Row1, Row2]
→ 30

Row 3:

Frame = [Row2, Row3]
→ 50

Row 4:

Frame = [Row3, Row4]
→ 70
*/

7.2 Insight:

--This is a:
--2-row rolling window

8. Example 2 — 3-row window

SELECT
    payment_id,
    amount,
    SUM(amount) OVER (
        ORDER BY payment_date
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS rolling_sum
FROM payment;

--Row-by-row frame:

| Row | Frame        | Result |
| --- | ------------ | ------ |
| 1   | [10]         | 10     |
| 2   | [10, 20]     | 30     |
| 3   | [10, 20, 30] | 60     |
| 4   | [20, 30, 40] | 90     |

9. What ROWS BETWEEN REALLY Means (Core Insight)
/*
Important truth:

	ROWS BETWEEN does NOT operate on values — it operates on row positions.

This is critical.
It does NOT care about:

time difference
value difference

It ONLY cares about:

row index position in sorted order*/

10. Mental Model (VERY IMPORTANT)
/*
Imagine a sliding window:

Row 1: [●]
Row 2: [● ●]
Row 3: [● ● ●]
Row 4: [● ● ●]

But controlled by rules:

start boundary
end boundary

That rule system = ROWS BETWEEN
*/

11. Why ROWS BETWEEN is necessary
/*
Without it:
SQL would assume default frame behavior like:

	UNBOUNDED PRECEDING → CURRENT ROW

Which gives running totals only.

But businesses need more:

rolling averages
last N transactions
moving sums
short-term trends

So ROWS BETWEEN gives full control.
*/

12. Business Interpretation
/*
Example 1: Finance

	“Show revenue of last 3 transactions per customer”
	ROWS BETWEEN 2 PRECEDING AND CURRENT ROW

Example 2: E-commerce

	“Smooth daily sales fluctuations using rolling window”

Example 3: Fraud detection

	“Check last 5 transactions behavior pattern”
*/

13. Common Mistakes

/*Mistake 1:

Thinking ROWS BETWEEN uses time

❌ Wrong
✔ It uses row position

Mistake 2:

Confusing frame with partition

❌ Partition = frame
✔ Partition = universe, frame = moving subset

Mistake 3:

Expecting it to ignore ORDER BY

❌ Without ORDER BY → meaningless frame
*/

14. Key Takeaway (Must Remember)

ROWS BETWEEN is the mechanism that defines exactly which rows form the frame for each
row-based computation in window functions.


Topic 4: UNBOUNDED preceding:
/*
Before we write a single query, I want you to forget that UNBOUNDED PRECEDING is a SQL keyword.
For the next hour, think of it as a frame boundary instruction.
Because that is what it really is.*/

1. First Principles: Why Does UNBOUNDED PRECEDING Exist?
/*
We learned:
A frame needs two boundaries:

ROWS BETWEEN <start_boundary> AND <end_boundary>

SQL needs answers to two questions:

	Where does the frame start?	
	Where does the frame end?*/

--Suppose we have ordered payments:

| Position | Amount |
| -------- | ------ |
| 1        | 10     |
| 2        | 20     |
| 3        | 30     |
| 4        | 40     |
| 5        | 50     |

/*
Now imagine SQL is processing Row 4.

Where should the frame start?

Possible answers:

Start at Row 3
Start at Row 2
Start at Row 1
Start at beginning of partition

SQL needs a way to express:
	"Start from the very first row available."
That is exactly why UNBOUNDED PRECEDING exists.
*/
2. Definition
/*
Formal Definition

UNBOUNDED PRECEDING means:
	Start at the first row of the partition.
No matter which row SQL is currently processing.

Professional Definition
	UNBOUNDED PRECEDING defines a frame boundary that always points to the 
	earliest row in the current partition.*/

3. The Most Important Mental Model

--Imagine a customer's payment history.

Row1
Row2
Row3
Row4
Row5
Row6

--Now SQL is currently processing:

--Row4

--If start boundary is:

--UNBOUNDED PRECEDING

--SQL says:

Start Here
    ↓
Row1
Row2
Row3
Row4 ← Current row

--Now move to Row5:

Start Here
    ↓
Row1
Row2
Row3
Row4
Row5 ← Current row

--Notice something important.
--The start never moves.
--Only the end moves.
--This is the secret behind cumulative calculations.

4. First dvdrental Query

--Let's start simple.
SELECT
    payment_id,
    payment_date,
    amount,
    SUM(amount) OVER (
        ORDER BY payment_date
        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
    ) AS running_total
FROM payment;

--both output same

SELECT
    payment_id,
    payment_date,
    amount,
    SUM(amount) OVER (
        ORDER BY payment_date
    ) AS running_total
FROM payment;

/*
Row 1

Frame:
Amount
5

Result:
5

Row 2

Frame:
Amount
5
7

Result:
12

Row 3

Frame:
Amount
5
7
4

Result:
16

Row 4

Frame:
Amount
5
7
4
10

Result:
26

Key Observation

The beginning never changes.

START = fixed
END = moving

This is exactly what:
UNBOUNDED PRECEDING

means.*/

6. Visual Frame Movement

--Imagine:
Row1:
[1]

Row2:
[1 2]

Row3:
[1 2 3]

Row4:
[1 2 3 4]

Row5:
[1 2 3 4 5]

--The frame grows.
--Why?
--
--Because:
--UNBOUNDED PRECEDING
--locks the start boundary to Row1 forever.

7. Real dvdrental Example — Customer Running Spend
--Business Question:
--
--How much has each customer spent up to every payment?

SELECT
    customer_id,
    payment_date,
    amount,
    SUM(amount) OVER (
        PARTITION BY customer_id
        ORDER BY payment_date
        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
    ) AS cumulative_spent
FROM payment
ORDER BY customer_id, payment_date;

--Business Interpretation
--Suppose Customer 1 paid:

| Date  | Amount |
| ----- | ------ |
| Jan 1 | 5      |
| Jan 3 | 8      |
| Jan 8 | 10     |

--Output

| Date  | Amount | Cumulative |
| ----- | ------ | ---------- |
| Jan 1 | 5      | 5          |
| Jan 3 | 8      | 13         |
| Jan 8 | 10     | 23         |

--This is exactly how:

--Banking systems
--Customer lifetime value models
--Subscription analytics
--work.

8. COUNT() Example

--Most students only practice SUM.
--Professionals practice every aggregate.

SELECT
    customer_id,
    payment_date,
    COUNT(*) OVER (
        PARTITION BY customer_id
        ORDER BY payment_date
        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
    ) AS payment_count_so_far
FROM payment;

--Business Question:
--How many payments has the customer made up to this point?
--Output:

| Payment | Count |
| ------- | ----- |
| 1st     | 1     |
| 2nd     | 2     |
| 3rd     | 3     |
| 4th     | 4     |

9. AVG() Example

SELECT
    customer_id,
    payment_date,
    amount,
    AVG(amount) OVER (
        PARTITION BY customer_id
        ORDER BY payment_date
        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
    ) AS running_avg
FROM payment;

--Business Question:
--How is the customer's average payment evolving over time

--This is common in:

--credit risk systems
--fraud detection
--customer behavior analytics

10. MAX() Example

--This one is extremely important analytically.

SELECT
    customer_id,
    payment_date,
    amount,
    MAX(amount) OVER (
        PARTITION BY customer_id
        ORDER BY payment_date
        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
    ) AS highest_payment_so_far
FROM payment;

--Business Question:
--What is the largest payment this customer has ever made up to this moment?
--Imagine:

| Amount |
| ------ |
| 5      |
| 8      |
| 20     |
| 7      |

--Result:
| Amount | Highest So Far |
| ------ | -------------- |
| 5      | 5              |
| 8      | 8              |
| 20     | 20             |
| 7      | 20             |

--Notice:
--The historical maximum remains visible.

11. MIN() Example

SELECT
    customer_id,
    payment_date,
    amount,
    MIN(amount) OVER (
        PARTITION BY customer_id
        ORDER BY payment_date
        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
    ) AS lowest_payment_so_far
FROM payment;

--Business Question:
--What is the smallest payment observed up to this point?

--Useful for:
--	anomaly detection
--	customer behavior tracking
--	monitoring systems

12. Why Professionals Love UNBOUNDED PRECEDING
/*
Because it creates:
Cumulative Analytics

Examples:

Running Revenue
SUM()

Running Order Count
COUNT()

Running Average
AVG()

Historical Maximum
MAX()

Historical Minimum
MIN()
*/

13. Common Student Mistakes

Mistake 1

Thinking:
UNBOUNDED PRECEDING means previous row.

Wrong.
Previous row:
1 PRECEDING

UNBOUNDED PRECEDING means:
Go all the way to the beginning.

Mistake 2

Thinking it means:
Entire table

Wrong.
It means:
Beginning of current partition
Not entire dataset.
*/
14. Senior Analyst Mental Model
/*
Beginners think:
UNBOUNDED PRECEDING = syntax

Senior analysts think:
UNBOUNDED PRECEDING = Historical context from the start of a partition

When they see it, they immediately recognize:

cumulative metrics
lifetime metrics
historical tracking
progressive analytics
*/
15. The One Sentence to Remember Forever
/*
Whenever you see:
	UNBOUNDED PRECEDING

Think:
	"Start my frame at the very first row of the partition and never move that starting point."

That single sentence explains why running totals, cumulative averages, cumulative counts, 
historical maxima, and lifetime customer metrics all work.*/

-- Running count

Practice Query

SELECT
    payment_date,
    COUNT(*) OVER (
        ORDER BY payment_date
        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
    )
FROM payment;


Topic 4: CURRENT row
/*
Deep Professional Understanding Using dvdrental
Now we arrive at one of the most important concepts in window framing.
Many students think:

	CURRENT ROW

simply means:
	"the row I am on"

While technically true, that understanding is far too shallow.
A professional SQL analyst understands that:
	CURRENT ROW is a moving reference point that SQL uses to build frames.
To master window functions, you must stop thinking of CURRENT ROW as a row and 
start thinking of it as a frame boundary marker.*/

1. Why CURRENT ROW Exists

--Earlier we learned:
--A frame needs two boundaries.

ROWS BETWEEN <start_boundary>
         AND <end_boundary>
/*
SQL must know:

	Where does the frame start?
	Where does the frame stop?

UNBOUNDED PRECEDING solved the first question:
	Where does the frame start?
Now SQL still needs:
	Where does the frame end?
CURRENT ROW is one of the answers.*/

2. Formal Definition

--Definition
--CURRENT ROW means:
--	The row currently being processed by the window function.

Professional Definition
	CURRENT ROW defines a frame boundary that points to the row 
	whose result SQL is currently calculating.
	
3. The Most Important Mental Shift
/*
Most beginners imagine SQL processing the entire dataset simultaneously.

--Window functions don't work that way.

Internally SQL behaves conceptually like this:

Process Row 1
Process Row 2
Process Row 3
Process Row 4
...

For each row:

	CURRENT ROW changes*/

4. Visualizing CURRENT ROW

--Imagine ordered payments:
--Position

| Position | Amount |
| -------- | ------ |
| 1        | 10     |
| 2        | 20     |
| 3        | 30     |
| 4        | 40     |
| 5        | 50     |

--When SQL is processing Row 1:
[10] ← CURRENT ROW
20
30
40
50

--When SQL moves to Row 2:
10
[20] ← CURRENT ROW
30
40
50

--When SQL moves to Row 3:
10
20
[30] ← CURRENT ROW
40
50

--Notice:
--CURRENT ROW is not fixed.
--It moves continuously.

5. Why CURRENT ROW Is So Important
/*
Without CURRENT ROW:

SQL would not know where to stop many frames.

Example:

ROWS BETWEEN UNBOUNDED PRECEDING
         AND CURRENT ROW

This means:

Start at beginning
Stop at current row

This creates:

Growing frame

which is the foundation of:

running totals
cumulative averages
cumulative counts
historical maximums*/

6. First dvdrental Example

SELECT
    payment_date,
    amount,
    SUM(amount) OVER (
        ORDER BY payment_date
        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
    ) AS running_total
FROM payment;

--Internal Execution
--Assume:

| Row | Amount |
| --- | ------ |
| 1   | 5      |
| 2   | 7      |
| 3   | 4      |
| 4   | 10     |

/*
Row 1
CURRENT ROW = Row 1

Frame:
[5]

Result:
5

Row 2
CURRENT ROW = Row 2

Frame:
[5,7]

Result:
12

Row 3
CURRENT ROW = Row 3

Frame:
[5,7,4]

Result:
16

Row 4

CURRENT ROW = Row 4

Frame:
[5,7,4,10]

Result:
26

Key Insight
CURRENT ROW causes the end boundary to move.

Start boundary = fixed
End boundary = moving

This creates cumulative behavior.*/

7. Another Example Using COUNT()

SELECT
    payment_date,
    COUNT(*) OVER (
        ORDER BY payment_date
        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
    ) AS cumulative_count
FROM payment;

--Frame progression:

| Current Row | Rows Visible |
| ----------- | ------------ |
| Row 1       | 1            |
| Row 2       | 1,2          |
| Row 3       | 1,2,3        |
| Row 4       | 1,2,3,4      |

--Result:

| Row | Count |
| --- | ----- |
| 1   | 1     |
| 2   | 2     |
| 3   | 3     |
| 4   | 4     |

8. MAX() Example

SELECT
    payment_date,
    amount,
    MAX(amount) OVER (
        ORDER BY payment_date
        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
    ) AS highest_so_far
FROM payment;

9. Business Interpretation
/*
Think of CURRENT ROW as:
	"Everything known up to this moment."
Companies use this constantly.

Financial Reporting
Question:
	How much revenue had been generated up to this transaction?
	
CURRENT ROW defines:
up to this transaction*/

10. CURRENT ROW Is Not Always the End
--
--Many students accidentally think:
--CURRENT ROW always appears at the end

--Wrong.
--It can appear on either side.

--Example:

ROWS BETWEEN CURRENT ROW
         AND UNBOUNDED FOLLOWING

--Meaning:
Current row
↓
Future rows

--Or:

ROWS BETWEEN CURRENT ROW
         AND 2 FOLLOWING

--Meaning:

Current row + next 2 rows

--This is important because CURRENT ROW is simply:
--A position marker.
--Not necessarily an ending point.

11. Mental Model Used by Senior Analysts

--Beginners think:

CURRENT ROW = current record

--Professionals think:

CURRENT row = Moving anchor point for frame construction

--Every frame definition is relative to it.

12. Relationship Between UNBOUNDED PRECEDING and CURRENT ROW

--This is one of the most common patterns in SQL:

ROWS BETWEEN UNBOUNDED PRECEDING
         AND CURRENT ROW

--Interpretation:
         
Start:
first row in partition

End:
current row

--Visual:

Row 1:
[1]

Row 2:
[1 2]

Row 3:
[1 2 3]

Row 4:
[1 2 3 4]

--This combination creates:

--Running totals
--Running averages
--Running counts
--Historical maximums
--Historical minimums

13. Common Student Mistakes
/*
Mistake 1

Thinking CURRENT ROW means:
Only current row

Wrong.
It identifies a boundary.
The frame may include many rows.

Example:

ROWS BETWEEN UNBOUNDED PRECEDING
         AND CURRENT ROW

At Row 100:
Frame contains:
Rows 1 → 100
Not just Row 100.

Mistake 2
Thinking CURRENT ROW is static.

Wrong.
It moves continuously during execution.

Mistake 3

Thinking CURRENT ROW is only used in running totals.

Wrong.
It is used in:

rolling windows
trailing windows
future-looking windows
ranking-related frame logic
LAST_VALUE behavior*/

14. Why CURRENT ROW Matters for LAST_VALUE

--This is the topic that confused you earlier.

--Suppose:

LAST_VALUE(amount)
OVER (
    ORDER BY payment_date
)

--The default frame often behaves like:

	UNBOUNDED PRECEDING
	TO CURRENT row
/*	
At Row 3:

Frame:

Row1
Row2
Row3

LAST_VALUE returns:

Row3 value
because CURRENT ROW is the end boundary.

Not:
Last row of partition

This is why LAST_VALUE seems broken.
Actually:

CURRENT ROW is limiting the frame.

We'll revisit this in depth later.*/

	
Topic 5: N preceding
/*
Deep Frame Understanding (dvdrental + Execution Thinking)

Now we arrive at the concept that turns your understanding from 
“cumulative thinking” → “true rolling analytics thinking.”

Up to now:

UNBOUNDED PRECEDING → expanding frame from the start
CURRENT ROW → moving endpoint

Now we introduce:

N PRECEDING = a fixed-size backward-looking window
*/
1. First Principles: Why N PRECEDING Exists
/*
SQL needed a way to answer this business question:

	“Instead of looking from the start, can I only look at the last N rows?”

Because real analytics often does NOT want full history.

It wants:

recent behavior
short-term trends
local smoothing
rolling calculations

So SQL introduces:

	N PRECEDING*/

2. Formal Definition

--N PRECEDING means:

	Start the frame N rows before the current row (based on ORDER BY sequence).
	
Professional Definition

	N PRECEDING defines a moving lower boundary of the frame that shifts 
	forward as the current row moves.
	
3. Key Mental Shift (VERY IMPORTANT)

--Until now:

UNBOUNDED PRECEDING:
--frame grows continuously

Now:

N PRECEDING:
--frame becomes fixed-size and slides forward

4. dvdrental Setup

--We use:
--payment(payment_id, customer_id, amount, payment_date)

--Assume sorted data:

| Row | Amount |
| --- | ------ |
| 1   | 10     |
| 2   | 20     |
| 3   | 30     |
| 4   | 40     |
| 5   | 50     |

5. Basic Example — 2 PRECEDING
Query

SELECT
    payment_id,
    amount,
    SUM(amount) OVER (
        ORDER BY payment_date
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS rolling_sum
FROM payment;

6. Step-by-Step Frame Construction

--We simulate SQL execution row by row.

--Row 1 (current row = 1)
--2 PRECEDING means:

--go 2 rows back → but none exist

--Frame:
| Row | Amount |
| --- | ------ |
| 1   | 10     |


Result:
10

Row 2
Frame:

| Row | Amount |
| --- | ------ |
| 1   | 10     |
| 2   | 20     |

Result:
30

Row 3
Frame:

| Row | Amount |
| --- | ------ |
| 1   | 10     |
| 2   | 20     |
| 3   | 30     |

Result:
60

Row 4

Now window starts shifting:
Frame:

| Row | Amount |
| --- | ------ |
| 2   | 20     |
| 3   | 30     |
| 4   | 40     |

Result:
90

Row 5
Frame:

| Row | Amount |
| --- | ------ |
| 3   | 30     |
| 4   | 40     |
| 5   | 50     |

Result:
120

7. Core Insight (VERY IMPORTANT)

N PRECEDING creates a SLIDING WINDOW
Unlike UNBOUNDED PRECEDING:

| Concept             | Behavior                  |
| ------------------- | ------------------------- |
| UNBOUNDED PRECEDING | Growing window            |
| N PRECEDING         | Fixed-size sliding window |

8. Visualization (Mental Model)

--Think of a moving window:

Row 1: [10]
Row 2: [10 20]
Row 3: [10 20 30]
Row 4: [20 30 40]
Row 5: [30 40 50]

--The window slides forward.

9. Business Interpretation (VERY IMPORTANT)
/*
Use Case 1: Sales Trend Analysis
	“What were sales in the last 3 transactions?”

Use Case 2: Customer Behavior
	“How much did a customer spend in their last 5 purchases?”

Use Case 3: Fraud Detection
	“Check if last 3 transactions show abnormal pattern”

Use Case 4: Performance smoothing
	“Smooth out spikes in revenue using rolling windows”
*/
10. Why N PRECEDING is powerful
/*
Because real-world data is:

noisy
unstable
non-linear

So analysts do NOT want full history.

They want:

local context

N PRECEDING provides that.*/

11. Comparison With Previous Concepts
/*
UNBOUNDED PRECEDING
	Always start from first row
→ cumulative behavior

CURRENT ROW
	Ends frame at current row
→ boundary control

N PRECEDING
	Start from N rows before current row
→ sliding local window
*/

12. Critical Mental Model
/*
At every row SQL does:

1. Identify current row
2. Look N rows back
3. Build frame
4. Apply function
5. Move to next row*/

13. Common Mistakes (VERY IMPORTANT)
/*
Mistake 1: Thinking it uses time

❌ Wrong:
“last 3 days”

✔ Correct:
“last 3 rows in ORDER BY sequence”

Mistake 2: Forgetting ORDER BY dependency

Without ORDER BY:
N PRECEDING is meaningless
Because row order defines “previous”

Mistake 3: Mixing with partition

Inside each partition:

N PRECEDING resets
It does NOT cross partitions*/

14. Senior Analyst Perspective
/*
Beginners think:
“It selects previous rows”

Experts think:
“It defines a sliding analytical context window over ordered data”

This shift is what makes you an analytics engineer instead of a query writer.*/

15. One Sentence Master Definition
/*
Whenever you see:
	N PRECEDING

Think:
	“A moving frame that includes the current row and the previous N rows based on ordering.”*/

16. What You Now Understand
/*
You now have full control over:

cumulative frames (UNBOUNDED PRECEDING)
boundary stopping (CURRENT ROW)
sliding windows (N PRECEDING)*/


Topic 6: How Frame Moves Row-by-row
/*
 * The Final Mental Model for Frame Execution (dvdrental)

This is the most important consolidation point in everything you have learned so far.

If you understand this properly, then:

UNBOUNDED PRECEDING
CURRENT ROW
N PRECEDING
ROWS BETWEEN

stop being separate concepts.

They become one system.*/

1. The Core Idea You Must Understand First
/*
Window functions do NOT execute like a normal query.
Instead, SQL behaves like this:
It recomputes the frame for every single row.

Not once.

Not twice.

But:
For every row in the result set.*/

2. The Execution Model (First Principles)
/*
For a window function:

SUM(amount) OVER (ORDER BY payment_date ...)

SQL internally does:

FOR each row in sorted data:
    1. Identify current row
    2. Build frame based on frame rule
    3. Apply aggregate function on that frame
    4. Store result for that row*/

3. dvdrental Dataset Mental Setup

--We use:

payment(payment_id, amount, payment_date)

--Sorted by payment_date:
| Row | Amount |
| --- | ------ |
| 1   | 10     |
| 2   | 20     |
| 3   | 30     |
| 4   | 40     |
| 5   | 50     |
4. Frame Movement Concept (Core Insight)
/*
A frame is NOT static.
It behaves like a moving window system.

At each row:

SQL recalculates the frame
Frame shifts depending on rule
Function runs again
*/

5. Case 1 — UNBOUNDED PRECEDING to CURRENT row

ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
Frame movement:
/*
Row 1

Frame:
[10]

Row 2

Frame:
[10, 20]

Row 3

Frame:
[10, 20, 30]

Row 4

Frame:
[10, 20, 30, 40]

Row 5

Frame:
[10, 20, 30, 40, 50]

Key observation:
Start is fixed
End moves forward

So frame grows.*/

6. Case 2 — N PRECEDING to CURRENT row

ROWS BETWEEN 2 PRECEDING AND CURRENT row
/*
Frame movement:

Row 1
[10]
Row 2
[10, 20]
Row 3
[10, 20, 30]
Row 4
[20, 30, 40]
Row 5
[30, 40, 50]

Key observation:
Frame size is constant (3 rows max)
Frame slides forward

This is a rolling window*/

7. Visual Model (VERY IMPORTANT)

Think of frame as a sliding box:
Row 1: [■]
Row 2: [■ ■]
Row 3: [■ ■ ■]
Row 4:   [■ ■ ■]
Row 5:     [■ ■ ■]

The box moves forward one row at a time.

8. Why Frame Must Be Recomputed for Each Row
/*
This is the key to understanding SQL internals.
SQL cannot:
compute frame once and reuse it

Because:

CURRENT ROW changes
N PRECEDING changes
ordering context shifts

So SQL must:

re-evaluate frame boundaries for every row*/

9. The Hidden Truth About Window Functions
/*
Most beginners think:
	SQL calculates once and applies result

Correct model:
	SQL recalculates context for every row independently

This is why window functions are:

powerful
expensive
analytical (not procedural)*/

10. Combining All Frame Types (Unified View)

--Now everything fits together:
--Frame rules determine movement:

| Frame Type          | Behavior        |
| ------------------- | --------------- |
| UNBOUNDED PRECEDING | Expanding frame |
| CURRENT ROW         | Moving boundary |
| N PRECEDING         | Sliding window  |

11. Business Interpretation (VERY IMPORTANT)
/*
Think of frame movement like business analysis over time:

Finance Example
“How much revenue has been generated up to this moment?”
Frame grows → cumulative revenue

Retail Example
“What were the last 3 transactions worth?”
Frame slides → recent behavior

Fraud Detection
“What patterns exist in last few transactions?”
Frame focuses locally → anomaly detection*/

12. Senior Analyst Mental Model
/*
Beginners see:
	rows and syntax

Professionals see:
	a continuously shifting analytical context over ordered data

They mentally simulate:

At each row:
    What data is visible?
    What window is active?
    What context is changing?*/

13. The Most Important Insight in This Entire Topic

If you remember only one thing:
	A frame is not a static subset of data — it is a continuously recomputed subset that 
	changes for every row based on window boundaries.

14. Why This Matters for LAST_VALUE (Preview)
/*
Now you are ready for the next big concept:

Because now you understand:

frame changes per row
CURRENT ROW restricts visibility
N PRECEDING limits history
UNBOUNDED PRECEDING expands history

So LAST_VALUE will finally make sense:

It is NOT broken — it is reacting to the frame you defined.*/

15. Final Checkpoint
/*
You should now clearly understand:

Why frames must move
How frames change per row
Why window functions are repeated per row
How different frame clauses control movement
Why cumulative vs rolling behavior exists*/

Topic 7: Why LAST_VALUE Behaves Strangely

1. The Student Confusion (Let’s Start Here)

--Most learners write:
SELECT
    customer_id,
    payment_date,
    amount,
    LAST_VALUE(amount) OVER (
        PARTITION BY customer_id
        ORDER BY payment_date
    ) AS last_value
FROM payment;
/*
And expect:

“Give me the last payment of each customer”

But instead they see something like:

NOT the last payment in the partition
BUT changing values row by row

So they conclude:

LAST_VALUE is broken

It is NOT broken.

It is strictly following frame rules.*/

2. The Real Reason (One Sentence)

LAST_VALUE behaves “strangely” because it is computed over the CURRENT FRAME, 
not the entire partition.

--That single sentence is the entire mystery.

--Now we will build it properly.

3. Step Back — What LAST_VALUE Actually Does
Definition:

LAST_VALUE(x) returns:

--The last value inside the current frame.

--NOT the partition. NOT the table. Only the frame.

4. dvdrental Setup

--We use:

payment(customer_id, payment_date, amount)

--Assume for one customer:
| Row | payment_date | amount |
| --- | ------------ | ------ |
| 1   | 10:00        | 5      |
| 2   | 10:05        | 8      |
| 3   | 10:10        | 20     |
| 4   | 10:15        | 7      |

5. The Query That Confuses Everyone

SELECT
    payment_date,
    amount,
    LAST_VALUE(amount) OVER (
        PARTITION BY customer_id
        ORDER BY payment_date
    ) AS last_value
FROM payment;

6. What You EXPECT

--You expect:
| Row | LAST_VALUE |
| --- | ---------- |
| 1   | 7          |
| 2   | 7          |
| 3   | 7          |
| 4   | 7          |

7. What Actually Happens

--To understand this, we must look at the default frame behavior.

8. CRITICAL FACT: Default Frame in SQL

--When you write:

ORDER BY payment_date

--WITHOUT explicit frame clause, PostgreSQL uses:

RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW

(or similar default behavior depending on version/settings)

9. This is the REAL Problem
/*
So frame becomes:

At each row:
Row 1

Frame:

[5]

LAST_VALUE = 5

Row 2

Frame:

[5, 8]

LAST_VALUE = 8

Row 3

Frame:

[5, 8, 20]

LAST_VALUE = 20

Row 4

Frame:

[5, 8, 20, 7]

LAST_VALUE = 7*/

10. Final output

| Row | amount | LAST_VALUE |
| --- | ------ | ---------- |
| 1   | 5      | 5          |
| 2   | 8      | 8          |
| 3   | 20     | 20         |
| 4   | 7      | 7          |

11. Why This Feels “Wrong”
/*
Because your expectation was:
“Give me the last row of the entire partition”

But SQL is doing:
“Give me the last row of the CURRENT FRAME”

And the frame is shrinking or growing depending on definition.*/

12. The Core Insight

--LAST_VALUE is NOT global.

--It is:

--frame-relative

--This is the key realization.

13. The Fix (Professional Solution)

--To make LAST_VALUE behave as expected:

SELECT
    customer_id,
    payment_date,
    amount,
    LAST_VALUE(amount) OVER (
        PARTITION BY customer_id
        ORDER BY payment_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS correct_last_value
FROM payment;

14. Now Frame Becomes:

--At EVERY row:

[5, 8, 20, 7]

--So:

| Row | LAST_VALUE |
| --- | ---------- |
| 1   | 7          |
| 2   | 7          |
| 3   | 7          |
| 4   | 7          |

15. Why This Works
/*
Because now:

frame starts at first row
frame ends at last row
frame is constant across all rows

So LAST_VALUE becomes truly “last row of partition”.*/

16. The Deep Mental Model

--Now connect everything:

LAST_VALUE depends on:
| Concept               | Effect               |
| --------------------- | -------------------- |
| PARTITION BY          | defines group        |
| ORDER BY              | defines sequence     |
| FRAME                 | defines visibility   |
| CURRENT ROW (default) | cuts off frame early |

17. The Real Root Cause of Confusion
/*
The confusion was NOT LAST_VALUE.

It was this:
	You assumed frame = full partition

But SQL actually used:
	frame = up to CURRENT ROW

That single mismatch causes the entire “bug feeling”.*/

18. Senior Analyst Understanding
/*
Beginners think:
LAST_VALUE is incorrect

Professionals think:
LAST_VALUE is correctly reflecting a dynamically changing frame

And they immediately ask:
“What is my frame definition?”*/

19. One Sentence Permanent Fix

Whenever LAST_VALUE confuses you, remember:

LAST_VALUE returns the last row in the CURRENT FRAME, not the entire partition 
— unless the frame is explicitly extended to UNBOUNDED FOLLOWING.

20. What You Now Fully Understand
/*
You now understand:

Why LAST_VALUE changes row by row
Why default frames cut off early
Why CURRENT ROW affects output
Why UNBOUNDED FOLLOWING fixes it
Why it is not a bug, but frame logic*/

21. Where You Stand Now (Big Achievement)
/*
You have now mastered:

Frame concept
Partition vs frame
ROWS BETWEEN
UNBOUNDED PRECEDING
CURRENT ROW
N PRECEDING
Frame movement
LAST_VALUE internals

This is already advanced analytics engineering territory.*/







Session 2 — A5.2 Running Totals

/*
Part 1 — What Is a Running Total?

Let's start from zero.

Traditional SUM

Suppose:

Payment
10
20
30
40

Query:*/

select sum(amount)
from payment;

--Result:
--sum
61312.04
/*
Question:
Can you see the growth over time?
No.

You only know:
Final Total = 61312.04
Everything else is lost.

Running Total Solves This Problem
Instead of:
Give me final total

we ask:
Show total at every step

Result:*/
| Amount | Running Total |
| ------ | ------------- |
| 10     | 10            |
| 20     | 30            |
| 30     | 60            |
| 40     | 100           |

--Now we see growth.
--Mental Model
--Imagine a bucket.

--Each new payment adds money.

Payment 1
Bucket = 10

Payment 2
Bucket = 30

Payment 3
Bucket = 60

Payment 4
Bucket = 100

--Running total = bucket value after every transaction.

/*Why Businesses Love Running Totals

Because businesses think in growth.

Questions like:

How much revenue have we generated so far?
How many customers have we acquired so far?
How much has this customer spent up to this point?
What is our progress toward a target?

are all cumulative questions.*/

--The Most Important Query in This Session

select
	customer_id,
	payment_date,
	amount,
	
	sum(amount) over (
		partition by customer_id
		order by payment_date
		rows between 
			unbounded preceding
			and current row
	) as sum_per_row
	
from payment;

--This is the mother of all running totals.
--Everything else is a variation.

--How SQL Executes It
--Suppose:

| Row | Amount |
| --- | ------ |
| 1   | 10     |
| 2   | 20     |
| 3   | 30     |
| 4   | 40     |
/*
Row 1
Frame:
[10]

Result:
10

Row 2
Frame:
[10,20]

Result:
30

Row 3
Frame:
[10,20,30]

Result:
60

Row 4
Frame:
[10,20,30,40]

Result:
100

This is cumulative behavior.*/

--Cumulative SUM (Professional Section)
--Let's use dvdrental.

--Query 1 — Overall Revenue Growth

SELECT
    payment_date,
    amount,
    SUM(amount) OVER (
        ORDER BY payment_date
        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
    ) AS running_revenue
FROM payment;

--Business Question:
--	How much revenue had been generated at each payment event?

--Business Interpretation
--Instead of seeing individual payments:

| Payment |
| ------- |
| 4.99    |
| 2.99    |
| 7.99    |

--You see

| Revenue So Far |
| -------------- |
| 4.99           |
| 7.98           |
| 15.97          |

--This is exactly how financial dashboards work.
--Query 2 — Customer Lifetime Spend

SELECT
    customer_id,
    payment_date,
    amount,
    SUM(amount) OVER (
        PARTITION BY customer_id
        ORDER BY payment_date
        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
    ) AS lifetime_spend
FROM payment;
/*
Business Question
How much has this customer spent so far?

Example Output
Customer 5:
 */
| Payment | Amount | Lifetime Spend |
| ------- | ------ | -------------- |
| 1       | 5      | 5              |
| 2       | 8      | 13             |
| 3       | 10     | 23             |
| 4       | 4      | 27             |

--This pattern appears everywhere:

--Banking
--Telecom
--SaaS
--E-commerce

--Query 3 — Revenue by Month (Running)

select 
	date_trunc('month', payment_date) as month,
	sum(amount) as monthly_revenue,
	
	sum(sum(amount)) over (
		order by date_trunc('month', payment_date)
		) as cmulative_sum

from payment
group by month;

/*
Stop here and notice something advanced.
We have:
SUM(SUM(amount))

This is:
aggregation of aggregation

A professional pattern.
Execution:

Step 1
Monthly revenue:
 */

| Month | Revenue |
| ----- | ------- |
| Jan   | 500     |
| Feb   | 600     |
| Mar   | 700     |

--Step 2
--Running revenue:

| Month | Revenue | Running |
| ----- | ------- | ------- |
| Jan   | 500     | 500     |
| Feb   | 600     | 1100    |
| Mar   | 700     | 1800    |

--This is how CFO dashboards are built.

Cumulative COUNT
--Now we count history instead of money.

--Query 4 — Number of Payments So Far

SELECT
    customer_id,
    payment_date,
    COUNT(*) OVER (
        PARTITION BY customer_id
        ORDER BY payment_date
        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
    ) AS payment_count
FROM payment;

--Business Question
--How many purchases has the customer made up to this point?

--Output
| Purchase | Count |
| -------- | ----- |
| First    | 1     |
| Second   | 2     |
| Third    | 3     |
| Fourth   | 4     |

/*
Professional Use Cases

Customer Engagement
How active is customer?

Loyalty Programs
How many purchases completed?

Subscription Analytics
How many billing events occurred?*/

Cumulative AVG
--Now we track average behavior over time.

--Query 5 — Running Average Payment

SELECT
    customer_id,
    payment_date,
    amount,
    AVG(amount) OVER (
        PARTITION BY customer_id
        ORDER BY payment_date
        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
    ) AS running_avg
FROM payment;

Suppose:

Amount
10
20
30
40

Results:
| Amount | Running Avg |
| ------ | ----------- |
| 10     | 10          |
| 20     | 15          |
| 30     | 20          |
| 40     | 25          |

--Why Analysts Care
--Because average behavior changes.

--Question:
--	Is customer spending increasing over time?

--Running averages reveal trends.

Advanced Query — Compare Current Payment vs Historical Average

select 
	customer_id,
	payment_date,
	amount,
	
	avg(amount) over (
		partition by customer_id
		order by payment_date
		rows between
			unbounded preceding 
			and current row
	) as running_avg,
	
	amount - 
	avg(amount) over (
		partition by customer_id
		order by payment_date
		rows between
			unbounded preceding 
			and current row
	) as deviation

from payment;

/*
Business Question
	Is this payment unusually high compared to historical behavior?
This is the foundation of anomaly detection.

Financial Reporting Patterns (Professional Analytics)
Now let's connect everything.
*/
Pattern 1 — Revenue Progress Tracking
 
SELECT
    payment_date,
    amount,
    SUM(amount) OVER (
        ORDER BY payment_date
    ) AS revenue_so_far
FROM payment;

--Question:
--How much money have we earned so far?

Pattern 2 — Customer Lifetime Value Growth

SELECT
    customer_id,
    payment_date,
    amount,
    SUM(amount) OVER (
        PARTITION BY customer_id
        ORDER BY payment_date
    ) AS customer_ltv
FROM payment;

--Question:
--How valuable is this customer becoming?

Pattern 3 — Transaction Growth Tracking

SELECT
    payment_date,
    COUNT(*) OVER (
        ORDER BY payment_date
    ) AS transactions_so_far
FROM payment;

--Question:
--How quickly are transactions accumulating?

Pattern 4 — Average Spend Evolution

SELECT
    payment_date,
    AVG(amount) OVER (
        ORDER BY payment_date
    ) AS avg_spend_so_far
FROM payment;

--Question:
--Is customer spending behavior changing?

/*
Common Mistakes

Mistake 1
Thinking:

SUM(amount)

and

SUM(amount) OVER(...)

are similar.
They are not.

One collapses rows.
One preserves rows.


Mistake 2

Forgetting ORDER BY
	
	SUM(amount) OVER ()

This gives total repeated on every row.
Not a running total.

Mistake 3

Thinking cumulative = rolling
Wrong.
We will learn rolling windows in Session 3.
*/
/*
Senior Analyst Mental Model

Beginners see:

	SUM(amount)

Experts see:
Historical accumulation process.
When they look at:*/
	SUM(amount) OVER (
    	ORDER BY payment_date
	)

--they immediately think:

--growth
--trajectory
--progress
--lifetime metrics
--financial reporting

--not syntax.

	
	
	
Session 3 — A5.3 Rolling Windows


The Transition from Historical Analytics to Professional Forecasting & Trend Analysis
/*
This is the final session of A5.
If Session 1 taught you:
	How frames work
and Session 2 taught you:
	How cumulative analytics work
then Session 3 teaches:
	How professional analysts study recent behavior instead of entire history.

1. The Core Problem with Running Totals

Let's start from first principles.

Suppose monthly revenue is:*/

| Month | Revenue |
| ----- | ------- |
| Jan   | 100     |
| Feb   | 120     |
| Mar   | 130     |
| Apr   | 125     |
| May   | 140     |

Running Total

| Month | Running Revenue |
| ----- | --------------- |
| Jan   | 100             |
| Feb   | 220             |
| Mar   | 350             |
| Apr   | 475             |
| May   | 615             |

--Question:
--Can you easily detect recent trends?

--Not really.
--Running totals always increase.

--They tell you:
--	total growth

--But they hide:
--	short-term behavior

/*
What Businesses Actually Want

Questions like:

How are the last 7 days performing?
What is the average of recent transactions?
Are recent sales improving?
Is customer activity declining?
Is performance accelerating?

These are not cumulative questions.

They are:

rolling window questions*/

2. What Is a Rolling Window?

Professional Definition
A rolling window is:
	
	A moving frame that only includes the most recent N rows relative to the current row.

--Mental Model
	
--Instead of:
Beginning → Current Row

(cumulative)

--We now use:
	Recent N Rows → Current Row

(rolling)

--Example
| Row | Revenue |
| --- | ------- |
| 1   | 100     |
| 2   | 120     |
| 3   | 130     |
| 4   | 125     |
| 5   | 140     |

--Frame
ROWS BETWEEN 2 PRECEDING
         AND CURRENT row
         
--Frames become:
Row1 → [100]

Row2 → [100,120]

Row3 → [100,120,130]

Row4 → [120,130,125]

Row5 → [130,125,140]

--Notice:
--The window slides.

3. Rolling Sum

--Concept
--A rolling sum answers:
--	How much activity occurred during the most recent N rows?

--dvdrental Example

select 
	payment_id,
	payment_date,
	amount,
	
	sum(amount) over (
		order by payment_date
		rows between 
			2 preceding
			and current row
	) as rolling_sum
	
from payment;

--Internal Execution
--Suppose:

| Row | Amount |
| --- | ------ |
| 1   | 10     |
| 2   | 20     |
| 3   | 30     |
| 4   | 40     |
| 5   | 50     |

--Results

| Row | Frame      | Rolling Sum |
| --- | ---------- | ----------- |
| 1   | [10]       | 10          |
| 2   | [10,20]    | 30          |
| 3   | [10,20,30] | 60          |
| 4   | [20,30,40] | 90          |
| 5   | [30,40,50] | 120         |

--Business Interpretation
--Question:
--What was the value of the last 3 transactions?

--Used in:

--Banking
--Retail
--Fraud monitoring
--Customer behavior analysis

4. Moving Average

--This is arguably the most important rolling metric.
--Why Moving Average Exists

--Raw data is noisy.
Example:
| Day | Revenue |
| --- | ------- |
| 1   | 100     |
| 2   | 400     |
| 3   | 50      |
| 4   | 500     |
| 5   | 120     |

--Can you see the trend?
--Difficult.
--
--Moving average smooths noise.
--Query

SELECT
    payment_date,
    amount,

    AVG(amount) OVER (
        ORDER BY payment_date
        ROWS BETWEEN 2 PRECEDING
                 AND CURRENT ROW
    ) AS moving_avg
FROM payment;

Execution

| Row | Frame        | Average |
| --- | ------------ | ------- |
| 1   | [100]        | 100     |
| 2   | [100,400]    | 250     |
| 3   | [100,400,50] | 183.33  |
| 4   | [400,50,500] | 316.67  |
| 5   | [50,500,120] | 223.33  |

--Key Insight
--Moving averages reduce volatility.
--
--This is why they are everywhere:
--
--Stock markets
--Sales forecasting
--Operational dashboards
--Product analytics

5. 7-Day Moving Average
/*
Real businesses rarely care about:
2 PRECEDING

They care about:

Last 7 Days
Last 30 Days
Last Quarter*/

SELECT
    payment_date,
    amount,

    AVG(amount) OVER (
        ORDER BY payment_date
        ROWS BETWEEN 6 PRECEDING
                 AND CURRENT ROW
    ) AS avg_7_day
FROM payment;

Interpretation:

Current row + Previous 6 rows = 7-row moving average

6. 30-Day Moving Average

SELECT
    payment_date,
    amount,

    AVG(amount) OVER (
        ORDER BY payment_date
        ROWS BETWEEN 29 PRECEDING
                 AND CURRENT ROW
    ) AS avg_30_day
FROM payment;
/*
Used for:

Revenue smoothing
KPI reporting
Forecasting

Important Note
With ROWS, SQL counts rows.
Not days.
Remember this.*/

7. Trailing Windows

--Now we introduce an important term.

--Definition
--A trailing window is:

	A rolling frame that looks backward from the current row.

--Example:
	ROWS BETWEEN 4 PRECEDING
         AND CURRENT row
         
Meaning:

Current row + previous 4 rows

--This is called:
	trailing 5-row window
	
Row 1 → [1]

Row 2 → [1,2]

Row 3 → [1,2,3]

Row 4 → [1,2,3,4]

Row 5 → [1,2,3,4,5]

Row 6 → [2,3,4,5,6]

Row 7 → [3,4,5,6,7]

Why Analysts Love Trailing Windows
/*
Because businesses care about:
	recent performance

more than ancient history.

Example Questions
Last 30 days revenue?
Last 10 transactions?
Last 5 customer purchases?
Last 7 login sessions?*/

8. Rolling Metrics by Customer

--Now let's make it more realistic.
--Customer Spending Trend

SELECT
    customer_id,
    payment_date,
    amount,

    AVG(amount) OVER (
        PARTITION BY customer_id
        ORDER BY payment_date
        ROWS BETWEEN 2 PRECEDING
                 AND CURRENT ROW
    ) AS recent_avg_spend
FROM payment;
/*
Business Question:
	How is customer spending behaving recently?

Now each customer gets:

independent window
independent trend
independent rolling average*/

9. Advanced Analytics Pattern

Compare Current Value vs Recent Average

SELECT
    customer_id,
    payment_date,
    amount,

    AVG(amount) OVER (
        PARTITION BY customer_id
        ORDER BY payment_date
        ROWS BETWEEN 4 PRECEDING
                 AND CURRENT ROW
    ) AS recent_avg,

    amount -
    AVG(amount) OVER (
        PARTITION BY customer_id
        ORDER BY payment_date
        ROWS BETWEEN 4 PRECEDING
                 AND CURRENT ROW
    ) AS deviation
FROM payment;

10. Rolling Sum vs Running Sum
--This interview question appears frequently.

Running Sum

UNBOUNDED PRECEDING
TO CURRENT ROW

Frame:

1
1,2
1,2,3
1,2,3,4

Always growing.

Rolling Sum

2 PRECEDING
TO CURRENT ROW

Frame:

1
1,2
1,2,3
2,3,4
3,4,5

Sliding.

--Professional Comparison
| Running           | Rolling          |
| ----------------- | ---------------- |
| Entire history    | Recent history   |
| Cumulative growth | Short-term trend |
| Lifetime metrics  | Local behavior   |
| Expanding frame   | Sliding frame    |

11. Portfolio-Level Project Query #1
Revenue Momentum Dashboard

SELECT
    DATE(payment_date) AS day,

    SUM(amount) AS revenue,

    AVG(SUM(amount)) OVER (
        ORDER BY DATE(payment_date)
        ROWS BETWEEN 6 PRECEDING
                 AND CURRENT ROW
    ) AS revenue_7day_avg

FROM payment
GROUP BY day
ORDER BY day;

--Business Value:
--Tracks:

--daily revenue
--revenue trend
--performance smoothing

--Portfolio-worthy query.

12. Portfolio-Level Project Query #2
Customer Trend Analysis

SELECT
    customer_id,
    payment_date,
    amount,

    SUM(amount) OVER (
        PARTITION BY customer_id
        ORDER BY payment_date
        ROWS BETWEEN 4 PRECEDING
                 AND CURRENT ROW
    ) AS recent_spending
FROM payment;

--Business Question
--How much has each customer spent in their last 5 purchases?
--
--Excellent portfolio project.
/*
Common Mistakes

Mistake 1

Thinking:

ROWS BETWEEN 6 PRECEDING
         AND CURRENT ROW

means 7 days.
Wrong.
It means 7 rows.

Mistake 2

Forgetting ORDER BY.
Without ordering:

	previous rows don't exist conceptually

Mistake 3

Confusing cumulative with rolling.

One grows.
One slides.*/


Following and unbounded Following:

--You already know how to look backward:

--N PRECEDING
--UNBOUNDED PRECEDING

--Now we learn how to look forward.

The Complete Frame Boundary Family
Think of frame boundaries as directions.

| Boundary            | Meaning                         |
| ------------------- | ------------------------------- |
| UNBOUNDED PRECEDING | Start at first row              |
| N PRECEDING         | Start N rows before current row |
| CURRENT ROW         | Current row position            |
| N FOLLOWING         | N rows after current row        |
| UNBOUNDED FOLLOWING | Last row of partition           |



← Past                               Future →
------------------------------------------------

UNBOUNDED PRECEDING
      N PRECEDING
            CURRENT ROW
                   N FOLLOWING
                         UNBOUNDED following
                         
Part 1 — N following

Definition
	N FOLLOWING

means:
	N rows after the current row.               
	
SELECT
    payment_id,
    amount,
    SUM(amount) OVER (
        ORDER BY payment_date
        ROWS BETWEEN CURRENT ROW
                 AND 2 FOLLOWING
    ) AS future_sum
FROM payment;
/*
What Is Happening?

Unlike PRECEDING:

Looking backward

FOLLOWING means:

Looking forward

The frame is now future-oriented.*/


Part 2 — UNBOUNDED FOLLOWING

--Now we reach the boundary that finally completes the LAST_VALUE story.

Definition

	UNBOUNDED FOLLOWING

means:
	Go all the way to the last row of the partition.

--Mental Model
--Suppose:
	
| Row | Amount |
| --- | ------ |
| 1   | 10     |
| 2   | 20     |
| 3   | 30     |
| 4   | 40     |
| 5   | 50     |

Current row:

Row 2

Then:

UNBOUNDED FOLLOWING

means:

Row 2
↓
Continue
↓
Until final row

Frame endpoint:

Row 5

Visualization

At Row 2:

20
30
40
50

Everything from current row to end.

SELECT
    payment_id,
    amount,

    SUM(amount) OVER (
        ORDER BY payment_date
        ROWS BETWEEN CURRENT ROW
                 AND UNBOUNDED FOLLOWING
    ) AS future_total
FROM payment;

--Internal Execution

| Row | Amount |
| --- | ------ |
| 1   | 10     |
| 2   | 20     |
| 3   | 30     |
| 4   | 40     |
| 5   | 50     |

Row 1
Frame:
10
20
30
40
50

Result:
150

Row 2
Frame:
20
30
40
50

Result:
140

Row 3
Frame:

30
40
50

Result:
120

Row 4
Frame:
40
50

Result:
90

Row 5
Frame:
50

Result:
50

Why UNBOUNDED FOLLOWING Matters

--This boundary is critical because it allows a frame to see:
--The entire future portion
--of the partition.

The LAST_VALUE Fix Revisited

select
	customer_id,
	payment_date,
	amount,
	
	last_value(amount) over (
		partition by customer_id
		order by payment_date
		rows between
			unbounded preceding
			and unbounded following
	) as last_value

from payment;


| Boundary            | Think                  |
| ------------------- | ---------------------- |
| UNBOUNDED PRECEDING | Beginning of partition |
| N PRECEDING         | N rows behind          |
| CURRENT ROW         | Current position       |
| N FOLLOWING         | N rows ahead           |
| UNBOUNDED FOLLOWING | End of partition       |

Beginning
    ↓
UNBOUNDED PRECEDING
      ↓
N PRECEDING
      ↓
CURRENT ROW
      ↓
N FOLLOWING
      ↓
UNBOUNDED FOLLOWING
    ↓
end

