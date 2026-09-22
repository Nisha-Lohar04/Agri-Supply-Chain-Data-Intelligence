import os
import random
from datetime import datetime, timedelta

import numpy as np
import pandas as pd
import psycopg2
from dotenv import load_dotenv
from faker import Faker


# ---------------------------------------------------------
# Configuration
# ---------------------------------------------------------

load_dotenv()

DB_CONFIG = {
    "host": os.getenv("DB_HOST"),
    "port": os.getenv("DB_PORT"),
    "dbname": os.getenv("DB_NAME"),
    "user": os.getenv("DB_USER"),
    "password": os.getenv("DB_PASSWORD"),
}

fake = Faker()
Faker.seed(42)
random.seed(42)
np.random.seed(42)

DATA_START = datetime(2025, 1, 1)
DATA_END = datetime(2026, 8, 31)

NUM_CUSTOMERS = 2000
NUM_SUPPLIERS = 50
NUM_PRODUCTS = 100
NUM_ORDERS = 10000


# ---------------------------------------------------------
# Reference Data
# ---------------------------------------------------------

REGIONS = [
    ("North", "India"),
    ("South", "India"),
    ("East", "India"),
    ("West", "India"),
    ("Central", "India"),
]

PRODUCT_CATEGORIES = {
    "Grains": ["Wheat", "Rice", "Corn", "Barley", "Millet"],
    "Oilseeds": ["Soybean", "Sunflower", "Mustard", "Groundnut"],
    "Pulses": ["Chickpeas", "Lentils", "Peas", "Pigeon Pea"],
    "Processed": ["Flour", "Oil", "Protein Meal", "Animal Feed"],
}

SUPPLIER_TYPES = [
    "Farmer Cooperative",
    "Agricultural Producer",
    "Processing Unit",
    "Distributor",
]

CUSTOMER_TYPES = [
    "Retailer",
    "Food Manufacturer",
    "Distributor",
    "Wholesaler",
    "Institutional Buyer",
]


def random_date(start=DATA_START, end=DATA_END):
    delta = end - start
    return start + timedelta(days=random.randint(0, delta.days))


# ---------------------------------------------------------
# Generate Regions
# ---------------------------------------------------------

def generate_regions():
    rows = []

    for idx, (region_name, country) in enumerate(REGIONS, start=1):
        rows.append({
            "region_id": idx,
            "region_name": region_name,
            "country": country,
        })

    return pd.DataFrame(rows)


# ---------------------------------------------------------
# Generate Customers
# ---------------------------------------------------------

def generate_customers():
    rows = []

    for customer_id in range(1, NUM_CUSTOMERS + 1):
        region_id = random.randint(1, len(REGIONS))

        rows.append({
            "customer_id": customer_id,
            "customer_name": fake.company(),
            "customer_type": random.choice(CUSTOMER_TYPES),
            "region_id": region_id,
            "created_at": random_date(
                datetime(2023, 1, 1),
                DATA_START
            ).date(),
        })

    return pd.DataFrame(rows)


# ---------------------------------------------------------
# Generate Suppliers
# ---------------------------------------------------------

def generate_suppliers():
    rows = []

    for supplier_id in range(1, NUM_SUPPLIERS + 1):
        rows.append({
            "supplier_id": supplier_id,
            "supplier_name": fake.company(),
            "supplier_type": random.choice(SUPPLIER_TYPES),
            "region_id": random.randint(1, len(REGIONS)),
            "lead_time_days": random.randint(2, 15),
            "supplier_rating": round(
                random.uniform(2.8, 5.0), 2
            ),
        })

    return pd.DataFrame(rows)


# ---------------------------------------------------------
# Generate Products
# ---------------------------------------------------------

