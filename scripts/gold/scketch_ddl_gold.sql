-- =================================================================================
-- 								Dimension: Customer
-- =================================================================================

-- To customers big table, we create a big Join
-- Select a master table (crm_cust_info) and Lefting with others tables related by customers
SELECT
	ci.cst_id,
	ci.cst_key,
	ci.cst_firstname,
	ci.cst_lastname,
	ci.cst_marital_status,
	ci.cst_gndr,
	ci.cst_create_date,
	ci.dwh_create_date,
	ca.bdate, 
	ca.gen,
	la.cntry
FROM
	DataWareHouse.silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON 		ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid


-- maybe we can found duplicates, so its indicates that we have relations many to many 
-- TIP: After Joining table, check if any duplicates were introduced by the join logic
-- query to check this
-- Expectation: No duplicates
SELECT cst_id, COUNT(*) FROM
(SELECT
	ci.cst_id,
	ci.cst_key,
	ci.cst_firstname,
	ci.cst_lastname,
	ci.cst_marital_status,
	ci.cst_gndr,
	ci.cst_create_date,
	ci.dwh_create_date,
	ca.bdate, 
	ca.gen,
	la.cntry
FROM
	DataWareHouse.silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON 		ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid)t
GROUP BY cst_id
HAVING COUNT(*) > 1
-- Reality: No duplicates 🤙🏽

-- We can see that we have ci.cst_gndr and ca.gen
-- we need to check that its presents the same result
SELECT DISTINCT
	ci.cst_gndr,
	ca.gen,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the master for gender info (data integration)
		ELSE COALESCE(ca.gen, 'n/a')
	END AS new_gen
FROM
	DataWareHouse.silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON 		ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid
ORDER BY 1,2 


SELECT
	ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key as customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name,
	la.cntry AS country,
	ci.cst_marital_status AS marital_status,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the master for gender info (data integration)
		ELSE COALESCE(ca.gen, 'n/a')
	END AS gender,
	ca.bdate AS birthdate,
	ci.cst_create_date AS create_date
FROM
	DataWareHouse.silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON 		ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid

-- Dimension vs Fact?
-- Descritive vs quantitative
-- surrogate key = customer_key in this case


-- So, lets create a view using this query to gold layer
CREATE VIEW gold.dim_customers AS 
SELECT
	ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key as customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name,
	la.cntry AS country,
	ci.cst_marital_status AS marital_status,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the master for gender info (data integration)
		ELSE COALESCE(ca.gen, 'n/a')
	END AS gender,
	ca.bdate AS birthdate,
	ci.cst_create_date AS create_date
FROM
	DataWareHouse.silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON 		ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid

-- Check
SELECT DISTINCT gender FROM gold.dim_customers


-- =================================================================================
-- 								Dimension: Product
-- =================================================================================

-- Master of products is crm_prd_info
SELECT
	pn.prd_id,
	pn.cat_id,
	pn.prd_key,
	pn.prd_nm,
	pn.prd_cost,
	pn.prd_line,
	pn.prd_start_dt,
	pc.cat,
	pc.subcat,
	pc.maintenance 
FROM DataWareHouse.silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL			--Filter out all historical data

-- check duplicates
SELECT prd_key, COUNT(*) FROM (
SELECT
	pn.prd_id,
	pn.cat_id,
	pn.prd_key,
	pn.prd_nm,
	pn.prd_cost,
	pn.prd_line,
	pn.prd_start_dt,
	pc.cat,
	pc.subcat,
	pc.maintenance 
FROM DataWareHouse.silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL			-- Filter out all historical data
)t GROUP BY prd_key 
HAVING COUNT(*) > 1				-- we dont have any duplicates


-- Sort the columns into logical groups to improve readability
SELECT
	pn.prd_id,
	pn.prd_key,
	pn.prd_nm,
	pn.cat_id,
	pc.cat,
	pc.subcat,
	pc.maintenance,
	pn.prd_cost,
	pn.prd_line,
	pn.prd_start_dt 
