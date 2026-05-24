WITH all_cte AS (
  SELECT * FROM `project_id.dataset_id.table_id` 
),
counts AS (
  SELECT
    COUNT(*) as total_rows,
    COUNTIF(unique_id IS NULL OR TRIM(unique_id) = '') AS unique_id,
    COUNTIF(source_system IS NULL OR TRIM(source_system) = '') AS source_system,
    COUNTIF(system_id IS NULL OR TRIM(system_id) = '') AS system_id,
    COUNTIF(company_code IS NULL OR TRIM(company_code) = '') AS company_code,
    COUNTIF(company_code_description IS NULL OR TRIM(company_code_description) = '') AS company_code_description,
    COUNTIF(legal_entity_code IS NULL OR TRIM(legal_entity_code) = '') AS legal_entity_code,
    COUNTIF(country_numeric_id IS NULL OR TRIM(country_numeric_id) = '') AS country_numeric_id,
    COUNTIF(country_alpha2_id IS NULL OR TRIM(country_alpha2_id) = '') AS country_alpha2_id,
    COUNTIF(country_alpha3_id IS NULL OR TRIM(country_alpha3_id) = '') AS country_alpha3_id,
    COUNTIF(country_name_en IS NULL OR TRIM(country_name_en) = '') AS country_name_en,
    COUNTIF(currency IS NULL OR TRIM(currency) = '') AS currency,
    COUNTIF(valuation_area IS NULL OR TRIM(valuation_area) = '') AS valuation_area,
    COUNTIF(plant IS NULL OR TRIM(plant) = '') AS plant,
    COUNTIF(plant_name IS NULL OR TRIM(plant_name) = '') AS plant_name,
    COUNTIF(purchasing_organization IS NULL OR TRIM(purchasing_organization) = '') AS purchasing_organization,
    COUNTIF(purchasing_organization_description IS NULL OR TRIM(purchasing_organization_description) = '') AS purchasing_organization_description,
    COUNTIF(sales_organization IS NULL OR TRIM(sales_organization) = '') AS sales_organization,
    COUNTIF(sales_organization_description IS NULL OR TRIM(sales_organization_description) = '') AS sales_organization_description,
    COUNTIF(division IS NULL OR TRIM(division) = '') AS division,
    COUNTIF(division_description IS NULL OR TRIM(division_description) = '') AS division_description,
    COUNTIF(insert_time IS NULL) AS insert_time
  FROM all_cte
)
-- replace each 'countif' line with your table columns
SELECT 
  'table_name' as BO,
  BOA,
  count_empty_lines,
  total_rows as count_total,
  CONCAT(ROUND(SAFE_DIVIDE(count_empty_lines * 100.0, total_rows), 4), '%') as empty_percentage
FROM counts
UNPIVOT(count_empty_lines FOR BOA IN (unique_id, source_system, company_code, company_code_description, legal_entity_code, country_numeric_id, country_alpha2_id, country_alpha3_id, country_name_en, currency, valuation_area, plant, plant_name, purchasing_organization, purchasing_organization_description, sales_organization, sales_organization_description, division, division_description, insert_time
))
-- add the list in the unpivot()
ORDER BY SAFE_DIVIDE(count_empty_lines * 100.0, total_rows) DESC