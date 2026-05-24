-- control data sample (filtered on posting_date (partitionned column) & clustured columns to limit costs on first tests)
-- current data used in published prod
SELECT DISTINCT
customer_sold_to_code,
customer_compass_code
,customer_hierarchy_1
,customer_hierarchy_2
,customer_hierarchy_3
,customer_hierarchy_4
,customer_hierarchy_5
customer_sold_to,
sales_customer_id,
source_system as source_system
FROM `project_id.dataset_id.table_id`
where posting_date = '2026-03-07' AND pl_line_code = 'R13000AA'
 AND value_in_local_currency <> 0 AND value_in_local_currency IS NOT NULL
 AND system_id IN('701', '060')
 and ltrim(customer_sold_to_code,'0') IN('51744','183895')


-- test data sample in non-prod env
-- verifying if customer data source remediation have impact on data

WITH test_cte AS(
SELECT DISTINCT
customer_sold_to_code,
customer_compass_code
,customer_hierarchy_1
,customer_hierarchy_2
,customer_hierarchy_3
,customer_hierarchy_4
,customer_hierarchy_5
customer_sold_to,
sales_customer_id,
'neo_test' as source_system
FROM `project_id.dataset_id.table_id` -- test sample - batch 1 - source_system 701
where posting_date = '2026-03-07' AND pl_line_code = 'R13000AA'
 AND value_in_local_currency <> 0 AND value_in_local_currency IS NOT NULL

UNION ALL

SELECT DISTINCT
customer_sold_to_code,
customer_compass_code
,customer_hierarchy_1
,customer_hierarchy_2
,customer_hierarchy_3
,customer_hierarchy_4
,customer_hierarchy_5
customer_sold_to,
sales_customer_id,
'ecc_test' as source_system
FROM `project_id.dataset_id.table_id`-- test sample - batch 1 - source_system 060
where posting_date = '2026-03-07' AND pl_line_code = 'R13000AA'
 AND value_in_local_currency <> 0 AND value_in_local_currency IS NOT NULL)

SELECT * FROM test_cte where ltrim(customer_sold_to_code,'0') IN('51744','183895') -- 1 random row per system to check if there is gaps with this unioned test table & control table

-- output gaps :
-- for ecc example : sales_customer_id is null while filled in control sample, all the rest is okay
-- for neo example : customer_compass_code is null while filled in control sample, sales_customer_id is different but not in theory a dq issue because it is a concat of other column & the formula changed between old & new cust source

-- for ecc example, the issue resolver is the same than in wbs_budget, Qualify with 'EBX' priority based on source_system & adding sap_division to the joining rule, 100% rows returned so its perfect
WITH test_cte AS (
  SELECT DISTINCT
    system_id,
    LTRIM(customer_sold_to_code, '0') AS customer_sold_to_code_norm,
    customer_sold_to_code,
    customer_hierarchy_1,
    customer_hierarchy_2,
    customer_hierarchy_3,
    customer_hierarchy_4,
    sales_organisation_code,
    distribution_channel_code,
    sap_division_code,
    sales_customer_id AS test_sales_customer_id
  FROM `project_id.dataset_id.table_id`
  WHERE posting_date = '2026-03-07'
    AND pl_line_code = 'R13000AA'
    AND value_in_local_currency IS NOT NULL
    AND value_in_local_currency <> 0
    AND system_id IN ('701', '060')
),

original_cte AS (
  SELECT DISTINCT
    system_id,
    LTRIM(customer_sold_to_code, '0') AS customer_sold_to_code_norm,
    customer_sold_to_code AS original_customer_sold_to_code,
    sales_organisation_code,
    distribution_channel_code,
    sap_division_code,
    sales_customer_id AS original_sales_customer_id
  FROM `project_id.dataset_id.table_id`
  WHERE posting_date = '2026-03-07'
    AND pl_line_code = 'R13000AA'
    AND value_in_local_currency IS NOT NULL
    AND value_in_local_currency <> 0
    AND system_id IN ('060')
),

