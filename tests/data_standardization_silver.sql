-- QUALITY CHECK AND DATA CLEANSING

-- =================================================================================
-- 									crm_cust_info
-- =================================================================================


-- =================================================================================
-- 						QUALITY CHECK OF THE SILVER TABLE
-- =================================================================================
-- Check for Nulls or Duplicates in Primary Key
-- Expectation: No result
SELECT
	cst_id,
	COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL
-- Reality: WE HAVE DUPLICATES!
-- AND one ID empty with duplicates 😳!!!!

-- Lets Clean
SELECT 
*
FROM bronze.crm_cust_info
WHERE cst_id = 29466

--"
--cst_id|cst_key   |cst_firstname|cst_lastname|cst_marital_status|cst_gndr|cst_create_date|
--------+----------+-------------+------------+------------------+--------+---------------+
-- 29466|AW00029466|             |            |                  |        |     2026-01-25|
-- 29466|AW00029466|Lance        |Jimenez     |M                 |        |     2026-01-26|
-- 29466|AW00029466|Lance        |Jimenez     |M                 |M       |     2026-01-27|"

-- So, we can take the latest register (fresh value) to use with only one for this duplicate
SELECT *
FROM (
	SELECT *,
		ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last		-- take only the last to do a one 
	FROM bronze.crm_cust_info
)t WHERE flag_last = 1		-- only with duplicates


-- Quality check
-- Check for unwanted spaces
-- Expectation: No results
SELECT cst_gndr
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)
-- Reality: WE HAVE UNWANTED SPACES  😳!!!!!!

-- Convert
SELECT
cst_id,
cst_key,
TRIM(cst_firstname) AS cst_firstname,
TRIM(cst_lastname) AS cst_lastname,
cst_marital_status,
cst_gndr,
cst_create_date
FROM ( 
	SELECT *,
		ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last		-- take only the last to do a one 
	FROM bronze.crm_cust_info
	WHERE cst_id IS NOT NULL
)t WHERE flag_last = 1



-- Now, check data standardization & consistency (cst_marital_status & cst_gndr)
-- Expectation: No result
SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info
-- Reality: WE HAVE NULLS TOO 😳!!!!

-- Convert
SELECT
cst_id,
cst_key,
TRIM(cst_firstname) AS cst_firstname,
TRIM(cst_lastname) AS cst_lastname,
cst_marital_status,
CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
	 WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
	 ELSE 'n/a'
END cst_gndr,
cst_create_date
FROM ( 
	SELECT *,
		ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last		-- take only the last to do a one 
	FROM bronze.crm_cust_info
	WHERE cst_id IS NOT NULL
)t WHERE flag_last = 1

-- The same verification we can apply to marital status
-- Expectation: No result
SELECT DISTINCT cst_marital_status
FROM bronze.crm_cust_info
-- Reality: WE HAVE NULLS TOO 😳!!!!

-- Convert
SELECT
cst_id,
cst_key,
TRIM(cst_firstname) AS cst_firstname,
TRIM(cst_lastname) AS cst_lastname,
CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
	 WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Maried'
	 ELSE 'n/a'
END cst_marital_status,
CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
	 WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
	 ELSE 'n/a'
END cst_gndr,
cst_create_date
FROM ( 
	SELECT *,
		ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last		-- take only the last to do a one 
	FROM bronze.crm_cust_info
	WHERE cst_id IS NOT NULL
)t WHERE flag_last = 1


-- Lets insert into silver layers
INSERT
	INTO
	silver.crm_cust_info (
	cst_id,
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_marital_status,
	cst_gndr,
	cst_create_date)

SELECT
cst_id,
cst_key,
TRIM(cst_firstname) AS cst_firstname,
TRIM(cst_lastname) AS cst_lastname,
CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
	 WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Maried'
	 ELSE 'n/a'
END cst_marital_status,
CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
	 WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
	 ELSE 'n/a'
