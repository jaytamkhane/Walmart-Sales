USE walmart_db; 

SELECT *
FROM walmart;

-- find how many transections have done by each methods
SELECT 
	payment_method,
    count(*) AS total_counts
FROM walmart
GROUP BY payment_method;

-- HOW MANY STORES THEY HAVE
SELECT
	Branch,
    MIN(Quantity)
FROM Walmart
GROUP BY Branch;

/* BUISNESS PROBLEMS */

-- Q1. FIND DIFFERENT PAYMENTS METHOD, NO OF TRANSACTIONS AND NO QUANTITY SOLD.

SELECT 
	payment_method,
    SUM(Quantity) AS No_Quantity_Sold,
    count(*) AS No_Payments
FROM walmart
GROUP BY payment_method;

-- Q2. IDENTIFY THE HIGHEST RATED CATEGORY IN EACH BRANCH, DISPLAY THE BRANCH, CATEGORY AND AVERAGE RATING.

SELECT *
FROM
( SELECT 
	Branch,
    Category,
    AVG(Rating) AS Avg_Rating,
    RANK() OVER(PARTITION BY Branch ORDER BY AVG(Rating) DESC) AS Rank_
FROM Walmart
GROUP BY Branch, Category
) AS High_Rated_Category
WHERE Rank_ = 1;

-- Q3. IDENTIFY THE BUSIEST DAY FOR EACH BRANCH BASED ON NUMBER OF TRANSACTIONS

SELECT *
FROM
	(SELECT 
		Branch,
		DAYNAME(STR_TO_DATE(Date, '%d/%m/%Y')) AS Day_Name,
		COUNT(*) AS No_Transactions,
		RANK() OVER(PARTITION BY Branch ORDER BY COUNT(*) DESC) AS Rank_
	FROM Walmart
	GROUP BY Branch, Day_Name) AS Busiest_Day
WHERE RANK_ = 1;

-- Q4. CALCULATE THE TOTAL QUANTITY OF ITEMS SOLD PER PAYMENT METHOD, LIST PAYMENT_METHOD AND TOTAL_QUANTITY

SELECT 
	payment_method,
    SUM(Quantity) AS No_Items_Sold
FROM walmart
GROUP BY payment_method;

-- Q5. DETERMINE THE AVERAGE, MINIMUM AND MAXIMUM RATING OF CATEGORY FOR EACH CITY. LIST THE CITY, AVG_RATING, MIN_RATING AND MAX_RATING.

SELECT 
	city,
    Category,
    MAX(Rating) AS Max_Ratings,
    MIN(Rating) AS Min_Ratings,
    AVG(Rating) AS Avg_Ratings
FROM walmart
GROUP BY City, Category;

/* Q6. CALCULATE THE TOTAL PROFIT FOR EACH CATEGORY BY CONSIDERING TOYAL_PROFIT AS (UNIT_PRICE * QUANTITY * PROFIT_MARGIN).
       LIST CATEGORY AND TOTAL PROFIT , ORDER FROM HIGHEST TO LOWEST.*/  

SELECT 
	Category,
    ROUND(SUM(Total), 2) AS Total_Revenue,
    ROUND(SUM(Total * Profit_Margin), 2) AS Profit
FROM Walmart
GROUP BY Category;

-- Q7. DETERMINE THE MOST COMMON PAYMENT METHOD FOR EACH BRACH. DISPLAY BRANCH AND PREFERED PAYMENT METHOD.

WITH cte
AS
(SELECT 
	Branch,
    Payment_Method,
    COUNT(*) AS Total_Trans,
    RANK() OVER(PARTITION BY Branch ORDER BY COUNT(*) DESC) AS Rank_
FROM Walmart
GROUP BY Branch, Payment_Method
)
SELECT *
FROM cte
WHERE Rank_ = 1;

-- Q8. CATEGORIES SALES INTO 3 GROUPS MORNING, AFTERNOON AND EVENING. FIND OUT WHICH OF THE SHIFT AND NUMBER OF INVOICES.

SELECT Branch,
    CASE 
        WHEN TIME(time) BETWEEN '06:00:00' AND '11:59:59' THEN 'Morning'
        WHEN TIME(time) BETWEEN '12:00:00' AND '17:59:59' THEN 'Afternoon'
        ELSE 'Evening'
    END AS Shift,
    COUNT(invoice_id) AS Number_of_Invoices
FROM Walmart
GROUP BY Branch, Shift
ORDER BY Branch, Number_of_Invoices DESC;

-- Q9. IDENTIFY THE 5 BRANCH WITH HIGHEST DECRESE RATIO IN REVENUE COMPARE TO LAST YEAR (CURRENT YEAR 2023 AND LAST YEAR 2022).

WITH Revenue
AS 
(SELECT 
	Branch, 
	YEAR(date) AS Year, 
	SUM(Total) AS TotalRevenue
FROM Walmart
WHERE YEAR(date) IN (2022, 2023)
GROUP BY Branch, YEAR(date)
),
RevenueDecrease 
AS 
(SELECT 
	r2022.Branch,
	r2022.TotalRevenue AS Revenue_2022,
	r2023.TotalRevenue AS Revenue_2023,
	((r2022.TotalRevenue - r2023.TotalRevenue) * 100.0 / r2022.TotalRevenue) AS Decrease_Percentage
FROM Revenue r2022
INNER JOIN Revenue r2023
ON r2022.Branch = r2023.Branch
WHERE r2022.Year = 2022 AND r2023.Year = 2023
)
SELECT 
    Branch,
	ROUND(Revenue_2022,2) AS Revenue_2022,
    Revenue_2023,
    ROUND(Decrease_Percentage,2) AS Decrease_Percentage
FROM RevenueDecrease
ORDER BY Decrease_Percentage DESC
LIMIT 5;
