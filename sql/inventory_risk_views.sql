-- ============================================================
-- INVENTORY RISK ANALYTICS
-- ============================================================

CREATE OR REPLACE VIEW vw_inventory_risk_summary AS
SELECT
    region_id,
    region_name,
    category,

    COUNT(*) AS inventory_records,

    SUM(stockout_flag) AS stockout_events,

    SUM(reorder_flag) AS reorder_events,

    ROUND(
        100.0 * SUM(stockout_flag) / NULLIF(COUNT(*), 0),
        2
    ) AS stockout_rate_pct,

    ROUND(
        AVG(stock_quantity),
        2
    ) AS avg_stock_quantity,

    ROUND(
        AVG(reorder_level),
        2
    ) AS avg_reorder_level

FROM vw_fact_inventory

GROUP BY
    region_id,
    region_name,
    category;