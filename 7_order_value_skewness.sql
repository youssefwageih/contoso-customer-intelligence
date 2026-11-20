/*
===============================================================================
7. Statistical Order Value Skewness: Mean vs. Continuous Median

Purpose:
    Analyzes order value distribution by contrasting the arithmetic average
    (AVG) against the continuous 50th percentile (PERCENTILE_CONT(0.5)).
    Identifies which categories are heavily distorted by high-ticket outlier orders.

*/

SELECT
    p.categoryname,
    COUNT(s.orderkey) AS total_order_items,
    ROUND(AVG(s.quantity * s.netprice * s.exchangerate)::numeric, 2) AS mean_order_value,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY s.quantity * s.netprice * s.exchangerate)::numeric, 2) AS median_order_value,
    ROUND(
        (AVG(s.quantity * s.netprice * s.exchangerate) / 
        NULLIF(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY s.quantity * s.netprice * s.exchangerate), 0))::numeric,
        2
    ) AS skew_ratio_mean_to_median,
    ROUND(MIN(s.quantity * s.netprice * s.exchangerate)::numeric, 2) AS min_order_value,
    ROUND(MAX(s.quantity * s.netprice * s.exchangerate)::numeric, 2) AS max_order_value
FROM sales s
LEFT JOIN product p ON s.productkey = p.productkey
WHERE s.orderdate BETWEEN '2023-01-01' AND '2023-12-31'
GROUP BY 
    p.categoryname
ORDER BY 
    mean_order_value DESC;
