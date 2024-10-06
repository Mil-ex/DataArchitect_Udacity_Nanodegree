-- Create a view that returns all employee attributes; results should resemble initial Excel file
CREATE VIEW Employee_Details_View AS
SELECT 
    e.EMPLOYEE_ID, 
    e.EMPLOYEE_name AS Employee_Name,
    e.EMPLOYEE_email AS Email,
    e.EMPLOYEE_hire AS Hire_Date,
    j.JOB_name AS Job_Title,
    sal.SALARY AS Salary,
    d.DEPARTMENT_name AS Department,
    m.EMPLOYEE_name AS Manager,
    h.EMP_HIST_start AS Start_Date,
    h.EMP_HIST_end AS End_Date,
    addr.ADDRESS_name AS Address,
    city.CITY_name AS City,
    state.STATE_name AS State,
    edu.EDUCATION_name AS Education_Level
FROM EMPLOYEE AS e
JOIN EMPLOYEE_HISTORY AS h ON e.EMPLOYEE_ID = h.EMPLOYEE_ID
JOIN JOB AS j ON h.JOB_ID = j.JOB_ID
JOIN DEPARTMENT AS d ON h.DEPARTMENT_ID = d.DEPARTMENT_ID
JOIN ADDRESS AS addr ON h.ADDRESS_ID = addr.ADDRESS_ID
JOIN CITY AS city ON addr.CITY_ID = city.CITY_ID
JOIN STATE AS state ON city.STATE_ID = state.STATE_ID
JOIN EDUCATION AS edu ON e.EDUCATION_ID = edu.EDUCATION_ID
JOIN EMPLOYEE AS m ON h.MANAGER_ID = m.EMPLOYEE_ID
JOIN SALARY AS sal ON h.SALARY_ID = sal.SALARY_ID;
SELECT * FROM employee_details_view;

-- Create a stored procedure with parameters that returns current and past jobs (include employee name, job title, department, manager name, start and end date for position) when given an employee name.
CREATE OR REPLACE FUNCTION GetEmployeeJobHistory(emp_id VARCHAR, emp_name VARCHAR)
RETURNS TABLE (
    Employee_Name VARCHAR,
    Job_Title VARCHAR,
    Department VARCHAR,
    Manager_Name VARCHAR,
    Start_Date DATE,
    End_Date DATE
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.EMPLOYEE_name AS Employee_Name,
        j.JOB_name AS Job_Title,
        d.DEPARTMENT_name AS Department,
        COALESCE(m.EMPLOYEE_name, 'No Manager') AS Manager_Name, -- Handle NULL manager
        h.EMP_HIST_start AS Start_Date,
        h.EMP_HIST_end AS End_Date
    FROM EMPLOYEE AS e
    JOIN EMPLOYEE_HISTORY AS h ON e.EMPLOYEE_ID = h.EMPLOYEE_ID
    JOIN JOB AS j ON h.JOB_ID = j.JOB_ID
    JOIN DEPARTMENT AS d ON h.DEPARTMENT_ID = d.DEPARTMENT_ID
    LEFT JOIN EMPLOYEE AS m ON h.MANAGER_ID = m.EMPLOYEE_ID
    WHERE e.EMPLOYEE_ID = emp_id
    AND LOWER(e.EMPLOYEE_name) = LOWER(emp_name);
END;
$$;
SELECT * FROM GetEmployeeJobHistory('Toni Lembeck');


-- Implement user security on the restricted salary attribute.
CREATE USER NoMgr WITH PASSWORD 'password';
GRANT CONNECT ON DATABASE postgres TO NoMgr;
GRANT USAGE ON SCHEMA public TO NoMgr;
GRANT SELECT ON EMPLOYEE_HISTORY TO NoMgr;
REVOKE SELECT ON SALARY FROM NoMgr;

SET ROLE NoMgr;
SELECT * FROM EMPLOYEE_HISTORY;

SELECT * FROM SALARY;

RESET ROLE;
