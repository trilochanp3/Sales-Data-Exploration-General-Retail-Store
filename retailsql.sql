use retail_stores;

-- alter table data
-- change order_id order_id int,
-- change order_date order_date date,
-- change ship_mode ship_mode varchar(100),


-- 1. Find Top 10 Highest Revenue Generating Products 
SELECT 
    product_id, 
    revenue
FROM 
    (
        SELECT 
            product_id, 
            SUM(sale_price) AS revenue
        FROM 
            data
        GROUP BY 
            product_id
    ) sub
ORDER BY 
    revenue DESC
LIMIT 10;

-- 2. Find Top 5 Highest Selling Products in Each Region
SELECT 
    region, 
    product_id, 
    sales
FROM 
    (
        SELECT 
            region, 
            product_id, 
            sales,
            ROW_NUMBER() OVER(PARTITION BY region ORDER BY sales DESC) AS rn
        FROM 
            (
                SELECT 
                    region, 
                    product_id, 
                    SUM(sale_price) AS sales
                FROM 
                    data
                GROUP BY 
                    region, 
                    product_id
            ) sub
    ) sub
WHERE 
    rn <= 5;	
    
    
-- 3. Find Month-over-Month Growth Comparison
SELECT 
    order_month,
    SUM(CASE WHEN order_year = 2022 THEN sales END) AS sales_2022,
    SUM(CASE WHEN order_year = 2023 THEN sales END) AS sales_2023
FROM 
    (
        SELECT 
            MONTH(order_date) AS order_month,
            YEAR(order_date) AS order_year,
            SUM(sale_price) AS sales
        FROM 
            data
        GROUP BY 
            MONTH(order_date), 
            YEAR(order_date)
    ) sub
GROUP BY 
    order_month
ORDER BY 
    order_month;
   
alter table data
change order_date order_date date;

-- 4. Find Month with Highest Sales for Each Category
SELECT 
    category,
    LEFT(order_year_month, 4) AS order_year,
    RIGHT(order_year_month, 2) AS order_month,
    sales
FROM 
    (
        SELECT 
            category,
            order_year_month,
            sales,
            ROW_NUMBER() OVER(PARTITION BY category ORDER BY sales DESC) AS rn
        FROM 
            (
                SELECT 
                    category,
                    DATE_FORMAT(order_date, '%Y%m') AS order_year_month,
                    SUM(sale_price) AS sales
                FROM 
                    data
                GROUP BY 
                    category, 
                    DATE_FORMAT(order_date, '%Y%m')
            ) sub
    ) sub
WHERE 
    rn = 1;
    
    
-- 5. Find Sub-Category with Highest Growth by Profit
SELECT 
    sub_category,
    sales_2022,
    sales_2023,
    sales_2023 - sales_2022 AS growth
FROM 
    (
        SELECT 
            sub_category,
            SUM(CASE WHEN order_year = 2022 THEN sales END) AS sales_2022,
            SUM(CASE WHEN order_year = 2023 THEN sales END) AS sales_2023
        FROM 
            (
                SELECT 
                    sub_category,
                    YEAR(order_date) AS order_year,
                    SUM(sale_price) AS sales
                FROM 
                    data
                GROUP BY 
                    sub_category, 
                    YEAR(order_date)
            ) sub
        GROUP BY 
            sub_category
    ) sub
ORDER BY 
    growth DESC;
    
