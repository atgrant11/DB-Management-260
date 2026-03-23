--Andrew Grant Lab 6

/*1. Use a JOIN to write a query showing all vendors that do not
have invoices.*/
SELECT vendor_name
FROM ap.vendors v
    LEFT JOIN ap.invoices i
        ON i.vendor_id = v.vendor_id
WHERE i.vendor_id IS NULL;

/*2. Rewrite the query from #1 using a subquery. Use the IN or
NOT IN operator in the where clause. Make sure your subquery returns 
only unique values.*/
SELECT vendor_name as "Vendor"
FROM ap.vendors
WHERE vendor_id NOT IN 
    (SELECT vendor_id
    FROM ap.invoices);
    
/*3a. Find the number of employees in each department we are not
concerned about the order of the records.*/
SELECT department_name AS department,
    COUNT(employee_id) AS emp_count
FROM hr.departments d
    JOIN hr.employees e
        ON d.department_id  = e.department_id
GROUP BY department_name;

/*3b. Using the query from 3a, find the average number of employees
per department.*/
SELECT ROUND(AVG(emp_count), 2) AS "Average Emp Per Dept"
FROM (SELECT department_name AS department,
        COUNT(employee_id) AS emp_count
    FROM hr.departments d
        JOIN hr.employees e
            ON d.department_id  = e.department_id
    GROUP BY department_name);
    
/*3c. Using the queries from 3a & 3b, show the departments that have
a number of employees higher than the average. DO NOT hardcode
any numbers. This query needs to work if the data should change.*/
SELECT department_name AS department,
    COUNT(employee_id) AS emp_count
FROM hr.departments d
    JOIN hr.employees e
        ON d.department_id  = e.department_id
GROUP BY department_name
HAVING COUNT(*) > (
        SELECT ROUND(AVG(emp_count), 2) AS "Average Emp Per Dept"
        FROM (SELECT department_name AS department,
                COUNT(employee_id) AS emp_count
                FROM hr.departments d
                    JOIN hr.employees e
                    ON d.department_id  = e.department_id
                GROUP BY department_name));
/*3d. Simplify the query from 3c by employing a factoring clause
(WITH). Add to this by sorting the records based on employee
count as shown*/
WITH dept_counts AS
(
    SELECT department_name AS department,
        COUNT(employee_id) AS emp_count
    FROM hr.departments d
        JOIN hr.employees e
            ON d.department_id  = e.department_id
    GROUP BY department_name
),
avg_count AS 
(
    SELECT ROUND(AVG(emp_count), 2) AS avg_emp
    FROM (SELECT department_name AS department,
            COUNT(employee_id) AS emp_count
            FROM hr.departments d
                JOIN hr.employees e
                ON d.department_id  = e.department_id
            GROUP BY department_name)
)
SELECT dc.department, 
    dc.emp_count
FROM dept_counts dc, avg_count ac
WHERE dc.emp_count > ac.avg_emp
ORDER BY dc.emp_count DESC;

/*4a. Use the MGS data set. Find the total order amount for
each order, make sure to consider any discount. No sorting
is needed.*/
SELECT o.customer_id, 
    o.order_id,
    SUM(oi.item_price - oi.discount_amount) AS order_amt
FROM mgs.orders o
    JOIN mgs.order_items oi
        ON o.order_id = oi.order_id
GROUP BY o.customer_id, o.order_id;
        
/*4b. Employ a factoring clause to implement the query from 4.a.
(do not modify the query from 4a). Find the customers who have orders 
at or above the MEDIAN of the order amount across all records (median is a 
built-in summary function).*/
WITH order_amts AS 
(
    SELECT o.customer_id, o.order_id,
        SUM(oi.item_price - oi.discount_amount) AS order_amt
    FROM mgs.orders o
         JOIN mgs.order_items oi
             ON o.order_id = oi.order_id
    GROUP BY o.customer_id, o.order_id
)
SELECT oa.customer_id,
    COUNT(DISTINCT oa.order_id) AS "Number of Orders",
    SUM(oa.order_amt) AS "Total Spent",
    SUM(oa.order_amt) / COUNT(DISTINCT oa.order_id) AS "Average Per Order"
FROM order_amts oa
WHERE oa.order_amt >= (
    SELECT MEDIAN(order_amt)
    FROM order_amts
)
GROUP BY oa.customer_id
ORDER BY "Average Per Order" DESC;

