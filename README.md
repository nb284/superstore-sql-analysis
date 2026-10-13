# Superstore Sales Analysis Using MySQL

## Project Overview

This project analyzes retail transaction data using MySQL to identify sales performance, profitability patterns, product performance, customer segments, regional differences, and shipping trends.

The project demonstrates data validation, SQL aggregation, date-based analysis, conditional grouping, Common Table Expressions (CTEs), and window functions.

## Business Objectives

- Evaluate overall sales and profit performance.
- Identify high-performing and low-performing product categories.
- Compare sales and profitability across regions and customer segments.
- Examine the relationship between discount levels and profit.
- Analyze monthly sales trends and month-over-month growth.
- Compare shipping methods and order-level profitability.

## Dataset

**Dataset:** Sample Superstore

**Source:** [Sample Superstore dataset on GitHub](https://github.com/)

The dataset contains retail transaction fields such as order dates, shipping dates, customer details, geographic information, product categories, sales, quantity, discount, and profit.

The expected dataset structure contains 21 columns. The actual row count and source file should be verified before analysis.

## Tools Used

- MySQL
- phpMyAdmin
- Python
- pandas
- mysql-connector-python
- GitHub

## Project Workflow

1. Prepare the MySQL database.
2. Inspect and validate the CSV dataset.
3. Import the data using Python.
4. Validate row counts, data types, missing values, and date consistency.
5. Perform SQL-based business analysis.
6. Document findings and recommendations.

## SQL Analysis

The analysis covers:

- Business performance overview
- Monthly and yearly sales trends
- Sales and profit by category and subcategory
- Product profitability
- Regional and customer segment performance
- Discount analysis
- Shipping performance
- Order-level profitability

## Key Findings

*To be completed after running the SQL queries and reviewing the results.*

- Total sales:
- Total profit:
- Total orders:
- Highest-performing category:
- Most profitable region:
- Products with the lowest profit:
- Discount-related observations:

## Business Recommendations

*Recommendations will be added after the findings have been validated.*

## Repository Structure

- `import_superstore.py` — CSV import script
- `data_validation.sql` — Data quality checks
- `analysis_queries.sql` — SQL business analysis
- `screenshots/` — Evidence of query results and analysis

## Limitations

The analysis describes the available transaction data and does not establish causation. Relationships between discount levels, sales, and profit should be interpreted in context.

## Author

Data Analyst Portfolio Project
