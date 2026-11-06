WITH product_dedup_elix AS (
  SELECT 
    product_code,
    product_gtin,
    axe_code,
    sub_axe_code,
    brand_code,
    sub_brand_code,
    compass_code,
    group_division,
    signature_code,
    neo_hierarchy_code
  FROM `itg-btdppublished-gbl-ww-pd.btdp_ds_c1_201_productdefinition_eu_pd.product_hierarchy_harmonized_v1`
  WHERE source_system = 'ELIXPEDIA'
  GROUP BY ALL
),
product_dedup_neo AS (
  SELECT 
    product_code,
    system_id,
    product_gtin,
    axe_code,
    sub_axe_code,
    brand_code,
    sub_brand_code,
    compass_code,
    group_division,
    signature_code,
    neo_hierarchy_code
  FROM `itg-btdppublished-gbl-ww-pd.btdp_ds_c1_201_productdefinition_eu_pd.product_hierarchy_harmonized_v1`
  WHERE source_system = 'NEO'
  GROUP BY ALL
)

SELECT 
  a.actual_turnover_cascading_unique_id,
  a.material_code,
  a.system_id,

  CAST(COALESCE(h1.product_gtin, h2.product_gtin, h3.product_gtin) AS INT64) AS ean_code,
  COALESCE(h1.axe_code, h2.axe_code, h3.axe_code) AS axis_code,
  COALESCE(h1.sub_axe_code, h2.sub_axe_code, h3.sub_axe_code) AS sub_axis_code,
  COALESCE(h1.brand_code, h2.brand_code, h3.brand_code) AS brand_code,
  COALESCE(h1.sub_brand_code, h2.sub_brand_code, h3.sub_brand_code) AS sub_brand_code,
  COALESCE(h1.compass_code, h2.compass_code, h3.compass_code) AS compass_product_code,
  COALESCE(h1.group_division, h2.group_division, h3.group_division) AS group_division,
  COALESCE(h1.signature_code, h2.signature_code, h3.signature_code) AS signature_code

FROM `itg-btdpfront-gbl-ww-np.btdp_ds_c3_109_gross_to_net_eu_np_private.tech_actual_turnover_cascading_v2_neo` a 
LEFT JOIN product_dedup_elix h1
  ON LTRIM(a.material_code,'0') = LTRIM(h1.product_code,'0') 
LEFT JOIN product_dedup_neo h2
  ON LTRIM(a.material_code,'0') = LTRIM(h2.product_code,'0') 
  AND a.system_id = h2.system_id
LEFT JOIN product_dedup_neo h3
  ON LTRIM(a.material_code,'0') = LTRIM(h3.product_code,'0') 
  AND h3.system_id IS NULL

WHERE a.posting_date BETWEEN '2026-01-01' AND '2026-03-31'
  AND a.source_system = 'NEO'
  and a.system_id = '701'

