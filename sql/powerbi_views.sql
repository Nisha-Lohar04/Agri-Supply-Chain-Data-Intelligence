-- ============================================================
-- POWER BI ANALYTICAL VIEWS
-- ============================================================

-- Main sales fact view
CREATE OR REPLACE VIEW vw_fact_sales AS
SELECT
    o.order_id,
    oi.order_item_id,
    o.order_date,

    -- Customer
    c.customer_id,
    c.customer_name,
    c.customer_type,

    -- Region
    r.region_id,
    r.region_name,
    r.country,

    -- Product
    p.product_id,
    p.product_name,
    p.category,

    -- Supplier
    s.supplier_id,
    s.supplier_name,
    s.supplier_type,

    -- Order details
    o.order_status,
    oi.quantity,
    oi.unit_price,
    oi.discount_percent,

    -- Financial metrics
    ROUND(
        oi.quantity * oi.unit_price *
        (1 - oi.discount_percent / 100.0),
        2
    ) AS net_sales,

    ROUND(
        oi.quantity * p.unit_cost,
        2
    ) AS product_cost,

    ROUND(
        (
            oi.quantity * oi.unit_price *
            (1 - oi.discount_percent / 100.0)
        ) -
        (oi.quantity * p.unit_cost),
        2
    ) AS gross_profit,

    ROUND(
        100.0 *
        (
            (
                oi.quantity * oi.unit_price *
                (1 - oi.discount_percent / 100.0)
            ) -
            (oi.quantity * p.unit_cost)
        )
        /
        NULLIF(
            oi.quantity * oi.unit_price *
            (1 - oi.discount_percent / 100.0),
            0
        ),
        2
    ) AS gross_margin_pct

FROM orders o

JOIN order_items oi
    ON o.order_id = oi.order_id

JOIN customers c
    ON o.customer_id = c.customer_id

JOIN regions r
    ON o.region_id = r.region_id

JOIN products p
    ON oi.product_id = p.product_id

LEFT JOIN suppliers s
    ON p.supplier_id = s.supplier_id;


-- Shipment fact view
CREATE OR REPLACE VIEW vw_fact_shipments AS
SELECT
    sh.shipment_id,
    sh.order_id,
    sh.supplier_id,

    s.supplier_name,
    s.supplier_type,

    o.customer_id,
    c.customer_name,

    o.region_id,
    r.region_name,

    sh.shipment_date,
    sh.expected_delivery_date,
    sh.actual_delivery_date,
    sh.shipment_status,

    CASE
        WHEN sh.actual_delivery_date <= sh.expected_delivery_date
        THEN 1
        ELSE 0
    END AS on_time_flag,

    CASE
        WHEN sh.actual_delivery_date > sh.expected_delivery_date
        THEN 1
        ELSE 0
    END AS late_flag,

    (
        sh.actual_delivery_date -
        sh.shipment_date
    ) AS delivery_days,

    (
        sh.actual_delivery_date -
        sh.expected_delivery_date
    ) AS delivery_variance_days

FROM shipments sh

JOIN orders o
    ON sh.order_id = o.order_id

JOIN customers c
    ON o.customer_id = c.customer_id

JOIN regions r
    ON o.region_id = r.region_id

JOIN suppliers s
    ON sh.supplier_id = s.supplier_id;


-- Inventory fact view
CREATE OR REPLACE VIEW vw_fact_inventory AS
SELECT
    i.inventory_id,
    i.inventory_date,

    i.product_id,
    p.product_name,
    p.category,

    i.region_id,
    r.region_name,

    i.stock_quantity,
    i.reorder_level,

    i.stock_quantity - i.reorder_level
        AS stock_buffer,

    CASE
        WHEN i.stock_quantity = 0
        THEN 1
        ELSE 0
    END AS stockout_flag,

    CASE
        WHEN i.stock_quantity <= i.reorder_level
        THEN 1
        ELSE 0
    END AS reorder_flag

FROM inventory i

JOIN products p
    ON i.product_id = p.product_id

JOIN regions r
    ON i.region_id = r.region_id;