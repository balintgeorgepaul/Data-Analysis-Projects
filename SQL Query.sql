/****** Script for SelectTopNRows command from SSMS  ******/
SELECT *
  FROM [SQL Data Cleaning].[dbo].[Nashville Housing]

  -- Standardize Date Format

  SELECT SaleDateConverted, Convert(Date, SaleDate)
  FROM [SQL Data Cleaning].[dbo].[Nashville Housing]

  Update [Nashville Housing]
  SET SaleDate = Convert(Date,SaleDate)
  
  ALTER TABLE [Nashville Housing]
  Add SaleDateConverted Date; 

  Update [Nashville Housing]
  SET SaleDateConverted = CONVERT(Date,SaleDate)

  -- Populate Property Address data

  SELECT *
  FROM [SQL Data Cleaning].[dbo].[Nashville Housing]
 -- Where PropertyAddress is null
 order by ParcelID

 SELECT a. ParcelID, a. PropertyAddress, b.ParcelID, b. PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
 From [SQL Data Cleaning].[dbo].[Nashville Housing] a
 JOIN [SQL Data Cleaning].[dbo].[Nashville Housing] b
      on a.ParcelID = b.ParcelID
	  AND a. [UniqueID] <> b.[UniqueID]
 Where a.PropertyAddress is null

 Update a
 SET PropertyAddress = ISNULL (a. PropertyAddress, b.PropertyAddress)
 FROM [SQL Data Cleaning].[dbo].[Nashville Housing] a
 JOIN [SQL Data Cleaning].[dbo].[Nashville Housing] b
      on a.ParcelID = b.ParcelID
	  AND a.[UniqueID] <> b.[UniqueID]
 Where a.PropertyAddress is null


 -- Breaking out Address into Individual Columns (Address, City, State)
 
 Select PropertyAddress
 From [SQL Data Cleaning].[dbo].[Nashville Housing]
 --Where PropertyAddress is null
 -- order by ParcelID

 Select 
 SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
 , SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address


 From [SQL Data Cleaning].[dbo].[Nashville Housing]

 ALTER TABLE [Nashville Housing]
 Add PropertySplitAddress Nvarchar(255);

 Update [Nashville Housing]
 SET PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

 ALTER TABLE [Nashville Housing]
 Add PropertySplitcity Nvarchar (255);
 
 Update [Nashville Housing]
 SET PropertySplitcity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))


 Select *
 From [SQL Data Cleaning].[dbo].[Nashville Housing]




 Select OwnerAddress
 From [SQL Data Cleaning].[dbo].[Nashville Housing]

 Select
 PARSENAME (REPLACE(OwnerAddress,',', '.'),3)
 ,PARSENAME (REPLACE(OwnerAddress,',', '.'),2)
 ,PARSENAME (REPLACE(OwnerAddress,',', '.'),1)
 From [SQL Data Cleaning].[dbo].[Nashville Housing]
 
ALTER TABLE [Nashville Housing]
Add OwnerSplitAddress Nvarchar(255);

Update [Nashville Housing]
SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress,',', '.'),3)

ALTER TABLE [Nashville Housing]
Add OwnerSplitCity Nvarchar (255);

Update [Nashville Housing]
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress,',', '.'),2)


ALTER TABLE [Nashville Housing]
Add OwnerSplitState Nvarchar(255);

Update [Nashville Housing]
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress,',', '.'),1)


-- Change 'Y' and 'N' to 'Yes' and 'No' in 'Sold as Vacant' field

Select Distinct (SoldAsVacant), Count(SoldAsVacant) 
 FROM [SQL Data Cleaning].[dbo].[Nashville Housing]
 Group by SoldAsVacant
 order by 2

 Select SoldAsVacant
 , CASE When SoldAsVacant = 'Y' THEN 'YES'
        When SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant  
		End
  FROM [SQL Data Cleaning].[dbo].[Nashville Housing]

Update [Nashville Housing]
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'YES'
        When SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant  
		End


-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
      ROW_NUMBER() OVER (
	  PARTITION BY ParcelID,
	               PropertyAddress,
				   SalePrice,
				   SaleDate,
				   LegalReference
				   ORDER BY
				       UniqueID
					   ) row_num

From [SQL Data Cleaning].[dbo].[Nashville Housing]
-- order by ParcelID
) 
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


-- Delete Unused Columns

Select *
From [SQL Data Cleaning].[dbo].[Nashville Housing]

ALTER TABLE [SQL Data Cleaning].[dbo].[Nashville Housing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [SQL Data Cleaning].[dbo].[Nashville Housing]
DROP COLUMN SaleDate