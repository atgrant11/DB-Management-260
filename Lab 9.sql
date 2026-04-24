--Andrew Grant Lab 9

/*1. Start your script with SET SERVEROUTPUT ON*/
SET SERVEROUTPUT ON;

/*2. Write an Anonymous PL/SQL block that does the following, your 
output should mimic the shown sample below.
• Use a cursor to get all products from the mgs schema that have a discount 
and were added in 2022.
• Print each product with their list price and their sale price. This needs to 
align nicely into columns. To accomplish this use the tab character, CHR(09), 
and set the width of the product name using RPAD to 35 columns (this will pad 
with blank spaces when needed or truncate the name if it is too long).
• Products need to be listed by category and add a category heading as shown 
before each group.
• Add a heading as shown.
• Besure to add any formatting as shown.
• On the line following the END; statement, add a / to separate the code so 
your work can be run as a script.*/
DECLARE
    prev_category VARCHAR2(25) := NULL;
    sale_price NUMBER;
    CURSOR mgs_cursor IS
        SELECT p.product_name, p.list_price,
            p.discount_percent, c.category_name
        FROM mgs.products p
            JOIN mgs.categories c
                USING (category_id)
        WHERE p.discount_percent > 0
            AND p.date_added BETWEEN '01-JAN-22' AND '31-DEC-22'
        ORDER BY c.category_name;
BEGIN
    DBMS_OUTPUT.PUT_LINE(RPAD('PRODUCT', 35) || 'LIST PRICE'
        || CHR(9) || 'SALE PRICE');
    FOR rec IN mgs_cursor LOOP
        IF prev_category IS NULL OR prev_category != rec.category_name THEN
            DBMS_OUTPUT.PUT_LINE('Category: ' || rec.category_name);
            prev_category := rec.category_name;
        END IF;
        
        sale_price := rec.list_price - (rec.list_price * rec.discount_percent / 100);
        
        DBMS_OUTPUT.PUT_LINE(
            RPAD(rec.product_name, 35) ||
            RPAD(TO_CHAR(rec.list_price, '$9,999.99'), 15) ||
            TO_CHAR(sale_price, '$9,999.99')
            );
    END LOOP;
END;
/

/*3. Copy the tables from the OM schema into your tablespace. You can do this 
via SQL Developer rather than with SQL statements (your choice). Give these 
tables prefixes of ‘OM_’, for example, OM_CUSTOMERS. In this script, include 
select statements to show the contents of each table, one for each table that 
you copied, using FETCH, limit each query to 10 rows.*/
CREATE TABLE om_customers AS
    SELECT *
    FROM om.customers; 
SELECT * FROM om_customers FETCH FIRST 10 ROWS ONLY;

CREATE TABLE om_items AS
    SELECT *
    FROM om.items;
SELECT * FROM om_items FETCH FIRST 10 ROWS ONLY;
    
CREATE TABLE om_order_details AS
    SELECT *
    FROM om.order_details;
SELECT * FROM om_order_details FETCH FIRST 10 ROWS ONLY;

CREATE TABLE om_orders AS
    SELECT *
    FROM om.orders;
SELECT * FROM om_orders FETCH FIRST 10 ROWS ONLY;

/*4. Since the constraints are not copied with the tables, add key 
constraints for each table. Each table needs to have a primary key. Add 
constraints for all foreign keys. Note that one table has a composite primary
key. Also add a column to the items table to keep track of inventory. 
This needs to be a number that defaults to 100. Write these statements to 
your script in order of execution.*/
ALTER TABLE om_customers
    ADD CONSTRAINT customers_pk PRIMARY KEY (customer_id);
    
ALTER TABLE om_items
    ADD CONSTRAINT items_pk PRIMARY KEY (item_id);
    
ALTER TABLE om_orders
    ADD CONSTRAINT orders_pk PRIMARY KEY (order_id);
    
ALTER TABLE om_orders    
    ADD CONSTRAINT orders_fk_customer FOREIGN KEY (customer_id) 
        REFERENCES om_customers(customer_id);
        
ALTER TABLE om_order_details
    ADD CONSTRAINT order_details_pk PRIMARY KEY (order_id, item_id);

ALTER TABLE om_order_details
    ADD CONSTRAINT order_details_pk_orders
        FOREIGN KEY (order_id) REFERENCES om_orders(order_id);
        
