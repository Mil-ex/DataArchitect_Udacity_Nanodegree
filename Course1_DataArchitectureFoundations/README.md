# Data Architecture Foundations

This chapter focuses on the fundamental principles of data architecture, including data modeling, database design, and the implementation of entity-relationship diagrams (ERDs). The primary goal was to understand the foundations of relational databases and how to design efficient, scalable data systems for real-world applications.

## Key Concepts Learned

**Data Modeling:**

Built a conceptual model to capture business rules and relationships between entities.

**Entity-Relationship Diagrams (ERD):**

Used ERDs to visualize and define the structure of databases and relationships between tables.

**3NF Normalization:**

Applied normalization rules to reduce redundancy and ensure data consistency.

**SQL Database Implementation:**

Developed PostgreSQL databases and learned how to write efficient SQL queries for data retrieval.

## Project: Designing an HR Database

In this project, I designed and built a database for the HR department at Tech ABC Corp, a fast-growing video game company. The project simulates a real-world scenario, starting from gathering business requirements to creating a fully functional HR database. The main goal was to move employee data management from spreadsheets to a scalable database solution.

### Business Scenario

Due to rapid expansion from 10 to 200 employees across multiple locations, the HR department struggled to manage employee information using spreadsheets. My task was to design a scalable database to streamline employee information management.

### Support Material

The HR dataset contains 205 records with 15 fields, detailing employee information such as name, department, title, salary, hire date, and work location. The data was not normalized, requiring significant structuring before use, while keeping in mind the Best-Practices of the IT department.

### Project Steps

**Information Gathering:**

Developed business and technical proposals to outline the database requirements and structure.

**Design:**

Created ERD diagrams (conceptual, logical and physical) using Lucidchart to design the database architecture.
![ERDs](./ERDs.png)

**Implementation:**

Staged the data, built the database using SQL DDL commands, populated the provided HR dataset with with CRUD commands and finally queried data.
<a href="SQL">SQL Files</a>

**Enhancements:**

Added views, stored procedures, and security features to improve the database functionality.