END cst_gndr,
cst_create_date
FROM ( 
	SELECT *,
		ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last		-- take only the last to do a one 
	FROM bronze.crm_cust_info
	WHERE cst_id IS NOT NULL
)t WHERE flag_last = 1



-- =================================================================================
-- 						QUALITY CHECK OF THE SILVER TABLE
-- =================================================================================
-- Check for Nulls or Duplicates in Primary Key
-- Expectation: No result
SELECT
	cst_id,
	COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL
-- Reality: No result 🤙🏽

-- Check for unwanted spaces
-- Expectation: No results
SELECT cst_gndr
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)
-- Reality: No result 🤙🏽

-- check data standardization & consistency (cst_marital_status & cst_gndr)
-- Expectation: No result
SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info;

SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;
-- Reality: No result 🤙🏽








-- =================================================================================
-- 									crm_prd_info		| Bronze Check
-- =================================================================================

-- All the table in bronze
SELECT prd_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt
FROM DataWareHouse.bronze.crm_prd_info;


-- Check for Nulls or Duplicates in Primary Key
-- Expectation: No result
SELECT 
	prd_id,
	COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL
-- Reality: No result 🤙🏽


-- Create another information 
SELECT
	prd_id,
	prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
FROM
	DataWareHouse.bronze.crm_prd_info;



SELECT
	*
FROM bronze.erp_px_cat_g1v2;

-- so, crm_prd_info.prd_key is the same as erp_px_cat_g1v2.id, but we need to cut crm_prd_info.prd_key
-- So, create a substring cat_id
SELECT
	prd_id,
	prd_key,
	SUBSTRING(prd_key, 1, 5) cat_id,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
FROM
	DataWareHouse.bronze.crm_prd_info;

SELECT DISTINCT id FROM bronze.erp_px_cat_g1v2;
-- but in erp_px_cat_g1v2 we have underscore

-- fix using REPLACE
SELECT
	prd_id,
	prd_key,
	REPLACE(SUBSTRING(prd_key, 1, 5),'-', '_') cat_id,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
FROM
	DataWareHouse.bronze.crm_prd_info
WHERE REPLACE(SUBSTRING(prd_key, 1, 5),'-', '_') NOT IN (SELECT DISTINCT id FROM bronze.erp_px_cat_g1v2);


-- The second part of crm_prd_info.prd_key is correlated to crm_sales_details.sls_prd_key
SELECT
	sls_prd_key
FROM
	DataWareHouse.bronze.crm_sales_details;

-- so...
SELECT
	prd_id,
	prd_key,
	REPLACE(SUBSTRING(prd_key, 1, 5),'-', '_') cat_id,
	SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,				-- second part
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
FROM
	DataWareHouse.bronze.crm_prd_info
WHERE SUBSTRING(prd_key, 7, LEN(prd_key)) NOT IN (SELECT sls_prd_key FROM DataWareHouse.bronze.crm_sales_details);
-- We know now we have a lot of products with any order



-- Check for unwanted spaces in prd_nm
-- Expectation: No results
SELECT
	prd_nm
FROM
	DataWareHouse.bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)
-- Reality: No result 🤙🏽


-- Check for NULLs or Negative numbers
SELECT 
	prd_cost
FROM DataWareHouse.bronze.crm_prd_info
WHERE prd_cost IS NULL OR prd_cost < 0
-- Reality: WE HAVE NULLS 😳!!!! (but any negative number)

-- JUST replace for 0:
SELECT
	prd_id,
	prd_key,
	REPLACE(SUBSTRING(prd_key, 1, 5),'-', '_') cat_id,
	SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
	ISNULL(prd_cost, 0) AS prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
FROM
	DataWareHouse.bronze.crm_prd_info
WHERE prd_cost < 0
-- Reality: No result 🤙🏽


