/*
===============================================================================
6. Product Category Revenue Rankings & Profit Margins

Purpose:
    Ranks Contoso's product categories by lifetime gross revenue and evaluates
    gross profit margins ((netprice - unitcost) / netprice) to uncover
    high-margin merchandise opportunities versus pure high-volume drivers.
*/

SELECT
    p.categoryname,
    COUNT(DISTINCT s.orderkey) AS total_orders,
    ROUND(SUM(s.quantity * s.netprice * s.exchangerate)::numeric, 2) AS gross_revenue_usd,
    ROUND(SUM(s.quantity * (s.netprice - s.unitcost) * s.exchangerate)::numeric, 2) AS gross_profit_usd,
    ROUND(
        (100.0 * SUM(s.quantity * (s.netprice - s.unitcost) * s.exchangerate) / 
        NULLIF(SUM(s.quantity * s.netprice * s.exchangerate), 0))::numeric, 
        1
    ) AS gross_profit_margin_pct
FROM sales s
LEFT JOIN product p ON s.productkey = p.productkey
GROUP BY
    p.categoryname
ORDER BY
    gross_revenue_usd DESC;
