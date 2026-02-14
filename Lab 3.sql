--Andrew Grant Lab 3
/*1. Write a SELECT statement that utilizes only the COUNT function to 
show how many orders exist, how many were shipped, how many were not shipped.*/
SELECT COUNT(order_id) AS "Number of Orders",
    COUNT(shipped_date) AS "Number of Shipments",
    SUM( 
        CASE
        WHEN shipped_date IS NULL
            THEN 1
            ELSE 0
        END) AS "Orders Pending" 
FROM om.orders;

/*2. Write a select statement to show the average price, lowest price, 
highest price, the first and last title (alphabetically) of the items that 
the shop sells. Use the substring function to limit the 
titles to 20 characters. */
SELECT TO_CHAR(AVG(unit_price), '$99,999.99') AS "Average",
    TO_CHAR(MIN(unit_price), '$99,999.99') AS "Lowest Price",
    TO_CHAR(MAX(unit_price), '$99,999.99') AS "Highest Price",
    SUBSTR(MIN(title), 1, 20) AS "First Title",
    SUBSTR(MAX(title), 1, 20) AS "Last Title"
FROM om.items;

/*3. Add up the invoices, get the number of invoices, calculate the
average based on these two fields in the null sample set. Then use the 
built in average function to calculate the average. Is there a difference 
between the two averages? Why?*/
SELECT SUM(invoice_total) AS "Invoice Total",
    COUNT(invoice_id) AS "Number of Invoices",
    SUM(invoice_total) / COUNT(*) AS "Calculated Average",
    AVG(invoice_total) AS "Average"
FROM ex.null_sample;
/*They are different because The AVG() function ignores any null values while
COUNT(*) includes null values.*/

/*4. How many items does each artist have in the music shops catalog?
Put the result in a single field using the concantenation operator
(|| - use of this operator is required). Pay close attention to the
ordering.*/
SELECT COUNT(artist) || ' ' || artist AS "items by artist"
FROM om.items
GROUP BY artist
ORDER BY COUNT(artist)DESC, artist ASC; 

/*5. Show the customers that order most often, but only show customers 
that have at least 4 orders. Place our most loyal customers first.*/
SELECT customer_id AS "CUSTOMERS", 
    COUNT(customer_id) AS "ORDERS"
FROM om.orders
GROUP BY customer_id
HAVING COUNT(customer_id) >= 4
ORDER BY "ORDERS" DESC;

/*6. How many items are in the catalog that have a price of at least $16.
Only show the prices that have more than 1 item associated with
it. There is ordering in the result set. Make sure to show the dollars
and cents associated with the price, even if the price stored does not
have cents (to the penny). Use the where and having to create the
most efficient query.*/
SELECT COUNT(title) AS "NUM ITEMS",
    TO_CHAR(unit_price, '$99.99') AS "UNIT_PRICE"
FROM om.items
WHERE TO_CHAR(unit_price) > 16
GROUP BY unit_price
HAVING COUNT(title) > 1
ORDER BY unit_price;

/*7a. Considering these clauses: GROUP BY, ORDER BY, WHERE, HAVING; what 
is the order in which they are executed.
They are executed in this order: frist is WHERE, second is GROUP BY, last
is HAVING.*/
/*7b). How do you determine whether to use WHERE or HAVING? 
The difference between WHERE and HAVING is that WHERE eliminates
rows and HAVING eliminates groups. HAVING works best with summary data
while WHERE can be used with or without summary data.*/

/*8. Using the AP schema, use the ROLL UP operator to show the invoice 
amount by month and vendor. Use NVL to convert any grouping rows to equal 
signs as shown in the sample. Show only invoices that occured in June and 
July 2024.*/
SELECT 
    NVL(TO_CHAR(vendor_id), '======') AS "Vendor",
    NVL(TO_CHAR(TRUNC(invoice_date,'MM'), 'MM-YY'), '======') AS "Month",
    TO_CHAR(SUM(invoice_total), '$999,999.99') AS "Invoice Amount"
FROM ap.invoices
WHERE invoice_date >= DATE '2024-06-01' AND invoice_date < DATE '2024-08-01'
GROUP BY ROLLUP (vendor_id, TRUNC(invoice_date,'MM'))
ORDER BY vendor_id, TRUNC(invoice_date,'MM');

/*9. Starting with the query from problem 8, change the ROLL UP to CUBE. 
Change the formatting of the date. Use NVL2 to format the vendor as shown. 
Only consider JUNE dates. Order the data to get the results shown below. 
Note the images show the row number.*/
SELECT NVL2(vendor_id, TO_CHAR(vendor_id),'=====') AS "Vendor",
    NVL(TO_CHAR(TRUNC(invoice_date), 'MM/DD/YYYY'),'=====') AS "Date",
    TO_CHAR(SUM(invoice_total), 'FM$999,999,999,990.00') AS "Invoice Amount"
FROM ap.invoices
WHERE invoice_date >= DATE '2024-06-01' AND invoice_date < DATE '2024-07-01'
GROUP BY CUBE (vendor_id, TRUNC(invoice_date))
HAVING TRUNC(invoice_date) IS NOT NULL
ORDER BY TRUNC(invoice_date),
    CASE WHEN vendor_id IS NULL THEN 1 ELSE 0 END,
    vendor_id;
    
/*10. Examine the results from #8 vs #9. What changed when the query 
used CUBE rather than ROLL UP. What is the difference between these two 
functions; be complete with this answer and use complete sentences.*/
/*The main difference is that CUBE generates aggregates for all possible
combinations of selected columns in the result set. ROLLUP will keep any
hierarchy of the selected columns in place when putting its aggregates to
the result set.*/