FROM DataWareHouse.silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL


-- Rename columns to friendly, meaningful names
SELECT
	pn.prd_id AS product_id,
	pn.prd_key AS product_number,
	pn.prd_nm AS product_name,
	pn.cat_id AS category_id,
	pc.cat AS category,
	pc.subcat AS subcategory,
	pc.maintenance,
	pn.prd_cost AS cost,
	pn.prd_line AS product_line,
	pn.prd_start_dt AS start_date
FROM DataWareHouse.silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL


-- Then, create a primary key
SELECT
	ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
	pn.prd_id AS product_id,
	pn.prd_key AS product_number,
	pn.prd_nm AS product_name,
	pn.cat_id AS category_id,
	pc.cat AS category,
	pc.subcat AS subcategory,
	pc.maintenance,
	pn.prd_cost AS cost,
	pn.prd_line AS product_line,
	pn.prd_start_dt AS start_date
FROM DataWareHouse.silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL

-- So, lets create the view
CREATE VIEW gold.dim_products AS
SELECT
	ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
	pn.prd_id AS product_id,
	pn.prd_key AS product_number,
	pn.prd_nm AS product_name,
	pn.cat_id AS category_id,
	pc.cat AS category,
	pc.subcat AS subcategory,
	pc.maintenance,
	pn.prd_cost AS cost,
	pn.prd_line AS product_line,
	pn.prd_start_dt AS start_date
FROM DataWareHouse.silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL


-- now lets check
SELECT * FROM gold.dim_products



-- =================================================================================
-- 								Fact: sales
-- =================================================================================
-- all informations
SELECT
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price,
	dwh_create_date
FROM
	DataWareHouse.silver.crm_sales_details;

-- take sls_prd_key and sls_cust_id and build a fact
-- Use the dimension's surrogate keys instead of IDs to easily connect facts with dimensions
SELECT
	sd.sls_ord_num,
	pr.product_key, 			-- two keys by dimensions
	cs.customer_key,
	sd.sls_prd_key,
	sd.sls_cust_id,
	sd.sls_order_dt,
	sd.sls_ship_dt,
	sd.sls_due_dt,
	sd.sls_sales,
	sd.sls_quantity,
	sd.sls_price,
	sd.dwh_create_date
FROM DataWareHouse.silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
ON sd.sls_prd_key = pr.product_number 
LEFT JOIN gold.dim_customers cs
ON sd.sls_cust_id = cs.customer_id 

-- Rename columns to friendly names
SELECT
	sd.sls_ord_num AS order_number,
	pr.product_key, 			-- two keys by dimensions
	cs.customer_key,
	sd.sls_order_dt AS order_date,
	sd.sls_ship_dt AS shipping_date,
	sd.sls_due_dt AS due_date,
	sd.sls_sales AS sales_amount,
	sd.sls_quantity AS quantity,
	sd.sls_price AS price
FROM DataWareHouse.silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
ON sd.sls_prd_key = pr.product_number 
LEFT JOIN gold.dim_customers cs
ON sd.sls_cust_id = cs.customer_id 


-- now we have in order: dimension keys; dates; measures

-- lets create a view
CREATE VIEW gold.fact_sales AS
SELECT
	sd.sls_ord_num AS order_number,
	pr.product_key, 			-- two keys by dimensions
	cs.customer_key,
	sd.sls_order_dt AS order_date,
	sd.sls_ship_dt AS shipping_date,
	sd.sls_due_dt AS due_date,
	sd.sls_sales AS sales_amount,
	sd.sls_quantity AS quantity,
	sd.sls_price AS price
FROM DataWareHouse.silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
ON sd.sls_prd_key = pr.product_number 
LEFT JOIN gold.dim_customers cs
ON sd.sls_cust_id = cs.customer_id 

-- check
SELECT * FROM gold.fact_sales









