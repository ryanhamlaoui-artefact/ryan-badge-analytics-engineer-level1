# Ryan Hamlaoui - Analytics Engineering Level 1 application

## Purpose

This repository contains SQL examples from my day-to-day work as a **Data Product Owner in the Data Finance Transformation team at L’Oréal Global.**

It includes:

- **one-off test queries** used to assess whether source table remediations create data quality issues or impact business meaning
- **reusable shortcut** queries developed to save time on recurring data quality checks and user access validation for Finance data

Queries have been **anonymised** to respect L'Oreal data privacy & finance sensitivity, I added many comments to try to give you as much context as possible. 

## Tree
``` bash
ANALYTICS-ENG-LEVEL1/ 
├── ponctual-one-use-tests/ 
│ ├── source_table_remediation_issue_detection_test.sql
│ └── wip_source_remediations_tests.sql 
├── reusable-shortcut-queries/ 
│ ├── completeness_check_dimensional.sql 
│ ├── pnl_line_access_check.sql 
│ └── uid_uniqueness_test.sql 
└── README.md
```