mapping_cte AS (
  SELECT
    legacy_customer_code,
    system_id,
    source_system,
    legacy_distribution_channel,
    legacy_sales_organization,
    legacy_division,
    current_customer_sales_area_id,
    insert_timestamp
  FROM `project_id.dataset_id.table_id`
),

replicated_cte AS (
  SELECT DISTINCT
    t.system_id,
    t.customer_sold_to_code_norm,
    t.customer_sold_to_code,
    t.sales_organisation_code,
    t.distribution_channel_code,
    t.sap_division_code,
    m.current_customer_sales_area_id AS replicated_sales_customer_id
  FROM test_cte t
  LEFT JOIN (
    SELECT
      legacy_customer_code,
      legacy_sales_organization,
      legacy_distribution_channel,
      legacy_division,
      system_id,
      source_system,
      current_customer_sales_area_id,
      insert_timestamp
    FROM mapping_cte
    QUALIFY ROW_NUMBER() OVER (
      PARTITION BY
        system_id,
        legacy_sales_organization,
        legacy_distribution_channel,
        legacy_division,
        LTRIM(legacy_customer_code, '0')
      ORDER BY
        CASE WHEN source_system = 'EBX' THEN 1 ELSE 2 END,
        insert_timestamp DESC
    ) = 1
  ) m
    ON m.system_id = t.system_id
   AND m.legacy_sales_organization = t.sales_organisation_code
   AND m.legacy_distribution_channel = t.distribution_channel_code
   AND m.legacy_division = t.sap_division_code
   AND LTRIM(m.legacy_customer_code, '0') = LTRIM(
     COALESCE(
       NULLIF(TRIM(t.customer_sold_to_code), ''),
       NULLIF(TRIM(t.customer_hierarchy_4), ''),
       NULLIF(TRIM(t.customer_hierarchy_3), ''),
       NULLIF(TRIM(t.customer_hierarchy_2), ''),
       NULLIF(TRIM(t.customer_hierarchy_1), '')
     ),
     '0'
   )
)

SELECT DISTINCT
  COALESCE(o.original_customer_sold_to_code, t.customer_sold_to_code) AS customer_sold_to_code,
  o.original_sales_customer_id,
  t.test_sales_customer_id,
  r.replicated_sales_customer_id,
  t.system_id,
  t.sales_organisation_code,
  t.distribution_channel_code,
  t.sap_division_code
FROM test_cte t
LEFT JOIN original_cte o
  ON t.system_id = o.system_id
 AND t.customer_sold_to_code_norm = o.customer_sold_to_code_norm
 AND t.sales_organisation_code = o.sales_organisation_code
 AND t.distribution_channel_code = o.distribution_channel_code
 AND t.sap_division_code = o.sap_division_code
LEFT JOIN replicated_cte r
  ON t.system_id = r.system_id
 AND t.customer_sold_to_code = r.customer_sold_to_code
 AND t.sales_organisation_code = r.sales_organisation_code
 AND t.distribution_channel_code = r.distribution_channel_code
 AND t.sap_division_code = r.sap_division_code
ORDER BY
  customer_sold_to_code,
  t.system_id,
  t.sales_organisation_code,
  t.distribution_channel_code,
  t.sap_division_code;

-- replication of key from customer to be sure everythings works 
WITH test_cte AS (
  SELECT DISTINCT
    system_id,
    LTRIM(customer_sold_to_code, '0') AS customer_sold_to_code_norm,
    customer_sold_to_code,
    customer_hierarchy_1,
    customer_hierarchy_2,
    customer_hierarchy_3,
    customer_hierarchy_4,
    sales_organisation_code,
    distribution_channel_code,
    sap_division_code,
    sales_customer_id AS test_sales_customer_id
  FROM `project_id.dataset_id.table_id`
  WHERE posting_date = '2026-03-07'
    AND pl_line_code = 'R13000AA'
    AND value_in_local_currency IS NOT NULL
    AND value_in_local_currency <> 0
    AND system_id IN ('701', '060')
),

