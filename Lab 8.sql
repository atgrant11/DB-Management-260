--Andrew Grant Lab 8

/*1. Create a view that defines a view named open_items that shows the invoices 
that haven’t been paid. Use a command that will replace an existing view with 
the same name. This view should return four columns from the Vendors and 
Invoices tables in the ap schema: vendor_name, invoice_number, invoice_total,
and balance_due (invoice_total – payment_total – credit_total). However, a row 
should only be returned when the balance due is greater than zero, and the rows 
should be in order with the highest balance due first. Write a simple select 
statement to review the data that it returns. For your answer include (a) the 
statement to create the view and (b) the select statement to view the 
records. (40 rows)*/
CREATE OR REPLACE VIEW open_items AS
    SELECT v.vendor_name,
        i.invoice_number,
        i.invoice_total,
        (i.invoice_total - i.payment_total - i.credit_total) AS balance_due
    FROM ap.invoices i
        JOIN ap.vendors v
            ON i.vendor_id = v.vendor_id
    WHERE (i.invoice_total - i.payment_total - i.credit_total) > 0
    ORDER BY balance_due DESC;

/*2. Using the open_items view, write a select statement that shows those 
invoices where the invoice total is not the same as the balance due. 
Format as shown (do not worry about an order by).*/
SELECT vendor_name AS "Vendor",
    TO_CHAR(invoice_total, '$999,999.99') AS "Total",
    TO_CHAR(balance_due, '$999,999.99') AS "Amount Due"
FROM open_items
WHERE invoice_total != balance_due;

/*3. Create a view named open_items_summary, using open_items as the base 
table, that returns one summary row for each vendor that contains invoices 
with unpaid balances due. Use a command that will replace an existing view 
with the same name. Each row should include vendor_name, open_item_count (the
number of invoices with a balance due), and open_item_total (the total of the 
balance due amounts), the largest open item amount, and the rows should be 
sorted by the open item totals in descending sequence. Include a simple select 
statement to show the records in the view.(16 rows)*/
CREATE OR REPLACE VIEW open_items_summary AS
    SELECT vendor_name,
        COUNT(*) AS open_item_count,
        SUM(balance_due) AS open_item_total,
        MAX(balance_due) AS highest_open_item
    FROM open_items
    GROUP BY vendor_name
    ORDER BY open_item_total DESC;
    
/*4. Write an anonymous PL/SQL block to display the number of students in the 
student.student table. */
SET SERVEROUTPUT ON;
DECLARE
    num_students NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO num_students
    FROM student.student;
    DBMS_OUTPUT.PUT_LINE('The total number of students is ' 
        || num_students || '.');
END;

/*5. Write an anonymous PL/SQL block to display the highest course number and 
its description as shown. Use the student schema. Use a subquery rather than 
sorting and limiting the rows. In the declaration section, use %TYPE to declare 
the variable types.*/
SET SERVEROUTPUT ON;
DECLARE
    course_num student.course.course_no%TYPE;
    course_desc student.course.description%TYPE;
BEGIN
    SELECT course_no,
        description
    INTO course_num,
        course_desc
    FROM student.course
    WHERE course_no = (SELECT MAX(course_no)
        FROM student.course);
    DBMS_OUTPUT.PUT_LINE('Highest course is ' || 
        course_num || ' ' || course_desc || '.');
END;

/*6. Write an anonymous PL/SQL block to display the earliest and latest 
registration dates. Use the student schema. Use a subquery rather than sorting
and limiting the rows.*/
SET SERVEROUTPUT ON;
DECLARE
    early_date student.enrollment.enroll_date%TYPE;
    late_date student.enrollment.enroll_date%TYPE;
BEGIN
    SELECT (SELECT MIN(enroll_date) FROM student.enrollment),
        (SELECT MAX(enroll_date) FROM student.enrollment)
    INTO early_date,
        late_date
    FROM dual;
    DBMS_OUTPUT.PUT_LINE('Earliest Registration Date: ' || 
        TO_CHAR(early_date, 'MM/DD/YYYY'));
    DBMS_OUTPUT.PUT_LINE('Latest Registration Date: ' || 
        TO_CHAR(late_date, 'MM/DD/YYYY'));
END;

/*7. Write three loops in an anonymous PL/SQL block.*/
SET SERVEROUTPUT ON;
DECLARE
    k NUMBER := 5;
BEGIN
    --7a. For loop that counts from 1 to 5 inclusively.
    FOR i IN 1..5 LOOP
        DBMS_OUTPUT.PUT(i || ' ');
        END LOOP;
        DBMS_OUTPUT.PUT_LINE(' ');
    --7b. For loop that counts from 20 down to 10 inclusively.
    FOR j IN REVERSE 10..20 LOOP
        DBMS_OUTPUT.PUT(j || ' ');
        END LOOP;
        DBMS_OUTPUT.PUT_LINE(' ');
    --7c. While loop that counts by 5 from 5 to 50 inclusively.
    WHILE k <= 50 LOOP
        DBMS_OUTPUT.PUT(k || ' ');
        k := k + 5;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE(' ');
END;