# 📊 Data Warehouse Analytics Project (SQL Server)

## 🚀 Project Overview

This project demonstrates the design and implementation of a **Data Warehouse** using **SQL Server**, following a modern **Bronze → Silver → Gold architecture approach**.

The focus of this project is the **Gold Layer**, where data is transformed into a **business-ready format** for analytics, reporting, and decision-making.

---

## 🏗️ Data Architecture

### 🔹 Gold Layer (Analytics Layer)

The `gold` schema represents the **final layer** of the data pipeline.

It contains:

* Cleaned and structured data
* Business-friendly models
* Optimized tables for analytical queries

📌 Key characteristics:

* Dimensional modeling (Star Schema)
* High performance (indexes)
* Ready for BI tools (Power BI, Tableau, etc.)

---

## ⭐ Data Model (Star Schema)

The project follows a **Star Schema design**, composed of:

### 📌 Fact Table

* **`fact_sales`**

  * Stores transactional data
  * Metrics:

    * `sales_amount`
    * `quantity`
    * `price`

### 📌 Dimension Tables

* **`dim_customers`**

  * Customer attributes (name, gender, country, etc.)

* **`dim_products`**

  * Product attributes (category, cost, product line, etc.)

📊 Relationships:

* `fact_sales.customer_key → dim_customers.customer_key`
* `fact_sales.product_key → dim_products.product_key`

---

## ⚙️ Features Implemented

### ✅ Database Setup

* Automated database creation
* Schema creation (`gold`)
* Safe reset (drop & recreate)

### ✅ Data Loading

* Bulk data ingestion using `BULK INSERT`
* CSV-based dataset integration

### ✅ Data Modeling

* Primary Keys (PK)
* Foreign Keys (FK)
* Star Schema design

### ✅ Performance Optimization

* Clustered index on `order_date`
* Non-clustered indexes for joins and filtering

---

## 📈 Analytical Queries

This project includes advanced SQL analytics such as:

### 🔹 Time-Based Analysis

* Sales by Year and Month
* Monthly trends using `DATETRUNC`

### 🔹 Cumulative Analysis

* Running total of sales
* Moving average price

### 🔹 Performance Analysis

* Product performance vs average
* Year-over-Year comparison (`LAG`)

### 🔹 Proportional Analysis

* Category contribution to total sales (%)

### 🔹 Customer Segmentation

Customers are grouped into:

* **VIP** → High spending + long-term customers
* **Regular** → Moderate spending + long-term
* **New** → Recent customers

---

## 🧠 Key Business Insights

Using this model, we can answer questions like:

* Which products perform above or below average?
* How are sales evolving over time?
* Which categories drive the most revenue?
* Who are the most valuable customers?

---

## 🛠️ Technologies Used

* Microsoft SQL Server
* T-SQL
* Data Modeling (Star Schema)
* Data Warehousing Concepts

---

## 📂 Project Structure

```
/sql-data-analytics-project
│
├── datasets/
│   └── csv-files/
│
├── scripts/
│   └── data_warehouse_setup.sql
│
└── README.md
```

---

## ⚠️ Important Note

This script:

* Drops and recreates the database
* Deletes all existing data

👉 Use with caution in production environments.

---

## 🎯 What I Learned

* Designing a dimensional data model
* Implementing a Data Warehouse from scratch
* Writing advanced analytical SQL queries
* Optimizing performance with indexes
* Translating data into business insights

---

## 📌 Next Steps

* Integrate with Power BI for dashboards
* Add Silver/Bronze layers
* Automate ETL pipeline
* Deploy to cloud (Azure / AWS)

---

## 🤝 Let's Connect

If you're interested in data analytics, BI, or data engineering, feel free to connect or reach out!
