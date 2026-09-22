import os

import psycopg2
from dotenv import load_dotenv


load_dotenv()


def get_connection():
    return psycopg2.connect(
        host=os.getenv("DB_HOST"),
        port=os.getenv("DB_PORT"),
        dbname=os.getenv("DB_NAME"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
    )


VALIDATION_QUERIES = {
    "customers_missing_names": """
        SELECT COUNT(*)
        FROM customers
        WHERE customer_name IS NULL;
    """,

    "products_invalid_prices": """
        SELECT COUNT(*)
        FROM products
        WHERE unit_price <= 0
           OR unit_cost <= 0;
    """,

    "orders_missing_dates": """
        SELECT COUNT(*)
        FROM orders
        WHERE order_date IS NULL;
    """,

    "orders_invalid_amounts": """
        SELECT COUNT(*)
        FROM orders
        WHERE total_amount < 0;
    """,

    "order_items_invalid_quantity": """
        SELECT COUNT(*)
        FROM order_items
        WHERE quantity <= 0;
    """,

    "inventory_negative_stock": """
        SELECT COUNT(*)
        FROM inventory
        WHERE stock_quantity < 0;
    """,

    "inventory_negative_reorder_level": """
        SELECT COUNT(*)
        FROM inventory
        WHERE reorder_level < 0;
    """,

    "shipments_invalid_dates": """
        SELECT COUNT(*)
        FROM shipments
        WHERE actual_delivery_date < shipment_date;
    """,

    "shipments_missing_dates": """
        SELECT COUNT(*)
        FROM shipments
        WHERE shipment_date IS NULL
           OR expected_delivery_date IS NULL
           OR actual_delivery_date IS NULL;
    """,

    "orphan_order_items": """
        SELECT COUNT(*)
        FROM order_items oi
        LEFT JOIN orders o
            ON oi.order_id = o.order_id
        WHERE o.order_id IS NULL;
    """,
}


def run_validation():
    connection = get_connection()
    cursor = connection.cursor()

    print("\nRunning data-quality checks...\n")

    total_checks = 0
    passed_checks = 0
    failed_checks = 0

    for check_name, query in VALIDATION_QUERIES.items():

        cursor.execute(query)
        result = cursor.fetchone()[0]

        total_checks += 1

        if result == 0:
            status = "PASS"
            passed_checks += 1
        else:
            status = "FAIL"
            failed_checks += 1

        print(
            f"{status:<6} | "
            f"{check_name:<35} | "
            f"records: {result}"
        )

    cursor.close()
    connection.close()

    print("\n" + "=" * 70)
    print(f"Total checks : {total_checks}")
    print(f"Passed       : {passed_checks}")
    print(f"Failed       : {failed_checks}")
    print("=" * 70)

    if failed_checks > 0:
        raise SystemExit(1)


if __name__ == "__main__":
    run_validation()