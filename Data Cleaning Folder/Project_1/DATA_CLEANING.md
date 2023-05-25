# An SQL Data Cleaning Project
## by nguyendangthuy97@gmail.com

For this project, I follow the guidance of Alex The Analyst to complete the cleaning process.
I take the liberty to change the table name to 'tble' for simplicity.

Let's take a look at the table to examine the data in its original form.
```sql
select * from [tble]
````
**Results**
![image](https://github.com/shandarren/resume/assets/132535188/ae0a5040-d7de-4e04-87b0-4584bd10bd4c)
![image](https://github.com/shandarren/resume/assets/132535188/9fd8bb0e-baf4-4dc1-b359-c6ac4e1e35f5)

It seems like the date column has already been in the right format. We move on to check the null values in the PropertyAddress column
```sql
Select PropertyAddress from [tble]
where PropertyAddress is null;
```
![image](https://github.com/shandarren/resume/assets/132535188/de93dd7f-e8ec-4b92-a91a-df853b6f63c3)

Looks like we need to work on the null values in the address column. We could either replace the null value with "No Address". However, let's check if we can populate the null values with an already existing valid values.

Through inspection, there are rows with identical ParcelID value, but some have address while others don't.
```sql
select a.ParcelID, a.PropertyAddress, b.[ParcelID], b.PropertyAddress
from [tble] as a
join [tble] as b
on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;
```

Hence, we could add the address values of the rows which have identical ParcelID to those whose addresses are null. We do that by using `isnull()`.
```sql
Update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from [tble] as a
join [tble] as b
on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;
```

We check the results using
```sql
Select PropertyAddress from [tble]
where PropertyAddress is null;
```
**Results:**

![image](https://github.com/shandarren/resume/assets/132535188/bff32f13-cc24-4cae-8830-a4394de8fbbd)

## We move on to split the address to multiple individual columns
Let's inspect the address column first.

```sql
select PropertyAddress from [tble];
```
![image](https://github.com/shandarren/resume/assets/132535188/6a904128-5561-4355-a350-3bdea6629579)

We see the address value has two components: the address and the city, separated by the dilimiter ",".
We can split the column into two by using the combination of SUBSTRING() and CHARINDEX().
SUBSTRING is used to extract the chars from an expression, but it needs us to indicate the number of chars to extract.
While CHARINDEX returns the position of the chars we want in an expression, in this case, we want the position number of the delimiter ",".

```sql
Select
SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,100) as City
from [tble];
```

![image](https://github.com/shandarren/resume/assets/132535188/876a17d7-50cb-455f-a61c-6ed8c7cbf443)

Subsequently, we create two new columns and add the values into these two new columns
```sql
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
```

**Results:**

![image](https://github.com/shandarren/resume/assets/132535188/751443d7-4361-4915-aaea-79b1d3e97135)

## There is also an Owneraddress column, we shall split it but with PARSENAME technique

Let's inspect it.

```sql
select OwnerAddress from [tble]
```

![image](https://github.com/shandarren/resume/assets/132535188/c1f8b144-ba20-41ae-a746-ab804d715a16)

This time there are two delimiters ",". Essentially, PARSENAME() will return the respective chunk of chars that are separated by ".". <br>
So before using PARSENAME we need to replace the "," into "." with REPLACE().

```sql
SELECT
PARSENAME(replace(OwnerAddress,',','.'),3) as Ownersplitaddress,
PARSENAME(replace(OwnerAddress,',','.'),2) as Ownersplitcity,
PARSENAME(replace(OwnerAddress,',','.'),1) as Ownersplitstate
FROM [tble]
```

![image](https://github.com/shandarren/resume/assets/132535188/c87ca876-b30b-49c4-b58b-ea86141f5b6b)

Subsequently, we add columns and values.

```sql
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
```
**Results:**

![image](https://github.com/shandarren/resume/assets/132535188/1be4140a-9457-4a2c-91c2-2ef9156d8c5e)

## Next, we normalize the SoldAsVacant column.
We inspect the column

```sql
select distinct(SoldAsVacant), count(SoldAsVacant)
from [tble]
group by SoldAsVacant
```

![image](https://github.com/shandarren/resume/assets/132535188/710a4b9b-7d4e-4eda-9128-07e5d1917ae0)

We want the 0 value to represent "No", and the 1 value to represent "Yes".
Since the column datatype is currently interger, we cannot replace them directly into text type. <br>
I approach this by creating another Column called "SoldAsVacant2", fill it with 'Yes' and 'No' through CASE WHEN function, delete the original "SoldAsVacant" column and then rename "SoldAsVacant2" to "SoldAsVacant"

```sql
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
```
**Results:**

![image](https://github.com/shandarren/resume/assets/132535188/44d9e72e-c848-4662-ac08-e1614f6f2e2c)

## Then, we remove duplicate rows by using two techniques Groupby & Having and CTE.
I will clone the [tble] into [tble2] first.

```sql
Select * into [tble2] from [tble]
```

**Groupby and Having technique conducted on table [tble]:**

```sql
SELECT ParcelID, LandUse, PropertyAddress, SaleDate, SalePrice, LegalReference, LandUse, OwnerName  ,COUNT(*)
from [tble]    
Group by ParcelID, LandUse, PropertyAddress, SaleDate, SalePrice, LegalReference, LandUse, OwnerName
HAVING Count(*)>1
```
![image](https://github.com/shandarren/resume/assets/132535188/571a1fcf-fb2c-4149-9076-3e8b0d7e0cd3)

Essentially, the last column represents the number of occurence of the combination of the above attributes. <br>
If the count is larger than 1, then the corresponding combination of attributes is duplicated. <br>
Thanksfully, even when duplicated, these rows have their own UniqueID, so we just need to keep one ID from these duplicated Rows. (Either using MIN() or MAX())

```sql
Delete FROM [tble]
where UniqueID NOT IN (
    SELECT MAX(UniqueID)
    FROM [tble]
    Group by ParcelID, LandUse, PropertyAddress, SaleDate, SalePrice, LegalReference, LandUse, OwnerName
)

