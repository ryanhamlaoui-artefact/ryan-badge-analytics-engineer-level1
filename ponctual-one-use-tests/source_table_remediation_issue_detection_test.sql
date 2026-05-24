-- Hello Anirban "Data engineer NAME" , I hope you are doing well, first thanks for your work on wbs test table
-- I tested the table & found that joining rules were wrong & we had many differences between old wbs & the new test one on customer_description, here is my query to detect the missmatch : 
WITH v1 AS (
  SELECT 
    *,
    CONCAT(
      COALESCE(customer, ''), '|',
      COALESCE(system_id, ''), '|',
      COALESCE(CAST(data_record_number AS STRING), ''), '|',
      COALESCE(CAST(posting_date AS STRING), ''), '|',
      COALESCE(profit_center, ''), '|',
      COALESCE(CAST(signature_code_bitmap_1 AS STRING), ''), '|',
      COALESCE(CAST(transaction_sequence_number AS STRING), ''), '|',
      COALESCE(CAST(pl_sensitivity_code_bitmap AS STRING), ''), '|',
      COALESCE(CAST(value_in_local_currency AS STRING), '')
    ) AS uid,
    FARM_FINGERPRINT(
      CONCAT(
        COALESCE(customer, ''), '|',
        COALESCE(system_id, ''), '|',
        COALESCE(CAST(data_record_number AS STRING), ''), '|',
        COALESCE(CAST(posting_date AS STRING), ''), '|',
        COALESCE(profit_center, ''), '|',
        COALESCE(CAST(signature_code_bitmap_1 AS STRING), ''), '|',
        COALESCE(CAST(transaction_sequence_number AS STRING), ''), '|',
        COALESCE(CAST(pl_sensitivity_code_bitmap AS STRING), ''), '|',
        COALESCE(CAST(value_in_local_currency AS STRING), '')
      )
    ) AS tech_uid
  FROM `project_id.dataset_id.table_id` -- this is the current table used in pd (control table)
),
test AS (
  SELECT 
    *,
    CONCAT(
      COALESCE(customer, ''), '|',
      COALESCE(system_id, ''), '|',
      COALESCE(CAST(data_record_number AS STRING), ''), '|',
      COALESCE(CAST(posting_date AS STRING), ''), '|',
      COALESCE(profit_center, ''), '|',
      COALESCE(CAST(signature_code_bitmap_1 AS STRING), ''), '|',
      COALESCE(CAST(transaction_sequence_number AS STRING), ''), '|',
      COALESCE(CAST(pl_sensitivity_code_bitmap AS STRING), ''), '|',
      COALESCE(CAST(value_in_local_currency AS STRING), '')
    ) AS uid,
    FARM_FINGERPRINT(
      CONCAT(
        COALESCE(customer, ''), '|',
        COALESCE(system_id, ''), '|',
        COALESCE(CAST(data_record_number AS STRING), ''), '|',
        COALESCE(CAST(posting_date AS STRING), ''), '|',
        COALESCE(profit_center, ''), '|',
        COALESCE(CAST(signature_code_bitmap_1 AS STRING), ''), '|',
        COALESCE(CAST(transaction_sequence_number AS STRING), ''), '|',
        COALESCE(CAST(pl_sensitivity_code_bitmap AS STRING), ''), '|',
        COALESCE(CAST(value_in_local_currency AS STRING), '')
      )
    ) AS tech_uid
  FROM `project_id.dataset_id.table_id` -- this is the test table with new sources
),
verif_cte AS (
  SELECT
  v1.uid,
  COALESCE(v1.customer_description, '') AS customer_description_v1,
  test.customer_description AS customer_description_test,
  TRIM(CONCAT(
      COALESCE(v1.customer_description, g2.full_name, ""),
      " ",
      COALESCE(g2.organization_legal_name_2, "")
    )) as concat_legal_name_v1,
  g2.organization_legal_name_2
FROM v1
LEFT JOIN(
  SELECT
    business_partner_golden_id,
    organization_legal_name_1,
    organization_legal_name_2,
    full_name
  FROM `project_id.dataset_id.table_id` -- old source table, I call it here because new customer_legal_name is a concat of organization_legal_name_1 &organization_legal_name_2
  -- before we only use in our table organization_legal_name_1, now we need to use customer_legal_name
  -- so to verify quality, I need to reproduce source table behavior
  QUALIFY
    ROW_NUMBER() OVER (
      PARTITION BY business_partner_golden_id
      ORDER BY insert_timestamp DESC
    ) = 1
) g2
ON REGEXP_REPLACE(v1.customer, r'^0+', '')=g2.business_partner_golden_id
INNER JOIN test
  ON v1.tech_uid = test.tech_uid
)
SELECT DISTINCT concat_legal_name_v1, customer_description_test FROM verif_cte
WHERE concat_legal_name_v1 <> customer_description_test
ORDER BY concat_legal_name_v1 ASC

