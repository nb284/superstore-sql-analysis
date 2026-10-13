/*Ringkasan performa bisnis*/
SELECT
    COUNT(*) AS transaction_rows,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(DISTINCT product_id) AS unique_products,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    SUM(quantity) AS total_units_sold,
    ROUND(AVG(discount) * 100, 2) AS average_discount_pct
FROM superstore;

/*Analisis penjualan dan profit per tahun*/
SELECT
    YEAR(order_date) AS sales_year,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM superstore
GROUP BY YEAR(order_date)
ORDER BY sales_year;

/*Analisis bulanan*/
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM superstore
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY sales_month;

/*Pertumbuhan penjualan dari bulan sebelumnya*/
WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
        SUM(sales) AS total_sales
    FROM superstore
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
),
sales_with_previous AS (
    SELECT
        sales_month,
        total_sales,
        LAG(total_sales) OVER (
            ORDER BY sales_month
        ) AS previous_month_sales
    FROM monthly_sales
)
SELECT
    sales_month,
    ROUND(total_sales, 2) AS total_sales,
    ROUND(previous_month_sales, 2) AS previous_month_sales,
    ROUND(
        100.0 * (total_sales - previous_month_sales)
        / NULLIF(previous_month_sales, 0),
        2
    ) AS growth_pct
FROM sales_with_previous
ORDER BY sales_month;

/*Performa kategori produk*/
SELECT
    category,
    SUM(quantity) AS units_sold,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(
        100.0 * SUM(profit) / NULLIF(SUM(sales), 0),
        2
    ) AS profit_margin_pct
FROM superstore
GROUP BY category
ORDER BY total_sales DESC;

/*Performa subkategori*/
SELECT
    category,
    sub_category,
    SUM(quantity) AS units_sold,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(
        100.0 * SUM(profit) / NULLIF(SUM(sales), 0),
        2
    ) AS profit_margin_pct
FROM superstore
GROUP BY category, sub_category
ORDER BY total_profit DESC;

/*Sepuluh produk dengan profit tertinggi*/
SELECT
    product_id,
    MAX(product_name) AS product_name,
    MAX(category) AS category,
    MAX(sub_category) AS sub_category,
    SUM(quantity) AS units_sold,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM superstore
GROUP BY product_id
ORDER BY total_profit DESC
LIMIT 10;

/*Sepuluh produk dengan profit terendah*/
SELECT
    product_id,
    MAX(product_name) AS product_name,
    MAX(category) AS category,
    MAX(sub_category) AS sub_category,
    SUM(quantity) AS units_sold,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM superstore
GROUP BY product_id
ORDER BY total_profit ASC
LIMIT 10;

/*Performa wilayah*/
SELECT
    region,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(quantity) AS units_sold,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(
        100.0 * SUM(profit) / NULLIF(SUM(sales), 0),
        2
    ) AS profit_margin_pct
FROM superstore
GROUP BY region
ORDER BY total_sales DESC;

/*Performa segmen pelanggan*/
SELECT
    segment,
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM superstore
GROUP BY segment
ORDER BY total_sales DESC;

/*Sepuluh pelanggan dengan penjualan tinggi*/
SELECT
    customer_id,
    MAX(customer_name) AS customer_name,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM superstore
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 10;

/*Performa negara bagian*/
SELECT
    state,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM superstore
GROUP BY state
ORDER BY total_profit DESC;

/*Pengaruh diskon terhadap profit*/
SELECT
    CASE
        WHEN discount = 0 THEN '0% - No Discount'
        WHEN discount <= 0.20 THEN 'Above 0% - 20%'
        WHEN discount <= 0.50 THEN 'Above 20% - 50%'
        ELSE 'Above 50%'
    END AS discount_group,
    COUNT(*) AS transaction_rows,
    ROUND(AVG(discount) * 100, 2) AS average_discount_pct,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(AVG(profit), 2) AS average_profit_per_row
FROM superstore
GROUP BY discount_group
ORDER BY MIN(discount);

/*Performa metode pengiriman*/
SELECT
    ship_mode,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(quantity) AS units_sold,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(AVG(DATEDIFF(ship_date, order_date)), 2)
        AS avg_shipping_days
FROM superstore
GROUP BY ship_mode
ORDER BY total_sales DESC;

/*Periksa kontribusi profit negatif*/
SELECT
    category,
    sub_category,
    COUNT(*) AS loss_rows,
    ROUND(SUM(sales), 2) AS sales_on_loss_rows,
    ROUND(SUM(profit), 2) AS total_negative_profit
FROM superstore
WHERE profit < 0
GROUP BY category, sub_category
ORDER BY total_negative_profit ASC;

/*Distribusi nilai pesanan*/
WITH order_summary AS (
    SELECT
        order_id,
        SUM(sales) AS order_sales,
        SUM(profit) AS order_profit,
        SUM(quantity) AS total_units
    FROM superstore
    GROUP BY order_id
)
SELECT
    COUNT(*) AS total_orders,
    ROUND(AVG(order_sales), 2) AS avg_order_value,
    ROUND(AVG(order_profit), 2) AS avg_order_profit,
    ROUND(AVG(total_units), 2) AS avg_units_per_order,
    ROUND(MIN(order_sales), 2) AS smallest_order_sales,
    ROUND(MAX(order_sales), 2) AS largest_order_sales
FROM order_summary;

/*Pesanan dengan profit terendah*/
SELECT
    order_id,
    MIN(order_date) AS order_date,
    MAX(customer_name) AS customer_name,
    ROUND(SUM(sales), 2) AS order_sales,
    SUM(quantity) AS total_units,
    ROUND(SUM(profit), 2) AS order_profit
FROM superstore
GROUP BY order_id
ORDER BY order_profit ASC
LIMIT 10;

/*Perbandingan sales dan profit berdasarkan kota*/
SELECT
    city,
    state,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM superstore
GROUP BY city, state
HAVING COUNT(DISTINCT order_id) >= 5
ORDER BY total_sales DESC
LIMIT 20;