ALTER TABLE om_order_details
    ADD CONSTRAINT order_details_pk_items
        FOREIGN KEY (item_id) REFERENCES om_items(item_id);

ALTER TABLE om_items
    ADD inventory NUMBER DEFAULT 100;
    
SELECT * FROM om_customers FETCH FIRST 10 ROWS ONLY;
SELECT * FROM om_items FETCH FIRST 10 ROWS ONLY;
SELECT * FROM om_order_details FETCH FIRST 10 ROWS ONLY;
SELECT * FROM om_orders FETCH FIRST 10 ROWS ONLY;

/*5. Add this statement for each table and verify that they execute correctly. 
This will show the DDL for the table. NOTE: everything in single quotes needs 
to be uppercase - again confirm that the statements execute. To see the entire 
DDL statement, highlight the statement(s) and run as a script.*/
SELECT TO_CHAR(DBMS_METADATA.GET_DDL('TABLE','OM_CUSTOMERS')) FROM dual;
SELECT TO_CHAR(DBMS_METADATA.GET_DDL('TABLE','OM_ITEMS')) FROM dual;
SELECT TO_CHAR(DBMS_METADATA.GET_DDL('TABLE','OM_ORDERS')) FROM dual;
SELECT TO_CHAR(DBMS_METADATA.GET_DDL('TABLE','OM_ORDER_DETAILS')) FROM dual;

/*6. Create a trigger that automatically adjusts the inventory when an order 
is placed. You can assume that the inventory will never go below zero - so we 
do not need to check the stock before decrementing or do anything to 
address backorders.*/
CREATE OR REPLACE TRIGGER inv_change
    AFTER INSERT ON om_order_details
    FOR EACH ROW
BEGIN
    UPDATE om_items
    SET inventory = inventory - :NEW.order_qty
    WHERE item_id = :NEW.item_id;
END;
/

/*7. Using insert statements, add 3 orders that will cause the trigger to fire. 
The orders must be:
• Complete (include an order record with corresponding order detail records).
• At least 2 order detail records must have a quantity greater than 1.
• You can hardcode values in the insert statements, i.e. you do not need to 
use subqueries to generate the next order id, etc.
Include select statements to show that the new orders were added and the
inventory was affected.*/
INSERT ALL
    INTO om_orders (order_id, customer_id, order_date, shipped_date)
        VALUES (100, 4, '15-APR-26', SYSDATE)
    INTO om_order_details (order_id, item_id, order_qty)
        VALUES (100, 2, 4)
SELECT * FROM dual;

INSERT ALL
    INTO om_orders (order_id, customer_id, order_date, shipped_date)
        VALUES (101, 12, '23-MAR-26', '01-APR-26')
    INTO om_order_details (order_id, item_id, order_qty)
        VALUES (101, 6, 1)
SELECT * FROM dual;

INSERT ALL
    INTO om_orders (order_id, customer_id, order_date, shipped_date)
        VALUES (102, 3, '23-APR-26', NULL)
    INTO om_order_details (order_id, item_id, order_qty)
        VALUES (102, 7, 1)
SELECT * FROM dual;

--Order 1
SELECT order_id, item_id,
    o.customer_id, 
    od.order_qty,
    i.inventory,
    o.order_date,
    o.shipped_date
FROM om_order_details od
    JOIN om_items i
        USING(item_id)
    JOIN om_orders o
        USING(order_id)
WHERE order_id = 100;

--Order 2
SELECT order_id, item_id,
    o.customer_id, 
    od.order_qty,
    i.inventory,
    o.order_date,
    o.shipped_date
FROM om_order_details od
    JOIN om_items i
        USING(item_id)
    JOIN om_orders o
        USING(order_id)
WHERE order_id = 101;

--Order 3
SELECT order_id, item_id,
    o.customer_id, 
    od.order_qty,
    i.inventory,
    o.order_date,
    o.shipped_date
FROM om_order_details od
    JOIN om_items i
        USING(item_id)
    JOIN om_orders o
        USING(order_id)
WHERE order_id = 102;

        
/*8. nclude statements to drop all of the tables and the trigger in the 
correct order.*/
DROP TRIGGER inv_change;

DROP TABLE om_order_details;

DROP TABLE om_orders;

DROP TABLE om_items;

DROP TABLE om_customers;