--Check again--

SELECT ParcelID, LandUse, PropertyAddress, SaleDate, SalePrice, LegalReference, LandUse, OwnerName  ,COUNT(*)
from [tble]    
Group by ParcelID, LandUse, PropertyAddress, SaleDate, SalePrice, LegalReference, LandUse, OwnerName
HAVING Count(*)>1
```
![image](https://github.com/shandarren/resume/assets/132535188/dd5fe8ca-8a39-4b1b-a349-e8b7040e9341)

**Successful!**

**CTE Technique conducted on table [tble2].** 
First we use: row_number() OVER (Partition by [combination of attributes] ORDER by [attribute]). <br>
Basically, this function does the same thing as the Groupby & Having above. It returns the column representing the number of times the [combination of attributes] of that row has occured.<br>
<br>
If the value of this column in a row is larger than 1, then that row attributes combination is duplicated and should be deleted.

```sql
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

--We delete the rows above--
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

-- check again--

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
```
![image](https://github.com/shandarren/resume/assets/132535188/6c28f02a-28c2-4bd7-a39d-3fb5e54ead23)

**Successful !*

We check the results from 2 techniques:
```sql
select * from [tble]
select * from [tble2]
```
![image](https://github.com/shandarren/resume/assets/132535188/723be2e0-8488-4359-ab4e-38ac7338e888)
![image](https://github.com/shandarren/resume/assets/132535188/802672d0-6de6-44e3-8c9d-2233094e865a)

Both returns the same number rows left !


## Finally, we remove unused columns that we don't need and export to csv file.
```sql
ALTER TABLE [tble]
drop COLUMN OwnerAddress, TaxDistrict, PropertyAddress
```



