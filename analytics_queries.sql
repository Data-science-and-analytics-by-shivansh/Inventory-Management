-- Current Stock Levels & Low Stock Alert
SELECT 
    ProductName,
    CurrentStock,
    CASE WHEN CurrentStock < 50 THEN 'Low Stock - Reorder' 
         WHEN CurrentStock > 500 THEN 'Overstock' 
         ELSE 'OK' END AS StockStatus
FROM Inventory
ORDER BY CurrentStock ASC;

-- Inventory Turnover Ratio
SELECT 
    ProductName,
    SUM(SalesQuantity) / AVG(CurrentStock) AS TurnoverRatio
FROM Inventory
GROUP BY ProductName
ORDER BY TurnoverRatio DESC;

-- Reorder Recommendations (assuming ReorderPoint column or calculate)
SELECT 
    ProductName,
    CurrentStock,
    LeadTimeDays,
    AVG(SalesQuantity) * LeadTimeDays * 1.2 AS SuggestedReorderQty  -- Safety factor 20%
FROM Inventory
GROUP BY ProductName, CurrentStock, LeadTimeDays
HAVING CurrentStock < AVG(SalesQuantity) * LeadTimeDays * 1.5;
