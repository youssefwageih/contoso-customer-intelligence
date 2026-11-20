/*
===============================================================================
3. 5x5 Behavioral RFM Customer Persona Matrix

Purpose:
    Constructs a behavioral segmentation matrix using NTILE(5) across Recency
    (days since last purchase), Frequency (distinct order count), and Monetary
    value (lifetime net spend) to classify customers into actionable personas.

*/

WITH customer_rfm_raw AS (
    SELECT
        customerkey,
        MAX(orderdate) AS last_order_date,
        -- Recency: Days elapsed since customer's last order relative to latest database date
        (SELECT MAX(orderdate) FROM sales) - MAX(orderdate) AS recency_days,
        -- Frequency: Distinct order count
        COUNT(DISTINCT orderkey) AS frequency,
        -- Monetary: Total spend
        SUM(quantity * netprice * exchangerate) AS monetary_value
    FROM sales
    GROUP BY
        customerkey
),
rfm_scores AS (
    SELECT
        customerkey,
        recency_days,
        frequency,
        monetary_value,
        NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,   -- Lower recency days = higher score (5 = most recent)
        NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,        -- Higher order count = higher score
        NTILE(5) OVER (ORDER BY monetary_value ASC) AS m_score    -- Higher spend = higher score
    FROM customer_rfm_raw
)
SELECT
    CASE
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
        WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal Customers'
        WHEN r_score >= 4 AND f_score <= 2 THEN 'Recent Promising'
        WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk (High Spenders)'
        ELSE 'Hibernating / Lost'
    END AS rfm_persona,
    COUNT(customerkey) AS total_customers,
    ROUND((100.0 * COUNT(customerkey) / (SELECT COUNT(*) FROM rfm_scores))::numeric, 1) AS pct_of_customers,
    ROUND(AVG(monetary_value)::numeric, 2) AS avg_spend,
    ROUND(SUM(monetary_value)::numeric, 2) AS total_persona_revenue,
    ROUND((100.0 * SUM(monetary_value) / (SELECT SUM(monetary_value) FROM rfm_scores))::numeric, 1) AS pct_total_revenue
FROM rfm_scores
GROUP BY
    1
ORDER BY
    total_persona_revenue DESC;
