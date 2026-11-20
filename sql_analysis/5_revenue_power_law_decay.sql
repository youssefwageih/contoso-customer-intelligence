/*
===============================================================================
5. Customer Lifetime Revenue Concentration (Power-Law Decay from Day 0)

Purpose:
    Measures the concentration of lifetime enterprise revenue across days elapsed
    since each customer's initial acquisition. Demonstrates the extreme power-law
    nature of e-commerce spend where Day 0 accounts for over 61% of total cash flow.

*/

WITH customer_acquisition AS (
    SELECT 
        customerkey, 
        MIN(orderdate) AS first_order_date
    FROM sales 
    GROUP BY 
        customerkey
),
order_day_deltas AS (
    SELECT 
        s.customerkey,
        (s.orderdate - ca.first_order_date) AS days_since_first_purchase,
        (s.quantity * s.netprice * s.exchangerate) AS order_revenue
    FROM sales s
    JOIN customer_acquisition ca ON s.customerkey = ca.customerkey
),
binned_days AS (
    SELECT
        CASE
            WHEN days_since_first_purchase = 0 THEN '01. Day 0 (Acquisition Day)'
            WHEN days_since_first_purchase BETWEEN 1 AND 7 THEN '02. Days 1 – 7 (First Week)'
            WHEN days_since_first_purchase BETWEEN 8 AND 30 THEN '03. Days 8 – 30 (Month 1)'
            WHEN days_since_first_purchase BETWEEN 31 AND 90 THEN '04. Days 31 – 90 (Quarter 1)'
            WHEN days_since_first_purchase BETWEEN 91 AND 180 THEN '05. Days 91 – 180 (Half Year)'
            WHEN days_since_first_purchase BETWEEN 181 AND 365 THEN '06. Days 181 – 365 (Year 1)'
            ELSE '07. Days 365+ (Long-Term Retention)'
        END AS tenure_bucket,
        order_revenue
    FROM order_day_deltas
)
SELECT 
    tenure_bucket,
    ROUND(SUM(order_revenue)::numeric, 2) AS total_revenue_usd,
    ROUND(
        (100.0 * SUM(order_revenue) / 
        (SELECT SUM(quantity * netprice * exchangerate) FROM sales))::numeric, 
        2
    ) AS pct_of_all_time_revenue
FROM binned_days
GROUP BY 
    tenure_bucket
ORDER BY 
    tenure_bucket;
