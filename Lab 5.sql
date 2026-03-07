--Andrew Grant Lab 5 3/6/26

/*1. The following information using the HR table space. Use an EXPLICIT join.
Use the minimum salary for the job title, defined where the job titles are 
defined. Include all sorting. */
SELECT first_name || ' ' || last_name AS "Employee Name",
    j.job_title AS "Job Title",
    (e.salary - j.min_salary) AS "Diff from Min Salary"
FROM hr.employees e
    JOIN hr.jobs j
        ON e.job_id = j.job_id
ORDER BY last_name;

/*2. Rewrite the query from #1 using an IMPLICIT join*/
SELECT first_name || ' ' || last_name AS "Employee Name",
    j.job_title AS "Job Title",
    (e.salary - j.min_salary) AS "Diff from Min Salary"
FROM hr.employees e, hr.jobs j
WHERE e.job_id = j.job_id
ORDER BY last_name;

/*3. Display the following result table using the HR table space, follow all 
formatting and order. Show only those with salary of at least 12000*/
SELECT first_name, last_name,
    j.job_title,
    TO_CHAR(e.salary, '$999,999') AS salary,
    CASE
        WHEN (commission_pct IS NULL)
            THEN 'No Commission'
        WHEN (commission_pct IS NOT NULL)
            THEN TO_CHAR(commission_pct * 100) || '%'
    END AS commission
FROM hr.employees e
    JOIN hr.jobs j
        ON e.job_id = j.job_id
WHERE e.salary >= 12000
ORDER BY e.salary DESC;

/*4. Display the following result table using the HR table space, 
follow all formatting and order.*/
SELECT 
    l.location_id, 
    l.city, 
    c.country_name, 
    r.region_name
FROM hr.locations l
    JOIN hr.countries c 
        ON l.country_id = c.country_id
    JOIN hr.regions r 
        ON c.region_id = r.region_id
ORDER BY c.country_name;

/*5.Display the following result table using the HR table space, follow 
all formatting and order. You must use USING clauses to join the tables.*/
SELECT c.country_name AS country_name,
    TO_CHAR(ROUND(AVG(e.salary)), '$999,999') AS avg_salary
FROM hr.employees e
    JOIN hr.departments d
        USING(department_id)
    JOIN hr.locations l
        USING(location_id)
    JOIN hr.countries c
        USING(country_id)
GROUP BY c.country_name
ORDER BY c.country_name;

/*6. Use the HR table space. Display the employees and their managers with 
the same formatting. Order by the last name of the manager and the last name 
of the employee. Do not include employees without manager.*/
SELECT e.first_name || ' ' || e.last_name AS employee,
    m.first_name || ' ' || m.last_name AS manager
FROM hr.employees e
LEFT JOIN hr.employees m 
    ON e.manager_id = m.employee_id
WHERE e.manager_id IS NOT NULL
ORDER BY m.last_name, e.last_name;

/*7. Using the student schema, display the employees showing their 
old title and their new title. Include all employees. If they do not have 
an old title, put N/A instead. Use a LEFT JOIN.*/
SELECT ec.name, ec.employee_id,
    ec.title AS new_title,
    CASE
        WHEN e.title IS NULL
            THEN 'N/A'
        ELSE e.title
    END AS old_title
FROM student.employee_change ec
    LEFT JOIN student.employee e
        ON e.employee_id = ec.employee_id;
        
/*8. Display the employees showing their old title and their new title. 
Include only employees that have old titles – do not use a WHERE clause.*/
SELECT ec.name, ec.employee_id,
    ec.title AS new_title,
    e.title AS old_title
FROM student.employee_change ec
    INNER JOIN student.employee e
        ON e.employee_id = ec.employee_id;
        
/*9. Display the employees showing their old title and their new title. 
Include all employees.*/
SELECT
    COALESCE(e.name, ec.name) AS first_name,
    COALESCE(e.employee_id, ec.employee_id) AS employee_id,
    ec.title AS new_title,
    NVL(e.title, 'N/A') AS old_title
FROM student.employee e
    FULL OUTER JOIN student.employee_change ec
        ON e.employee_id = ec.employee_id
ORDER BY employee_id;

/*10. Display the course cost that is larger than the average of the course 
costs. You must use a subquery.*/
SELECT cost
FROM student.course
WHERE cost >
    (SELECT AVG(cost)
    FROM student.course);

/*11. Use AP schema. Subquery must be used. Display all invoice amounts that 
are smaller than the largest invoice amount for vendor 123. Do not hardcode 
the value of the largest invoice. Fetch first 10 rows only.(full result set: 
82 rows total).*/
SELECT vendor_name AS vendor, 
    invoice_number AS invoice, 
    TO_CHAR(invoice_total, '$99,999.99') AS total
FROM ap.invoices
    JOIN ap.vendors
        USING (vendor_id)
WHERE invoice_total <
    (SELECT MAX(invoice_total)
    FROM ap.invoices
    WHERE vendor_id = 123)
ORDER BY vendor_name
FETCH FIRST 10 ROWS ONLY;

/*12. Display the vendors without invoices. Use a subquery. 
Fetch first 10 rows only.*/
SELECT vendor_id,
    vendor_name AS name,
    vendor_state AS state
FROM ap.vendors
WHERE vendor_id NOT IN
    (SELECT vendor_id
    FROM ap.invoices)
ORDER BY vendor_state, vendor_name
FETCH FIRST 10 ROWS ONLY;

/*13. Display each invoice amount that is higher than the vendors average
invoice amount. You must use a correlated subquery.*/
SELECT vendor_id AS id,
    invoice_number AS invoice,
    TO_CHAR(invoice_total,'$999,999.99') AS total
FROM ap.invoices i
WHERE invoice_total >
    (SELECT AVG(invoice_total)
    FROM ap.invoices
    WHERE vendor_id = i.vendor_id)
ORDER BY vendor_id, invoice_total;