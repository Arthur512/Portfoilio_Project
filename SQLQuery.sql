-- show sale data table
select *
from sales

-- show product table
select *
from products
 
-- show store table
select *
from stores

-- show inventory table
select *
from inventory

-- join sales, products and store table

select top 10 sales.*, sales.Units*products.Product_Cost Cost, sales.Units*products.Product_Price Price, products.Product_Name, products.Product_Category,stores.Store_Name, stores.Store_City,stores.Store_Location, stores.Store_Open_Date,
sales.Units*products.Product_Price - sales.Units*products.Product_Cost Profit
from sales
join products on sales.Product_ID = products.Product_ID
join stores on sales.Store_ID=stores.Store_ID;

-- total sales, total profit and Rate of Return by year

select YEAR(DATE) YEAR, FORMAT(SUM(PRICE),'C','EN-US') sale, FORMAT(SUM(profit),'C','EN-US') profit, 
format(sum(profit)/SUM(Cost),'P2') RoR
from (select sales.*, sales.Units*products.Product_Cost Cost, sales.Units*products.Product_Price Price, products.Product_Name, products.Product_Category,stores.Store_Name, stores.Store_City,stores.Store_Location, stores.Store_Open_Date,
	sales.Units*products.Product_Price - sales.Units*products.Product_Cost Profit
	from sales
	join products on sales.Product_ID = products.Product_ID
	join stores on sales.Store_ID=stores.Store_ID) as total_sale
group by YEAR(DATE);
 
-- total sales, total profit and Rate of Return by month

select DATEADD(MONTH, DATEDIFF(MONTH, 0, date), 0) as month, FORMAT(SUM(PRICE),'C','EN-US') sale, FORMAT(SUM(profit),'C','EN-US') profit, 
format(sum(profit)/SUM(Cost),'P2') RoR
from (select sales.*, sales.Units*products.Product_Cost Cost, sales.Units*products.Product_Price Price, products.Product_Name, products.Product_Category,stores.Store_Name, stores.Store_City,stores.Store_Location, stores.Store_Open_Date,
	sales.Units*products.Product_Price - sales.Units*products.Product_Cost Profit
	from sales
	join products on sales.Product_ID = products.Product_ID
	join stores on sales.Store_ID=stores.Store_ID) as total_sale
group by DATEADD(MONTH, DATEDIFF(MONTH, 0, date), 0)
order by 1 asc;

-- total sales, total profit and Rate of Return by category, by month

select Product_Category, DATEADD(MONTH, DATEDIFF(MONTH, 0, date), 0) as month, FORMAT(SUM(PRICE),'C','EN-US') sale, FORMAT(SUM(profit),'C','EN-US') profit, 
format(sum(profit)/SUM(Cost),'P2') RoR
from (select sales.*, sales.Units*products.Product_Cost Cost, sales.Units*products.Product_Price Price, products.Product_Name, products.Product_Category,stores.Store_Name, stores.Store_City,stores.Store_Location, stores.Store_Open_Date,
	sales.Units*products.Product_Price - sales.Units*products.Product_Cost Profit
	from sales
	join products on sales.Product_ID = products.Product_ID
	join stores on sales.Store_ID=stores.Store_ID) as total_sale
group by Product_Category, DATEADD(MONTH, DATEDIFF(MONTH, 0, date), 0)
order by 1,2 asc;

-- total sales and profit by store
select Store_Name, FORMAT(SUM(PRICE),'C','EN-US') sale, FORMAT(SUM(profit),'C','EN-US') profit, 
format(sum(profit)/SUM(Cost),'P2') RoR
from (select sales.*, sales.Units*products.Product_Cost Cost, sales.Units*products.Product_Price Price, products.Product_Name, products.Product_Category,stores.Store_Name, stores.Store_City,stores.Store_Location, stores.Store_Open_Date,
	sales.Units*products.Product_Price - sales.Units*products.Product_Cost Profit
	from sales
	join products on sales.Product_ID = products.Product_ID
	join stores on sales.Store_ID=stores.Store_ID) as total_sale
group by Store_Name
order by 2 desc, 3 desc ;

-- total sales and profit by location

select Store_Location, FORMAT(SUM(PRICE),'C','EN-US') sale, FORMAT(SUM(profit),'C','EN-US') profit, 
format(sum(profit)/SUM(Cost),'P2') RoR
from (select sales.*, sales.Units*products.Product_Cost Cost, sales.Units*products.Product_Price Price, products.Product_Name, products.Product_Category,stores.Store_Name, stores.Store_City,stores.Store_Location, stores.Store_Open_Date,
	sales.Units*products.Product_Price - sales.Units*products.Product_Cost Profit
	from sales
	join products on sales.Product_ID = products.Product_ID
	join stores on sales.Store_ID=stores.Store_ID) as total_sale
