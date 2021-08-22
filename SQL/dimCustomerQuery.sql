--use [AdventureWorks2019]
--insert into [DemoDW].dbo.DimCustomer
SELECT 
	convert(int, c.CustomerID) AS [CustomerKey],
    CONVERT(nvarchar(15), c.AccountNumber) AS [CustomerAlternateKey], 
    convert(nvarchar(8), p.Title) AS [Title], 
    convert(nvarchar(50), p.FirstName) AS [FirstName], 
    convert(nvarchar(50), p.MiddleName) AS [MiddleName], 
    convert(nvarchar(50), p.LastName) AS [LastName], 
    converT(bit, p.NameStyle) AS [NameStyle],
	CONVERT(date, LEFT(Survey.ref.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";BirthDate','varchar(20)'), 10)) AS [BirthDate],
	Survey.ref.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";MaritalStatus','nchar(1)') AS [MaritalStatus], 	
	convert(nvarchar(10), p.Suffix) AS [Suffix], 
	Survey.ref.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";Gender','nvarchar(1)') AS [Gender], 
	convert(nvarchar(50), ea.EmailAddress) AS [EmailAddress], 
	Survey.ref.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";TotalChildren','tinyint') AS [TotalChildren], 
    Survey.ref.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";NumberChildrenAtHome','tinyint') AS [NumberChildrenAtHome], 
	p.Demographics.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";(IndividualSurvey/Education)[1]','nvarchar(40)') as [EnglishEducation],
    CAST(Survey.ref.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";HomeOwnerFlag','bit') AS nchar(1)) AS [HouseOwnerFlag], 
    Survey.ref.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";NumberCarsOwned','tinyint') AS [NumberCarsOwned], 
	convert(nvarchar(120), a.AddressLine1) AS [AddressLine1], 
	convert(nvarchar(120), a.AddressLine2) AS [AddressLine2], 
	CONVERT(nvarchar(20), pp.PhoneNumber) AS [Phone], 
	CONVERT(date, LEFT(Survey.ref.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";DateFirstPurchase','varchar(20)'), 10)) AS [DateFirstPurchase],     
    Survey.ref.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";CommuteDistance','nvarchar(15)') AS [CommuteDistance]
FROM 
	[Person].[Person] p
		INNER JOIN 
	(select bea1.BusinessEntityID, bea1.AddressID, bea1.AddressTypeID, bea1.rowguid, bea1.ModifiedDate
		from Person.BusinessEntityAddress as bea1
		inner join
		(
			select *,
			  rank() over (
				partition by BusinessEntityID 
				order by AddressID
			  ) _rank
			from [Person].[BusinessEntityAddress]
		) as T on bea1.[BusinessEntityID] = T.[BusinessEntityID] 
						and bea1.[AddressID] = T.[AddressID] 
						and bea1.[AddressTypeID] = T.[AddressTypeID]
		where T._rank = 1
	) bea ON bea.[BusinessEntityID] = p.[BusinessEntityID] 
		INNER JOIN 
	[Person].[Address] a ON a.[AddressID] = bea.[AddressID]
		INNER JOIN 
	[Person].[StateProvince] sp ON sp.[StateProvinceID] = a.[StateProvinceID]
		INNER JOIN 
	[Person].[CountryRegion] cr ON cr.[CountryRegionCode] = sp.[CountryRegionCode]
		INNER JOIN 
	[Person].[AddressType] at ON at.[AddressTypeID] = bea.[AddressTypeID]
		INNER JOIN 
	[Sales].[Customer] c ON c.[PersonID] = p.[BusinessEntityID]
		LEFT OUTER JOIN 
	[Person].[EmailAddress] ea ON ea.[BusinessEntityID] = p.[BusinessEntityID]
		LEFT OUTER JOIN 
	[Person].[PersonPhone] pp ON pp.[BusinessEntityID] = p.[BusinessEntityID]
		LEFT OUTER JOIN 
	[Person].[PhoneNumberType] pnt ON pnt.[PhoneNumberTypeID] = pp.[PhoneNumberTypeID]
		CROSS APPLY 
	p.[Demographics].nodes(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";IndividualSurvey') AS Survey(ref) 

order by [CustomerKey] ASC


