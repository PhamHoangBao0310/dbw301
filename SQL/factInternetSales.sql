--use [AdventureWorks2019]
--insert into [DemoDW].dbo.FactInternetSales
select 
		--sod.SalesOrderID, 
		dimProduct.ProductKey as [ProductKey],
		--sod.ProductID as [ProductID],
		soh.CustomerID as [CustomerKey],
		soh.SalesOrderNumber as [SalesOrderNumber],
		rank() over (
			partition by sod.SalesOrderID
			order by sod.SalesOrderDetailID
		) [SalesOrderLineNumber],
		convert(smallint, sod.OrderQty) as [OrderQuantity],
		convert(money, sod.OrderQty * dimProduct.StandardCost) as [TotalProductCost],
		convert(money, sod.LineTotal) as [SaleAmount]
from [Sales].[SalesOrderDetail] as sod
		left outer join
	 [Production].Product as p on p.ProductID = sod.ProductID
		left outer join
	 [Sales].[SalesOrderHeader] as soh on sod.[SalesOrderID] = soh.[SalesOrderID]
		left outer join 
	 [DemoDW].dbo.DimProduct as dimProduct on p.[ProductNumber] = dimProduct.[ProductAlternateKey]
where [CarrierTrackingNumber] is Null 
     and ((dimProduct.[EndDate] is NULL or [OrderDate] <= dimProduct.[EndDate]) 
	      and ([OrderDate] >= dimProduct.[StartDate]))
