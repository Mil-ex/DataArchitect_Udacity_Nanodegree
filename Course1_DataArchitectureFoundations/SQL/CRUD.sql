-- Question 1: Return a list of employees with Job Titles and Department Names
SELECT 
    e.EMPLOYEE_name, 
    j.JOB_name, 
    d.DEPARTMENT_name
FROM EMPLOYEE AS e
LEFT JOIN EMPLOYEE_HISTORY AS h ON e.EMPLOYEE_ID = h.EMPLOYEE_ID
LEFT JOIN JOB AS j ON h.JOB_ID = j.JOB_ID
LEFT JOIN DEPARTMENT AS d ON h.DEPARTMENT_ID = d.DEPARTMENT_ID
ORDER BY e.EMPLOYEE_name;


-- Question 2: Insert Web Programmer as a new job title
INSERT INTO JOB (JOB_name)
SELECT 'Web Programmer'
WHERE NOT EXISTS (SELECT 1 FROM JOB WHERE JOB_name = 'Web Programmer');
SELECT * FROM JOB

-- Question 3: Correct the job title from web programmer to web developer
UPDATE JOB
SET JOB_name = 'Web Developer'
WHERE LOWER(JOB_name) = 'web programmer';
SELECT * FROM JOB

-- Question 4: Delete the job title Web Developer from the database
UPDATE EMPLOYEE_HISTORY
SET JOB_ID = (SELECT JOB_ID FROM JOB WHERE JOB_name = 'Unknown')
WHERE JOB_ID = (SELECT JOB_ID FROM JOB WHERE JOB_name = 'Web Developer');
DELETE FROM JOB
WHERE JOB_name = 'Web Developer';
SELECT * FROM JOB

-- Question 5: How many employees are in each department?
SELECT 
    d.DEPARTMENT_name, 
    COUNT(h.EMPLOYEE_ID) AS employee_count
FROM EMPLOYEE_HISTORY AS h
LEFT JOIN DEPARTMENT AS d ON h.DEPARTMENT_ID = d.DEPARTMENT_ID
WHERE h.EMP_HIST_end > CURRENT_DATE
GROUP BY d.DEPARTMENT_name;

-- Question 6: Write a query that returns current and past jobs (include employee name, job title, department, manager name, start and end date for position) for employee Toni Lembeck.
SELECT 
    e.EMPLOYEE_name AS Employee,
    j.JOB_name AS Job_Title,
    d.DEPARTMENT_name AS Department,
    m.EMPLOYEE_name AS Manager_Name,
    h.EMP_HIST_start AS Start_Date,
    h.EMP_HIST_end AS End_Date
FROM EMPLOYEE AS e
JOIN EMPLOYEE_HISTORY AS h ON e.EMPLOYEE_ID = h.EMPLOYEE_ID
JOIN JOB AS j ON h.JOB_ID = j.JOB_ID
JOIN DEPARTMENT AS d ON h.DEPARTMENT_ID = d.DEPARTMENT_ID
LEFT JOIN EMPLOYEE AS m ON h.MANAGER_ID = m.EMPLOYEE_ID
WHERE e.EMPLOYEE_name = 'Toni Lembeck';


-- Question 7: Describe how you would apply table security to restrict access to employee salaries using an SQL server.
CREATE ROLE HR_ROLE;
CREATE ROLE EMPLOYEE_ROLE;
GRANT SELECT ON EMPLOYEE_HISTORY TO HR_ROLE;
GRANT SELECT (EMPLOYEE_ID, JOB_ID, DEPARTMENT_ID, LOCATION_ID, EMP_HIST_start, EMP_HIST_end, MANAGER_ID) 
ON EMPLOYEE_HISTORY TO EMPLOYEE_ROLE;
GRANT HR_ROLE TO hr_user;
GRANT EMPLOYEE_ROLE TO employee_user;
/* 
In this last step it is important to mention that the roles are domain-login based. The IT department provides the information which user is hr or employee.
By creating the respective roles and granting access in the database it just needs to be mapped.
*/




