/*
1. Top Paying Customers by Lifetime Net Revenue

Purpose:
    Identifies the top 10 highest-spending customers across Contoso's global
    markets. Aggregates lifetime net revenue, total order volume, and Average
    Order Value (AOV) while standardizing messy customer demographic attributes.
*/

WITH customer_spending AS (
    SELECT
        s.customerkey,
        CONCAT(
            INITCAP(TRIM(COALESCE(c.givenname, ''))),
            ' ',
            INITCAP(TRIM(COALESCE(c.surname, '')))
        ) AS customer_name,
        COALESCE(c.countryfull, 'Unknown') AS country,
        COALESCE(c.continent, 'Unknown') AS continent,
        c.age,
        COUNT(DISTINCT s.orderkey) AS total_orders,
        ROUND(SUM(s.quantity * s.netprice * s.exchangerate)::numeric, 2) AS lifetime_net_spend_usd,
        ROUND((SUM(s.quantity * s.netprice * s.exchangerate) / COUNT(DISTINCT s.orderkey))::numeric, 2) AS avg_order_value_usd,
        MIN(s.orderdate) AS first_purchase_date,
        MAX(s.orderdate) AS latest_purchase_date
    FROM sales s
    JOIN customer c ON s.customerkey = c.customerkey
    GROUP BY
        s.customerkey,
        c.givenname,
        c.surname,
        c.countryfull,
        c.continent,
        c.age
)
SELECT
    customerkey,
    customer_name,
    country,
    continent,
    age,
    total_orders,
    lifetime_net_spend_usd,
    avg_order_value_usd,
    first_purchase_date,
    latest_purchase_date
FROM customer_spending
ORDER BY
    lifetime_net_spend_usd DESC
LIMIT 10;