-- 705 distinct rows missmatch
 
--So after some tests I think I found the issue, they put priority to 'EBX' current_customer_code to fill customer_legal_name, because our wbs customer matches multiple current_customer_code from 'EBX' & 'ECC'
--Here the fix SQL : 
WITH v1 AS (
  SELECT 
    *,
    CONCAT(
      COALESCE(customer, ''), '|',
      COALESCE(system_id, ''), '|',
      COALESCE(CAST(data_record_number AS STRING), ''), '|',
      COALESCE(CAST(posting_date AS STRING), ''), '|',
      COALESCE(profit_center, ''), '|',
      COALESCE(CAST(signature_code_bitmap_1 AS STRING), ''), '|',
      COALESCE(CAST(transaction_sequence_number AS STRING), ''), '|',
      COALESCE(CAST(pl_sensitivity_code_bitmap AS STRING), ''), '|',
      COALESCE(CAST(value_in_local_currency AS STRING), '')
    ) AS uid,
    FARM_FINGERPRINT(
      CONCAT(
        COALESCE(customer, ''), '|',
        COALESCE(system_id, ''), '|',
        COALESCE(CAST(data_record_number AS STRING), ''), '|',
        COALESCE(CAST(posting_date AS STRING), ''), '|',
        COALESCE(profit_center, ''), '|',
        COALESCE(CAST(signature_code_bitmap_1 AS STRING), ''), '|',
        COALESCE(CAST(transaction_sequence_number AS STRING), ''), '|',
        COALESCE(CAST(pl_sensitivity_code_bitmap AS STRING), ''), '|',
        COALESCE(CAST(value_in_local_currency AS STRING), '')
      )
    ) AS tech_uid
  FROM `project_id.dataset_id.table_id`
),
test AS (
  SELECT 
    *,
    CONCAT(
      COALESCE(customer, ''), '|',
      COALESCE(system_id, ''), '|',
      COALESCE(CAST(data_record_number AS STRING), ''), '|',
      COALESCE(CAST(posting_date AS STRING), ''), '|',
      COALESCE(profit_center, ''), '|',
      COALESCE(CAST(signature_code_bitmap_1 AS STRING), ''), '|',
      COALESCE(CAST(transaction_sequence_number AS STRING), ''), '|',
      COALESCE(CAST(pl_sensitivity_code_bitmap AS STRING), ''), '|',
      COALESCE(CAST(value_in_local_currency AS STRING), '')
    ) AS uid,
    FARM_FINGERPRINT(
      CONCAT(
        COALESCE(customer, ''), '|',
        COALESCE(system_id, ''), '|',
        COALESCE(CAST(data_record_number AS STRING), ''), '|',
        COALESCE(CAST(posting_date AS STRING), ''), '|',
        COALESCE(profit_center, ''), '|',
        COALESCE(CAST(signature_code_bitmap_1 AS STRING), ''), '|',
        COALESCE(CAST(transaction_sequence_number AS STRING), ''), '|',
        COALESCE(CAST(pl_sensitivity_code_bitmap AS STRING), ''), '|',
        COALESCE(CAST(value_in_local_currency AS STRING), '')
      )
    ) AS tech_uid
  FROM `project_id.dataset_id.table_id`
),
fix_cte AS (
  SELECT
  v1.uid,
  COALESCE(v1.customer_description, '') AS customer_description_v1,
  test.customer_description AS customer_description_test,
  TRIM(custo.customer_legal_name) AS fix_customer_description,
  TRIM(CONCAT(
      COALESCE(v1.customer_description, g2.full_name, ''),
      ' ',
      COALESCE(g2.organization_legal_name_2, '')
    )) as concat_legal_name_v1,
  g2.organization_legal_name_2,
FROM v1
LEFT JOIN(
  SELECT
    business_partner_golden_id,
    organization_legal_name_1,
    organization_legal_name_2,
    full_name
  FROM `project_id.dataset_id.table_id`
  QUALIFY
    ROW_NUMBER() OVER (
      PARTITION BY business_partner_golden_id
      ORDER BY insert_timestamp DESC
    ) = 1
) g2
ON REGEXP_REPLACE(v1.customer, r'^0+', '')=g2.business_partner_golden_id
LEFT JOIN (
  SELECT
    current_customer_code,
    customer_legal_name,
    source_system
  FROM `project_id.dataset_id.table_id`
  QUALIFY 
    ROW_NUMBER() OVER (
      PARTITION BY LTRIM(current_customer_code, '0')
      ORDER BY
        CASE
          WHEN source_system = 'EBX' THEN 1
          ELSE 2
        END,
        insert_timestamp DESC
    ) = 1
) custo
ON LTRIM(v1.customer, '0') = LTRIM(custo.current_customer_code, '0')
INNER JOIN test
  ON v1.tech_uid = test.tech_uid
)
SELECT DISTINCT concat_legal_name_v1, fix_customer_description FROM fix_cte
WHERE concat_legal_name_v1 <> fix_customer_description
 
