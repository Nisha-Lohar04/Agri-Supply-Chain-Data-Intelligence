-- ============================================================
-- MONTHLY BUSINESS KPI ANALYTICS
-- ============================================================

CREATE OR REPLACE VIEW vw_monthly_kpis AS
SELECT
    DATE_TRUNC('month', order_date)::DATE AS month,

    region_id,
    region_name,

    COUNT(DISTINCT order_id) AS total_orders,

    SUM(quantity) AS units_sold,

    ROUND(
        SUM(net_sales),
        2
    ) AS total_sales,

    ROUND(
        SUM(gross_profit),
        2
    ) AS gross_profit,

    ROUND(
        100.0 * SUM(gross_profit)
        / NULLIF(SUM(net_sales), 0),
        2
    ) AS gross_margin_pct,

    COUNT(
        DISTINCT customer_id
    ) AS active_customers

FROM vw_fact_sales

GROUP BY
    DATE_TRUNC('month', order_date)::DATE,
    region_id,
    region_name;