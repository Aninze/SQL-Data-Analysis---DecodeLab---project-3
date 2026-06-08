-----------------------------------------------------------------------------------------------------------
/*
-----------------------------------------------------------------------------------------------------------
DECODE LAB PROJECT 3

Use SQL queries to extract insights from a dataset Key Requirement:
- Write SELECT queries
- Use WHERE, ORDER BY, GROUP BY
- Perform basic aggregations ( COUNT, SUM, AVG )

Key skills:
SQL fundamental
Quarying data
Filtering and grouping
------------------------------------------------------------------------------------------------------------
*/
------------------------------------------------------------------------------------------------------------
-- Create a decodelab database
create database decodelab 

-- Import the neccessary file needed for project 
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------



-- QUESTIONS AND ANSWER
------------------------------------------------------------------------------------------------------------
-- 1. Find total sales revenue by product.
select 
	product,
	round(sum(Totalprice),2) as Revenue
from customerTable
group by Product

------------------------------------------------------------------------------------------------------------
-- 2. Count the number of orders for each order status.
select 
	OrderStatus,
	count(orderstatus) as Count_
from customerTable
group by OrderStatus

------------------------------------------------------------------------------------------------------------
-- 3. Find the top 5 customers by total spending.
With CustomerSpending as (
	select 
		CustomerID,
		round(sum(Totalprice),3) as Totalspent
	from customerTable
	group by CustomerID
)
select top 5 *
from CustomerSpending
order by Totalspent desc

------------------------------------------------------------------------------------------------------------
-- 4. Calculate average order value by payment method.
select 
	PaymentMethod,
	round(avg(TotalPrice),3) as avg_totalprice
from customerTable
group by PaymentMethod
------------------------------------------------------------------------------------------------------------
-- 5. Find products sold more than 100 times.
select 
	product,
	sum(Quantity) as UnitSold
from customerTable
group by product
having sum(Quantity) > 100

------------------------------------------------------------------------------------------------------------
-- 6. Show monthly revenue trends.
with monthly_revenue as (
	select 
		month(date) as monthNumber,
		left(datename(month,date),3) as monthName,
		round(TotalPrice,2,2) as Revenue
	from customerTable
)
select 
	monthNumber,
	monthName,
	sum(Revenue) as Revenue
from monthly_revenue
group by monthNumber,monthName
order by monthNumber asc

------------------------------------------------------------------------------------------------------------
-- 7. Find customers who placed more than 3 orders.
select 
	OrderID,
	count(OrderID) as count_
from customerTable
group by OrderID
having count(OrderID) > 3

------------------------------------------------------------------------------------------------------------
-- 8. Determine the most frequently used coupon code.
With Most_used_coupon as (
	select 
		CouponCode,
		count(CouponCode) as coupon_count
	from customerTable
	group by CouponCode 
)
select 
	case
		when coupon_count = ( select max(coupon_count) from Most_used_coupon) then 'Most Used Couponcode'
		else 'Less Used' 
		end as Coment,
	CouponCode
from Most_used_coupon
where coupon_count = ( select max(coupon_count) from Most_used_coupon)

------------------------------------------------------------------------------------------------------------
-- 9. Calculate average quantity ordered per product.
select 
	product,
	avg(quantity) as avg_quantity
from customerTable
group by product

------------------------------------------------------------------------------------------------------------
-- 10. Find all cancelled orders with order value greater than $500.
select *
from customerTable
where OrderStatus = 'Cancelled'
	and TotalPrice > 500


------------------------------------------------------------------------------------------------------------
-- 11. Rank products by total revenue generated.
select 
	Product,
	round(TotalPrice,2,2) as Revenue,
	Rank() over (order by Totalprice desc) as rnk
from customerTable

------------------------------------------------------------------------------------------------------------
-- 12. Find the percentage contribution of each product to total revenue.
select 
	Product,
	format(round((Revenue / TotalRevenue),2,2),'P0')
from (
	select 
		product,
		round(sum(totalprice),2,2) as Revenue,
		round((select sum(TotalPrice) from customerTable),2,2) as TotalRevenue
	from customerTable
	group by Product ) as t1

------------------------------------------------------------------------------------------------------------
-- 13. Identify customers who used more than one payment method.
select 
	CustomerID, 
	count(PaymentMethod) as count_
from customerTable
group by CustomerID
having count(PaymentMethod) > 1

------------------------------------------------------------------------------------------------------------
-- 14. Find the average order value for each referral source.
select 
	ReferralSource,
	round(avg(TotalPrice),2,2) as Avg_Revenue
from customerTable
group by ReferralSource

------------------------------------------------------------------------------------------------------------
-- 15. Determine which referral source generated the highest revenue.
With referralSource as (
	select 
		ReferralSource,
		round(sum(TotalPrice),2,2) as Revenue
	from customerTable
	group by ReferralSource 
)
select 
	case
		when Revenue = ( select max(revenue) from referralSource) then 'Highst Revenue generated'
		else 'Less revenue'
		end as Comment,
	ReferralSource