-- 0 rows missmatch

--The part that needs to be implemented in our sproc is this : 
 
SQL
  QUALIFY 
    ROW_NUMBER() OVER (
      PARTITION BY LTRIM(current_customer_code, '0')
      ORDER BY
        CASE
          WHEN source_system = 'EBX' THEN 1
          ELSE 2
        END,
      insert_timestamp DESC
  ) = 1
-- If needed for explanations we can make a call


-- after Anirban "Data engineer NAME" updated code based on my suggested fix
WITH v1 AS (
  SELECT 
    *,
    CONCAT(
      COALESCE(customer, ''), '|',
      COALESCE(system_id, ''), '|',
      COALESCE(CAST(data_record_number AS STRING), ''), '|',
      COALESCE(CAST(posting_date AS STRING), ''), '|',
      COALESCE(profit_center, ''), '|',
      COALESCE(CAST(signature_code_bitmap_1 AS STRING), ''), '|',
      COALESCE(CAST(transaction_sequence_number AS STRING), ''), '|',
      COALESCE(CAST(pl_sensitivity_code_bitmap AS STRING), ''), '|',
      COALESCE(CAST(value_in_local_currency AS STRING), '')
    ) AS uid,
    FARM_FINGERPRINT(
      CONCAT(
        COALESCE(customer, ''), '|',
        COALESCE(system_id, ''), '|',
        COALESCE(CAST(data_record_number AS STRING), ''), '|',
        COALESCE(CAST(posting_date AS STRING), ''), '|',
        COALESCE(profit_center, ''), '|',
        COALESCE(CAST(signature_code_bitmap_1 AS STRING), ''), '|',
        COALESCE(CAST(transaction_sequence_number AS STRING), ''), '|',
        COALESCE(CAST(pl_sensitivity_code_bitmap AS STRING), ''), '|',
        COALESCE(CAST(value_in_local_currency AS STRING), '')
      )
    ) AS tech_uid
  FROM `project_id.dataset_id.table_id`
),
test AS (
  SELECT 
    *,
    CONCAT(
      COALESCE(customer, ''), '|',
      COALESCE(system_id, ''), '|',
      COALESCE(CAST(data_record_number AS STRING), ''), '|',
      COALESCE(CAST(posting_date AS STRING), ''), '|',
      COALESCE(profit_center, ''), '|',
      COALESCE(CAST(signature_code_bitmap_1 AS STRING), ''), '|',
      COALESCE(CAST(transaction_sequence_number AS STRING), ''), '|',
      COALESCE(CAST(pl_sensitivity_code_bitmap AS STRING), ''), '|',
      COALESCE(CAST(value_in_local_currency AS STRING), '')
    ) AS uid,
    FARM_FINGERPRINT(
      CONCAT(
        COALESCE(customer, ''), '|',
        COALESCE(system_id, ''), '|',
        COALESCE(CAST(data_record_number AS STRING), ''), '|',
        COALESCE(CAST(posting_date AS STRING), ''), '|',
        COALESCE(profit_center, ''), '|',
        COALESCE(CAST(signature_code_bitmap_1 AS STRING), ''), '|',
        COALESCE(CAST(transaction_sequence_number AS STRING), ''), '|',
        COALESCE(CAST(pl_sensitivity_code_bitmap AS STRING), ''), '|',
        COALESCE(CAST(value_in_local_currency AS STRING), '')
      )
    ) AS tech_uid
  FROM `project_id.dataset_id.table_id` -- new test table name, updated with my fix suggestion
),
verif_cte AS (
  SELECT
  v1.uid,
  COALESCE(v1.customer_description, '') AS customer_description_v1,
  test.customer_description AS customer_description_test,
  TRIM(CONCAT(
      COALESCE(v1.customer_description, g2.full_name, ""),
      " ",
      COALESCE(g2.organization_legal_name_2, "")
    )) as concat_legal_name_v1,
  g2.organization_legal_name_2
FROM v1
LEFT JOIN(
  SELECT
    business_partner_golden_id,
    organization_legal_name_1,
    organization_legal_name_2,
    full_name
  FROM `project_id.dataset_id.table_id`
  QUALIFY
    ROW_NUMBER() OVER (
      PARTITION BY business_partner_golden_id
      ORDER BY insert_timestamp DESC
    ) = 1
) g2
ON REGEXP_REPLACE(v1.customer, r'^0+', '')=g2.business_partner_golden_id
INNER JOIN test
  ON v1.tech_uid = test.tech_uid
)

SELECT DISTINCT concat_legal_name_v1, fix_customer_description FROM fix_cte
WHERE concat_legal_name_v1 <> fix_customer_description
ORDER BY fix_customer_description ASC

-- this new test table "test_table_name" is not displaying unmatched rows
-- fix worked
-- we can reload np table with this new logic, test again on np & then push on release 