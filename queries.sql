-- -- Create 'departments' table
-- CREATE TABLE departments (
--     id SERIAL PRIMARY KEY,
--     name VARCHAR(50),
--     manager_id INT
-- );

-- -- Create 'employees' table
-- CREATE TABLE employees (
--     id SERIAL PRIMARY KEY,
--     name VARCHAR(50),
--     hire_date DATE,
--     job_title VARCHAR(50),
--     department_id INT REFERENCES departments(id)
-- );

-- -- Create 'projects' table
-- CREATE TABLE projects (
--     id SERIAL PRIMARY KEY,
--     name VARCHAR(50),
--     start_date DATE,
--     end_date DATE,
--     department_id INT REFERENCES departments(id)
-- );

-- -- Insert data into 'departments'
-- INSERT INTO departments (name, manager_id)
-- VALUES ('HR', 1), ('IT', 2), ('Sales', 3);

-- -- Insert data into 'employees'
-- INSERT INTO employees (name, hire_date, job_title, department_id)
-- VALUES ('John Doe', '2018-06-20', 'HR Manager', 1),
--        ('Jane Smith', '2019-07-15', 'IT Manager', 2),
--        ('Alice Johnson', '2020-01-10', 'Sales Manager', 3),
--        ('Bob Miller', '2021-04-30', 'HR Associate', 1),
--        ('Charlie Brown', '2022-10-01', 'IT Associate', 2),
--        ('Dave Davis', '2023-03-15', 'Sales Associate', 3);

-- -- Insert data into 'projects'
-- INSERT INTO projects (name, start_date, end_date, department_id)
-- VALUES ('HR Project 1', '2023-01-01', '2023-06-30', 1),
--        ('IT Project 1', '2023-02-01', '2023-07-31', 2),
--        ('Sales Project 1', '2023-03-01', '2023-08-31', 3);
       
--        UPDATE departments
-- SET manager_id = (SELECT id FROM employees WHERE name = 'John Doe')
-- WHERE name = 'HR';

-- UPDATE departments
-- SET manager_id = (SELECT id FROM employees WHERE name = 'Jane Smith')
-- WHERE name = 'IT';

-- UPDATE departments
-- SET manager_id = (SELECT id FROM employees WHERE name = 'Alice Johnson')
-- WHERE name = 'Sales';

--1. Find the longest ongoing project for each department.
SELECT dept.name, proj.name, MAX(end_date - start_date) AS duration
	FROM projects proj
    JOIN departments dept ON proj.department_id = dept.id
    GROUP BY dept.name, proj.name
    ORDER BY duration DESC;

--2. Find all employees who are not managers.
SELECT *
	FROM employees
    WHERE id NOT IN(SELECT manager_id FROM departments);

--3. Find all employees who have been hired after the start of a project in their department.
SELECT emp.name, proj.start_date, emp.hire_date
	FROM employees emp
    JOIN projects proj ON emp.department_id = proj.department_id
    WHERE emp.hire_date > proj.start_date;

--4. Rank employees within each department based on their hire date (earliest hire gets the highest rank).

SELECT e.name AS employee_name, e.hire_date, e.department_id,
    RANK() OVER(PARTITION BY e.department_id ORDER BY e.hire_date ASC) AS rank
FROM employees e
ORDER BY e.department_id, rank;


--5. Find the duration between the hire date of each employee and the hire date of the next employee hired in the same department.

WITH ranked_employees AS (
    SELECT e.name AS employee_name, e.hire_date, e.department_id,
        RANK() OVER(PARTITION BY e.department_id ORDER BY e.hire_date ASC) AS rank_num
    FROM employees e
),
lead_ranked AS (
    SELECT *,
        LEAD(hire_date) OVER(PARTITION BY department_id ORDER BY hire_date ASC) AS next_hire_date
    FROM ranked_employees
)

SELECT re1.department_id, re1.employee_name AS employee, re2.employee_name AS next_hired_employee,
    re2.hire_date - re1.hire_date AS duration
FROM lead_ranked re1
JOIN lead_ranked re2 ON re1.rank_num = re2.rank_num - 1 AND re1.department_id = re2.department_id;

