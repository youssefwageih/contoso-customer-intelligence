/*
===============================================================================
2. Customer Segmentation & Pareto Revenue Distribution

Purpose:
    Segments the customer base into Low-Value (bottom 25%), Mid-Value (middle 50%),
    and High-Value (top 25%) tiers using statistical continuous percentiles.
    Demonstrates the Pareto concentration law in customer lifetime spending.
*/

WITH customer_ltv_summary AS (
    SELECT
        s.customerkey,
        SUM(s.quantity * s.netprice * s.exchangerate) AS total_ltv
    FROM sales s
    GROUP BY
        s.customerkey
),
ltv_percentile_thresholds AS (
    SELECT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_ltv) AS p25_ltv,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_ltv) AS p75_ltv
    FROM customer_ltv_summary
),
customer_segments AS (
    SELECT
        c.customerkey,
        c.total_ltv,
        CASE
            WHEN c.total_ltv < p.p25_ltv THEN '1 - Low-Value (Bottom 25%)'
            WHEN c.total_ltv BETWEEN p.p25_ltv AND p.p75_ltv THEN '2 - Mid-Value (Middle 50%)'
            ELSE '3 - High-Value (Top 25%)'
        END AS customer_segment
    FROM customer_ltv_summary c
    CROSS JOIN ltv_percentile_thresholds p
)
SELECT
    customer_segment,
    COUNT(customerkey) AS customer_count,
    ROUND((100.0 * COUNT(customerkey) / (SELECT COUNT(*) FROM customer_segments))::numeric, 1) AS pct_of_customers,
    ROUND(SUM(total_ltv)::numeric, 2) AS total_segment_revenue,
    ROUND((100.0 * SUM(total_ltv) / (SELECT SUM(total_ltv) FROM customer_segments))::numeric, 1) AS pct_of_total_revenue,
    ROUND((SUM(total_ltv) / COUNT(customerkey))::numeric, 2) AS avg_ltv_per_customer
FROM customer_segments
GROUP BY
    customer_segment
ORDER BY
    total_segment_revenue DESC;
