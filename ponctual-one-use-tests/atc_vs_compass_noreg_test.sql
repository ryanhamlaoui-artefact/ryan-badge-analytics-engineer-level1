
/** Objective of the query : 
    - Analyse gaps between ATC & Compass extracted table
    - Compass is a controlling tool & should be source of truth for ATC
    - Scope : 2025 - SAPMENA region + Japan Cluster - CNS and child pl lines
    - Grain : Cluster + pl_line + period
        - Uncomment bu & multidiv filter to check at lower grain
    - FULL OUTER JOIN to identify :
        - PL lines allocation mapping issue -> 
            - ROOT level match but we have unmatched leaves under the hierarchy (R15000AA gap = 0)
            - some lines on leaf level are null on left or right side
            - the gaps are matching between leaves (ex : R13422AA gap = -1200 & R13205AB gap = 1200)
        - Replication issue ->
            - gap is the same at ROOT, NODE & LEAF level 
            - check at bu grain -> some BU can lack on ATC side
**/
WITH 
v2 AS (
  SELECT
    CASE 
      WHEN EXTRACT(month from posting_date) < 10 THEN CONCAT('M0',EXTRACT(month from posting_date))
      ELSE CONCAT('M',EXTRACT(month from posting_date))
    END AS period,
    pl_line_code,
    pl_line,
    atc.multidivision_region,
    atc.multidivision_cluster,
    -- atc.business_unit_code,
    atc.multidivision_region_code, 
    atc.multidivision_cluster_code,
    atc.system_id,
    SUM(value_in_local_currency) AS twwt_v2
  FROM `itg-btdpfront-gbl-ww-pd.btdp_ds_c3_109_gross_to_net_eu_pd.actual_turnover_cascading_v2` atc
  INNER JOIN (
  SELECT business_unit_code FROM `itg-btdpfront-gbl-ww-pd.btdp_ds_c1_108_organizationalstructure_eu_pd.bu_dimension_v1`
  WHERE am_nam_code = 'YAM') bu
  ON atc.business_unit_code = bu.business_unit_code
  WHERE atc.posting_date BETWEEN '2025-01-01' AND '2025-12-31'
    AND (
      atc.pl_line_code IN (
'R13120BA', 'R13130BA', 'R13421AA', 'R13422AA', 'R13120GA', 'R15100AA', 'R13440AA', 'R13151LA', 'R13130GA', 'R13130LA', 'R13120LA', 'R13120FB', 'R15110EA', 'R13661AA', 'R15110JA', 'R13611AA', 'R13120AB', 'R15110LA', 'R13130VA', 'R15110HA', 'R13620AA', 'R15110GB', 'R13641AA', 'R15110BA', 'R15110KA', 'R13651AA', 'R15110GC', 'R13630AA', 'R15110IA', 'R13671AA', 'R13672AA', 'R13680AA', 'R15110MA', 'R13151BA', 'R13152GA', 'R13721AA', 'R13722AA', 'R13151PB', 'R13151PC', 'R15120FA', 'R13152QA', 'R15120HA', 'R13120PC', 'R15130LA', 'R13205AC', 'R12110AA', 'R13205AE', 'R12210AA', 'R13205AB', 'R13210AA', 'R15140JA', 'R15140LA', 'R15140NA', 'R13220EA', 'R13220BA', 'R13220CA', 'R15140MA', 'R15140BA', 'R13205AD', 'R15110CA', 'R13820AA', 'R13810AA', 'R13000AA', 'R00100AA', 'R15000AA', 'R017000AA', 'R016000AA', 'R13100AA')
    OR
      atc.pl_line_code IN (SELECT DISTINCT LEAF FROM `itg-btdpfront-gbl-ww-pd.btdp_ds_c1_101_finance_masterdata_eu_pd.PL_PRODUCT_H_HIERARCHY` WHERE HIERARCHY = 'R15000AA')
    )
    AND atc.is_deleted IS FALSE
    AND (multidivision_region = 'SAPMENA' OR multidivision_cluster = 'Japan')
    -- AND multidivision_cluster = ''
  GROUP BY period, multidivision_region, pl_line_code, pl_line, multidivision_region_code, multidivision_cluster_code, system_id, multidivision_cluster
), -- ATC_v2 latest version of the GCP tables that I want to analyse its quality