-- check data standardization & consistency (prd_line)
-- Expectation: Organized datas and friendly names
SELECT DISTINCT prd_line
FROM DataWareHouse.bronze.crm_prd_info
-- Reality: WE HAVE NULLS AND THE VALUES ARE NOT FRIENDLY 😳!!!!

-- Replace abreviations for a friendly value
SELECT
	prd_id,
	REPLACE(SUBSTRING(prd_key, 1, 5),'-', '_') cat_id,
	SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
	prd_nm,
	ISNULL(prd_cost, 0) AS prd_cost,
	CASE UPPER(TRIM(prd_line)) 
		WHEN 'M' THEN 'Mountain'
	    WHEN 'R' THEN 'Road'
	    WHEN 'S' THEN 'Other Sales'
	    WHEN 'T' THEN 'Touring'
	    ELSE 'n/a'
	END AS prd_line,
	prd_start_dt,
	prd_end_dt
FROM
	DataWareHouse.bronze.crm_prd_info
-- Reality: No result 🤙🏽


-- Check for Invalid Date Orders
-- Expecation: No one start date should be minor than your end date
SELECT
	prd_start_dt,
	prd_end_dt
FROM
	DataWareHouse.bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt
-- Reality: WE HAVE A FEW START DATES MINOR THAN YOUR END DATE 😳!!!!

-- How can i fix this????
-- End date = start date of the "next" record but -1 day
SELECT
	prd_id,
	prd_key,
	prd_nm,
	prd_start_dt,
	prd_end_dt,
	LEAD(prd_start_dt - 1) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) as prd_end_dt_test
FROM
	DataWareHouse.bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt
-- AWESOME!

-- put inside a main query
SELECT
	prd_id,
	REPLACE(SUBSTRING(prd_key, 1, 5),'-', '_') cat_id,
	SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
	prd_nm,
	ISNULL(prd_cost, 0) AS prd_cost,
	CASE UPPER(TRIM(prd_line)) 
		WHEN 'M' THEN 'Mountain'
	    WHEN 'R' THEN 'Road'
	    WHEN 'S' THEN 'Other Sales'
	    WHEN 'T' THEN 'Touring'
	    ELSE 'n/a'
	END AS prd_line,
	prd_start_dt,
	LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) as prd_end_dt
FROM
	DataWareHouse.bronze.crm_prd_info
-- Reality: No result 🤙🏽

-- Plus: casting date to remove the hours
SELECT
	prd_id,
	REPLACE(SUBSTRING(prd_key, 1, 5),'-', '_') cat_id,
	SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
	prd_nm,
	ISNULL(prd_cost, 0) AS prd_cost,
	CASE UPPER(TRIM(prd_line)) 
		WHEN 'M' THEN 'Mountain'
	    WHEN 'R' THEN 'Road'
	    WHEN 'S' THEN 'Other Sales'
	    WHEN 'T' THEN 'Touring'
	    ELSE 'n/a'
	END AS prd_line,
	CAST(prd_start_dt AS DATE) as prd_start_date,
	CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE) AS prd_end_dt
FROM
	DataWareHouse.bronze.crm_prd_info
-- Reality: Done 🤙🏽
	

-- Lets insert into the silver table now
INSERT INTO silver.crm_prd_info (
	prd_id,
	cat_id,
	prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
)
SELECT
	prd_id,
	REPLACE(SUBSTRING(prd_key, 1, 5),'-', '_') cat_id,
	SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
	prd_nm,
	ISNULL(prd_cost, 0) AS prd_cost,
	CASE UPPER(TRIM(prd_line)) 
		WHEN 'M' THEN 'Mountain'
	    WHEN 'R' THEN 'Road'
	    WHEN 'S' THEN 'Other Sales'
	    WHEN 'T' THEN 'Touring'
	    ELSE 'n/a'
	END AS prd_line,
	CAST(prd_start_dt AS DATE) as prd_start_date,
	CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE) AS prd_end_dt
