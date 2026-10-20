-- SILVER LAYER
-- FIRST: Explore & understand the data
-- Document all that you understand about each table

-- crm_cust_info
SELECT
	TOP (1000)
	cst_id, 
	cst_key, 
	cst_firstname, 
	cst_lastname, 
	cst_marital_status, 
	cst_gndr, 
	cst_create_date
FROM
	DataWareHouse.bronze.crm_cust_info;

-- crm_prd_info
SELECT
	TOP (1000)
	prd_id,
	prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
FROM
	DataWareHouse.bronze.crm_prd_info;


-- From analysis:
-- The same product but costs (prd_cost) different:
-- "212|AC-HE-HL-U509-R |Sport-100 Helmet- Red         |      12|S       |2011-07-01 00:00:00.00
--  213|AC-HE-HL-U509-R |Sport-100 Helmet- Red         |      14|S       |2012-07-01 00:00:00.00
--  214|AC-HE-HL-U509-R |Sport-100 Helmet- Red         |      13|S       |2013-07-01 00:00:00.00"
-- So, this table shows current and history product informations


-- crm_sales_details
SELECT
	TOP (1000) sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
FROM
	DataWareHouse.bronze.crm_sales_details;

-- From analysis:
-- Can be used to connect with other tables
-- examples: sls_prd_key and sls_cust_id


-- ERP
-- erp_cust_az12
SELECT
	TOP 1000 cid,
	bdate,
	gen
FROM
	DataWareHouse.bronze.erp_cust_az12;

-- From analysis:
-- Cid is correlated with crm_cust_info.cst_key
-- so this table is only extra details about customers


-- erp_loc_a101
SELECT
	TOP 1000 cid,
	cntry
FROM
	DataWareHouse.bronze.erp_loc_a101;

-- From analysis:
-- Cid is correlated with crm_cust_info.cst_key
-- so this table is only extra details about customers

-- erp_px_cat_g1v2
SELECT
	TOP 1000 id,
	cat,
	subcat,
	maintenance
FROM
	DataWareHouse.bronze.erp_px_cat_g1v2;

-- From analysis:
-- This table union product categories
-- and this table is related to crm_prd_info
-- the erp_px_cat_g1v2.id is correlated to crm_prd_info.prd_key (but only the first part of key)