c AS (
  SELECT
    pnl_product_code,
    pnl_product,
    period,
    multidivision_region,
    multidivision_cluster,
    -- business_unit_code,
    multidivision_region_code, 
    multidivision_cluster_code,
    SUM(
      value_local *
      CASE
        WHEN LOWER(TRIM(currency_factor)) LIKE 'k%' THEN 1000
        WHEN LOWER(TRIM(currency_factor)) LIKE 'm%' THEN 1000000
        ELSE 1 
      END
    ) AS compass_value
  FROM `itg-btdpfront-gbl-ww-pd.btdp_ds_c3_103_pnl_by_product_eu_pd_private.pnl_by_product_actual_official_2025_aggregated_v1`
  WHERE (
      pnl_product_code IN (
'R13120BA', 'R13130BA', 'R13421AA', 'R13422AA', 'R13120GA', 'R15100AA', 'R13440AA', 'R13151LA', 'R13130GA', 'R13130LA', 'R13120LA', 'R13120FB', 'R15110EA', 'R13661AA', 'R15110JA', 'R13611AA', 'R13120AB', 'R15110LA', 'R13130VA', 'R15110HA', 'R13620AA', 'R15110GB', 'R13641AA', 'R15110BA', 'R15110KA', 'R13651AA', 'R15110GC', 'R13630AA', 'R15110IA', 'R13671AA', 'R13672AA', 'R13680AA', 'R15110MA', 'R13151BA', 'R13152GA', 'R13721AA', 'R13722AA', 'R13151PB', 'R13151PC', 'R15120FA', 'R13152QA', 'R15120HA', 'R13120PC', 'R15130LA', 'R13205AC', 'R12110AA', 'R13205AE', 'R12210AA', 'R13205AB', 'R13210AA', 'R15140JA', 'R15140LA', 'R15140NA', 'R13220EA', 'R13220BA', 'R13220CA', 'R15140MA', 'R15140BA', 'R13205AD', 'R15110CA', 'R13820AA', 'R13810AA', 'R13000AA', 'R00100AA', 'R15000AA', 'R017000AA', 'R016000AA', 'R13100AA')
    OR 
      pnl_product_code IN (SELECT DISTINCT LEAF FROM `itg-btdpfront-gbl-ww-pd.btdp_ds_c1_101_finance_masterdata_eu_pd.PL_PRODUCT_H_HIERARCHY` WHERE HIERARCHY = 'R15000AA')
    )
    AND period IN ('M01','M02','M03','M04','M05','M06','M07','M08','M09', 'M10','M11','M12')
    AND (multidivision_region = 'SAPMENA' OR multidivision_cluster = 'Japan')
    -- AND multidivision_cluster = ''
  GROUP BY multidivision_cluster, period, multidivision_region, pnl_product_code, pnl_product, multidivision_region_code, multidivision_cluster_code
) -- Compass source of truth

SELECT DISTINCT 
c.multidivision_cluster_code as compass_multidivision_cluster_code,
c.multidivision_cluster as compass_multidivision_cluster,
c.pnl_product_code as compass_pnl_product_code,
c.pnl_product as compass_pnl_product,
-- c.business_unit_code as compass_business_unit_code,
c.period as compass_period,
c.compass_value AS compass,

v2.multidivision_cluster_code as atc_multidivision_cluster_code,
v2.multidivision_cluster as atc_multidivision_cluster,
v2.pl_line_code as atc_pl_line_code,
v2.pl_line as atc_pl_line,
-- v2.business_unit_code as atc_business_unit_code,
v2.system_id,
v2.period as atc_period,
v2.twwt_v2,

COALESCE(c.compass_value, 0) - COALESCE(v2.twwt_v2, 0) AS gap,

  CASE 
    WHEN COALESCE(c.pnl_product_code,v2.pl_line_code) = 'R15000AA' THEN 'ROOT'
    WHEN  COALESCE(c.pnl_product_code,v2.pl_line_code) IN('R016000AA','R017000AA','R13000AA','R13100AA') THEN 'NODE'
    ELSE 'LEAF'
  END AS pl_line_level

FROM c
FULL OUTER JOIN v2 
ON v2.multidivision_cluster_code = c.multidivision_cluster_code
AND v2.pl_line_code = c.pnl_product_code
-- AND v2.business_unit_code = c.business_unit_code
AND c.period = v2.period

ORDER BY 
  c.multidivision_cluster,
  c.pnl_product_code,
  -- c.business_unit_code,
  c.period;