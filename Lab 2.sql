-- Andrew Grant Lab 2

/*1. Write a SELECT statement using the DUAL table to get the system date 
and the current date where the client is. Are these dates/times the same? 
Why or why not? What is the difference between these two functions? When 
would these functions result in different values? */

/*SYSDATE shows the date and time of where the database is located while
CURRENT_DATE shows the the time and date of the client's date and time.
In this case, they are the same because the client and database are located
in the same time zone but this will not always be the case. They would provide
different results if the Database was in New York and the client was in 
California. In that instance, the date may be the same but the client in 
California would be 3 hours behind the Database in New York.*/
--Query:
SELECT
    TO_CHAR(SYSDATE, 'MM/DD/YYYY HH24:MI:SS') AS "System Date",
    TO_CHAR(CURRENT_DATE, 'MM/DD/YYYY HH24:MI:SS') AS "Current Date"
FROM dual;


/*2. Write a query that retrieves the columns as shown in the sample 
(including headings, formatting and sorting). The third column is 
the invoice date plus 30 days. The final column is the last 
day of that month. */
SELECT invoice_number AS "Invoice #",
    invoice_date AS "Orig Date",
    (invoice_date + 30) AS "30 Days Out",
    LAST_DAY(invoice_date  + 30) AS "Last Day of the Month"
FROM ap.invoices;

/*3. Using the Student Schema, write a query that shows which students
enrolled on Feb 2, 2007, use = to do this. */
SELECT DISTINCT student_id AS "Id", 
    enroll_date AS "Enrollment Date"
FROM student.enrollment
WHERE TRUNC (enroll_date) = '02-FEB-07'
ORDER BY student_id DESC;

/*4. Using the course revenue table, write a query to retrieve the columns 
with the formatting, columns and order as shown in the sample to the right.*/
SELECT course_no, 
    TO_CHAR(revenue, '$99,999') AS "REVENUE",
    num_enrolled
FROM student.course_revenue
ORDER BY num_enrolled DESC;

/*5. Using the zip code table, show all cities that contain ‘vil’, do this 
with a single comparison (i.e. do not check for ‘Vil’ and ‘vil’) 
using wildcard characters (% and/or _) with the LIKE operators.
If new records are added, your query should still work. There is not particular 
order for these records.*/
SELECT city
FROM student.zipcode
WHERE REGEXP_LIKE (city, '[Vv]il');

/*6. Using the grade summary table, retrieve the columns and rows as
shown in the sample (include formatting and order). If there is not a grade 
given, make that grade a zero.*/
SELECT student_id, 
    COALESCE(midterm_grade, 0) AS "MIDTERM_GRADE"
FROM student.grade_summary
ORDER BY midterm_grade;

/*7. Using the grade summary table, retrieve the columns and rows
as shown in the sample to the right (include formatting and order). If
there is not a grade given, make that grade ‘Unknown’. Use the simplest
function available to do this.*/
SELECT student_id,
    LPAD(NVL(TO_CHAR(midterm_grade), 'Unknown'), 14, ' ') AS "MIDTERM_GRADE"
FROM student.grade_summary
ORDER BY midterm_grade;

/*8. Retrieve the columns and rows as shown in the sample to the right 
(include formatting and order). The grade shown is the final exam grade, 
if that is missing, it is the midterm grade. If there is not a midterm grade, 
it is the quiz grade. If there are not any grades, make it a zero. 
You must use the COALESCE function for this.*/
SELECT student_id,
    COALESCE(finalexam_grade, midterm_grade, quiz_grade, 0) AS "GRADE"
FROM student.grade_summary
ORDER BY GRADE DESC;

/*9. Write a query that examines the zip code table:
If the state is Massachusetts, Vermont, Connecticut, New Hampshire, Maine, or
Rhode Island, the region is New England.
If the state is Ohio, Indiana, West Virginia, Michigan, the region is Mid-West.
If the state is New York, New Jersey, Delaware, the region is Mid-Atlantic.
Any other state, the region is Other.
You must use a searched case statement and the IN operator to test for 
inclusion to complete this. If new records are added, the query should 
still work. */
SELECT DISTINCT state,
    CASE
        WHEN state IN ('MA', 'VT', 'CT', 'NH', 'ME', 'RI')
            THEN 'New England'
        WHEN state IN ('OH', 'IN', 'WV', 'MI')
            THEN 'Mid-West'
        WHEN state IN ('NY', 'NJ', 'DE')
            THEN 'Mid-Atlantic'
        ELSE 'Other'
    END AS "Region"
FROM student.zipcode
ORDER BY state;

/*10. Write a query that examines the course table:
If the course number is 2 digits, the year is Preparatory.
If the course number is 3 digits and starts with a 1, the year is Freshman.
If the course number is 3 digits and starts with a 2, the year is Sophomore.
If the course number is 3 digits and starts with a 3, the year is Junior.
If the course number is 3 digits and starts with a 4, the year is Senior.
You must use a simple case statement to complete this.
This one is a little tricky, but you have all the functions you need to 
complete it (think character functions). You do not have to evaluate the 
course numbers in the order given here. The order should not be dependent 
on the data in the table. If a record was added, the order should remain
consistent.*/
SELECT course_no AS "Course #",
    description AS "Course Description",
    CASE
        WHEN (LENGTH(course_no) = 2)
            THEN 'Prepatory'
        WHEN (LENGTH(course_no) = 3) AND (course_no LIKE '1%')
            THEN 'Freshman'
        WHEN (LENGTH(course_no) = 3) AND (course_no LIKE '2%')
            THEN 'Sophomore'
        WHEN (LENGTH(course_no) = 3) AND (course_no LIKE '3%')
            THEN 'Junior'
        WHEN (LENGTH(course_no) = 3) AND (course_no LIKE '4%')
            THEN 'Senior'
    END AS "Year"
FROM student.course;