FROM
	DataWareHouse.bronze.crm_prd_info
	
	
-- =================================================================================
-- 									crm_prd_info		| Silver Check
-- =================================================================================	
	
-- Check for Nulls or Duplicates in Primary Key
-- Expectation: No result
SELECT 
	prd_id,
	COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL
-- Reality: No result 🤙🏽

-- Check for unwanted spaces in prd_nm
-- Expectation: No results
SELECT
	prd_nm
FROM
	DataWareHouse.silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)
-- Reality: No result 🤙🏽

-- Check for NULLs or Negative numbers
SELECT 
	prd_cost
FROM DataWareHouse.silver.crm_prd_info
WHERE prd_cost IS NULL OR prd_cost < 0
-- Reality: No result 🤙🏽

-- check data standardization & consistency (prd_line)
-- Expectation: Organized datas and friendly names
SELECT DISTINCT prd_line
FROM DataWareHouse.silver.crm_prd_info
-- Reality: Organized datas and friendly names 🤙🏽

-- Check for Invalid Date Orders
-- Expecation: No one start date should be minor than your end date
SELECT
	prd_start_dt,
	prd_end_dt
FROM
	DataWareHouse.silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt
-- Reality: No one start date should be minor than your end date 🤙🏽

	
-- =================================================================================
-- 				crm_sales_details		| Bronze Check
-- =================================================================================

-- All table in bronze layer
SELECT sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price
FROM DataWareHouse.bronze.crm_sales_details;	

-- crm_sales_details.sls_prd_key is correlated to crm_prd_info.prd_key

SELECT prd_id, cat_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt, dwh_create_date
FROM DataWareHouse.silver.crm_prd_info;


-- crm_sales_details.sls_cust_id is correlated to crm_cust_info.cst_id
SELECT cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date
FROM DataWareHouse.bronze.crm_cust_info;

-- lets check the integrity of the values
SELECT
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
FROM
	DataWareHouse.bronze.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info);

SELECT
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
FROM
	DataWareHouse.bronze.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info);
-- We dont have any issues

-- Check for invalid dates
-- Expectation: No result 
SELECT
	NULLIF(sls_order_dt, 0) sls_order_dt
FROM
	DataWareHouse.bronze.crm_sales_details
WHERE sls_order_dt <= 0
-- Reality: many dates = 0 (same NULL) 😳!!!!

-- In this scenario, the length of the date must be 8 (varchar)
SELECT
	NULLIF(sls_order_dt, 0) sls_order_dt
FROM
	DataWareHouse.bronze.crm_sales_details
WHERE sls_order_dt <= 0 OR LEN(sls_order_dt) != 8
-- We have dates < 8

-- Check for outliers
SELECT
	NULLIF(sls_order_dt, 0) sls_order_dt
FROM
	DataWareHouse.bronze.crm_sales_details
WHERE
	sls_order_dt <= 0
	OR LEN(sls_order_dt) != 8
	OR sls_order_dt > 20500101
	OR sls_order_dt < 19000101
	
-- lets add some cases to sls_order_dt
SELECT
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_order_dt AS VARCHAR)AS DATE)
	END AS sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
FROM
	DataWareHouse.bronze.crm_sales_details;
	
-- okay, but we can check sls_ship_date too and sls_due_dt:
-- Expectation: No results
SELECT
	NULLIF(sls_ship_dt, 0) sls_ship_dt
FROM
	DataWareHouse.bronze.crm_sales_details
WHERE
	sls_ship_dt <= 0
	OR LEN(sls_ship_dt) != 8
	OR sls_ship_dt > 20500101
	OR sls_ship_dt < 19000101
-- Reality: No results 🤙🏽
	
-- Expectation: No results
SELECT
	NULLIF(sls_due_dt, 0) sls_due_dt
FROM
	DataWareHouse.bronze.crm_sales_details
