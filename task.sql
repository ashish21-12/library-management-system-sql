SELECT * FROM branch;
SELECT * FROM books ;
SELECT * FROM issued_status ;
SELECT * FROM return_status ;
SELECT * FROM employees ;
SELECT * FROM members ; 


-- project Task

--2. CRUD Operations

--Task 1. Create a New Book Record 
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
INSERT INTO books(isbn,book_title,category,rental_price,status,author,publisher)
VALUES( '978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

SELECT * FROM books
WHERE isbn ='978-1-60129-456-2';


--Task 2: Update an Existing Member's Address
UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';

--Task 3: Delete a Record from the Issued Status Table
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
SELECT * 
FROM issued_status 
WHERE issued_id = 'IS121'

DELETE FROM issued_status
WHERE issued_id = 'IS121'

--Task 4: Retrieve All Books Issued by a Specific Employee 
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * 
FROM issued_status 
WHERE issued_emp_id = 'E101'

--Task 5: List Members Who Have Issued More Than One Book
-- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT 
	issued_member_id ,
	COUNT(*) AS issued_count
FROM issued_status
GROUP BY 1 
HAVING COUNT(*) > 1;

--3. CTAS (Create Table As Select)
--Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
CREATE TABLE book_issued_cnt AS
SELECT 
	b.isbn,
	b.book_title,
	COUNT(ist.issued_book_isbn) AS no_issued
FROM books b
JOIN issued_status ist ON ist.issued_book_isbn=b.isbn 
GROUP BY b.isbn, b.book_title ;

SELECT * FROM book_issued_cnt ;
--4. Data Analysis & Findings
--Task 7. Retrieve All Books in a Specific Category:

SELECT * FROM books
WHERE category = 'Classic';

--Task 8: Find Total Rental Income by Category:
SELECT 
	b.category,
	SUM(b.rental_price),
	COUNT(*)
FROM books b
JOIN issued_status ist ON ist.issued_book_isbn=b.isbn
GROUP BY b.catogary ;

--Task 9:List Members Who Registered in the Last 180 Days:
INSERT INTO members (member_id, member_name, member_address, reg_date)
VALUES
('C114', 'Rahul Sha', 'Pune, Maharashtra', '2026-05-15'),
('C115', 'Sneha Pal', 'Mumbai, Maharashtra', CURRENT_DATE);

SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 DAYS';

--Task 10:List Employees with Their Branch Manager's Name and their branch details:
SELECT 
    e1.emp_id,
    e1.emp_name AS employee_name,
    b.branch_id,
    b.manager_id,
    e2.emp_name AS manager_name
FROM employees e1
JOIN branch b ON b.branch_id = e1.branch_id
JOIN employees e2 ON b.manager_id = e1.emp_id;

--Task 11. Create a Table of Books with Rental Price Above a Certain Threshold:

CREATE TABLE high_value_books AS
SELECT * FROM books 
WHERE rental_price > 7 ;

SELECT * FROM high_value_books;

--Task 12: Retrieve the List of Books Not Yet Returned

SELECT 
	ist.issued_id,
	ist.issued_book_name AS book_name,
	ist.issued_date	
FROM issued_status AS ist
LEFT JOIN 
return_status AS rs
ON rs.issued_id=ist.issued_id 
WHERE rs.return_id IS  NULL;










