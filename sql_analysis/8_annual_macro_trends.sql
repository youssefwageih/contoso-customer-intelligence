/*
===============================================================================
8. Annual Macro Trends: Revenue Trajectory & Customer Growth

Purpose:
    Tracks the full 10-year enterprise lifecycle (2015–2024), computing annual
    net revenue, active shopper counts, total order volume, and year-over-year
    revenue expansion rates using LAG().

*/

WITH annual_summary AS (
    SELECT
        EXTRACT(YEAR FROM orderdate)::int AS sales_year,
        COUNT(DISTINCT customerkey) AS active_customers,
        COUNT(DISTINCT orderkey) AS total_orders,
        ROUND((SUM(quantity * netprice * exchangerate) / 1e6)::numeric, 2) AS annual_revenue_millions_usd,
        ROUND(SUM(quantity * netprice * exchangerate)::numeric, 2) AS total_revenue_usd
    FROM sales
    GROUP BY
        EXTRACT(YEAR FROM orderdate)
)
SELECT
    sales_year,
    active_customers,
    total_orders,
    annual_revenue_millions_usd,
    LAG(annual_revenue_millions_usd) OVER (ORDER BY sales_year) AS prev_year_revenue_m,
    ROUND(
        (100.0 * (annual_revenue_millions_usd - LAG(annual_revenue_millions_usd) OVER (ORDER BY sales_year)) /
        NULLIF(LAG(annual_revenue_millions_usd) OVER (ORDER BY sales_year), 0))::numeric,
        1
    ) AS yoy_revenue_growth_pct
FROM annual_summary
ORDER BY
    sales_year;
