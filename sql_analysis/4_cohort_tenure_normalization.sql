/*
===============================================================================
4. Cohort Analysis & Tenure Normalization (Diagnosing Tenure Bias)

Purpose:
    Compares all-time unadjusted customer lifetime revenue against a normalized
    first 3-month observation window to prove whether customer quality has
    actually changed over successive annual acquisition cohorts (2018–2023).
*/

WITH customer_orders AS (
    SELECT
        customerkey,
        orderdate,
        quantity * netprice * exchangerate AS line_revenue,
        MIN(orderdate) OVER (PARTITION BY customerkey) AS first_purchase_date
    FROM sales
),
customer_summary AS (
    SELECT
        customerkey,
        EXTRACT(YEAR FROM first_purchase_date)::int AS cohort_year,
        SUM(line_revenue) AS total_ltv,
        SUM(
            CASE
                WHEN orderdate <= first_purchase_date + INTERVAL '3 months'
                THEN line_revenue
                ELSE 0
            END
        ) AS ltv_3months
    FROM customer_orders
    GROUP BY
        customerkey,
        first_purchase_date
)
SELECT
    cohort_year,
    COUNT(customerkey) AS acquired_customers,
    ROUND((SUM(total_ltv) / COUNT(customerkey))::numeric, 2) AS unadjusted_all_time_avg_ltv,
    ROUND((SUM(ltv_3months) / COUNT(customerkey))::numeric, 2) AS normalized_3month_avg_revenue
FROM customer_summary
WHERE cohort_year BETWEEN 2018 AND 2023
GROUP BY
    cohort_year
ORDER BY
    cohort_year;