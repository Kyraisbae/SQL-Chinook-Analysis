 /*
 Task 5: SQL Analysis on Chinook Database
 Author: Annabelle Felix-Uche
 Internship: Elevvo Pathways

 Description:
 This SQL script performs exploratory business analysis 
 on the Chinook music store database. It answers key 
 business questions such as revenue trends, top-selling 
 products, and customer/artist performance.

 Queries included:
   1. Top 10 Artists by Revenue
   2. Revenue by Genre
   3. Average Revenue per Invoice
   4. Revenue by Region
   5. Monthly Revenue Trend
   6. Top Selling Products (Tracks)
   7. JOINs – Combine Products and Sales
   8. Revenue by Country
   9. Rank Customers by Spend within Each Country
   10. Top Track by Genre (ROW_NUMBER)
   11. Top 10 Customers by Spend
   12. Year-over-Year Revenue Growth
   13. Top Albums by Sales

 Note:
 - Queries use JOINs, CASE statements, GROUP BY, 
   and window functions (ROW_NUMBER, RANK).
 - Results provide insights into product performance, 
   customer value, and overall sales trends.
*/


-- 1: Top 10 Artists by Revenue

SELECT ar.Name AS Artist, SUM(il.UnitPrice * il.Quantity) AS Revenue
FROM InvoiceLine il
JOIN Track t ON il.TrackId = t.TrackId
JOIN Album al ON t.AlbumId = al.AlbumId
JOIN Artist ar ON al.ArtistId = ar.ArtistId
GROUP BY ar.ArtistId
ORDER BY Revenue DESC
LIMIT 10;

-- 2: Revenue by Genre

SELECT g.Name AS Genre, SUM(il.UnitPrice * il.Quantity) AS Revenue
FROM InvoiceLine il
JOIN Track t ON il.TrackId = t.TrackId
JOIN Genre g ON t.GenreId = g.GenreId
GROUP BY g.GenreId
ORDER BY Revenue DESC;

-- 3: Average revenue by Invoice

SELECT ROUND(AVG(Total), 2) AS AvgInvoiceRevenue
FROM Invoice;

-- 4: Revenue by Region

SELECT 
    CASE 
        WHEN c.Country IN ('USA', 'Canada', 'Mexico') THEN 'North America'
        WHEN c.Country IN ('UK', 'France', 'Germany', 'Italy', 'Spain', 'Norway', 'Czech Republic') THEN 'Europe'
        WHEN c.Country IN ('Brazil', 'Argentina', 'Chile') THEN 'South America'
        WHEN c.Country IN ('Australia', 'India', 'Japan', 'Singapore') THEN 'Asia-Pacific'
        ELSE 'Other'
    END AS Region,
    SUM(i.Total) AS Revenue
FROM Invoice i
JOIN Customer c ON i.CustomerId = c.CustomerId
GROUP BY Region
ORDER BY Revenue DESC;

-- 5: Monthly revenue trend

SELECT 
    strftime('%Y-%m', InvoiceDate) AS Month,
    SUM(Total) AS Revenue
FROM Invoice
GROUP BY Month
ORDER BY Month;

-- 6: Top selling products

SELECT t.Name AS Track,
       SUM(il.Quantity) AS UnitsSold,
       SUM(il.UnitPrice * il.Quantity) AS Revenue
FROM InvoiceLine il
JOIN Track t ON il.TrackId = t.TrackId
GROUP BY t.TrackId
ORDER BY Revenue DESC
LIMIT 10;

-- 7: Using JOINs to Combine Product and Sales table

SELECT 
    t.TrackId,
    t.Name AS TrackName,
    g.Name AS Genre,
    ar.Name AS Artist,
    al.Title AS Album,
    SUM(il.Quantity * il.UnitPrice) AS Revenue,
    SUM(il.Quantity) AS UnitsSold
FROM InvoiceLine il
JOIN Track t ON il.TrackId = t.TrackId
JOIN Album al ON t.AlbumId = al.AlbumId
JOIN Artist ar ON al.ArtistId = ar.ArtistId
JOIN Genre g ON t.GenreId = g.GenreId
GROUP BY t.TrackId, t.Name, g.Name, ar.Name, al.Title
ORDER BY Revenue DESC;

-- 8: Revenue by country

SELECT c.Country, SUM(i.Total) AS Revenue
FROM Invoice i
JOIN Customer c ON i.CustomerId = c.CustomerId
GROUP BY c.Country
ORDER BY Revenue DESC;

-- 9: RANK Customer by spend withing each country

SELECT c.Country,
       c.FirstName || ' ' || c.LastName AS Customer,
       SUM(i.Total) AS TotalSpent,
       RANK() OVER (PARTITION BY c.Country ORDER BY SUM(i.Total) DESC) AS RankInCountry
FROM Customer c
JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY c.Country, c.CustomerId
ORDER BY c.Country, RankInCountry;

-- 10: TOP Tracks by Genre (ROW NUMBER)

SELECT Genre, Track, UnitsSold
FROM (
    SELECT g.Name AS Genre, 
           t.Name AS Track,
           SUM(il.Quantity) AS UnitsSold,
           ROW_NUMBER() OVER (
               PARTITION BY g.GenreId 
               ORDER BY SUM(il.Quantity) DESC
           ) AS RowNum
    FROM InvoiceLine il
    JOIN Track t ON il.TrackId = t.TrackId
    JOIN Genre g ON t.GenreId = g.GenreId
    GROUP BY g.GenreId, t.TrackId
) ranked
WHERE RowNum = 1;

-- 11: Top 10 Customers by Spend

SELECT c.FirstName || ' ' || c.LastName AS Customer,
       SUM(i.Total) AS TotalSpent
FROM Customer c
JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId
ORDER BY TotalSpent DESC
LIMIT 10;

-- 12: Year over Year Growth

SELECT strftime('%Y', InvoiceDate) AS Year, SUM(Total) AS Revenue
FROM Invoice
GROUP BY Year
ORDER BY Year;

-- 13: Top Albums By Sales

SELECT al.Title AS Album, ar.Name AS Artist, SUM(il.UnitPrice * il.Quantity) AS Revenue
FROM InvoiceLine il
JOIN Track t ON il.TrackId = t.TrackId
JOIN Album al ON t.AlbumId = al.AlbumId
JOIN Artist ar ON al.ArtistId = ar.ArtistId
GROUP BY al.AlbumId
ORDER BY Revenue DESC
LIMIT 10;



