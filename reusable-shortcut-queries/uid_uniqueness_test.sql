-- straight forward version
WITH cte as( 
SELECT 
    *,
    CONCAT(
      COALESCE(customer_sold_to_code, ''), '|',
      COALESCE(system_id, ''), '|',
      COALESCE(CAST(posting_date AS STRING), ''), '|',
      COALESCE(company_code, ''), '|',
      COALESCE(CAST(signature_code_bitmap_1 AS STRING), ''), '|',
      COALESCE(CAST(pl_sensitivity_code_bitmap AS STRING), ''), '|',
      COALESCE(CAST(value_in_local_currency AS STRING), '')
    ) AS uid
  FROM `project_id.dataset_id.transactional_table_id`
 )

SELECT
    COUNT(*) AS total_count,
    COUNT(*) - COUNT(DISTINCT uid) AS duplicate_count,
    CONCAT(ROUND(SAFE_DIVIDE(COUNT(DISTINCT uid), COUNT(*)) * 100.0, 6),'%') AS distinct_pct,
FROM cte

-- comparison version, you can add as many uid version as you want

WITH v2_cte AS(
    SELECT
        transactional_table_unique_id,
        CONCAT(
        COALESCE(system_id,''),'|',
        COALESCE(group_division,''),'|',
        COALESCE(company_code,''),'|',
        COALESCE(sku_location,''),'|',
        COALESCE(material_code,''), '|',
        COALESCE(valuation_class,''), '|',
        COALESCE(valuation_area,''), '|',
        COALESCE(CAST(price_units AS STRING),''), '|',
        COALESCE(CAST(standard_cost_of_sales AS STRING),''),'|',
        COALESCE(CAST(moving_average_price AS STRING),'')
        ) as transactional_table_unique_id_v2
    FROM `project_id.dataset_id.transactional_table_id`
)

SELECT
    COUNT(*) AS total_count,
    COUNT(*) - COUNT(DISTINCT transactional_table_unique_id) AS duplicate_count_v1,
    CONCAT(ROUND(SAFE_DIVIDE(COUNT(DISTINCT transactional_table_unique_id), COUNT(*)) * 100.0, 6),'%') AS distinct_pct_v1,
    COUNT(*) - COUNT(DISTINCT transactional_table_unique_id_v2) AS duplicate_count_2,
    CONCAT(ROUND(SAFE_DIVIDE(COUNT(DISTINCT transactional_table_unique_id_v2), COUNT(*)) * 100.0, 6),'%') AS distinct_pct_v2,
FROM v2_cte


