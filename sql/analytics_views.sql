-- ============================================================
-- AGRI SUPPLY CHAIN ANALYTICS LAYER
-- ============================================================

-- 1. Order-level sales and margin view
CREATE OR REPLACE VIEW vw_order_sales AS
SELECT
    o.order_id,
    o.order_date,
    o.customer_id,
    c.customer_name,
    c.customer_type,
    o.region_id,
    r.region_name,
    o.order_status,
    oi.product_id,
    p.product_name,
    p.category,
    oi.quantity,
    oi.unit_price,
    oi.discount_percent,

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
        ) - (oi.quantity * p.unit_cost),
        2
    ) AS gross_profit

FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN regions r
    ON o.region_id = r.region_id
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id;


-- 2. Supplier performance view
CREATE OR REPLACE VIEW vw_supplier_performance AS
SELECT
    s.supplier_id,
    s.supplier_name,
    s.supplier_type,
    r.region_name,
    s.lead_time_days,
    s.supplier_rating,

    COUNT(sh.shipment_id) AS total_shipments,

    COUNT(
        CASE
            WHEN sh.actual_delivery_date <= sh.expected_delivery_date
            THEN 1
        END
    ) AS on_time_shipments,

    ROUND(
        100.0 *
        COUNT(
            CASE
                WHEN sh.actual_delivery_date <= sh.expected_delivery_date
                THEN 1
            END
        )
        / NULLIF(COUNT(sh.shipment_id), 0),
        2
    ) AS on_time_delivery_pct,

    ROUND(
        AVG(
            sh.actual_delivery_date - sh.shipment_date
        ),
        2
    ) AS avg_delivery_days

FROM suppliers s
LEFT JOIN regions r
    ON s.region_id = r.region_id
LEFT JOIN shipments sh
    ON s.supplier_id = sh.supplier_id

GROUP BY
    s.supplier_id,
    s.supplier_name,
    s.supplier_type,
    r.region_name,
    s.lead_time_days,
    s.supplier_rating;


-- 3. Inventory health view
CREATE OR REPLACE VIEW vw_inventory_health AS
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

    CASE
        WHEN i.stock_quantity <= i.reorder_level
        THEN 'REORDER'
        ELSE 'HEALTHY'
    END AS inventory_status,

    CASE
        WHEN i.stock_quantity = 0
        THEN 1
        ELSE 0
    END AS stockout_flag

FROM inventory i
JOIN products p
    ON i.product_id = p.product_id
JOIN regions r
    ON i.region_id = r.region_id;


-- 4. Order fulfillment view
CREATE OR REPLACE VIEW vw_order_fulfillment AS
SELECT
    o.order_id,
    o.order_date,
    o.order_status,
    o.region_id,
    r.region_name,

    sh.shipment_id,
    sh.shipment_date,
    sh.expected_delivery_date,
    sh.actual_delivery_date,
    sh.shipment_status,

    CASE
        WHEN sh.actual_delivery_date <= sh.expected_delivery_date
        THEN 'On Time'
        ELSE 'Late'
    END AS delivery_performance,

    (
        sh.actual_delivery_date -
        sh.shipment_date
    ) AS delivery_days,

    (
        sh.actual_delivery_date -
        sh.expected_delivery_date
    ) AS delivery_variance_days

FROM orders o
JOIN regions r
    ON o.region_id = r.region_id
JOIN shipments sh
    ON o.order_id = sh.order_id;


-- 5. Regional business performance
CREATE OR REPLACE VIEW vw_regional_performance AS
SELECT
    r.region_id,
    r.region_name,

    COUNT(DISTINCT o.order_id) AS total_orders,

    ROUND(
        SUM(
            oi.quantity * oi.unit_price *
            (1 - oi.discount_percent / 100.0)
        ),
        2
    ) AS total_sales,

    ROUND(
        SUM(
            (
                oi.quantity * oi.unit_price *
                (1 - oi.discount_percent / 100.0)
            ) -
            (oi.quantity * p.unit_cost)
        ),
        2
    ) AS gross_profit,

    ROUND(
        100.0 *
        SUM(
            (
                oi.quantity * oi.unit_price *
                (1 - oi.discount_percent / 100.0)
            ) -
            (oi.quantity * p.unit_cost)
        )
        /
        NULLIF(
            SUM(
                oi.quantity * oi.unit_price *
                (1 - oi.discount_percent / 100.0)
            ),
            0
        ),
        2
    ) AS gross_margin_pct

FROM regions r
LEFT JOIN orders o
    ON r.region_id = o.region_id
LEFT JOIN order_items oi
    ON o.order_id = oi.order_id
LEFT JOIN products p
    ON oi.product_id = p.product_id

GROUP BY
    r.region_id,
    r.region_name;


-- 6. Data quality monitoring view
CREATE OR REPLACE VIEW vw_data_quality_summary AS

SELECT
    'customers' AS table_name,
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE customer_id IS NULL
    ) AS null_primary_keys,
    COUNT(*) FILTER (
        WHERE customer_name IS NULL
    ) AS null_required_fields
FROM customers

UNION ALL

SELECT
    'products',
    COUNT(*),
    COUNT(*) FILTER (
        WHERE product_id IS NULL
    ),
    COUNT(*) FILTER (
        WHERE product_name IS NULL
    )
FROM products

UNION ALL

SELECT
    'orders',
    COUNT(*),
    COUNT(*) FILTER (
        WHERE order_id IS NULL
    ),
    COUNT(*) FILTER (
        WHERE order_date IS NULL
    )
FROM orders

UNION ALL

SELECT
    'inventory',
    COUNT(*),
    COUNT(*) FILTER (
        WHERE inventory_id IS NULL
    ),
    COUNT(*) FILTER (
        WHERE inventory_date IS NULL
    )
FROM inventory

UNION ALL

SELECT
    'shipments',
    COUNT(*),
    COUNT(*) FILTER (
        WHERE shipment_id IS NULL
    ),
    COUNT(*) FILTER (
        WHERE shipment_date IS NULL
    )
FROM shipments;