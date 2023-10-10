CREATE STAGE my_stage
URL = 's3://instakart/instakart_data/'
CREDENTIALS = (AWS_KEY_ID = 'AKIAQB5KUW4QYYHWWI4U' AWS_SECRET_KEY = 'tp7fM8eGR8IbvwiJIo27oRGzTZzXayAp+szHRu/z');

CREATE OR REPLACE FILE FORMAT csv_file_format
TYPE = 'CSV'
FIELD_DELIMITER = ','
SKIP_HEADER = 1
FIELD_OPTIONALLY_ENCLOSED_BY='"'; -- If the CSV file has a header row, skip it

--1)CREATING AISLES TABLE
CREATE TABLE aisles(
        aisle_id INTEGER PRIMARY KEY,
        aisle VARCHAR
    );
-- loading data into aisles table
COPY INTO aisles (aisle_id, aisle)
FROM @my_stage/aisles.csv
FILE_FORMAT = (FORMAT_NAME = 'csv_file_format');

--2)creating departments table
CREATE TABLE departments (
        department_id INTEGER PRIMARY KEY,
        department VARCHAR
    );
-- loading data into departments table
COPY INTO departments (department_id, department)
FROM @my_stage/departments.csv
FILE_FORMAT = (FORMAT_NAME = 'csv_file_format');

--3)creating products table
CREATE OR REPLACE TABLE products (
        product_id INTEGER PRIMARY KEY,
        product_name VARCHAR,
        aisle_id INTEGER,
        department_id INTEGER
    );
--loading data into products table
COPY INTO products (product_id, product_name, aisle_id, department_id)
FROM @my_stage/products.csv
FILE_FORMAT = (FORMAT_NAME = 'csv_file_format');

--4)creating orders table
CREATE OR REPLACE TABLE orders (
        order_id INTEGER PRIMARY KEY,
        user_id INTEGER,
        eval_set STRING,
        order_number INTEGER,
        order_dow INTEGER,
        order_hour_of_day INTEGER,
        days_since_prior_order INTEGER
    );
-- loading data
COPY INTO orders (order_id, user_id, eval_set, order_number, order_dow, order_hour_of_day, days_since_prior_order)
FROM @my_stage/orders.csv
FILE_FORMAT = (FORMAT_NAME = 'csv_file_format');

-- 5)order_products table

CREATE OR REPLACE TABLE order_products (
        order_id INTEGER,
        product_id INTEGER,
        add_to_cart_order INTEGER,
        reordered INTEGER,
        PRIMARY KEY (order_id, product_id)
    );
    
COPY INTO order_products (order_id, product_id, add_to_cart_order, reordered)
FROM @my_stage/order_products.csv
FILE_FORMAT = (FORMAT_NAME = 'csv_file_format');


select * from aisles;
select * from departments;
select * from products;
select * from orders;
select * from order_products;

-- dim_user table
create or replace table dim_users as (
select user_id from orders
);
select * from dim_users;

-- dim_products table
create or replace table dim_products as (
select product_id,product_name from products);
select * from dim_products;

-- dim_aisles table
create or replace table dim_aisles as(
select aisle_id,aisle from aisles);
select * from dim_aisles;

-- dim_departments table
create or replace table dim_departments as(
select department_id,department from departments
);
select * from dim_departments;
-- dim_orders 
create or replace table dim_orders as (
select order_id,order_number,order_dow,order_hour_of_day,days_since_prior_order from orders);
select * from dim_orders;

-- fact_order_products
CREATE TABLE fact_order_products AS (
  SELECT
    op.order_id,
    op.product_id,
    o.user_id,
    p.department_id,
    p.aisle_id,
    op.add_to_cart_order,
    op.reordered
  FROM
    order_products op
  JOIN
    orders o ON op.order_id = o.order_id
  JOIN
    products p ON op.product_id = p.product_id
);
select * from fact_order_products;

-- Analytics
-- 1)Query to calculate the total number of products ordered per department:
SELECT
  d.department,
  COUNT(*) AS total_products_ordered
FROM
  fact_order_products fop
JOIN
  dim_departments d ON fop.department_id = d.department_id
GROUP BY
  d.department;

-- 2)Query to find the top 5 aisles with the highest number of reordered products:
select da.aisle,count(*)as total_reordered from dim_aisles da
join fact_order_products fop 
on da.aisle_id=fop.aisle_id
group by da.aisle
order by total_reordered desc
limit 5;

-- 3)Query to calculate the average number of products added to the cart per order by day of the week:
SELECT
  o.order_dow,
  AVG(fop.add_to_cart_order) AS avg_products_per_order 
FROM fact_order_products fop
JOIN dim_orders o ON fop.order_id = o.order_id
GROUP BY
  o.order_dow;

-- 4)Query to identify the top 10 users with the highest number of unique products ordered:
SELECT
  u.user_id,COUNT(DISTINCT fop.product_id) AS unique_products_ordered
FROM
  fact_order_products fop
JOIN
  dim_users u ON fop.user_id = u.user_id
GROUP BY u.user_id
ORDER By unique_products_ordered DESC
LIMIT 10;