original_cte AS (
  SELECT DISTINCT
    system_id,
    LTRIM(customer_sold_to_code, '0') AS customer_sold_to_code_norm,
    customer_sold_to_code AS original_customer_sold_to_code,
    sales_organisation_code,
    distribution_channel_code,
    sap_division_code,
    sales_customer_id AS original_sales_customer_id
  FROM `project_id.dataset_id.table_id`
  WHERE posting_date = '2026-03-07'
    AND pl_line_code = 'R13000AA'
    AND value_in_local_currency IS NOT NULL
    AND value_in_local_currency <> 0
    AND system_id IN ('060')
),

mapping_cte AS (
  SELECT
    legacy_customer_code,
    system_id,
    source_system,
    legacy_distribution_channel,
    legacy_sales_organization,
    legacy_division,
    current_customer_sales_area_id,
    insert_timestamp
  FROM `project_id.dataset_id.table_id`
),

replicated_cte AS (
  SELECT DISTINCT
    t.system_id,
    t.customer_sold_to_code_norm,
    t.customer_sold_to_code,
    t.sales_organisation_code,
    t.distribution_channel_code,
    t.sap_division_code,
    CONCAT(
      m.system_id, '|',
      m.legacy_customer_code, '|',
      m.legacy_sales_organization, '|',
      m.legacy_distribution_channel, '|',
      m.legacy_division
    ) AS replicated_mapping_key,
    m.current_customer_sales_area_id AS replicated_sales_customer_id
  FROM test_cte t
  LEFT JOIN (
    SELECT
      legacy_customer_code,
      legacy_sales_organization,
      legacy_distribution_channel,
      legacy_division,
      system_id,
      source_system,
      current_customer_sales_area_id,
      insert_timestamp
    FROM mapping_cte
    QUALIFY ROW_NUMBER() OVER (
      PARTITION BY
        system_id,
        legacy_sales_organization,
        legacy_distribution_channel,
        legacy_division,
        LTRIM(legacy_customer_code, '0')
      ORDER BY
        CASE
          WHEN source_system = 'EBX' THEN 1
          ELSE 2
        END,
        insert_timestamp DESC
    ) = 1
  ) m
    ON m.system_id = t.system_id
   AND m.legacy_sales_organization = t.sales_organisation_code
   AND m.legacy_distribution_channel = t.distribution_channel_code
   AND m.legacy_division = t.sap_division_code
   AND LTRIM(m.legacy_customer_code, '0') = LTRIM(
     COALESCE(
       NULLIF(TRIM(t.customer_sold_to_code), ''),
       NULLIF(TRIM(t.customer_hierarchy_4), ''),
       NULLIF(TRIM(t.customer_hierarchy_3), ''),
       NULLIF(TRIM(t.customer_hierarchy_2), ''),
       NULLIF(TRIM(t.customer_hierarchy_1), '')
     ),
     '0'
   )
)

SELECT DISTINCT
  COALESCE(o.original_customer_sold_to_code, t.customer_sold_to_code) AS customer_sold_to_code,
  o.original_sales_customer_id,
  t.test_sales_customer_id,
  r.replicated_sales_customer_id,
  r.replicated_mapping_key,
  t.system_id,
  t.sales_organisation_code,
  t.distribution_channel_code,
  t.sap_division_code
FROM test_cte t
LEFT JOIN original_cte o
  ON t.system_id = o.system_id
 AND t.customer_sold_to_code_norm = o.customer_sold_to_code_norm
 AND t.sales_organisation_code = o.sales_organisation_code
 AND t.distribution_channel_code = o.distribution_channel_code
 AND t.sap_division_code = o.sap_division_code
LEFT JOIN replicated_cte r
  ON t.system_id = r.system_id
 AND t.customer_sold_to_code = r.customer_sold_to_code
 AND t.sales_organisation_code = r.sales_organisation_code
 AND t.distribution_channel_code = r.distribution_channel_code
 AND t.sap_division_code = r.sap_division_code
ORDER BY
  customer_sold_to_code,
  t.system_id,
  t.sales_organisation_code,
  t.distribution_channel_code,
  t.sap_division_code;