WHERE
	sls_due_dt <= 0
	OR LEN(sls_due_dt) != 8
	OR sls_due_dt > 20500101
	OR sls_due_dt < 19000101
-- Reality: No results 🤙🏽
	
-- organize all the dates
SELECT
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_order_dt AS VARCHAR)AS DATE)
	END AS sls_order_dt,
	CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_ship_dt AS VARCHAR)AS DATE)
	END AS sls_ship_dt,
	CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_due_dt AS VARCHAR)AS DATE)
	END AS sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
FROM
	DataWareHouse.bronze.crm_sales_details;	

-- Check for invalid dates (correct)
-- We need to check if the sls_order_dt have a higher value than sls_ship_dt, sls_due_dt
-- Expectation: No results
SELECT 
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt
FROM DataWareHouse.bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt
-- Reality: No results 🤙🏽
	
-- now:
-- Check data consistency: Between sales, quantity, and price
-- the sls_sales = sls_quantity * sls_price
-- values must not be NULL, zero, or negative
-- Expectation: No results
SELECT DISTINCT
	sls_sales,
	sls_quantity,
	sls_price
FROM0
	DataWareHouse.bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price
-- Reality: Many values <= 0, NULLS and differents of "sls_sales = sls_quantity * sls_price" 😳!!!!
-- MANY ISSUES 💀!!!!

-- How can we fix this???
-- if sales is negative, zero, or null, derive it using quantity and price
-- if price is zero or null, calculate it using sales and quantity
-- if price is negative, convert it to a positive value
SELECT DISTINCT
	sls_sales AS old_sls_sales,
	sls_quantity,
	sls_price AS old_sls_price,
	CASE  
		WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
			THEN sls_quantity *  ABS(sls_price)
		ELSE sls_sales
	END AS sls_sales,
	CASE  
		WHEN sls_price IS NULL OR sls_price <= 0 OR sls_price <= 0
			THEN sls_sales / NULLIF(sls_quantity, 0)
		ELSE sls_price
	END AS sls_price
FROM
	DataWareHouse.bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price

-- lets integrated it to the main query:
SELECT
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_order_dt AS VARCHAR)AS DATE)
	END AS sls_order_dt,
	CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_ship_dt AS VARCHAR)AS DATE)
	END AS sls_ship_dt,
	CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_due_dt AS VARCHAR)AS DATE)
	END AS sls_due_dt,
	CASE  
		WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
			THEN sls_quantity *  ABS(sls_price)
		ELSE sls_sales
	END AS sls_sales,
	sls_quantity,
		CASE  
		WHEN sls_price IS NULL OR sls_price <= 0 OR sls_price <= 0
			THEN sls_sales / NULLIF(sls_quantity, 0)
		ELSE sls_price
	END AS sls_price
FROM
	DataWareHouse.bronze.crm_sales_details;	

-- we have to alter the ddl again (change INTs to DATEs)


-- Lets insert into the silver table now
INSERT INTO silver.crm_sales_details (
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
) 

SELECT
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_order_dt AS VARCHAR)AS DATE)
	END AS sls_order_dt,
	CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_ship_dt AS VARCHAR)AS DATE)
	END AS sls_ship_dt,
	CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_due_dt AS VARCHAR)AS DATE)
	END AS sls_due_dt,
	CASE  
		WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
			THEN sls_quantity *  ABS(sls_price)
		ELSE sls_sales
	END AS sls_sales,
	sls_quantity,
		CASE  
		WHEN sls_price IS NULL OR sls_price <= 0 OR sls_price <= 0
			THEN sls_sales / NULLIF(sls_quantity, 0)
		ELSE sls_price
	END AS sls_price
FROM
	DataWareHouse.bronze.crm_sales_details;	


-- =================================================================================
-- 				crm_sales_details		| silver Check
-- =================================================================================
-- Check for invalid dates
-- Expectation: No result 
SELECT *
FROM
	DataWareHouse.silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;
