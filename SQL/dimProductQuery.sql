--use [AdventureWorks2019]
--insert into [DemoDW].dbo.DimProduct
select 
    --IDENTITY(INT,1,1) AS [ProductKey],
    --p.ProductID as [Test_ProductID],
	convert(nvarchar(25), p.ProductNumber) as [ProductAlternateKey],
	convert(int, p.ProductSubcategoryID) as [ProductSubcategoryKey],
	convert(nchar(3), p.WeightUnitMeasureCode) as [WeightUnitMeasureCode],
	convert(nchar(3), p.SizeUnitMeasureCode) as [SizeUnitMeasureCode],
	convert(nvarchar(50), p.Name) as [EnglishProductName],
	convert(money, pclph.StandardCost) as [StandardCost],
	convert(bit, p.FinishedGoodsFlag) as [FinishedGoodsFlag], 
	convert(nvarchar(15), CASE when (p.Color is NULL) THEN 'NA' Else p.Color End) as [Color],
	convert(smallint, p.SafetyStockLevel) as [SafetyStockLevel],
	convert(smallint, p.ReorderPoint) as [ReorderPoint],
	convert(money, pclph.ListPrice) as [ListPrice],
	convert(nvarchar(50), p.Size) as [Size],
	convert(float, p.Weight) as [Weight],
	convert(int, p.DaysToManufacture) as [DaysToManufacture],
	convert(nchar(2), p.ProductLine) as [ProductLine],
	convert (money, 0.6 * pclph.ListPrice) as [DealerPrice],
	convert(nchar(2), p.Class) as [Class],
	convert(nchar(2), p.Style) as [Style],
	convert(nvarchar(50), pm.Name) as [ModelName],
	convert(varbinary(MAX), pp.LargePhoto) as [LargePhoto],
	convert(nvarchar(400), pd.Description) as [EnglishDescription],
	convert(datetime, COALESCE(pclph.StartDate, p.SellStartDate)) as [StartDate],
	convert(datetime, COALESCE(pclph.EndDate, p.SellEndDate )) as [EndDate],
	convert(nvarchar(7), CASE when (EndDate is NULL) THEN 'Current' Else NULL End) as [Status] 
--into TempDB
from 
	Production.Product as p
	LEFT OUTER JOIN 
	Production.ProductProductPhoto as ppp on p.ProductID = ppp.ProductID
	LEFT Outer join 
	Production.ProductPhoto as pp on ppp.ProductPhotoID = pp.ProductPhotoID
	LEFT Outer join
	Production.ProductModel as pm on pm.ProductModelID = p.ProductModelID
	Left Outer join
	(select pch.ProductID, pch.StandardCost, pch.StartDate, pch.EndDate, plph.ListPrice 
		from Production.ProductCostHistory as pch join
			Production.ProductListPriceHistory as plph
		on pch.ProductID = plph.ProductID and pch.StartDate = plph.StartDate
	) as pclph on pclph.ProductID = p.ProductID
	left outer join
	(Select pmpdc.ProductModelID, pd.Description
		from Production.ProductModelProductDescriptionCulture as pmpdc join
		Production.ProductDescription as pd 
	on pmpdc.ProductDescriptionID = pd.ProductDescriptionID
	where pmpdc.CultureID like '%en%'
	) as pd on p.ProductModelID = pd.ProductModelID
	
Order by StartDate ASC