group by Store_Location
order by 2 desc, 3 desc ;

-- sales and profit of the store which had most value stock
select Store_ID, store_name, FORMAT(SUM(PRICE),'C','EN-US') sale, FORMAT(SUM(profit),'C','EN-US') profit, 
format(sum(profit)/SUM(Cost),'P2') RoR
from
(select sales.*, sales.Units*products.Product_Cost Cost, sales.Units*products.Product_Price Price, products.Product_Name, products.Product_Category,stores.Store_Name, stores.Store_City,stores.Store_Location, stores.Store_Open_Date,
	sales.Units*products.Product_Price - sales.Units*products.Product_Cost Profit
	from sales
	join products on sales.Product_ID = products.Product_ID
	join stores on sales.Store_ID=stores.Store_ID) as total_sale
where Store_ID = (select Store_ID from (select top 1 Store_ID, sum(Stock_On_Hand*Product_Cost) Stock_Value
													from inventory
													join products
													on inventory.Product_ID=products.Product_ID
													group by Store_ID
													order by 2 desc) stock)
group by Store_ID, store_name;

-- calculate sales of each type of product, separated by year
select Product_Category, FORMAT(SUM(sale2017),'C','EN-US') as '2017', FORMAT(SUM(sale2018),'C','EN-US') as '2018'
from (select Product_Category,
		case when year(Date)=2017 then Price else 0 end as sale2017  ,
		case when year(Date)=2018 then Price else 0 end as sale2018 
		from
			(select sales.*, sales.Units*products.Product_Cost Cost, sales.Units*products.Product_Price Price, products.Product_Name, products.Product_Category,stores.Store_Name, stores.Store_City,stores.Store_Location, stores.Store_Open_Date,
			sales.Units*products.Product_Price - sales.Units*products.Product_Cost Profit
			from sales
			join products on sales.Product_ID = products.Product_ID
			join stores on sales.Store_ID=stores.Store_ID) as total_sale) as sub
group by Product_Category

-- List sales and inventory quantity by Product_ID and Store_ID
select
case when t1.Store_ID is not null then t1.Store_ID else t2.Store_ID end as Store_ID,
case when t1.Product_ID is not null then t1.Product_ID else t2.Product_ID end as Product_ID,
case when t1.Sold is not null then t1.Sold else 0 end as Sold,
case when t2.Stock is not null then t2.Stock else 0 end as Stock
from
	(select Store_ID, Product_ID, sum(Units) as Sold
	from sales
	group by Store_ID, Product_ID) t1
full join
	(select Store_ID, Product_ID, sum(Stock_On_Hand) as Stock
	from inventory
	group by Store_ID, Product_ID) t2
on t1.Store_ID=t2.Store_ID
and t1.Product_ID = t2.Product_ID
order by 1,2

-- best selling product in each loction
select Store_Location, Product_Name, FORMAT(Sale,'C','EN-US') as Sale
from
	(select Store_Location, Product_Name, sum(Price) as Sale,
	RANK() over(partition by Store_Location order by sum(Price) desc) as Rank
	from
		(select sales.*, sales.Units*products.Product_Cost Cost, sales.Units*products.Product_Price Price, products.Product_Name, products.Product_Category,stores.Store_Name, stores.Store_City,stores.Store_Location, stores.Store_Open_Date,
		sales.Units*products.Product_Price - sales.Units*products.Product_Cost Profit
		from sales
		join products on sales.Product_ID = products.Product_ID
		join stores on sales.Store_ID=stores.Store_ID) as total_sale
	group by Store_Location, Product_Name) as t1
where Rank=1

-- sales of the stores in each location which are greater than the average store sales for that region
select t1.Store_Location, t1.Store_Name, FORMAT(t1.Sale,'C','EN-US') as Sale
from
	(select Store_Location, Store_Name, sum(Product_Price*Units) as Sale
	from sales
	join products on sales.Product_ID = products.Product_ID
	join stores on sales.Store_ID=stores.Store_ID
	group by Store_Location, Store_Name) t1
join
	(select Store_Location, avg(Sale) as Avg_sale
	from 
		(select Store_Location, Store_Name, sum(Product_Price*Units) as Sale
		from sales
		join products on sales.Product_ID = products.Product_ID
		join stores on sales.Store_ID=stores.Store_ID
		group by Store_Location, Store_Name) as t0
	group by Store_Location) t2
on t1.Store_Location=t2.Store_Location
where t1.Sale > t2.Avg_sale
order by 1,3 desc;

