def generate_products():
    rows = []

    product_names = []

    for category, names in PRODUCT_CATEGORIES.items():
        for name in names:
            product_names.append((category, name))

    for product_id in range(1, NUM_PRODUCTS + 1):
        category, base_name = random.choice(product_names)

        unit_cost = round(
            random.uniform(50, 1000), 2
        )

        markup = random.uniform(1.10, 1.45)

        rows.append({
            "product_id": product_id,
            "product_name": f"{base_name} Grade {random.choice(['A', 'B', 'Premium'])} {product_id}",
            "category": category,
            "unit_price": round(unit_cost * markup, 2),
            "unit_cost": unit_cost,
            "supplier_id": random.randint(1, NUM_SUPPLIERS),
        })

    return pd.DataFrame(rows)


# ---------------------------------------------------------
# Generate Orders + Order Items
# ---------------------------------------------------------

def generate_orders(products, customers):
    order_rows = []
    item_rows = []

    item_id = 1

    for order_id in range(1, NUM_ORDERS + 1):

        customer_id = random.randint(1, NUM_CUSTOMERS)

        customer_region = customers.loc[
            customers["customer_id"] == customer_id,
            "region_id"
        ].iloc[0]

        order_date = random_date().date()

        status = random.choices(
            ["Completed", "Processing", "Cancelled"],
            weights=[0.82, 0.13, 0.05],
            k=1
        )[0]

        num_items = random.randint(1, 5)

        total_amount = 0

        for _ in range(num_items):

            product = products.sample(
                1,
                random_state=random.randint(1, 1000000)
            ).iloc[0]

            quantity = random.randint(1, 100)

            discount = round(
                random.uniform(0, 15), 2
            )

            item_total = (
                quantity
                * product["unit_price"]
                * (1 - discount / 100)
            )

            total_amount += item_total

            item_rows.append({
                "order_item_id": item_id,
                "order_id": order_id,
                "product_id": int(product["product_id"]),
                "quantity": quantity,
                "unit_price": float(product["unit_price"]),
                "discount_percent": discount,
            })

            item_id += 1

        order_rows.append({
            "order_id": order_id,
            "customer_id": customer_id,
            "order_date": order_date,
            "region_id": int(customer_region),
            "order_status": status,
            "total_amount": round(total_amount, 2),
        })

    return (
        pd.DataFrame(order_rows),
        pd.DataFrame(item_rows),
    )


# ---------------------------------------------------------
# Generate Inventory
# ---------------------------------------------------------

def generate_inventory(products):
    rows = []

    inventory_id = 1

    dates = pd.date_range(
        DATA_START,
        DATA_END,
        freq="MS"
    )

    for date in dates:

        sample_products = products.sample(
            min(len(products), 70),
            random_state=date.month + date.year
        )

        for _, product in sample_products.iterrows():

            for region_id in range(1, 6):

                stock = random.randint(50, 5000)

                reorder_level = random.randint(
                    100,
                    1000
                )

                rows.append({
                    "inventory_id": inventory_id,
                    "product_id": int(product["product_id"]),
                    "region_id": region_id,
                    "inventory_date": date.date(),
                    "stock_quantity": stock,
                    "reorder_level": reorder_level,
                })

                inventory_id += 1

    return pd.DataFrame(rows)


# ---------------------------------------------------------
# Generate Shipments
# ---------------------------------------------------------

def generate_shipments(orders, suppliers):
    rows = []

    shipment_id = 1

    for _, order in orders.iterrows():

        supplier_id = random.randint(
            1,
            NUM_SUPPLIERS
        )

        shipment_date = (
            order["order_date"]
            + timedelta(days=random.randint(1, 3))
        )

        expected_delivery = (
            shipment_date
            + timedelta(days=random.randint(3, 10))
        )

        # Most shipments arrive close to expected date.
        delay = random.choices(
            [-2, -1, 0, 1, 2, 3, 5, 7],
            weights=[5, 10, 30, 20, 15, 10, 7, 3],
            k=1
        )[0]

        actual_delivery = (
            expected_delivery
            + timedelta(days=delay)
        )

        rows.append({
            "shipment_id": shipment_id,
            "order_id": int(order["order_id"]),
            "supplier_id": supplier_id,
            "shipment_date": shipment_date,
            "expected_delivery_date": expected_delivery,
            "actual_delivery_date": actual_delivery,
            "shipment_status": (
                "Delivered"
                if actual_delivery <= DATA_END.date()
                else "In Transit"
            ),
        })

        shipment_id += 1

    return pd.DataFrame(rows)


