select * from [table]
--where PropertyAddress is null;
select [SaleDate] from [table];

select [SaleDate], CONVERT(date,SaleDate)
from [table]


-- working with Property Address -- 
Select*, PropertyAddress from [table]
--where PropertyAddress is null;
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.[ParcelID], b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from [table] as a
join [table] as b
on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;

Update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from [table] as a
join [table] as b
on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;


-- Breaking the ADdress into multiple columns--
select PropertyAddress from [table]

Select
SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,100) as City
from [table];

-- Add a new column 'NewColumnName' to table 'TableName' in schema 'SchemaName'
ALTER TABLE [table]
Add Propertysplitaddress nvarchar(255)

select Propertysplitaddress from [table]

UPDATE [table]
set Propertysplitaddress =   SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1) 

ALTER TABLE [table]
Add Propertysplitcity nvarchar(255)

select Propertysplitcity from [table]

UPDATE [table]
set Propertysplitcity =SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,100)






select * from [table]

SELECT
PARSENAME(replace(OwnerAddress,',','.'),3) as Ownersplitaddress,
PARSENAME(replace(OwnerAddress,',','.'),2) as Ownersplitcity,
PARSENAME(replace(OwnerAddress,',','.'),1) as Ownersplitstate
FROM [table]

--- ADD COLUMNS:
ALTER TABLE [table]
Add Ownersplitaddress nvarchar(255)
ALTER TABLE [table]
Add Ownersplitcity nvarchar(255)
ALTER TABLE [table]
Add Ownersplitstate nvarchar(255)

-- add values into new columns
update [table]
set Ownersplitaddress = PARSENAME(replace(OwnerAddress,',','.'),3)

update [table]
set Ownersplitcity = PARSENAME(replace(OwnerAddress,',','.'),2)

update [table]
set Ownersplitstate = PARSENAME(replace(OwnerAddress,',','.'),1)



--SOLDASVACANT

select distinct(SoldAsVacant), count(SoldAsVacant), distinct(SoldAsVacant2)
from [table]
group by SoldAsVacant

select * from [table]

Alter table [table]
Add SoldAsVacant2 nvarchar(255)

UPDATE [table]
set SoldAsVacant2 = 
    CASE    WHEN SoldAsVacant = 0 THEN 'No'
            WHEN SoldAsVacant = 1 THEN 'Yes'
            END;

select SoldAsVacant2,
    CASE    WHEN SoldAsVacant = 0 THEN 'No'
            WHEN SoldAsVacant = 1 THEN 'Yes'
            END AS SoldAsVacant3
From [table]

select distinct(SoldAsVacant3), count(SoldAsVacant3)
from [table]
group by SoldAsVacant3

--REMOVE DUPLICATES
-- #1 USING GROUPBY AND HAVING CLAUSE
SELECT * from [table]

SELECT ParcelID, LandUse, PropertyAddress, SaleDate, SalePrice, LegalReference, LandUse, OwnerName  ,COUNT(*)
from [table]    
Group by ParcelID, LandUse, PropertyAddress, SaleDate, SalePrice, LegalReference, LandUse, OwnerName
HAVING Count(*)>1

Delete FROM [table]
where UniqueID NOT IN (
    SELECT MAX(UniqueID)
    FROM [table]
    Group by ParcelID, LandUse, PropertyAddress, SaleDate, SalePrice, LegalReference, LandUse, OwnerName

)


SELECT * INTO [table2] from [table]
--#2 USING CTE
select * from table2  

Select * INTO [table3] from [table2]

WITH CTE AS(
select row_number() OVER (Partition by
                         ParcelID, 
                         LandUse, 
                         PropertyAddress, 
                         SaleDate, 
                         SalePrice, 
                         LegalReference,  
                         OwnerName 
                         ORDER by UniqueID)row_num,ParcelID, 
                         LandUse, 
                         PropertyAddress, 
                         SaleDate, 
                         SalePrice, 
                         LegalReference, 
                         OwnerName
from [table2])
select*
from CTE
where row_num>1

select count(*) from [table]
select count(*) from [table2]

select * from [table2]
-- DELETE UNUSED COLUMNS
ALTER TABLE [table]
drop COLUMN OwnerAddress, TaxDistrict, PropertyAddress

select * from [table]
Alter Table [table]
drop column SoldAsVacant

Alter Table [table]
ADD SoldAsVacant nvarchar(255)

UPDATE [table]
set SoldAsVacant = SoldAsVacant2

select SoldAsVacant from [table]
exec sp_rename [table]'table.SoldAsVacant', 'SoldAsVacant'

select * from [table]