-- Reality: No results 🤙🏽

-- Check data consistency: Between sales, quantity, and price
-- the sls_sales = sls_quantity * sls_price
-- values must not be NULL, zero, or negative
-- Expectation: No results
SELECT DISTINCT
	sls_sales,
	sls_quantity,
	sls_price
FROM
	DataWareHouse.silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;
-- Reality: No results 🤙🏽


-- final
SELECT * FROM DataWareHouse.silver.crm_sales_details;





-- =================================================================================
-- 				erp_cust_az12		| bronze Check
-- =================================================================================

-- All table
SELECT cid, bdate, gen
FROM DataWareHouse.bronze.erp_cust_az12;


-- erp_cust_az12.cid is correlated with  crm_cust_info.cst_key
SELECT cst_key
FROM DataWareHouse.silver.crm_cust_info;

-- but in the erp_cust_az12, we have additional information in the begin "NAS"
SELECT cid, bdate, gen
FROM DataWareHouse.bronze.erp_cust_az12
WHERE cid like '%AW00011010%'			-- real value from crm_cust_info

-- Check cid
SELECT
	CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
		ELSE cid
	END cid,
	bdate,
	gen
FROM
	DataWareHouse.bronze.erp_cust_az12

	
-- Identify out-of-range dates
-- Expectation: realistic data
SELECT DISTINCT
	bdate
FROM DataWareHouse.bronze.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()
-- Reality: datas completele out of the box like futures birthdate  😳!!!!

SELECT
	CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
		ELSE cid
	END cid,
	CASE WHEN bdate > GETDATE() THEN NULL
		ELSE bdate
	END AS bdate,
	gen
FROM
	DataWareHouse.bronze.erp_cust_az12
	
-- Check data standardization & consistency
-- check for gen
-- Expectation: standard
SELECT DISTINCT
	gen
FROM
	DataWareHouse.bronze.erp_cust_az12
-- Reality: Complete messy 😳!!!!

SELECT 
	CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
		ELSE cid
	END cid,
	CASE WHEN bdate > GETDATE() THEN NULL
		ELSE bdate
	END AS bdate,
	CASE WHEN UPPER(TRIM(gen)) LIKE 'F%' THEN 'Female'
		 WHEN UPPER(TRIM(gen)) LIKE 'M%' THEN 'Male'
		 ELSE 'n/a'
	END AS gen
FROM
	DataWareHouse.bronze.erp_cust_az12

	
-- Lets insert into silver layer
INSERT INTO DataWareHouse.silver.erp_cust_az12
(cid,
	bdate,
	gen)
SELECT 
	CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
		ELSE cid
	END cid,
	CASE WHEN bdate > GETDATE() THEN NULL
		ELSE bdate
	END AS bdate,
	CASE WHEN UPPER(TRIM(gen)) LIKE 'F%' THEN 'Female'
		 WHEN UPPER(TRIM(gen)) LIKE 'M%' THEN 'Male'
		 ELSE 'n/a'
	END AS gen
FROM
	DataWareHouse.bronze.erp_cust_az12
	

-- =================================================================================
-- 				erp_cust_az12		| silver Check
-- =================================================================================
-- Identify out-of-range dates
-- Expectation: realistic data
SELECT DISTINCT
	bdate
FROM DataWareHouse.silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()
-- Reality: realistic data 🤙🏽

-- Check data standardization & consistency
-- check for gen
-- Expectation: standard
SELECT DISTINCT
	gen
FROM
	DataWareHouse.silver.erp_cust_az12
-- Reality: standard 🤙🏽
	
-- all
SELECT cid, bdate, gen, dwh_create_date
FROM DataWareHouse.silver.erp_cust_az12;



-- =================================================================================
-- 				erp_loc_a101		| bronze Check
-- =================================================================================
-- all table
SELECT cid, cntry
FROM DataWareHouse.bronze.erp_loc_a101;

