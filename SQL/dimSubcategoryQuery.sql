--use [AdventureWorks2019]

--insert into [DemoDW].dbo.DimProductSubcategory
select 
	psc.ProductSubcategoryID as [ProductSubcategoryAlternateKey],
	psc.Name as [EnglishProductSubCategoryName]
from Production.ProductSubcategory as psc
Order by [ProductSubcategoryAlternateKey]




