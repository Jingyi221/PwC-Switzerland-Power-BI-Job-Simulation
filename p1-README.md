Analyze Data in a Model Car Database with MySQL Workbench

Overview
In this project, I will step into the shoes of an entry-level data analyst at the fictional Mint Classics Company, helping to analyze data in a relational database with the goal of supporting inventory-related business decisions that lead to the closure of a storage facility.

Project Scenario
Mint Classics Company, a retailer of classic model cars and other vehicles, is looking at closing one of their storage facilities. 
To support a data-based business decision, they are looking for suggestions and recommendations for reorganizing or reducing inventory, while still maintaining timely service to their customers. For example, they would like to be able to ship a product to a customer within 24 hours of the order being placed.
As a data analyst, I have been asked to use MySQL Workbench to familiarize yourself with the general business by examining the current data. I will be provided with a data model and sample data tables to review. I will then need to isolate and identify those parts of the data that could be useful in deciding how to reduce inventory. I will write queries to answer questions like these:
1) Where are items stored and if they were rearranged, could a warehouse be eliminated?
2) How are inventory numbers related to sales figures? Do the inventory counts seem appropriate for each item?
3) Are we storing items that are not moving? Are any items candidates for being dropped from the product line?
The answers to questions like those should help me to formulate suggestions and recommendations for reducing inventory with the goal of closing one of the storage facilities. 
Project Objectives
1. Explore products currently in inventory.
2. Determine important factors that may influence inventory reorganization/reduction.
3. Provide analytic insights and data-driven recommendations.

My Challenge
My challenge will be to conduct an exploratory data analysis to investigate if there are any patterns or themes that may influence the reduction or reorganization of inventory in the Mint Classics storage facilities. To do this, I will import the database and then analyze data. I will also pose questions, and seek to answer them meaningfully using SQL queries to retrieve data from the database provided.
In this project, we'll use the fictional Mint Classics relational database and a relational data model. Both will be provided.
After I perform my  analysis, I will share my findings.

 
Solutions
Task 1- Import the Classic Model Car Relational Database
 
Here are all the tables after import ‘mintclassicsDB.sql’.
Task 2 - Familiarize yourself with the Mint Classic database and business processes.
 
This is an Enhanced Entity-Relationship (EER) diagram for the "MINT CLASSICS DATABASE" . Below is an analysis of the structure and relationships:
Key Entities and Relationships:
1.	Warehouses:
o	Attributes: warehouseCode, warehouseName, warehousePctCap
o	Relationship: Connected to products (One-to-Many) → Each warehouse stocks multiple products.
2.	Products:
o	Attributes: productCode, productName, productLine, productScale, productVendor, productDescription, quantityInStock, warehouseCode, buyPrice, MSRP
o	Relationship:
	Linked to warehouses (Many-to-One) via warehouseCode.
	Linked to productlines (Many-to-One).
	Connected to orderdetails (Many-to-Many) through productCode.
3.	Productlines:
o	Attributes: productLine, textDescription, htmlDescription, image
o	Relationship: Connected to products (One-to-Many).
4.	Customers:
o	Attributes: customerNumber, customerName, contactLastName, contactFirstName, phone, address, city, state, postalCode, country, salesRepEmployeeNumber, creditLimit
o	Relationships:
	Linked to employees via salesRepEmployeeNumber (One-to-One).
	Linked to orders (One-to-Many).
5.	Orders:
o	Attributes: orderNumber, orderDate, requiredDate, shippedDate, status, comments, customerNumber
o	Relationships:
	Connected to customers (Many-to-One).
	Connected to orderdetails (One-to-Many).
6.	Orderdetails:
o	Attributes: orderNumber, productCode, quantityOrdered, priceEach, orderLineNumber
o	Relationships:
	Connected to orders (Many-to-One).
	Connected to products (Many-to-One).
