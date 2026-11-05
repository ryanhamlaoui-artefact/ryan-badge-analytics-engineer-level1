WITH gcc1 AS(
SELECT
  group_costs_center_code,
  group_cost_center,
  pnl_line_code
FROM `itg-btdppublished-gbl-ww-pd.btdp_ds_c1_101_finance_masterdata_eu_pd.groupcostcenter_v1`
),
gcc2 AS(
SELECT
  group_costs_center_hierarchy_1_code,
  group_costs_center_hierarchy_1,
  pnl_line_code
FROM `itg-btdppublished-gbl-ww-pd.btdp_ds_c1_101_finance_masterdata_eu_pd.groupcostcenter_v1`
),
gcc3 AS(
SELECT
  group_costs_center_hierarchy_2_code,
  group_costs_center_hierarchy_2,
  pnl_line_code
FROM `itg-btdppublished-gbl-ww-pd.btdp_ds_c1_101_finance_masterdata_eu_pd.groupcostcenter_v1`
),
combined_setleaf AS (
SELECT SETCLASS, SETNAME, VALFROM, insert_time, '060' AS system_id FROM `itg-btdpslt-gbl-ww-pd.btdp_ds_c3_eccs_eu_pd.V_SETLEAF_060`
UNION ALL
SELECT SETCLASS, SETNAME, VALFROM, insert_time, '005' AS system_id FROM `itg-btdpslt-gbl-ww-pd.btdp_ds_c3_eccs_eu_pd.V_SETLEAF_005`
UNION ALL
SELECT SETCLASS, SETNAME, VALFROM, insert_time, '062' AS system_id FROM `itg-btdpslt-gbl-ww-pd.btdp_ds_c3_eccs_eu_pd.V_SETLEAF_062`
UNION ALL
SELECT SETCLASS, SETNAME, VALFROM, insert_time, '047' AS system_id FROM `itg-btdpslt-gbl-ww-pd.btdp_ds_c3_eccs_eu_pd.V_SETLEAF_047`
UNION ALL
SELECT SETCLASS, SETNAME, VALFROM, insert_time, '051' AS system_id FROM `itg-btdpslt-gbl-ww-pd.btdp_ds_c3_eccs_eu_pd.V_SETLEAF_051`
UNION ALL
SELECT SETCLASS, SETNAME, VALFROM, insert_time, '065' AS system_id FROM `itg-btdpslt-gbl-ww-pd.btdp_ds_c3_eccs_eu_pd.V_SETLEAF_065`
UNION ALL
SELECT SETCLASS, SETNAME, VALFROM, insert_time, '054' AS system_id FROM `itg-btdpslt-gbl-ww-pd.btdp_ds_c3_eccs_eu_pd.V_SETLEAF_054`
UNION ALL
SELECT SETCLASS, SETNAME, VALFROM, insert_time, '072' AS system_id FROM `itg-btdpslt-gbl-ww-pd.btdp_ds_c3_eccs_eu_pd.V_SETLEAF_072`
UNION ALL
SELECT SETCLASS, SETNAME, VALFROM, insert_time, '048' AS system_id FROM `itg-btdpslt-gbl-ww-pd.btdp_ds_c3_eccs_eu_pd.V_SETLEAF_048`
UNION ALL
SELECT SETCLASS, SETNAME, VALFROM, insert_time, '070' AS system_id FROM `itg-btdpslt-gbl-ww-pd.btdp_ds_c3_eccs_eu_pd.V_SETLEAF_070`
UNION ALL
SELECT SETCLASS, SETNAME, VALFROM, insert_time, '043' AS system_id FROM `itg-btdpslt-gbl-ww-pd.btdp_ds_c3_eccs_eu_pd.V_SETLEAF_043`
UNION ALL
SELECT SETCLASS, SETNAME, VALFROM, insert_time, '042' AS system_id FROM `itg-btdpslt-gbl-ww-pd.btdp_ds_c3_eccs_eu_pd.V_SETLEAF_042`
UNION ALL
SELECT SETCLASS, SETNAME, VALFROM, insert_time, '032' AS system_id FROM `itg-btdpslt-gbl-ww-pd.btdp_ds_c3_eccs_eu_pd.V_SETLEAF_032`
UNION ALL
SELECT SETCLASS, SETNAME, VALFROM, insert_time, '053' AS system_id FROM `itg-btdpslt-gbl-ww-pd.btdp_ds_c3_eccs_eu_pd.V_SETLEAF_053`
UNION ALL
SELECT SETCLASS, SETNAME, VALFROM, insert_time, '008' AS system_id FROM `itg-btdpslt-gbl-ww-pd.btdp_ds_c3_eccs_eu_pd.V_SETLEAF_008`
UNION ALL
SELECT SETCLASS, SETNAME, VALFROM, insert_time, '011' AS system_id FROM `itg-btdpslt-gbl-ww-pd.btdp_ds_c3_eccs_eu_pd.V_SETLEAF_011`
UNION ALL
SELECT SETCLASS, SETNAME, VALFROM, insert_time, '056' AS system_id FROM `itg-btdpslt-gbl-ww-pd.btdp_ds_c3_eccs_eu_pd.V_SETLEAF_056`
UNION ALL
SELECT SETCLASS, SETNAME, VALFROM, insert_time, '007' AS system_id FROM `itg-btdpslt-gbl-ww-pd.btdp_ds_c3_eccs_eu_pd.V_SETLEAF_007`
UNION ALL
SELECT SETCLASS, SETNAME, VALFROM, insert_time, '002' AS system_id FROM `itg-btdpslt-gbl-ww-pd.btdp_ds_c3_eccs_eu_pd.V_SETLEAF_002`
UNION ALL
SELECT SETCLASS, SETNAME, VALFROM, insert_time, '018' AS system_id FROM `itg-btdpslt-gbl-ww-pd.btdp_ds_c3_eccs_eu_pd.V_SETLEAF_018`
UNION ALL
SELECT SETCLASS, SETNAME, VALFROM, insert_time, '073' AS system_id FROM `itg-btdpslt-gbl-ww-pd.btdp_ds_c3_eccs_eu_pd.V_SETLEAF_073`
UNION ALL
SELECT SETCLASS, SETNAME, VALFROM, insert_time, '701' AS system_id FROM `itg-btdpslt-gbl-ww-pd.btdp_ds_c3_neos_eu_pd.V_SETLEAF_701`
UNION ALL
SELECT SETCLASS, SETNAME, VALFROM, insert_time, '702' AS system_id FROM `itg-btdpslt-gbl-ww-pd.btdp_ds_c3_neos_eu_pd.V_SETLEAF_702`
UNION ALL
SELECT SETCLASS, SETNAME, VALFROM, insert_time, '703' AS system_id FROM `itg-btdpslt-gbl-ww-pd.btdp_ds_c3_neos_eu_pd.V_SETLEAF_703`
UNION ALL
SELECT SETCLASS, SETNAME, VALFROM, insert_time, '704' AS system_id FROM `itg-btdpslt-gbl-ww-pd.btdp_ds_c3_neos_eu_pd.V_SETLEAF_704`
),
setleaf_dedup AS (
  SELECT DISTINCT SETNAME, VALFROM, system_id, insert_time
  FROM combined_setleaf
  WHERE SETCLASS = '0101'
    AND (SETNAME LIKE 'CU%' OR SETNAME LIKE 'BO%')
    AND REGEXP_CONTAINS(SETNAME, r'^(CU|BO)[0-9]+$')
  QUALIFY ROW_NUMBER() OVER (
    PARTITION BY VALFROM, system_id
    ORDER BY insert_time DESC
  ) = 1
),
cc AS(
SELECT
  source_system,
  system_id,
  cost_center_code,
  cost_center_description,
  profit_center_code,
  insert_timestamp,
  company_code,
  business_area_code,
  standard_group,
FROM `itg-btdppublished-gbl-ww-pd.btdp_ds_c1_101_finance_masterdata_eu_pd.costcenter_v1`
WHERE valid_to > current_date()
AND source_system IS DISTINCT FROM 'WISE'
QUALIFY ROW_NUMBER() OVER(
  PARTITION BY cost_center_code
  ORDER BY insert_timestamp DESC
) = 1
),
local_cost_dim_mapp_ecc AS(
SELECT
  cc.source_system,
  cc.system_id,
  cc.cost_center_code AS local_cost_center_code,
  cc.cost_center_description AS local_cost_center_description,
  COALESCE(gcc1.group_costs_center_code, gcc2.group_costs_center_hierarchy_1_code, gcc3.group_costs_center_hierarchy_2_code) as group_cost_center_code,
  COALESCE(gcc1.group_cost_center, gcc2.group_costs_center_hierarchy_1, gcc3.group_costs_center_hierarchy_2) as group_cost_center_description,
  setleaf_dedup.SETNAME AS customer_boutique_code,
  cust.customer AS customer_boutique_description,
  cc.profit_center_code,
  pf.profit_center_long_description AS profit_center_description,
  bu.compass_business_unit AS business_unit_code, 
  bu_dim.business_unit_long_description AS business_unit_description, 
  COALESCE(gcc1.pnl_line_code, gcc2.pnl_line_code, gcc3.pnl_line_code) as pnl_line_code,
  pl_cost.VALUE AS pnl_line_description,
  cc.insert_timestamp
FROM cc
LEFT JOIN `itg-btdppublished-gbl-ww-pd.btdp_ds_c1_108_organizationalstructure_eu_pd.mapping_bu_v1` bu
ON cc.profit_center_code = bu.profit_center
AND cc.company_code = bu.company_code
AND cc.business_area_code = bu.business_area
AND bu.active_flag = 'Y'
LEFT JOIN `itg-btdppublished-gbl-ww-pd.btdp_ds_c1_101_finance_masterdata_eu_pd.profitcenter_v1` pf
ON cc.profit_center_code = pf.profit_center_code
LEFT JOIN gcc1
ON cc.standard_group = gcc1.group_costs_center_code 
LEFT JOIN gcc2
ON cc.standard_group = gcc2.group_costs_center_hierarchy_1_code 
LEFT JOIN gcc3
ON cc.standard_group = gcc3.group_costs_center_hierarchy_2_code 
LEFT JOIN `itg-btdppublished-gbl-ww-pd.btdp_ds_c1_108_organizationalstructure_eu_pd.bu_dimension_v1` bu_dim 
ON bu.compass_business_unit = bu_dim.business_unit_code
LEFT JOIN setleaf_dedup
ON cc.cost_center_code = setleaf_dedup.VALFROM
AND cc.system_id = setleaf_dedup.system_id
LEFT JOIN `itg-btdppublished-gbl-ww-pd.btdp_ds_c1_101_finance_masterdata_eu_pd.customer_dimension_v1`  cust 
ON setleaf_dedup.SETNAME = cust.customer_code
LEFT JOIN `itg-btdppublished-gbl-ww-pd.btdp_ds_c1_101_finance_masterdata_eu_pd.PL_COST_ATTR` pl_cost 
ON COALESCE(gcc1.pnl_line_code, gcc2.pnl_line_code, gcc3.pnl_line_code) = pl_cost.ELEMENT
AND ATTRIBUTE = 'EN SHORT'
WHERE COALESCE(gcc1.pnl_line_code, gcc2.pnl_line_code, gcc3.pnl_line_code) IS NOT NULL
AND cc.source_system = 'ECC'
),
local_cost_dim_mapp_neo AS(
SELECT 
  cc.source_system,
  cc.system_id,
  cc.cost_center_code AS local_cost_center_code,
  cc.cost_center_description AS local_cost_center_description,
  COALESCE(gcc1.group_costs_center_code, gcc2.group_costs_center_hierarchy_1_code, gcc3.group_costs_center_hierarchy_2_code) as group_cost_center_code,
  COALESCE(gcc1.group_cost_center, gcc2.group_costs_center_hierarchy_1, gcc3.group_costs_center_hierarchy_2) as group_cost_center_description,
  setleaf_dedup.SETNAME AS customer_boutique_code,
  cust.customer AS customer_boutique_description,
  cc.profit_center_code,
  pf.profit_center_long_description AS profit_center_description,
  pf.business_unit_code, 
  bu_dim.business_unit_long_description AS business_unit_description, 
  COALESCE(gcc1.pnl_line_code, gcc2.pnl_line_code, gcc3.pnl_line_code) as pnl_line_code,
  pl_cost.VALUE AS pnl_line_description,
  cc.insert_timestamp
FROM cc
LEFT JOIN `itg-btdppublished-gbl-ww-pd.btdp_ds_c1_108_organizationalstructure_eu_pd.mapping_bu_v1` bu
ON cc.profit_center_code = bu.profit_center
AND cc.company_code = bu.company_code
AND cc.business_area_code = bu.business_area
AND bu.active_flag = 'Y'
LEFT JOIN `itg-btdppublished-gbl-ww-pd.btdp_ds_c1_101_finance_masterdata_eu_pd.profitcenter_v1` pf
ON cc.profit_center_code = pf.profit_center_code
LEFT JOIN gcc1
ON cc.standard_group = gcc1.group_costs_center_code 
LEFT JOIN gcc2
ON cc.standard_group = gcc2.group_costs_center_hierarchy_1_code 
LEFT JOIN gcc3
ON cc.standard_group = gcc3.group_costs_center_hierarchy_2_code 
LEFT JOIN `itg-btdppublished-gbl-ww-pd.btdp_ds_c1_108_organizationalstructure_eu_pd.bu_dimension_v1` bu_dim 
ON pf.business_unit_code = bu_dim.business_unit_code
LEFT JOIN setleaf_dedup
ON cc.cost_center_code = setleaf_dedup.VALFROM
LEFT JOIN `itg-btdppublished-gbl-ww-pd.btdp_ds_c1_101_finance_masterdata_eu_pd.customer_dimension_v1`  cust 
ON setleaf_dedup.SETNAME = cust.customer_code
LEFT JOIN `itg-btdppublished-gbl-ww-pd.btdp_ds_c1_101_finance_masterdata_eu_pd.PL_COST_ATTR` pl_cost 
ON COALESCE(gcc1.pnl_line_code, gcc2.pnl_line_code, gcc3.pnl_line_code) = pl_cost.ELEMENT
AND ATTRIBUTE = 'EN SHORT'
WHERE COALESCE(gcc1.pnl_line_code, gcc2.pnl_line_code, gcc3.pnl_line_code) IS NOT NULL
AND cc.source_system = 'NEO'
),
union_cte AS(
SELECT * FROM local_cost_dim_mapp_ecc
UNION ALL
SELECT * FROM local_cost_dim_mapp_neo
)
SELECT * from union_cte 
