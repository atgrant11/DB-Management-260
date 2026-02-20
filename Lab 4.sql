--Andrew Grant Lab 4
/*1. Show the customers and their shipping address as demonstrated in the 
results set. Include all sorting.*/
SELECT c.first_name AS first_name,
    c.last_name AS last_name,
    a.city,
    a.state
FROM mgs.customers c
    JOIN mgs.addresses a
    ON c.shipping_address_id = a.address_id
ORDER BY a.state, a.city;

/*2. Use a natural join to list all customers with all of their 
known addresses (billing or shipping). Include all sorting.*/
SELECT c.first_name AS first_name,
    c.last_name AS last_name,
    a.city,
    a.state
FROM mgs.customers c
    JOIN mgs.addresses a
    USING (customer_id)
ORDER BY a.state, a.city;

/*3. Find any customers whose shipping and billing address are not in the 
same city (you may assume that city names are unique, i.e. there does not 
exist a city name that is the same in two different states, therefore you 
do not need to consider the state field in this rule).*/
SELECT first_name,
    last_name,
    a1.city as city,
    a1.state as state,
    a2.city as city_1,
    a2.state as state_1
FROM mgs.customers c
    JOIN mgs.addresses a1
        ON c.shipping_address_id = a1.address_id
    JOIN mgs.addresses a2
        ON c.billing_address_id = a2.address_id
WHERE a1.city <> a2.city;

/*4. Show the products that have been ordered, we are most interested in 
popularity, sort accordingly.*/
SELECT p.product_name AS "Product",
    COUNT(o.product_id) AS "Frequency"
FROM mgs.order_items o
    JOIN mgs.products p
        ON p.product_id = o.product_id
GROUP BY p.product_name
ORDER BY COUNT(o.product_id) DESC, p.product_name;

/*5. Using the MINUS functionality, show products that have not 
been ordered. You might find it helpful to start with the query from #4.*/
SELECT p.product_name as "Product"
FROM mgs.products p

MINUS

SELECT p.product_name
FROM mgs.products p
JOIN mgs.order_items o
    ON p.product_id = o.product_id;
    
/*6. Find the number of orders being shipped to different states (billing
vs shipping address).*/
SELECT a.state AS state,
    COUNT(o.order_id) AS "Frequency"
FROM mgs.orders o
JOIN mgs.addresses a
    ON o.ship_address_id = a.address_id
GROUP BY a.state
ORDER BY "Frequency" DESC, a.state;

/*7. Rewrite the query in #6 using a NATURAL JOIN. Do you get the same 
results? Why or why not? Give me an explantion that includes what fields 
are being used in the join and how that affects the results. Include the 
query.*/
/*The results are different because ON specifies how the two tables are
joined in the result set while a NATURAL JOIN automatically combines
columns with the same name.*/
--Query:
SELECT state,
    COUNT(order_id) AS Frequency
FROM mgs.orders
NATURAL JOIN mgs.addresses
GROUP BY state
ORDER BY Frequency DESC, state;

/*8a. Show the order totals with the customer name. To join the tables, 
you are required to use the USING clause. Make sure you format, sort,
and use aliases as shown.*/
SELECT TO_CHAR(SUM(oi.item_price), '$99,999.99') AS "Order Total",
    order_id AS "Order Number",
    c.first_name || ' ' || c.last_name AS "Customer"
FROM mgs.order_items oi
    JOIN mgs.orders o
        USING(order_id)
    JOIN mgs.customers c
        USING(customer_id)
GROUP BY order_id, c.first_name , c.last_name
ORDER BY "Order Total" DESC;
/*8b. Can this table be sorted by last name? Why or why not?
    It can because it's a column that is present in the SELECT statement. 
    Although it is apart of a concatenated string, it is still able to be
    selected.*/

/*9. Starting with #8, change the query to show totals by customer
across all of their orders.*/
SELECT TO_CHAR(SUM(oi.item_price), '$99,999.99') AS "Order Total",
    c.first_name || ' ' || c.last_name AS "Customer"
FROM mgs.order_items oi
    JOIN mgs.orders o
        USING (order_id)
    JOIN mgs.customers c
        USING (customer_id)
GROUP BY c.first_name,c.last_name
ORDER BY "Order Total" DESC;

/*10a. There are two different prices for products: the selling price (from the 
order items table) and the list price. Write a query to show if any items are 
sold at a price that is different from the list price*/
SELECT p.product_name AS "Product",
    item_price AS "Sold Price",
    list_price AS "List Price"
FROM mgs.order_items
    JOIN mgs.products p 
    USING (product_id)
WHERE item_price <> list_price;
/*10b. No products were sold at a price other than list price.*/

/*11. Create a product listing of all products as shown, include sorting, 
formatting, and any aliases. For the description, show the number of 
characters included in the description then show the first 10 & last 10 char-
acters separated with an ellipsis.*/
SELECT p.product_name AS "Product",
    c.category_name AS "Category",
    p.list_price AS "Price",
    LENGTH(p.description) AS "Desc Len",
    SUBSTR(p.description, 1, 10) || '...' || 
        SUBSTR(p.description, -10) AS "Description"
FROM mgs.products p
    JOIN mgs.categories c
        ON p.category_id = c.category_id
ORDER BY c.category_name, p.product_name;

/*12. We want to market to frequent customers. In order to make sure 
the marketing is relavent, we want to see what category those customers 
order from most often. We only want to see customers who have ordered from
a category more than once. You do not need to address any sorting for this.*/
SELECT c.first_name || ' ' || c.last_name AS "Customer",
    cat.category_name AS "Category",
    COUNT(*) AS "Times Ordered"
FROM mgs.customers c
    JOIN mgs.orders o
        ON c.customer_id = o.customer_id
    JOIN mgs.order_items oi
        ON o.order_id = oi.order_id
    JOIN mgs.products p
        ON oi.product_id = p.product_id
    JOIN mgs.categories cat
        ON p.category_id = cat.category_id
GROUP BY c.first_name, c.last_name, cat.category_name
HAVING COUNT(*) > 1
ORDER BY "Customer";
