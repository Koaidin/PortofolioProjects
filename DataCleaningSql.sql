## select data cleaning

SELECT * 
FROM NashvilleHousing;

## Populate Property Address Data


SET SQL_SAFE_UPDATES = 0;
UPDATE NashvilleHousing
SET propertyAddress = NULL 
WHERE propertyAddress = '';

SELECT *
FROM NashvilleHousing
##WHERE PropertyAddress is null
ORDER BY ParcelID;


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM NashvilleHousing a JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID != b.UniqueID
WHERE a.PropertyAddress is null;

UPDATE NashvilleHousing a
LEFT JOIN NashvilleHousing b ON a.ParcelID = b.ParcelID 
AND a.UniqueID <> b.UniqueID 
SET a.PropertyAddress = b.PropertyAddress 
WHERE
    a.PropertyAddress IS NULL;


## Breaking down address into individual colums (address,city,sta)

SELECT PropertyAddress
FROM NashvilleHousing;

SELECT substring_index(Propertyaddress,',', 1) AS Address, 
	   substring_index(Propertyaddress,',', -1) AS city
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD split_address varchar(50);

UPDATE NashvilleHousing 
SET split_address = substring_index(Propertyaddress,',', 1);

ALTER TABLE NashvilleHousing
ADD disperate_city varchar(50);

UPDATE NashvilleHousing
SET disperate_city = substring_index(Propertyaddress,',', -1);


SELECT * 
FROM NashvilleHousing;



## Seperate the OwnerAddress

SELECT substring_index(OwnerAddress,',',1),
substring_index(substring_index(OwnerAddress,',',2),' ',-1),
substring_index(OwnerAddress,',',-1)
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress varchar(50);

UPDATE NashvilleHousing
SET OwnerSplitAddress = substring_index(OwnerAddress,',',1);

ALTER TABLE NashvilleHousing
ADD Owner_split_city varchar(50);

UPDATE NashvilleHousing
SET Owner_split_city = substring_index(substring_index(OwnerAddress,',',2),' ',-1);

ALTER TABLE NashvilleHousing
ADD Owner_split_state varchar(50);

UPDATE NashvilleHousing
SET Owner_split_state = substring_index(OwnerAddress,',',-1);

SELECT * 
FROM NashvilleHousing;

## Change Y and N to Yes and No in 'SoldAsVacant' field

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'N' THEN 'No'
		 WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 ELSE SoldAsVacant
         END    
FROM NashvilleHousing;

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'N' THEN 'No'
		 WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 ELSE SoldAsVacant
         END;   


## REMOVE DUBLICATES

WITH RowNumCte AS(
SELECT *, 
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
			PropertyAddress,
            SaleDate,
            LegalReference,
            SalePrice
            ORDER BY 
				UniqueID) AS row_num
FROM NashvilleHousing
##ORDER BY ParcelID
)
DELETE NH
FROM NashvilleHousing NH JOIN RowNumCte R ON NH.UniqueID = R.UniqueID
WHERE row_num > 1;
## ORDER BY PropertyAddress;


## Delete Unused Columns 

SELECT * 
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
##DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress;