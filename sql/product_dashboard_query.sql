WITH sales AS (
SELECT
    CASE
        WHEN `Retailer Country` IS NULL OR `Retailer Country` = '#N/A' THEN 'Unknown'
        WHEN `Retailer Country` IN (
            'Austria','Belgium','Denmark','Finland','France','Germany',
            'Italy','Netherlands','Spain','Sweden','Switzerland','United Kingdom'
        ) THEN 'Europe'
        WHEN `Retailer Country` IN ('China','Japan','Korea','Singapore') THEN 'Asia'
        WHEN `Retailer Country` = 'Australia' THEN 'Oceania'
        WHEN `Retailer Country` IN ('Canada','Mexico','United States') THEN 'North America'
        WHEN `Retailer Country` = 'Brazil' THEN 'South America'
        ELSE 'Other'
    END AS region,

    CASE
        WHEN `Retailer Country` IS NULL OR `Retailer Country` = '#N/A'
        THEN 'Unknown'
        ELSE `Retailer Country`
    END AS country,

    EXTRACT(YEAR FROM `Date`) AS year_date,
    EXTRACT(MONTH FROM `Date`) AS month_date,

    `Retailer name` AS retailer_name,
    `Retailer Type` AS retailer_type,
    `Product line` AS product_line,
    `Product type` AS product_type,
    `Product brand` AS product_brand,
    `Order Method` AS order_method,

    COUNT(DISTINCT `Retailer name`) AS total_retailers,
    ROUND(SUM(`Order Total Sale`)) AS revenue,
    ROUND(SUM(`Quantity`)) AS quantity,
    ROUND(SUM(`Margin`)) AS gross_profit,

    ROUND(SAFE_DIVIDE(SUM(`Margin`), SUM(`Order Total Sale`)) * 100, 1) AS margin_pct,

    ROUND(SUM(`Order total`) - SUM(`Order Total Sale`)) AS discount_sum,

    ROUND(
        SAFE_DIVIDE(
            SUM(`Order total`) - SUM(`Order Total Sale`),
            SUM(`Order total`)
        ) * 100,
        1
    ) AS discount_pct

FROM `gooutside-501308.GoOutside.total`
WHERE `Order Total Sale` != 0
GROUP BY
    region,
    country,
    year_date,
    month_date,
    retailer_name,
    retailer_type,
    product_line,
    product_type,
    product_brand,
    order_method
)

SELECT
    *,

    LAG(revenue) OVER (
        PARTITION BY
            country,
            retailer_name,
            retailer_type,
            product_line,
            product_type,
            product_brand,
            order_method,
            month_date
        ORDER BY year_date
    ) AS revenue_prev_year,

    ROUND(
        SAFE_DIVIDE(
            revenue,
            LAG(revenue) OVER (
                PARTITION BY
                    country,
                    retailer_name,
                    retailer_type,
                    product_line,
                    product_type,
                    product_brand,
                    order_method,
                    month_date
                ORDER BY year_date
            )
        ) * 100 - 100,
        1
    ) AS revenue_yoy_pct

FROM sales;
