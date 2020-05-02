

1. Employees all over the world. Can you tell me the top three cities that we have employees?
Expected result:
City      employee count
San Francisco   6
Paris                  5
Syndney            4

SELECT o.city, COUNT(employeeNumber) AS employee_count
FROM employees e
LEFT JOIN offices o
ON e.officeCode = o.officeCode
GROUP BY o.city
ORDER BY employee_count DESC
LIMIT 3

San Francisco, Paris, Sydney

2. For company products, each product has inventory and buy price, msrp. Assume that every product is sold on msrp price. Can you write a query to tell company executives: profit margin on each product lines
Profit margin= sum(profit if all sold) - sum(cost of each=buyPrice) / sum (buyPrice)
Product line = each product belongs to a product line. You need group by product line. 

SELECT p.`productLine`, 
	   SUM(o.`quantityOrdered` * (p.`MSRP` - p.`buyPrice`)) / SUM(o.`quantityOrdered` * p.`buyPrice`) AS profit_margin
FROM products p
JOIN orderdetails o
ON p.`productCode` = o.`productCode`
GROUP BY p.`productLine`;





3. company wants to award the top 3 sales rep They look at who produces the most sales revenue.
A.	can you write a query to help find the employees. 

SELECT e.firstName, e.lastName, SUM(p.amount) AS revenue
FROM customers c
JOIN employees e
ON c.salesRepEmployeeNumber = e.employeeNumber
LEFT JOIN payments p
ON c.customerNumber = p.customerNumber
GROUP BY e.employeeNumber, e.firstName, e.lastName
ORDER BY revenue DESC
LIMIT 3


Gerard	Hernandez	1112003.81
Leslie	Jennings	989906.55
Pamela	Castillo	750201.87

      B. if we want to promote the employee to a manager, what do you think are the tables to be updated. 

employees, customer (if sales rep to manager)


      C. An employee  is leaving the company, write a stored procedure to handle the case. 1). Make the current employee inactive, 2). Replaced with its manager employeenumber in order table. 

1)	Assume we have active/inactive column called status in employee table

CREATE PROCEDURE to_inactive ( IN employee_id INT)
BEGIN
UPDATE employees
SET
       status = ‘inactive’ WHERE employeeNumber = employee_id;
END 

2)	I am not able to see employeenumber in order table but only in employees table and customers table, below is how to replace with its manager employeenumber in customers table

CREATE PROCEDURE to_inactive ( IN employee_id INT)
BEGIN
UPDATE customers c JOIN employees e ON (c.salesRepEmployeeNumber = e.employeeNumber)
SET c.salesRepEmployeeNumber = e.reportsTo
WHERE c.salesRepEmployeeNumber = employee_id





=======following challenge:
Employee 
[employee_id, employee_name, gender, current_salary, department_id, start_date, term_date]

Employee_salary 
[employee_id, salary, year, month]
1  20 2019 1
1 21 2019 2
1 20 2019 3 

Department 
[department_id, department_name]

4. Employee Salary Change Times 
Ask to provide a table to show for each employee in a certain department how many times their Salary changes 

WITH salary_if_changed AS (


SELECT employee_id, SUM(CASE WHEN salary = next_salary THEN 0 ELSE 1    END) AS change_time
FROM (
	SELECT *, LEAD(salary) OVER(PARTITION BY employee_id ORDER BY year, month) AS next_salary
	FROM Employee_salary
)  t1
		GROUP BY employee_id
	
	SELECT e.employee_name, d.department_name
	FROM salary_if_changed s
	JOIN Employee e
	ON s.employee_id = e.employee_id
	JOIN Department d
	ON e.department_id = d.department_id


	



5. Top 3 salary
	Ask to provide a table to show for each department the top 3 salary with employee name 
and employee has not left the company.

I assume this means top 3 salary employee who has not left the company.

SELECT department_name, employee_name
FROM (
SELECT d.department_name, sub.*,
	DENSE_RANK() OVER(PARTITION BY d.department_id ORDER BY current_salary DESC) AS rk
FROM (
	SELECT employee_name, current_salary, department_id
FROM Employee
WHERE term_date IS NULL
) sub
JOIN Department d
ON sub.department_id = d.department_id
) t
WHERE rk <= 3

