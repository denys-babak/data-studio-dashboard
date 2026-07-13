SELECT
    DATE_TRUNC(DATE(`Date`), MONTH) AS month_date,
    CASE
        WHEN `Retailer Country` IS NULL OR `Retailer Country` = '#N/A'
        THEN 'Unknown'
        ELSE `Retailer Country`
    END AS country,
    `Retailer name` AS retailer_name,
    `Retailer Type` AS retailer_type,
    `Product line` AS product_line,
    `Product type` AS product_type,
    `Product brand` AS product_brand,
    `Order Method` AS order_method,
	COUNT(*) AS orders,
    SUM(`Order Total Sale`) AS revenue,
    SUM(`Quantity`) AS quantity,
	ROUND(SUM(`Margin`)) AS gross_profit,
	ROUND(SUM(`Margin`) / SUM(`Order Total Sale`), 1) AS margin_pct,
	ROUND(SUM(`Order total` - `Order Total Sale`)) AS discount_sum,
	ROUND((SUM(`Order total`) - SUM(`Order Total Sale`)) / SUM(`Order total`), 1) AS discount_pct
FROM `gooutside-501308.GoOutside.total`
WHERE `Order Total Sale` != 0
GROUP BY
    month_date,
    country,
    retailer_name,
    retailer_type,
    product_line,
    product_type,
    product_brand,
    order_method;
