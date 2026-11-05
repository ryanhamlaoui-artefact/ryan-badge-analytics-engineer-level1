DECLARE p_material STRING DEFAULT 'P0724400';
DECLARE p_system   STRING DEFAULT '002';
DECLARE p_run_ts   TIMESTAMP DEFAULT TIMESTAMP('2026-10-07 14:30:57 UTC');
 
CREATE TEMP TABLE old_value AS
SELECT distinct product_code, source_system, system_id, product_description, insert_timestamp
FROM `itg-btdpfront-gbl-ww-np.btdp_ds_c1_201_productdefinition_eu_np.tech_product_hierarchy_v1_harmonized`
FOR SYSTEM_TIME AS OF p_run_ts
WHERE product_code = p_material AND (system_id = p_system OR system_id IS NULL);
 
SELECT 'old value' AS snapshot, * FROM old_value
UNION ALL
SELECT distinct 'current value', product_code, source_system, system_id, product_description, insert_timestamp
FROM `itg-btdpfront-gbl-ww-np.btdp_ds_c1_201_productdefinition_eu_np.tech_product_hierarchy_v1_harmonized`
WHERE product_code = p_material AND (system_id = p_system OR system_id IS NULL)
ORDER BY snapshot DESC, source_system, system_id;
 