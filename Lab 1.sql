-- Andrew Grant Lab 1

/* 1. Write a query that shows all columns and rows of the general ledger
without listing the column names. */
SELECT *
FROM ap.general_ledger_accounts;

/* 2. Write a query that shows the line items amounts greater than $500. 
Be sure to use the same columns with the aliases as shown in the sample.*/
SELECT account_number, line_item_amt AS "AMOUNT",
    line_item_description AS "DESCRIPTION"
FROM ap.invoice_line_items
WHERE (line_item_amt > 500);

/*3. Write a query that shows the same columns and vendor records with 
city names that start with ‘B’, ‘C’, or ‘D’ (you may assume there is not 
a city called ‘E’). Use the BETWEEN operator (this is required). 
Force the query to return records in the order shown. */
SELECT vendor_name AS "VENDOR", vendor_city AS "CITY"
FROM ap.vendors
WHERE vendor_city BETWEEN 'B' AND 'D'
ORDER BY vendor_city;

/*4. Write a query that shows the same columns and vendor records 
showing only unique states and zip codes. Force the query to return 
records in the order shown (both columns are sorted).*/
SELECT DISTINCT vendor_state AS "STATE", vendor_zip_code AS "ZIP"
FROM ap.vendors
ORDER BY vendor_state DESC;

/*5. Write a query that shows the same columns and vendors that are
in Kansas, Missouri, or Nebraska. Use the IN operator (this is required). 
Force the query to return records in the order shown (both columns 
are sorted). */
SELECT vendor_name AS "Vendor Name", vendor_state AS "Vendor State"
FROM ap.vendors
WHERE vendor_state IN ('KS', 'MO', 'NE')
ORDER BY vendor_state;

/*6. Write a query that shows the same columns and invoice records showing. 
We want to see the records with the 4 lowest invoice totals, if there are 
multiple records with the same value (tied for 4th place) show all relevant 
records. Be sure to use the column aliases as shown in the sample. The query 
must work for any data, if there were 4 records tied for 4th place, 
you would get 7 rows.*/
SELECT invoice_id AS "ID", vendor_id AS "VENDOR", invoice_total AS "AMOUNT"
FROM ap.invoices
WHERE (invoice_total < 10)
ORDER BY invoice_total;

/*7. Write a query that shows the same columns and invoices with numbers 
that contain ‘9-4’ anywhere in the number. Use the LIKE operator with 
wildcards (this is required). Force the query to return records in the 
order shown. */
SELECT invoice_id AS "Id", invoice_number AS "Invoice #"
FROM ap.invoices
WHERE invoice_number LIKE '%9-4%'
ORDER BY invoice_id DESC;

/*8. Write a query that shows the same columns and invoices with a balance
due greater than 1000. Force the query to return records in the order shown 
and use the column alias in the order by statement. */
SELECT invoice_id AS "ID", invoice_total AS "Balance Due"
FROM ap.invoices
WHERE (invoice_total > 1000)
ORDER BY "Balance Due" DESC;

/*9. Write a query that shows the same columns using the invoice table. 
We want to see what vendors have which payment terms (and we only want to 
see unique combinations). Force the query to return records in the order 
shown and use the column position (i.e. column numbers) in the 
order by statement. */
SELECT DISTINCT vendor_id AS "Vendor", terms_id AS "Terms"
FROM ap.invoices
ORDER BY 1;

/*10. Write a query that shows the same columns using the invoice table. 
We want to see vendors with ids of 120 and higher that have made payments 
in June (and we only want to see unique combinations). Use the LIKE operator 
with wildcards to limit the date (this is required). Force the query to return 
records in the order shown (both columns are sorted) and use the column 
position (i.e. column numbers)in the order by statement. */
SELECT DISTINCT vendor_id AS "Vendor", payment_date AS "Payment"
FROM ap.invoices
WHERE (vendor_id > 120) AND (payment_date LIKE '%JUN%')
ORDER BY 1, 2 DESC;

/*11. What is the range of invoice totals of the highest 10% of invoices 
where the due date is in June of 2024 (your query must work for data that
includes different years). How many records were returned?*/
    /*Range: 601.95 - 20551.18
      Number of Records in Result Set: 8*/
    --Query:
SELECT vendor_id AS "Vendor", invoice_total AS "Invoice Amount",
    invoice_due_date AS "Invoice Due"
FROM ap.invoices
WHERE invoice_due_date LIKE '%JUN%'
FETCH FIRST 10 PERCENT ROWS ONLY;