-- erp_loc_a101.cid is correlated with  crm_cust_info.cst_key
SELECT cst_key
FROM DataWareHouse.silver.crm_cust_info;

-- but in the erp_loc_a101 we have "-"
-- so:
SELECT
	REPLACE(cid, '-', '') cid,
	cntry
FROM
	DataWareHouse.bronze.erp_loc_a101
WHERE REPLACE(cid, '-', '') NOT IN (SELECT cst_key FROM silver.crm_cust_info);	-- data are matching

SELECT
	REPLACE(cid, '-', '') cid,
	cntry
FROM
	DataWareHouse.bronze.erp_loc_a101;

-- Data standardization & consistency for cntry
-- Expectation: No NULLS, empty strings or abbreviation of countries
SELECT DISTINCT cntry FROM DataWareHouse.bronze.erp_loc_a101;
-- Reality: NULLS, empty strings and abbreviation of countries 😳!!

-- lets transform
SELECT
	REPLACE(cid, '-', '') AS cid,
	CASE
	    WHEN TRIM(cntry) = 'DE' THEN 'Germany'
	    WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
	    WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
	    ELSE TRIM(cntry)
	END                   AS cntry -- Normalize and Handle missing or blank country codes
	FROM bronze.erp_loc_a101;

-- Lets insert into silver layer:
INSERT INTO silver.erp_loc_a101 (
    cid,
    cntry
)
SELECT
    REPLACE(cid, '-', '') AS cid,
    CASE
        WHEN TRIM(cntry) = 'DE' THEN 'Germany'
        WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
        WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
        ELSE TRIM(cntry)
    END                   AS cntry 
FROM bronze.erp_loc_a101;


-- =================================================================================
-- 				erp_loc_a101		| silver Check
-- =================================================================================
-- Data standardization & consistency for cntry
-- Expectation: No NULLS, empty strings or abbreviation of countries
SELECT
	DISTINCT cntry
FROM
	DataWareHouse.silver.erp_loc_a101;
-- Reality: NULLS, empty strings and abbreviation of countries 😳!!

SELECT * FROM DataWareHouse.silver.erp_loc_a101;



-- =================================================================================
-- 				erp_px_cat_g1v2		| bronze Check
-- =================================================================================

SELECT id, cat, subcat, maintenance
FROM DataWareHouse.bronze.erp_px_cat_g1v2;

-- erp_px_cat_g1v2.id is correlated with  crm_prd_info.prd_key but we create on silver layer one new column calls 
-- cat_id, and this new column is the real correlation with erp_px_cat_g1v2.id
SELECT prd_id, cat_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt, dwh_create_date
FROM DataWareHouse.silver.crm_prd_info;


-- Check for unwanted sapces
-- Expectation: No result
SELECT
	id,
	cat,
	subcat,
	maintenance
FROM
	DataWareHouse.bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
OR subcat != TRIM(subcat)
OR maintenance != TRIM (maintenance)
-- Reality: We don't have any unwanted spaces  🤙🏽

-- Check data standardization & consistency
-- cat
SELECT DISTINCT
	cat
FROM
	DataWareHouse.bronze.erp_px_cat_g1v2

-- subcat
SELECT DISTINCT
	subcat
FROM
	DataWareHouse.bronze.erp_px_cat_g1v2

-- maintenance
SELECT DISTINCT
	maintenance
FROM
	DataWareHouse.bronze.erp_px_cat_g1v2
-- WE FOUND A DUPLICATE HERE  😳!!!!

	
-- Lets insert into silver layer
INSERT INTO silver.erp_px_cat_g1v2 (
    id,
    cat,
    subcat,
    maintenance
)
SELECT
    id,
    cat,
    subcat,
    maintenance
FROM bronze.erp_px_cat_g1v2;

-- ONly needs now, create a big procedure to this (maybe using AI)