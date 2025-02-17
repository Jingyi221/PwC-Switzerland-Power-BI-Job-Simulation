USE mintclassics;

SHOW TABLES;

-- Step 1: Explore Products in Inventory

-- Inventory Levels by Warehouse
SELECT p.warehouseCode, SUM(p.quantityInStock) AS total_stock
FROM products p
GROUP BY p.warehouseCode
ORDER BY total_stock DESC;

-- Inventory Levels by Warehouse
SELECT w.warehouseCode, w.warehousePctCap, SUM(p.quantityInStock) AS total_stock
FROM warehouses w
JOIN products p ON w.warehouseCode = p.warehouseCode
GROUP BY w.warehouseCode, w.warehousePctCap
ORDER BY w.warehousePctCap DESC;

-- Step 2: Determine Key Factors for Inventory Reductionad

-- Identifying Best-Selling Products
-- Top-Selling Products by Quantity Sold (Top 10)
SELECT p.productCode, p.productName, p.warehouseCode, 
       SUM(od.quantityOrdered) AS total_sold
FROM orderdetails od
JOIN products p ON od.productCode = p.productCode
GROUP BY p.productCode, p.productName, p.warehouseCode
ORDER BY total_sold DESC
LIMIT 10;

-- Top-Selling Products by Revenue (Top 10)
SELECT p.productCode, p.productName, p.warehouseCode, 
       SUM(od.quantityOrdered * od.priceEach) AS total_revenue
FROM orderdetails od
JOIN products p ON od.productCode = p.productCode
GROUP BY p.productCode, p.productName, p.warehouseCode
ORDER BY total_revenue DESC
LIMIT 10;

-- Best-Selling Products by Warehouse
SELECT p.warehouseCode, p.productCode, p.productName, 
       SUM(od.quantityOrdered) AS total_sold
FROM orderdetails od
JOIN products p ON od.productCode = p.productCode
GROUP BY p.warehouseCode, p.productCode, p.productName
ORDER BY p.warehouseCode, total_sold DESC;

-- Fastest-Moving Products (High Sales & Low Stock)
SELECT p.productCode, p.productName, p.warehouseCode, 
       SUM(od.quantityOrdered) AS total_sold, p.quantityInStock
FROM orderdetails od
JOIN products p ON od.productCode = p.productCode
GROUP BY p.productCode, p.productName, p.warehouseCode, p.quantityInStock
HAVING total_sold > (0.9 * p.quantityInStock) -- Sold more than 90% of stock
ORDER BY total_sold DESC;

-- Identify Products with Low Sales but High Stock
SELECT 
    p.productCode,
    p.productName,
    p.warehouseCode,
    p.quantityInStock,
    COALESCE(SUM(od.quantityOrdered), 0) AS total_sold
FROM
    products p
        LEFT JOIN
    orderdetails od ON p.productCode = od.productCode
GROUP BY p.productCode , p.productName , p.warehouseCode , p.quantityInStock
HAVING total_sold < (0.1 * p.quantityInStock)
ORDER BY p.quantityInStock DESC;

-- Identify Products with No Sales
SELECT p.productCode, p.productName, p.warehouseCode, p.quantityInStock
FROM products p
LEFT JOIN orderdetails od ON p.productCode = od.productCode
WHERE od.productCode IS NULL
ORDER BY p.quantityInStock DESC;

-- Slow-Moving Products by Warehouse
SELECT p.warehouseCode, p.productCode, p.productName, 
       p.quantityInStock, 
       COALESCE(SUM(od.quantityOrdered), 0) AS total_sold
FROM products p
LEFT JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY p.warehouseCode, p.productCode, p.productName, p.quantityInStock
HAVING total_sold = 0
ORDER BY p.warehouseCode, p.quantityInStock DESC;

-- Average Fulfillment Time per Warehouse
SELECT p.warehouseCode, AVG(DATEDIFF(o.shippedDate, o.orderDate)) AS avg_fulfillment_time
FROM orders o
JOIN orderdetails od ON o.orderNumber = od.orderNumber
JOIN products p ON od.productCode = p.productCode
GROUP BY p.warehouseCode
ORDER BY avg_fulfillment_time DESC;