7.	Payments:
o	Attributes: customerNumber, checkNumber, paymentDate, amount
o	Relationship: Connected to customers (Many-to-One).
8.	Employees:
o	Attributes: employeeNumber, lastName, firstName, extension, email, officeCode, reportsTo, jobTitle
o	Relationships:
	Connected to offices via officeCode (Many-to-One).
	Hierarchical relationship within employees via reportsTo.
	Linked to customers through salesRepEmployeeNumber.
9.	Offices:
o	Attributes: officeCode, city, phone, address, state, country, territory
o	Relationship: Connected to employees (One-to-Many).
 
Task 3 – Investigate the business problem and identify tables impacted

Step 1: Explore Products in Inventory

We need to examine:
•	Inventory levels per warehouse.
•	Sales performance of each product.
•	Storage capacity utilization.

Query: Inventory Levels by Warehouse

SELECT p.warehouseCode, SUM(p.quantityInStock) AS total_stock
FROM products p
GROUP BY p.warehouseCode
ORDER BY total_stock DESC;

Query: Inventory Levels by Warehouse

SELECT w.warehouseCode, w.warehousePctCap, SUM(p.quantityInStock) AS total_stock
FROM warehouses w
JOIN products p ON w.warehouseCode = p.warehouseCode
GROUP BY w.warehouseCode, w.warehousePctCap
ORDER BY w.warehousePctCap DESC;

Step 2: Determine Key Factors for Inventory Reduction

•	Compare inventory levels with sales figures.
•	Identify slow-moving and overstocked products.
•	Determine the most frequently ordered products.

1.	Identifying Best-Selling Products

Query: Top-Selling Products by Quantity Sold (Top 10)

SELECT p.productCode, p.productName, p.warehouseCode, 
       SUM(od.quantityOrdered) AS total_sold
FROM orderdetails od
JOIN products p ON od.productCode = p.productCode
GROUP BY p.productCode, p.productName, p.warehouseCode
ORDER BY total_sold DESC
LIMIT 10;
 
Query: Top-Selling Products by Revenue

SELECT p.productCode, p.productName, p.warehouseCode, 
       SUM(od.quantityOrdered * od.priceEach) AS total_revenue
FROM orderdetails od
JOIN products p ON od.productCode = p.productCode
GROUP BY p.productCode, p.productName, p.warehouseCode
ORDER BY total_revenue DESC
LIMIT 10;
 
Query: Best-Selling Products by Warehouse

SELECT p.warehouseCode, p.productCode, p.productName, 
       SUM(od.quantityOrdered) AS total_sold
FROM orderdetails od
JOIN products p ON od.productCode = p.productCode
GROUP BY p.warehouseCode, p.productCode, p.productName
ORDER BY p.warehouseCode, total_sold DESC;  
 
Query: Fastest-Moving Products (High Sales & Low Stock)
SELECT p.productCode, p.productName, p.warehouseCode, 
       SUM(od.quantityOrdered) AS total_sold, p.quantityInStock
FROM orderdetails od
JOIN products p ON od.productCode = p.productCode
GROUP BY p.productCode, p.productName, p.warehouseCode, p.quantityInStock
HAVING total_sold > (0.9 * p.quantityInStock) -- Sold more than 90% of stock
ORDER BY total_sold DESC;
 
2.	Identifying Slow-Moving Inventory
Query: Identify Products with Low Sales but High Stock

SELECT p.productCode, p.productName, p.warehouseCode, 
       p.quantityInStock, 
       COALESCE(SUM(od.quantityOrdered), 0) AS total_sold
FROM products p
LEFT JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY p.productCode, p.productName, p.warehouseCode, p.quantityInStock
HAVING total_sold < (0.1 * p.quantityInStock) -- Less than 10% of stock sold
ORDER BY p.quantityInStock DESC;

Query: Identify Products with No Sales

SELECT p.productCode, p.productName, p.warehouseCode, p.quantityInStock
FROM products p
LEFT JOIN orderdetails od ON p.productCode = od.productCode
WHERE od.productCode IS NULL
ORDER BY p.quantityInStock DESC;
 
Query: Slow-Moving Products by Warehouse

