/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [Data_cleaning].[dbo].[Houston]


  select count(*) from [Data_cleaning].[dbo].[Houston];


/* cleaning Data in SQL Queries */

Select * from [Data_cleaning].[dbo].[Houston];

------------------------------------------------------------------------------------------------------------------------

--Standardize Date Format

alter table houston alter column SaleDate DATE;

-----------------------------------------------------------------------------------------------------------------------


--Populate Property Address data

select * from [Data_cleaning].[dbo].[Houston]
-- where property is null
order by ParcelID;

--As the null PropertyAddress have the same parcelID hence populating it with the help of the other ParcelID.
-- Using SELFJOIN


select a.ParcelID,a.PropertyAddress,b.ParcelID,B.PropertyAddress,
ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Data_cleaning].[dbo].[Houston] a
join [Data_cleaning].[dbo].[Houston] b
			on a.ParcelID = b.ParcelID
			AND a.[UniqueID ] <> b.[UniqueID ] --Juust to make sure they have different UniqueID as they should not be the repeated values
where a.PropertyAddress is null;

-- As the 
update a 
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from [Data_cleaning].[dbo].[Houston] a 
join [Data_cleaning].[dbo].[Houston] b
			on a.ParcelID = b.ParcelID
			and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;


select * from [Data_cleaning].[dbo].[Houston]
where PropertyAddress is null ;
-- Now no more Null values in PropertyAddress.


-----------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress from [Data_cleaning].[dbo].[Houston];


select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as Address
,SUBSTRING (PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress)) As Address

from [Data_cleaning].[dbo].[Houston];

alter table [Data_cleaning].[dbo].[Houston]
Add Property_Split_Address Nvarchar(255);

update [Data_cleaning].[dbo].[Houston]
SET Property_Split_Address = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1)

ALter table [Data_cleaning].[dbo].[Houston]
Add Property_Split_City Nvarchar(255);

update [Data_cleaning].[dbo].[Houston]
set Property_Split_City = SUBSTRING (PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress))


select * from [Data_cleaning].[dbo].[Houston]




select OwnerAddress from [Data_cleaning].[dbo].[Houston]

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From [Data_cleaning].[dbo].[Houston]



ALTER TABLE [Data_cleaning].[dbo].[Houston]
Add Owner_Split_Address Nvarchar(255);

Update [Data_cleaning].[dbo].[Houston]
SET Owner_Split_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE [Data_cleaning].[dbo].[Houston]
Add Owner_Split_City Nvarchar(255);

Update [Data_cleaning].[dbo].[Houston]
SET Owner_Split_City = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE [Data_cleaning].[dbo].[Houston]
Add Owner_Split_State Nvarchar(255);

Update [Data_cleaning].[dbo].[Houston]
SET Owner_Split_State = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



select * from [Data_cleaning].[dbo].[Houston];





--------------------------------------------------------------------------------------------------------------------------



-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [Data_cleaning].[dbo].[Houston]
Group by SoldAsVacant
order by 2

select SoldAsVacant,
 CASE when SoldAsVacant = 'Y' THEN 'YES'
				when SoldAsVacant = 'N' THEN 'NO' 
				ELSE SoldAsVacant 
				END
from [Data_cleaning].[dbo].[Houston]

update [Data_cleaning].[dbo].[Houston]
set SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'YES'
				when SoldAsVacant = 'N' THEN 'NO' 
				ELSE SoldAsVacant 
				END 


-----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Checking the duplicate rows 

With RowNumCTE as (
select *,
	ROW_NUMBER() over(
	PARTITION BY ParcelID,
				 PropertyAddress, 
				 salePrice, 
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID) row_num 
from [Data_cleaning].[dbo].[Houston]
)
select * from RowNumCTE
where row_num > 1



-- Removing Duplicates

with RowNumCTE as (
select *, 
		ROW_NUMBER() over ( 
		partition by ParcelID,
				 PropertyAddress, 
				 salePrice, 
				 SaleDate,
				 LegalReference
				 order by uniqueID) row_num 
				 from [Data_cleaning].[dbo].[Houston]
)
delete from RowNumCTE
where row_num > 1



--Delete unused columns


select * from [Data_cleaning].[dbo].[Houston]

alter table [Data_cleaning].[dbo].[Houston] 
drop column OwnerAddress, PropertyAddress