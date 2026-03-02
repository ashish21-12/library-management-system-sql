--library managment project Advance queries 

SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM members;
SELECT * FROM issued_status;
SELECT * FROM return_status;


-- Task 13: Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a 30-day return period).
-- Display the member's_id, member's name,  book title, issue date, and days overdue.
--> Table  we need to join 
-- isuued_status = members = books = return_status

SELECT 
	ms.member_id,
	ms.member_name,  
	bk.book_title, 
	ist.issued_date,
	CURRENT_DATE - ist.issued_date AS over_due_date
FROM issued_status AS ist
JOIN
	members AS ms
	ON ms.member_id = issued_member_id
JOIN 
	books AS bk
	ON bk.isbn = ist.issued_book_isbn
LEFT JOIN
	return_status AS rs
	ON rs.issued_id = ist.issued_id
WHERE 
	rs.return_date IS NULL 
	AND (CURRENT_DATE - ist.issued_date)>30
ORDER BY 1 ;



-- Task 14: Update Book Status on Return
-- Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).

CREATE OR REPLACE PROCEDURE add_returned_record(p_return_id VARCHAR(10),p_issued_id VARCHAR(10),p_book_quality VARCHAR(10))
LANGUAGE plpgsql
AS $$ 

DECLARE
	v_book_isbn VARCHAR(50) ;
	v_book_name VARCHAR(80) ;
BEGIN
	-- updating return table 
	INSERT INTO return_status(return_id,issued_id,return_date,book_quality)
	VALUES(p_return_id,p_issued_id, CURRENT_DATE ,p_book_quality) ;

	SELECT 
		issued_book_isbn ,
		issued_book_name 
		INTO
		v_book_isbn,
		v_book_name
	FROM issued_status
	WHERE issued_id = p_issued_id ;

	UPDATE books
	SET status ='yes'
	WHERE isbn = v_book_isbn ;
	
	RAISE NOTICE'Thank  you for returning the book: %',v_book_name ;

END ;
$$



--#Testing FUNCTION add_return_records
issued_id = IS135
ISBN = WHERE isbn = '978-0-307-58837-1'

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM return_status
WHERE issued_id = 'IS135';

-- calling function 
CALL add_returned_record('RS138', 'IS135', 'Good');

-- calling function 
CALL add_returned_record('RS148', 'IS140', 'Good');

/*
Task 15: Branch Performance Report ,Create a query that generates a performance report for each branch,
showing the number of books issued, the number of books returned, 
and the total revenue generated from book rentals. */

CREATE TABLE branch_reports
AS
SELECT 
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) as number_book_issued,
    COUNT(rs.return_id) as number_of_book_return,
    SUM(bk.rental_price) as total_revenue
FROM issued_status as ist
JOIN 
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
JOIN 
books as bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY 1, 2;

SELECT * FROM branch_reports;


/*
Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing
members who have issued at least one book in the last 6 months.*/
CREATE TABLE active_members AS
SELECT * 
FROM members 
WHERE member_id  IN (	SELECT 
							issued_member_id
						FROM issued_status
						WHERE issued_date > CURRENT_DATE - INTERVAL '6 month'
					  ) ;


SELECT * FROM active_members ;


-- Task 17: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues.
-- Display the employee name, number of books processed, and their branch.

SELECT 
	e.emp_id ,
	e.emp_name ,
	COUNT(ist.issued_emp_id) AS total_book_issued ,
	b.*
FROM issued_status ist
JOIN employees AS e
	ON e.emp_id = ist.issued_emp_id
JOIN branch AS b 
	ON b.branch_id = e.branch_id 
GROUP BY e.emp_id,b.branch_id
ORDER BY COUNT(ist.issued_emp_id) DESC
LIMIT 3 ;



-- Task 19: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system.1
-- Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
-- The procedure should function as follows: The stored procedure should take the book_id as an input parameter.
-- The procedure should first check if the book is available (status = 'yes'). 
-- If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
-- If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.


CREATE OR REPLACE PROCEDURE issue_book(p_issued_id VARCHAR(10), p_issued_member_id VARCHAR(30), p_issued_book_isbn VARCHAR(30), p_issued_emp_id VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE
-- all the variabable
    v_status VARCHAR(10);

BEGIN
-- all the code
    -- checking if book is available 'yes'
    SELECT 
        status 
        INTO
        v_status
    FROM books
    WHERE isbn = p_issued_book_isbn;

    IF v_status = 'yes' THEN

        INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        VALUES
        (p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);

        UPDATE books
            SET status = 'no'
        WHERE isbn = p_issued_book_isbn;

        RAISE NOTICE 'Book records added successfully for book isbn : %', p_issued_book_isbn;


    ELSE
        RAISE NOTICE 'Sorry to inform you the book you have requested is unavailable book_isbn: %', p_issued_book_isbn;
    END IF;
END;
$$

-- Testing The function
SELECT * FROM books
WHERE isbn='978-0-553-29698-2';
-- "978-0-553-29698-2" -- yes
-- "978-0-375-41398-8" -- no
SELECT * FROM issued_status;

CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');
CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');

SELECT * FROM books
WHERE isbn = '978-0-375-41398-8'

