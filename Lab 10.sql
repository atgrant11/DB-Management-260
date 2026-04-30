-- Andrew Grant Lab 10

/*1. Start script with SET SERVEROUTPUT ON*/
SET SERVEROUTPUT ON;

/*2. Create a function called GET_BALANCE_DUE. Write this so it will 
overwrite a function with the same name.
• input: invoice_id
• table: ap.invoices
• return: the balance due (invoice_total - payment_total - credit_total)*/
CREATE OR REPLACE FUNCTION get_balance_due
(
    invoice_id_param NUMBER
)
RETURN NUMBER
AS
    balance_due_var NUMBER;
BEGIN
    SELECT (invoice_total - payment_total - credit_total) AS balance_due
    INTO balance_due_var
    FROM invoices
    WHERE invoice_id = invoice_id_param;
    
    RETURN balance_due_var;
END;
/

/*3. Write a query that uses the GET_BALANCE_DUE function to create the 
following result set, only get invoices for vendors in California. 
Return only the first 5 rows, after sorting in descending order by the 
balance due. When you create the order by, do not recalculate the balance due. 
(40 rows before constraining the number of rows returned).*/
SELECT v.vendor_name AS "Vendor Name",
    i.invoice_number AS "Invoice Number",
    TO_CHAR(i.invoice_total, '$9,999.99') AS "Invoice Amount",
    TO_CHAR(get_balance_due(i.invoice_id), '$9,999.99') AS "Balance Due"
FROM invoices i
    JOIN vendors v
        USING (vendor_id)
WHERE vendor_state = 'CA'
ORDER BY "Balance Due" DESC
FETCH FIRST 5 ROWS ONLY;
/

/*4. Create a stored procedure named UPDATE_EMPLOYEE, ensure that it will 
overwrite an existing procedure with the same name. Update the ST_EMPLOYEE table.
Pass in the employee id and the new salary. If the new salary is not greater 
than zero, raise a custom application error. Make the error number -20001. If 
the employee id does not exist, raise a custom application error. Make the 
error number -20002. If any other error occurs, raise a custom application error. 
Make the error number -20003 and pass through the Oracle error message 
(even though you will end up with two ORA-#####). Test this by commenting out 
the employee id error section temporarily. If all goes well, make sure to commit 
the change to the database. Make the error messages easy for the user to 
understand.*/
CREATE OR REPLACE PROCEDURE update_employee
(
    employee_id_param NUMBER,
    new_salary_param NUMBER
)
AS
    row_count NUMBER;
    ex_invalid_salary   EXCEPTION;
    ex_invalid_employee EXCEPTION;
    PRAGMA EXCEPTION_INIT(ex_invalid_salary, -20001);
    PRAGMA EXCEPTION_INIT(ex_invalid_employee, -20002);
BEGIN
    IF new_salary_param <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'New salary must be greater than 0.');
    END IF;
    
    SELECT COUNT(*)
    INTO row_count
    FROM st_employee
    WHERE employee_id = employee_id_param;
    
    IF row_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Please enter valid employee ID.');
    END IF;
    
    UPDATE st_employee
        SET salary = new_salary_param
        WHERE employee_id = employee_id_param;
        
        COMMIT;
EXCEPTION
    WHEN ex_invalid_salary OR ex_invalid_employee THEN
        RAISE;
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20003, 'Unexpected error occurred: '
            || SQLERRM);
END;
/

/*5. Write 4 calls to the procedure that will cover all cases: 
zero salary (edge case), negative salary, invalid employee id, 
everything is correct.*/
--Zero salary
CALL update_employee(1, 0);
/
--Negative salary
CALL update_employee(2, -580);
/
--Invalid employee id
CALL update_employee(5, 1500);
/
--Everything correct
CALL update_employee(4, 750);