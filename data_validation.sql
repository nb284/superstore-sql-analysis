/*Periksa jumlah baris dan kolom*/
USE customer_sales_analysis;
SELECT COUNT(*) AS total_rows
FROM superstore;
SHOW COLUMNS FROM superstore;

/*Periksa duplikasi ID baris*/
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT row_id) AS unique_row_ids,
    COUNT(*) - COUNT(DISTINCT row_id) AS duplicate_row_ids
FROM superstore;

/*Periksa nilai kosong*/
SELECT
    SUM(order_id IS NULL) AS missing_order_id,
    SUM(order_date IS NULL) AS missing_order_date,
    SUM(ship_date IS NULL) AS missing_ship_date,
    SUM(customer_id IS NULL) AS missing_customer_id,
    SUM(product_id IS NULL) AS missing_product_id,
    SUM(sales IS NULL) AS missing_sales,
    SUM(quantity IS NULL) AS missing_quantity,
    SUM(profit IS NULL) AS missing_profit
FROM superstore;

/*Periksa tanggal pengiriman*/
SELECT COUNT(*) AS invalid_shipping_dates
FROM superstore
WHERE ship_date < order_date;

/*Periksa nilai numerik yang tidak wajar*/
SELECT
    SUM(sales < 0) AS negative_sales_rows,
    SUM(quantity <= 0) AS nonpositive_quantity_rows,
    SUM(discount < 0 OR discount > 1) AS unusual_discount_rows
FROM superstore;