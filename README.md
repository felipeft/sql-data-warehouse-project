# SQL Data Warehouse & Analytics Project

A modern **Data Warehouse and Analytics** project built with **SQL Server**, covering the complete data engineering workflow from raw data ingestion to analytical modeling and business insights.

This project was originally developed as part of the **Data With Baraa SQL Data Warehouse course** and was later **refactored, reorganized, and documented by Felipe Feitosa Teixeira** as part of my Data Engineering learning journey and professional portfolio.

---

## Project Overview

The goal of this project is to design and implement a modern data warehouse that consolidates data from multiple source systems and prepares it for analytical workloads.

The solution follows the **Medallion Architecture**, separating the data pipeline into three layers:

- **Bronze** — raw data ingestion
- **Silver** — data cleansing, standardization, and transformation
- **Gold** — business-ready dimensional models for analytics

The project demonstrates practical concepts commonly used in Data Engineering, including:

- ETL pipeline development
- Data cleansing and transformation
- Data integration
- Dimensional data modeling
- Star schema design
- Data quality validation
- SQL analytics
- Data warehouse architecture
- Technical documentation

---

## Data Architecture

The architecture follows the **Bronze, Silver, and Gold** layers of the Medallion Architecture.

![Data Architecture](docs/data_architecture.png)

### Bronze Layer

The Bronze layer stores the source data in its original format.

Data from the ERP and CRM systems is provided through CSV files and loaded into SQL Server with minimal transformation.

### Silver Layer

The Silver layer is responsible for preparing the data for downstream analytical use.

This stage includes:

- Data cleansing
- Standardization
- Normalization
- Duplicate handling
- Data type validation
- Business-rule transformations
- Integration between ERP and CRM datasets

### Gold Layer

The Gold layer contains business-ready datasets designed for analytics and reporting.

The data is modeled using a **Star Schema**, with fact and dimension tables optimized for analytical queries.

---

## ETL Pipeline

The project implements an ETL workflow that moves data through the three warehouse layers.

```text
CSV Sources
    |
    v
Bronze Layer
Raw ingestion
    |
    v
Silver Layer
Cleaning + Transformation + Integration
    |
    v
Gold Layer
Star Schema / Analytical Model
    |
    v
SQL Analytics & Reporting
```

The pipeline integrates information from two source systems:

- **CRM**
  - Customers
  - Products
  - Sales transactions

- **ERP**
  - Customer demographics
  - Customer locations
  - Product categories

---

## Project Requirements

### Data Engineering

The main objective is to build a modern SQL Server data warehouse capable of consolidating sales information from multiple systems.

The implementation includes:

- Importing ERP and CRM datasets from CSV files
- Cleaning and validating source data
- Resolving data quality issues
- Integrating information from different systems
- Building analytical fact and dimension tables
- Creating reusable SQL scripts for each warehouse layer
- Documenting the architecture and data model

The project focuses on the latest available dataset and does not implement historical tracking.

---

## Analytics

The Gold layer supports SQL-based analysis focused on three main business areas:

### Customer Behavior

Analysis of customer characteristics and purchasing behavior.

### Product Performance

Evaluation of products, categories, and their contribution to sales.

### Sales Trends

Analysis of sales performance and trends over time.

These analytical models make it possible to generate business metrics and support data-driven decision-making.

---

## Data Modeling

The analytical layer uses dimensional modeling based on a **Star Schema**.

The Gold layer contains:

- Fact tables
- Customer dimensions
- Product dimensions
- Date-related attributes
- Business-ready analytical fields

![Data Model](docs/data_model.png)

This structure simplifies analytical queries and improves readability for BI and reporting workloads.

---

## Data Flow

The complete flow of data through the project is documented below:

![Data Flow](docs/data_flow.png)

Additional documentation is available in the `docs/` directory.

---

## Technologies

The main technologies and tools used in this project are:

- **SQL**
- **Microsoft SQL Server**
- **SQL Server Management Studio (SSMS)**
- **ETL**
- **Dimensional Modeling**
- **Star Schema**
- **Medallion Architecture**
- **Draw.io**
- **Git**
- **GitHub**

---

## Repository Structure

```text
data-warehouse-project/
│
├── datasets/
│   ├── source_crm/
│   └── source_erp/
│
├── docs/
│   ├── requirements.md
│   ├── data_architecture.png
│   ├── data_flow.png
│   ├── data_integration.png
│   ├── data_model.png
│   ├── ETL.png
│   ├── data_catalog.md
│   ├── naming_conventions.md
│   ├── data_layers.pdf
│   └── Project_Notes_Sketches.pdf
│
├── scripts/
│   ├── init_database.sql
│   ├── bronze/
│   ├── silver/
│   └── gold/
│
├── tests/
│
├── README.md
├── LICENSE
└── .gitignore
```

---

## Documentation

The `docs/` directory contains supporting documentation for the project, including:

- Data architecture
- Data flow
- Data integration
- ETL design
- Dimensional model
- Data catalog
- Naming conventions
- Project requirements

For the detailed project requirements, see:

[`docs/requirements.md`](docs/requirements.md)

---

## Running the Project

### 1. Clone the repository

```bash
git clone https://github.com/felipeft/sql-data-warehouse-project.git
cd sql-data-warehouse-project
```

### 2. Install SQL Server

The project uses **Microsoft SQL Server** as the database engine.

SQL Server Express can be used for local development.

### 3. Open SQL Server Management Studio

Connect to your SQL Server instance using SSMS.

### 4. Initialize the database

Run:

```text
scripts/init_database.sql
```

This creates the database structure and the Bronze, Silver, and Gold schemas.

### 5. Load the Bronze Layer

Execute the scripts inside:

```text
scripts/bronze/
```

These scripts ingest the raw CSV datasets.

### 6. Build the Silver Layer

Execute the scripts inside:

```text
scripts/silver/
```

These scripts clean, standardize, validate, and integrate the source data.

### 7. Build the Gold Layer

Execute the scripts inside:

```text
scripts/gold/
```

These scripts create the analytical fact and dimension models.

### 8. Run Data Quality Tests

Use the scripts available in:

```text
tests/
```

to validate the Silver and Gold layers.

---

## Key Concepts Practiced

This project was used to strengthen practical knowledge in:

- SQL development
- Data Engineering
- Data Warehouse design
- ETL pipelines
- Data quality
- Data integration
- Dimensional modeling
- Star schema
- Analytical SQL
- Data documentation
- Git and version control

---

## Project Origin

This repository is based on the **SQL Data Warehouse Project** taught by **Baraa Khatib Salkini — Data With Baraa**.

The original educational project provided the initial architecture, datasets, and learning workflow.

This version was completed and refactored for study and portfolio purposes, with adjustments to project organization, documentation, implementation, and presentation.

Original project:

https://github.com/DataWithBaraa/sql-data-warehouse-project

---

## About Me

I'm **Felipe Feitosa Teixeira**, a Computer Engineer focused on **Data Engineering**, backend development, and data-driven systems.

I use projects like this to develop practical experience with data pipelines, SQL, data modeling, analytics, and modern Data Engineering architectures.

### Connect with me

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Felipe%20Feitosa%20Teixeira-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/felipe-ft)

[![Portfolio](https://img.shields.io/badge/Portfolio-felipeft.github.io-000000?style=for-the-badge&logo=github&logoColor=white)](https://felipeft.github.io/)

---

## License

This project is licensed under the [MIT License](LICENSE).

The educational foundation of this project belongs to its original author and course. This repository represents my implementation and refactoring of the project for learning and portfolio purposes.