from referralSource
where Revenue = ( select max(revenue) from referralSource)

------------------------------------------------------------------------------------------------------------
-- 16. Find repeat customers (customers with more than one order).
select 
	CustomerID,
	count(*) as Numnber_of_repitation
from customerTable
group by CustomerID
having count(*) > 1
------------------------------------------------------------------------------------------------------------
-- 17. Calculate revenue lost from cancelled orders.
select 
	round(sum(Totalprice),2,2) as Revenue_loss
from customerTable
where OrderStatus = 'Cancelled'

------------------------------------------------------------------------------------------------------------
-- 18. Compare average order values between coupon users and non-coupon users.
	-- view creation
create view v_coupon as 
select avg(TotalPrice) as coupon_revenue
from customerTable
where CouponCode not in ('Freeship')
	-- Query 
With non_coupon as (
	select TotalPrice as non_couponR
	from customerTable
	where CouponCode = 'FREESHIP'
	)
select 
	round(avg(non_couponR),2,2) as avg_non_couponR,
	round((select * from v_coupon),2,2) as avg_CouponR
from non_Coupon


------------------------------------------------------------------------------------------------------------
-- 19. Find the most popular product in each year.
select top 1 *
from (
	select 
		Product, 
		count(*) as Pop_count
	from customerTable
	group by Product ) as t1
order by Pop_count

------------------------------------------------------------------------------------------------------------
-- 20. Identify customers whose spending exceeds the overall average customer spending.
select 
	CustomerID,
	round(sum(TotalPrice),2,2) as Revenue
from customerTable
group by CustomerID
having sum(TotalPrice) > (	select avg(TotalPrice)
							from customerTable 
							)
	
------------------------------------------------------------------------------------------------------------
-- 21. Calculate month-over-month revenue growth percentage.
With MonthlySales as (
	select 
		year(Date) as SalesYear,
		month(Date) as SalesMonth,
		Round(sum(TotalPrice),2,2) as CurrentMonthRevenue
	from customerTable
	group by Year(Date),month(Date)
),
LaggedSales as (
select 
	SalesYear,
	SalesMonth,
	CurrentMonthRevenue,
	lag(CurrentMonthRevenue,1) over (order by SalesYear,SalesMonth) as PreviousMonthRevenue
from MonthlySales
)
select 
	SalesYear,
	SalesMonth,
	CurrentMonthRevenue,
	isnull(PreviousMonthRevenue, 0) as PreviousMonthRevenue,
	case
		when PreviousMonthRevenue is null or PreviousMonthRevenue = 0 then 0
		else round((((CurrentMonthRevenue - PreviousMonthRevenue) * 100) / PreviousMonthRevenue),2,2)
		end as MoMGrowthPercentage
from LaggedSales
order by SalesYear , SalesMonth

------------------------------------------------------------------------------------------------------------
-- 22. Find the top-selling product each month using window functions.
With Product_ranking as (
	select
		Year(Date) as YearNumber,
		month(Date) as MonthNumber,
		Product,
		count(Product) as ProductCount
	from customerTable
	group by year(Date),month(date),product
	),
Top_sellingProduct as (
	select 
		YearNumber,
		MonthNumber,
		product,
		Row_number() over (partition by YearNumber, MonthNumber order by productCount) as Rnk
	from Product_ranking 
	)
select 
	YearNumber,
	MonthNumber,
	product
from Top_sellingProduct
where rnk = 1

------------------------------------------------------------------------------------------------------------
-- 23. Calculate customer lifetime value (CLV).
With CustomerMetrics as (
	select 
		CustomerID,
		avg(TotalPrice) as AvgOrderValue,
		Count(OrderID) as TotalOrder,
		case 
			when datediff(day,min(date),max(date)) = 0 then 1.0/365.0
			else datediff(day, min(date), max(date)) / 365.0
			end as LifeSpanYears
	from customerTable
	group by CustomerID
)
select 
	CustomerID,
	round(AvgOrderValue,2,2) as AvgOrderValue,
	(TotalOrder / LifeSpanYears) as PurchaseFrequencyPerYear,
	LifeSpanYears,
	Round((AvgOrderValue * (TotalOrder / LifeSpanYears) * LifeSpanYears),2,2) as predictive_CLV
from CustomerMetrics
order by predictive_CLV desc

------------------------------------------------------------------------------------------------------------
-- 24. Segment customers into High, Medium, and Low spenders.
select 
	CustomerID,
	Expenditure,
	case
		when segment = 1 then 'High'
		when segment = 2 then 'Medium'
		else 'Low'
		end as Segment
from (
	select 
		CustomerID,
		Round(TotalPrice,2,2) as Expenditure,
		ntile(3) over (order by Totalprice desc) as segment
	from customerTable ) as t1

------------------------------------------------------------------------------------------------------------
-- 25. Identify customers whose latest order was cancelled.
select 
	CustomerID,
	max(date) as latest_date
