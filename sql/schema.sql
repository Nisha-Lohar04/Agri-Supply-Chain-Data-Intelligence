CREATE TABLE regions (
    region_id SERIAL PRIMARY KEY,
    region_name VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL
);

CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(150) NOT NULL,
    customer_type VARCHAR(50),
    region_id INT REFERENCES regions(region_id),
    created_at DATE
);

CREATE TABLE suppliers (
    supplier_id SERIAL PRIMARY KEY,
    supplier_name VARCHAR(150) NOT NULL,
    supplier_type VARCHAR(100),
    region_id INT REFERENCES regions(region_id),
    lead_time_days INT,
    supplier_rating DECIMAL(3,2)
);

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    category VARCHAR(100),
    unit_price DECIMAL(12,2),
    unit_cost DECIMAL(12,2),
    supplier_id INT REFERENCES suppliers(supplier_id)
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    order_date DATE NOT NULL,
    region_id INT REFERENCES regions(region_id),
    order_status VARCHAR(50),
    total_amount DECIMAL(14,2)
);

CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(order_id),
    product_id INT REFERENCES products(product_id),
    quantity INT NOT NULL,
    unit_price DECIMAL(12,2),
    discount_percent DECIMAL(5,2)
);

CREATE TABLE inventory (
    inventory_id SERIAL PRIMARY KEY,
    product_id INT REFERENCES products(product_id),
    region_id INT REFERENCES regions(region_id),
    inventory_date DATE NOT NULL,
    stock_quantity INT,
    reorder_level INT
);

CREATE TABLE shipments (
    shipment_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(order_id),
    supplier_id INT REFERENCES suppliers(supplier_id),
    shipment_date DATE,
    expected_delivery_date DATE,
    actual_delivery_date DATE,
    shipment_status VARCHAR(50)
);