/*4c. Starting with 4.b., improve the result set with formatting. 
Do not use the ROUND function. Only show customers that are at or above 
the median as far as cost per order and have more than 1 order.*/
WITH order_amts AS 
(
    SELECT o.customer_id, o.order_id,
        SUM(oi.item_price - oi.discount_amount) AS order_amt
    FROM mgs.orders o
         JOIN mgs.order_items oi
             ON o.order_id = oi.order_id
    GROUP BY o.customer_id, o.order_id
)
SELECT c.first_name || ' ' || c.last_name AS "Customer Name",
    COUNT(DISTINCT oa.order_id) AS "Number of Orders",
    TO_CHAR(SUM(oa.order_amt), '$999,999.99') AS "Total Spent",
    TO_CHAR(AVG(oa.order_amt), '$999,999.99') AS "Average Per Order"
FROM order_amts oa
    JOIN mgs.customers c
        ON oa.customer_id = c.customer_id
WHERE oa.order_amt >= (
    SELECT MEDIAN(order_amt)
    FROM order_amts
)
HAVING COUNT(DISTINCT oa.order_id) > 1
GROUP BY c.first_name || ' ' || c.last_name;

/*4d. Starting with 4.c., show all customers with more than 1 order, 
regardless of the amount spent. Add a total line as shown using ROLLUP 
(use NVL to change the null value). Order as shown.*/
WITH order_amts AS 
(
    SELECT o.customer_id, o.order_id,
        SUM(oi.item_price - oi.discount_amount) AS order_amt
    FROM mgs.orders o
         JOIN mgs.order_items oi
             ON o.order_id = oi.order_id
    GROUP BY o.customer_id, o.order_id
)
SELECT NVL(c.first_name || ' ' || c.last_name, 'TOTAL') AS "Customer Name",
    COUNT(DISTINCT oa.order_id) AS "Number of Orders",
    TO_CHAR(SUM(oa.order_amt), '$999,999.99') AS "Total Spent",
    TO_CHAR(AVG(oa.order_amt), '$999,999.99') AS "Average Per Order"
FROM order_amts oa
    JOIN mgs.customers c
        ON oa.customer_id = c.customer_id
GROUP BY ROLLUP(c.first_name || ' ' || c.last_name)
HAVING COUNT(DISTINCT oa.order_id) > 1;

/*4e. Text response in a comment: why is the total from 4d not equal to the
number of orders as shown in the result set? How might the order of operations 
affect this? How do you think this could be fixed (you do not need to fix it, 
just state how you would go about fixing it)*/
    /*ROLLUP totals all customer orders, not just the customers with orders
    greater than 1. Order of Operations affects this by grouping the orders
    together then sorts out the groups that don't match the HAVING condition. 
    The only way this could be fixed would be by using multiple factoring
    clauses and subqueries.*/

/*5. Using a correlated subquery, find all invoices in the AP data set 
where the total is strictly greater than the average total for the vendor 
in question.*/
SELECT v.vendor_name, 
    TO_CHAR(i.invoice_total, '$999,999.99') AS "Total"
FROM ap.invoices i
    JOIN ap.vendors v
        ON i.vendor_id = v.vendor_id
WHERE invoice_total > (
        SELECT AVG(invoice_total)
        FROM ap.invoices inv
        WHERE inv.vendor_id = i.vendor_id)
ORDER BY v.vendor_name, "Total" DESC;

/*6. Find all invoices with balance due, showing only those with a balance 
due higher than the average balance due (only consider invoices with a 
balance due). Use a factoring clause. Order as shown.*/
WITH inv_balance AS 
(
    SELECT vendor_name,
        invoice_number,
        (invoice_total - payment_total - credit_total) AS balance_due
    FROM ap.invoices i
        JOIN ap.vendors v
            ON i.vendor_id = v.vendor_id
    WHERE (invoice_total - payment_total - credit_total) > 0
)
SELECT ib.vendor_name AS "Vendor",
    ib.invoice_number AS "Invoice",
    TO_CHAR(ib.balance_due, '$999,999.99') AS "Balance Due"
FROM inv_balance ib
WHERE ib.balance_due >
    (
        SELECT AVG(balance_due)
        FROM inv_balance
    )
ORDER BY "Balance Due" DESC;