# ---------------------------------------------------------
# Database Insert
# ---------------------------------------------------------

def insert_dataframe(cursor, dataframe, table_name, columns):

    query = f"""
        INSERT INTO {table_name}
        ({', '.join(columns)})
        VALUES ({', '.join(['%s'] * len(columns))})
    """

    records = []

    for _, row in dataframe.iterrows():
        values = []

        for column in columns:
            value = row[column]

            if pd.isna(value):
                value = None
            elif isinstance(value, np.integer):
                value = int(value)
            elif isinstance(value, np.floating):
                value = float(value)
            elif isinstance(value, np.bool_):
                value = bool(value)

            values.append(value)

        records.append(tuple(values))

    cursor.executemany(query, records)

# ---------------------------------------------------------
# Main
# ---------------------------------------------------------

def main():

    print("Generating agricultural supply-chain dataset...")

    regions = generate_regions()
    customers = generate_customers()
    suppliers = generate_suppliers()
    products = generate_products()

    orders, order_items = generate_orders(
        products,
        customers
    )

    inventory = generate_inventory(products)

    shipments = generate_shipments(
        orders,
        suppliers
    )

    print(f"Regions:      {len(regions):,}")
    print(f"Customers:    {len(customers):,}")
    print(f"Suppliers:    {len(suppliers):,}")
    print(f"Products:     {len(products):,}")
    print(f"Orders:       {len(orders):,}")
    print(f"Order Items:  {len(order_items):,}")
    print(f"Inventory:    {len(inventory):,}")
    print(f"Shipments:    {len(shipments):,}")

    connection = psycopg2.connect(**DB_CONFIG)

    cursor = connection.cursor()

    try:

        insert_dataframe(
            cursor,
            regions,
            "regions",
            [
                "region_id",
                "region_name",
                "country",
            ],
        )

        insert_dataframe(
            cursor,
            customers,
            "customers",
            [
                "customer_id",
                "customer_name",
                "customer_type",
                "region_id",
                "created_at",
            ],
        )

        insert_dataframe(
            cursor,
            suppliers,
            "suppliers",
            [
                "supplier_id",
                "supplier_name",
                "supplier_type",
                "region_id",
                "lead_time_days",
                "supplier_rating",
            ],
        )

        insert_dataframe(
            cursor,
            products,
            "products",
            [
                "product_id",
                "product_name",
                "category",
                "unit_price",
                "unit_cost",
                "supplier_id",
            ],
        )

        insert_dataframe(
            cursor,
            orders,
            "orders",
            [
                "order_id",
                "customer_id",
                "order_date",
                "region_id",
                "order_status",
                "total_amount",
            ],
        )

        insert_dataframe(
            cursor,
            order_items,
            "order_items",
            [
                "order_item_id",
                "order_id",
                "product_id",
                "quantity",
                "unit_price",
                "discount_percent",
            ],
        )

        insert_dataframe(
            cursor,
            inventory,
            "inventory",
            [
                "inventory_id",
                "product_id",
                "region_id",
                "inventory_date",
                "stock_quantity",
                "reorder_level",
            ],
        )

        insert_dataframe(
            cursor,
            shipments,
            "shipments",
            [
                "shipment_id",
                "order_id",
                "supplier_id",
                "shipment_date",
                "expected_delivery_date",
                "actual_delivery_date",
                "shipment_status",
            ],
        )

        connection.commit()

        print("\nData successfully loaded into PostgreSQL.")

    except Exception as error:

        connection.rollback()

        print("\nError loading data:")
        print(error)

        raise

    finally:

        cursor.close()
        connection.close()


if __name__ == "__main__":
    main()