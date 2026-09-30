# Agri Supply Chain Data Intelligence

An end-to-end **data analytics and business intelligence platform** for analyzing sales, inventory, supplier performance, shipments, and data quality across an agricultural supply chain.

## Overview

This project implements a production-style analytics pipeline that transforms structured operational data into business insights using Python ETL, PostgreSQL, SQL analytics, and Power BI.

**Pipeline:**

Raw Data → Python ETL → Data Validation → PostgreSQL → SQL Analytics → Power BI → Business Insights

## Dataset

The synthetic dataset contains:

- 5 regions
- 2,000 customers
- 50 suppliers
- 100 products
- 10,000 orders
- 30,068 order items
- 7,000 inventory records
- 10,000 shipment records

## Key Analytics

The platform calculates:

- Total sales and gross profit
- Gross margin
- Average order value
- Regional performance
- Product/category sales
- Supplier on-time delivery
- Inventory stockout and reorder risk
- Monthly sales trends
- Customer activity
- Data-quality exceptions

## Executive KPIs

Current dataset results:

| KPI | Value |
|---|---:|
| Total Sales | ₹912.56M |
| Gross Profit | ₹139.78M |
| Gross Margin | 15.32% |
| Orders | 10,000 |
| Units Sold | 1,512,336 |
| Customers | 1,988 |
| Products | 100 |
| Average Order Value | ₹91,255.74 |

## Power BI Dashboards

### Executive Overview

Provides:

- Executive KPI cards
- Monthly sales trend
- Regional sales
- Top 10 products
- Supplier delivery performance
- Inventory stockout events
- Product-category sales

### Supply Chain Performance

Provides:

- Average supplier on-time delivery
- Inventory stockout monitoring
- Supplier performance analysis
- Stockout risk by region
- Stockout rate by product category

### Data Quality & Monitoring

Provides:

- Orders processed
- Inventory records
- Stockout exceptions
- Regional/category inventory risk
- Reorder and stockout monitoring

## Data Quality

Automated validation checks cover:

- Missing customer names
- Invalid product prices
- Missing order dates
- Invalid order amounts
- Invalid quantities
- Negative inventory
- Invalid reorder levels
- Invalid shipment dates
- Missing shipment dates
- Orphan order items
  
All implemented validation checks currently pass on the generated dataset.

## Tech Stack

- **Python:** Pandas, NumPy, Faker
- **Database:** PostgreSQL
- **Analytics:** SQL, DAX
- **BI:** Microsoft Power BI
- **Infrastructure:** Docker
- **Version Control:** Git/GitHub


## Project Structure

```text
Agri-Supply-Chain-Data-Intelligence/
├── data/
│   ├── raw/
│   └── processed/
├── src/
│   ├── etl/
│   ├── validation/
│   └── analytics/
├── sql/
├── powerbi/
├── docs/
├── tests/
├── docker-compose.yml
├── requirements.txt
└── .gitignore
```
## Running the Project
## 1. Start PostgreSQL
```bash
 docker compose up -d
```
## 2. Activate the Python environment
```bash
 .venv\Scripts\Activate.ps1
```
## 3. Install dependencies
```bash
 pip install -r requirements.txt
```
## 4. Generate and load the dataset
```bash
 python src/etl/generate_data.py
```
## 5. Run data validation
```bash
 python src/validation/validate_data.py
```

Load the analytical views from the PostgreSQL database.
 
## Key Skills Demonstrated


| Area | Skills |
|---|---|
| **Data Engineering** | Python ETL · Data Validation · Relational Data Modeling · PostgreSQL |
| **Data Analytics** | SQL · KPI Development · Data Quality · Supply Chain Analytics |
| **Business Intelligence** | Power BI · DAX · Dashboard Development · Data Visualization |
| **Tools & Infrastructure** | Docker · Git · GitHub |

