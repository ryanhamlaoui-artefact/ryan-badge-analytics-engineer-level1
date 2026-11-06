# Ryan Hamlaoui - Analytics Engineering Level 1 application

## Purpose

This repository contains SQL examples from my day-to-day work as a **Data Product Owner in the Data Finance Transformation team at L’Oréal Global.**

It includes:

It includes:
- **`ponctual-one-use-tests/` (Ad-hoc QA & Regression Audits):** One-off validation queries used for non-regression testing (`atc_vs_compass_noreg_test.sql`), assessing whether upstream source table remediations create data quality issues (`source_table_remediation_issue_detection_test.sql`), and detecting historical data drift using BigQuery Time Travel (`timetravel_test.sql`).
- **`reusable-shortcut-queries/` (Reusable QA & Governance Templates):** Standardized, DRY queries developed to save time on recurring data quality checks—such as technical UID uniqueness (`uid_uniqueness_test.sql`), grain uniqueness on transactional fact tables (`uniqueness_test_transactional_table.sql`), dimensional completeness (`completness_check_dimensional.sql`), and sensitive Finance user access validation (`pnl_line_access_check.sql`).
- **`table-dev/` (Data Modeling & Transformation Prototypes):** SQL transformation models and target table prototypes built in BigQuery Non-Prod (`local_cost_center_v1.sql`, `atc_neo_test_product_fall_back.sql`), implementing business logic, fallback rules, and target schemas to serve as executable specifications for production pipelines.

*Note: Queries have been **anonymised** to respect L'Oréal's data privacy and financial sensitivity. I have included detailed inline comments throughout the scripts to provide full business and technical context.*

## Repository Structure

```bash
ANALYTICS-ENG-LEVEL1/
├── ponctual-one-use-tests/
│   ├── atc_vs_compass_noreg_test.sql
│   ├── source_table_remediation_issue_detection_test.sql
│   └── timetravel_test.sql
├── reusable-shortcut-queries/
│   ├── completness_check_dimensional.sql
│   ├── pnl_line_access_check.sql
│   ├── uid_uniqueness_test.sql
│   └── uniqueness_test_transactional_table.sql
├── table-dev/
│   ├── atc_neo_test_product_fall_back.sql
│   └── local_cost_center_v1.sql
└── README.md
```