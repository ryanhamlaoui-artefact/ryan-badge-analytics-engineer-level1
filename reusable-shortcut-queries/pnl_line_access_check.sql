-- Here is an example of anonymised short_cut query 
-- Dev of a reusable query to quickly check users access to pnl line (very sensitive data) 
-- Before the access where check on an inefficient way with excel files + sql queries, I created 1 single query reusable for this process 


WITH amaas_id AS (
  SELECT
    a.*,
    TRIM(x) AS job_code
  FROM `project_id.dataset_id.table_id` a
  CROSS JOIN UNNEST(a.job_function_level1_code) AS x
),
sensitivity_mapp AS (
  SELECT
    s.*,
    TRIM(y) AS sensitivity_code
  FROM `project_id.dataset_id.table_id` s
  CROSS JOIN UNNEST(SPLIT(s.pl_sensitivity_code, ',')) AS y
)
SELECT DISTINCT
  amaas_id.email AS user_email,
  sensitivity_mapp.pl_code AS pnl_line_code,
  amaas_id.job_function_level1_code AS job_function_code,
  amaas_id.job_function_level1 AS job_function_label,
  amaas_id.job_function_level2_code AS job_function_2_code,
  amaas_id.job_function_level2 AS job_function_2_label
FROM amaas_id
INNER JOIN sensitivity_mapp
  ON amaas_id.job_code = sensitivity_mapp.sensitivity_code
-- WHERE amaas_id.email = LOWER('ryan.hamlaoui@loreal.com')
-- AND sensitivity_mapp.pl_code = 'R15000AA'

-- Update email & optionally pl_code to check if user have access to pnl lines
-- If a pnl_line is displayed it means that user have access