SELECT p.warehouseCode, p.productCode, p.productName, 
       p.quantityInStock, 
       COALESCE(SUM(od.quantityOrdered), 0) AS total_sold
FROM products p
LEFT JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY p.warehouseCode, p.productCode, p.productName, p.quantityInStock
HAVING total_sold = 0
ORDER BY p.warehouseCode, p.quantityInStock DESC;
 
3.Query: Average Fulfillment Time per Warehouse

SELECT p.warehouseCode, AVG(DATEDIFF(o.shippedDate, o.orderDate)) AS avg_fulfillment_time
FROM orders o
JOIN orderdetails od ON o.orderNumber = od.orderNumber
JOIN products p ON od.productCode = p.productCode
GROUP BY p.warehouseCode
ORDER BY avg_fulfillment_time DESC;
 
Task 4 - Formulate suggestions and recommendations for solving the business problem.

Key Metrics

1.	Warehouse Capacity & Stock Levels:
o	Warehouse D: 75% capacity, 79,380 total stock
o	Warehouse A: 72% capacity, 131,688 total stock
o	Warehouse B: 67% capacity, 219,183 total stock
o	Warehouse C: 50% capacity, 124,880 total stock (Lowest utilization)
2.	Sales Performance & Revenue Contribution:
o	Warehouse B has the highest sales and revenue contribution (e.g., Ferrari 360 Spider Red sold 1,808 units generating $276,839.98).
o	Warehouse A also has significant sales volume across multiple products.
o	Warehouse C & D have lower sales, but Warehouse D has the lowest total stock.
3.	Stock vs. Sales Imbalance:
o	Warehouse B holds a lot of stock but also has strong sales.
o	Warehouse C has relatively lower stock and lower sales, indicating inefficiency.
4.	Average fulfillment time:
o	Warehouse D: 4.2572 days
o	Warehouse B: 3.9611 days
o	Warehouse A: 3.8930 days
o	Warehouse C: 3.5178 days
 
Recommendations

1. Close or Repurpose Warehouse D 
•	Warehouse D has the highest average fulfillment time (4.2572), meaning slower service to customers.
•	It also has the lowest total stock (79,380) and high capacity utilization (75%), making it a less efficient option.
•	Closing or repurposing Warehouse D and redistributing its inventory to A, B, and C can help streamline operations.
2. Optimize Stock Distribution Based on Sales & Capacity
•	Move slow-selling items from B to C to free up space in B, which has the highest stock level (219,183 units) but also strong sales.
•	Warehouse C has the lowest capacity utilization (50%), so it can take on more inventory from high-stock locations.
•	Warehouse A has a balanced inventory and should focus on high-turnover products.
3. Reduce Excess Stock for Low-Selling Items
•	The 1985 Toyota Supra (7,733 units in B) has zero sales—consider liquidating or discontinuing this product.
•	High-stock, slow-selling items like 1995 Honda Civic and 2002 Chevy Corvette should be reduced or moved to a lower-cost warehouse.
•	Implement a "just-in-time" (JIT) inventory strategy for slow-moving items to avoid overstocking.
4. Improve Order Fulfillment Efficiency
•	Warehouse C has the best fulfillment time (3.5178) it could be used as a regional hub for fast-moving products.
•	Warehouse B should focus on best-selling items to improve turnover and fulfillment speed.
•	Automate inventory tracking and replenishment to prevent unnecessary stock accumulation.
5. Maintain Customer Service While Reducing Costs
•	Use Warehouse C for quick-turnaround products to maintain low fulfillment times.
•	Consolidate slow-moving inventory into a single warehouse to reduce storage costs while ensuring availability.
•	Optimize transportation logistics to balance warehouse loads and improve delivery times.
 Suggested Action Plan:
•	Close or repurpose Warehouse D and distribute its inventory to A, B, and C
•	Keep Warehouse C and move more inventory there due to its available space and faster fulfillment times  
•	Prioritize high-demand items in A & B to maximize efficiency
•	Reduce or discontinue excess stock (Toyota Supra, low-sellers)
•	Improve automation & logistics to keep fulfillment times low
