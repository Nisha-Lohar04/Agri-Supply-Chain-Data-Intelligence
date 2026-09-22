-- ============================================================
-- EXECUTIVE KPI SUMMARY
-- ============================================================

CREATE OR REPLACE VIEW vw_executive_kpis AS
SELECT
    COUNT(DISTINCT order_id) AS total_orders,

    COUNT(DISTINCT customer_id) AS total_customers,

    COUNT(DISTINCT product_id) AS total_products,

    SUM(quantity) AS total_units_sold,

    ROUND(
        SUM(net_sales),
        2
    ) AS total_sales,

    ROUND(
        SUM(gross_profit),
        2
    ) AS total_gross_profit,

    ROUND(
        100.0 * SUM(gross_profit)
        / NULLIF(SUM(net_sales), 0),
        2
    ) AS gross_margin_pct,

    ROUND(
        SUM(net_sales)
        / NULLIF(COUNT(DISTINCT order_id), 0),
        2
    ) AS average_order_value

FROM vw_fact_sales;