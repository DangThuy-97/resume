--Let's take a look at the table to examine the data in its original form.

select * from [tble]

--It seems like the date column has already been in the right format.




-----------------------------------------------
-- We move on to check the null values in the PropertyAddress column
Select PropertyAddress from [tble]
where PropertyAddress is null;

--Looks like we need to work on the null values in the address column. We could either replace the null value with "No Address". However, let's check if we can populate the null value with an already existing valid value.
--Through inspection, there are rows with identical ParcelID value, but some have address while others don't.

select a.ParcelID, a.PropertyAddress, b.[ParcelID], b.PropertyAddress
from [tble] as a
join [tble] as b
on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null


--Hence, we could add the address values of the rows which have identical ParcelID to those whose addresses are null. We do that by using `isnull()`.



Update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from [tble] as a
join [tble] as b
on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;

--We check the results using --

Select PropertyAddress from [tble]
where PropertyAddress is null;


-----------------------------------------------
-- We move on to split the address to multiple individual columns
-- Let's inspect the address column first.
select PropertyAddress from [tble]

--We see the address value has two components: the address and the city, separated by the dilimiter ",".
--We can split the column into two by using the combination of SUBSTRING() and CHARINDEX().
--SUBSTRING is used to extract the chars from an expression, but it needs us to indicate the number of chars to extract.
--While CHARINDEX returns the position of the chars we want in an expression, in this case, we want the position number of the delimiter ",".

Select
SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,100) as City
from [tble];

--Subsequently, we create two new columns and add the values into these two new columns

select Propertysplitaddress from [tble]

ALTER TABLE [tble]
Add Propertysplitaddress nvarchar(255);

ALTER TABLE [tble]
Add Propertysplitcity nvarchar(255)

UPDATE [tble]
set Propertysplitaddress =   SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1);

UPDATE [tble]
set Propertysplitcity =SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,100);

select propertysplitaddress, Propertysplitcity
from [tble]

-- There is also an Owneraddress column, we shall split it but with PARSENAME technique
select OwnerAddress from [tble]

--This time there are two delimiters ",". Essentially, PARSENAME() will return the respective chunk of chars that are separated by ".".
--So before using PARSENAME we need to replace the "," into "." with REPLACE().

SELECT
PARSENAME(replace(OwnerAddress,',','.'),3) as Ownersplitaddress,
PARSENAME(replace(OwnerAddress,',','.'),2) as Ownersplitcity,
PARSENAME(replace(OwnerAddress,',','.'),1) as Ownersplitstate
FROM [tble]

-- Subsequently, we add columns and values

ALTER TABLE [tble]
Add Ownersplitaddress nvarchar(255)
ALTER TABLE [tble]
Add Ownersplitcity nvarchar(255)
ALTER TABLE [tble]
Add Ownersplitstate nvarchar(255)

update [tble]
set Ownersplitaddress = PARSENAME(replace(OwnerAddress,',','.'),3)

update [tble]
set Ownersplitcity = PARSENAME(replace(OwnerAddress,',','.'),2)

update [tble]
set Ownersplitstate = PARSENAME(replace(OwnerAddress,',','.'),1)

select Ownersplitaddress, Ownersplitcity, Ownersplitstate
from [tble]





--------------------------------------------------

-- Next, we normalize the SoldAsVacant column.
-- We inspect the column

select distinct(SoldAsVacant), count(SoldAsVacant)
from [tble]
group by SoldAsVacant

--We want the 0 value to represent "No", and the 1 value to represent "Yes".
--Since the column datatype is currently interger, we cannot replace them directly into text type. 
--I approach this by creating another Column called "SoldAsVacant2", fill it with 'Yes' and 'No' through CASE WHEN function, delete the original "SoldAsVacant" column and then rename "SoldAsVacant2" to "SoldAsVacant"

Alter table [tble]
Add SoldAsVacant2 nvarchar(255)

UPDATE [tble]
set SoldAsVacant2 = 
    CASE    WHEN SoldAsVacant = 0 THEN 'No'
            WHEN SoldAsVacant = 1 THEN 'Yes'
            END;

Alter table [tble]
drop COLUMN SoldAsVacant

exec sp_rename 'tble.SoldAsVacant2','SoldAsVacant'

Select SoldAsVacant
From [tble]





-----------------------------------------------

--Then, we remove duplicate rows by using two techniques Groupby & Having and CTE.
--I will clone the [tble] into [tble2] first. 

sql
Select * into [tble2] from [tble]
select * from [tble]
-- Groupby and Having technique on [tble]:

SELECT ParcelID, LandUse, PropertyAddress, SaleDate, SalePrice, LegalReference, LandUse, OwnerName  ,COUNT(*)
from [tble]    
Group by ParcelID, LandUse, PropertyAddress, SaleDate, SalePrice, LegalReference, LandUse, OwnerName
HAVING Count(*)>1

--Essentially, the last column represents the number of occurence of the combination of the above attributes. <br>
--If the count is larger than 1, then the corresponding combination of attributes is duplicated. <br>
--Thanksfully, even when duplicated, these rows have their own UniqueID, so we just need to keep one ID from these duplicated Rows. (Either using MIN() or MAX())


Delete FROM [tble]
where UniqueID NOT IN (
    SELECT MAX(UniqueID)
    FROM [tble]
    Group by ParcelID, LandUse, PropertyAddress, SaleDate, SalePrice, LegalReference, LandUse, OwnerName
)

--CTE Technique conducted on table [tble2].

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
from [tble2])
select*
from CTE
where row_num>1

-- We delete the rows above --

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
from [tble2])
DELETE FROM CTE
where row_num>1

--We check the results from 2 techniques:

select * from [tble]
select * from [tble2]




-----------------------------------------------
--Finally, we remove unused columns that we deem unnecessary
ALTER TABLE [tble]
drop COLUMN OwnerAddress, TaxDistrict, PropertyAddress

select * from [tble]