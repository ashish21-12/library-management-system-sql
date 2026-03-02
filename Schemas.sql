/* =====================================================
   LIBRARY MANAGEMENT SYSTEM - DATABASE SCHEMA
   ===================================================== */

-- =====================================================
-- 1️⃣ DROP TABLES (Child Tables First to Avoid FK Errors)
-- =====================================================

DROP TABLE IF EXISTS return_status;
DROP TABLE IF EXISTS issued_status;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS members;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS branch;


-- =====================================================
-- 2️⃣ CREATE MASTER TABLES (No Dependencies)
-- =====================================================

CREATE TABLE branch (
    branch_id VARCHAR(10) PRIMARY KEY,
    manager_id VARCHAR(10),
    branch_address VARCHAR(50),
    contact_no VARCHAR(15)
);

CREATE TABLE members (
    member_id VARCHAR(10) PRIMARY KEY,
    member_name VARCHAR(25),
    member_address VARCHAR(75),
    reg_date DATE
);

CREATE TABLE books (
    isbn VARCHAR(20) PRIMARY KEY,
    book_title VARCHAR(60),
    category VARCHAR(20),
    rental_price FLOAT,
    status VARCHAR(15),
    author VARCHAR(50),
    publisher VARCHAR(30)
);


-- =====================================================
-- 3️⃣ CREATE DEPENDENT TABLES
-- =====================================================

CREATE TABLE employees (
    emp_id VARCHAR(10) PRIMARY KEY,
    emp_name VARCHAR(25),
    position VARCHAR(20),
    salary INT,
    branch_id VARCHAR(10)
);

CREATE TABLE issued_status (
    issued_id VARCHAR(10) PRIMARY KEY,
    issued_member_id VARCHAR(10),
    issued_book_name VARCHAR(75),
    issued_date DATE,
    issued_book_isbn VARCHAR(20),
    issued_emp_id VARCHAR(10)
);

CREATE TABLE return_status (
    return_id VARCHAR(10) PRIMARY KEY,
    issued_id VARCHAR(10),
    return_book_name VARCHAR(60),
    return_date DATE,
    return_book_isbn VARCHAR(20)
);


-- =====================================================
-- 4️⃣ ADD FOREIGN KEY CONSTRAINTS
-- =====================================================

-- Employees → Branch
ALTER TABLE employees
ADD CONSTRAINT fk_employees_branch
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id);

-- Issued_Status → Members
ALTER TABLE issued_status
ADD CONSTRAINT fk_issued_member
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id);

-- Issued_Status → Books
ALTER TABLE issued_status
ADD CONSTRAINT fk_issued_book
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn);

-- Issued_Status → Employees
ALTER TABLE issued_status
ADD CONSTRAINT fk_issued_employee
FOREIGN KEY (issued_emp_id)
REFERENCES employees(emp_id);

-- Return_Status → Issued_Status
ALTER TABLE return_status
ADD CONSTRAINT fk_return_issued
FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id);