from customerTable
where OrderStatus = 'Cancelled'
group by CustomerID

------------------------------------------------------------------------------------------------------------
-- 26. Detect customers whose spending increased month-over-month.

------------------------------------------------------------------------------------------------------------
-- 27. Find products contributing to 80% of total revenue (Pareto Analysis).
With ProductContribution as (
	select 
		product,
		totalrevenue,
		round((select sum(TotalPrice) from customerTable),2,2) as TotalPrice
	from (
		select 
			product,
			Round(sum(TotalPrice),2,2) as totalrevenue
		from customerTable
		group by Product
		) as t1
	)
select 
	product,
	Format((totalrevenue / Totalprice), 'P0') as PercentageContribution
from ProductContribution

------------------------------------------------------------------------------------------------------------
-- 28. Compute rolling 3-month revenue totals.
select 
	year(Date) as salesYear,
	month(date) as salesMonth,
	totalprice,
	sum(Totalprice) over (
		order by month(date)
		rows between 2 preceding and current row
		) as Rolling_3_month_total
from customerTable
order by month(date)

---------------------------------------ALTERNATE---
With monthlyRevenue as (
	select
		datefromparts(Year(date), month(date), 1) as salesMonth,
		sum(Totalprice) as monthlyRevenue
	from customerTable
	group by datefromparts(year(date), month(date),1)
	)
select 
	salesMonth,
	monthlyRevenue,
	sum(monthlyRevenue) over (
		order by salesMonth
		rows between 2 preceding and current row 
		) as rolling_3_month_total
from monthlyRevenue
order by salesMonth



------------------------------------------------------------------------------------------------------------
-- 29. Identify the most effective coupon code based on generated revenue and usage frequency.
select 
	CouponCode,
	round(sum(TotalPrice),2,2) as Revenue,
	count(CouponCode) as frequency
from customerTable
group by CouponCode
order by sum(TotalPrice) desc

------------------------------------------------------------------------------------------------------------
-- 30. Build a customer retention analysis using cohort analysis.
WITH Cohorts AS (
    SELECT 
        CustomerID,
        DATEADD(month, DATEDIFF(month, 0, MIN(Date)), 0) AS CohortMonth
    FROM customerTable
    GROUP BY CustomerID
),
Activity AS (
    SELECT DISTINCT
        cc.CohortMonth,
        c.CustomerID,
        DATEDIFF(month, cc.CohortMonth, c.Date) AS CohortIndex
    FROM customerTable c
    JOIN Cohorts cc ON c.CustomerID = cc.CustomerID
),
RetentionCounts AS (
    SELECT 
        CohortMonth,
        CohortIndex,
        COUNT(DISTINCT CustomerID) AS ActiveCustomers,
        FIRST_VALUE(COUNT(DISTINCT CustomerID)) OVER (PARTITION BY CohortMonth ORDER BY CohortIndex) AS CohortSize
    FROM Activity
    GROUP BY CohortMonth, CohortIndex
),
FinalMatrix AS (
    SELECT 
        CohortMonth,
        CohortSize,
        100.0 * SUM(CASE WHEN CohortIndex = 0 THEN ActiveCustomers ELSE 0 END) / CohortSize AS M0,
        100.0 * SUM(CASE WHEN CohortIndex = 1 THEN ActiveCustomers ELSE 0 END) / CohortSize AS M1,
        100.0 * SUM(CASE WHEN CohortIndex = 2 THEN ActiveCustomers ELSE 0 END) / CohortSize AS M2,
        100.0 * SUM(CASE WHEN CohortIndex = 3 THEN ActiveCustomers ELSE 0 END) / CohortSize AS M3,
        100.0 * SUM(CASE WHEN CohortIndex = 4 THEN ActiveCustomers ELSE 0 END) / CohortSize AS M4,
        100.0 * SUM(CASE WHEN CohortIndex = 5 THEN ActiveCustomers ELSE 0 END) / CohortSize AS M5
    FROM RetentionCounts
    GROUP BY CohortMonth, CohortSize
)
SELECT 
    FORMAT(CohortMonth, 'yyyy-MM') AS [Cohort Month],
    CohortSize AS [Total Users],
    CONCAT(CAST(M0 AS DECIMAL(5,1)), '%') AS [Month 0],
    CONCAT(CAST(M1 AS DECIMAL(5,1)), '%') AS [Month 1],
    CONCAT(CAST(M2 AS DECIMAL(5,1)), '%') AS [Month 2],
    CONCAT(CAST(M3 AS DECIMAL(5,1)), '%') AS [Month 3],
    CONCAT(CAST(M4 AS DECIMAL(5,1)), '%') AS [Month 4],
    CONCAT(CAST(M5 AS DECIMAL(5,1)), '%') AS [Month 5]
FROM FinalMatrix
ORDER BY CohortMonth;
------------------------------------------------------------------------------------------------------------
-- view table 
select * from customerTable