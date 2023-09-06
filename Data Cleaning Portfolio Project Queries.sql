/*

Cleaning Data in SQL Queries
Queried using PostgreSQL

*/

--Creating Table for CSV File holding Housing Data

CREATE TABLE nashvillehousing (
	  UniqueID int
	, ParcelID varchar(255)
	, LandUse varchar(255)
	, PropertyAddress varchar(255)
	, SaleDate timestamp
	, SalePrice varchar(255)
	, LegalReference varchar(255)
	, SoldAsVacant varchar(10)
	, OwnerName varchar(255)
	, OwnerAddress varchar(255)
	, Acreage float
	, TaxDistrict varchar(255)
	, LandValue bigint
	, BuildingValue bigint
	, TotalValue bigint
	, YearBuilt int
	, Bedrooms int
	, FullBath int
	, HalfBath int
);

--Selecting entire table to verify data inserted correctly

SELECT * 
FROM nashvillehousing

-----------------------------------------------------------------------------------

--Changing Date format/Data Type

--Verifying the "Date" data type is what we want to use

SELECT 
	  saledate
	, CAST(saledate AS date)
FROM 
	nashvillehousing

--Updating Column to the Data Type we will be using

ALTER TABLE nashvillehousing
ALTER COLUMN saledate TYPE date

-----------------------------------------------------------------------------------

--Populate "PropertyAddress" Data

-- Selecting all Data where "PropertyAddress" column is null
SELECT *
FROM 
	nashvillehousing
WHERE
	propertyaddress IS NULL
ORDER BY
	parcelid

/* 
Using Self Join to populate records where "PropertyAddress" column is Null but have a matching Property Address
via "Parcelid" in another record
*/

SELECT 
	  nh.parcelid
	, nh.propertyaddress
	, nvh.parcelid
	, nvh.propertyaddress
FROM
	nashvillehousing nh
JOIN nashvillehousing nvh
	ON nh.parcelid = nvh.parcelid
	AND nh.uniqueid <> nvh.uniqueid
WHERE
nh.propertyaddress IS NULL
ORDER BY nh.parcelid

-- Updating Column "PropertyAddress"

UPDATE nashvillehousing AS nh
SET propertyaddress = nvh.propertyaddress
FROM
nashvillehousing AS nvh 
WHERE nh.parcelid = nvh.parcelid
AND nh.uniqueid <> nvh.uniqueid
AND nh.propertyaddress IS NULL

-- Verifying Update statement worked properly

SELECT *
FROM 
	nashvillehousing
WHERE
	propertyaddress IS NULL
ORDER BY
	parcelid
	
-----------------------------------------------------------------------------------

-- Breaking out "PropertyAddress" into individual columns (Address, City)

SELECT
	propertyaddress
FROM 
	nashvillehousing
ORDER BY
	parcelid
	

SELECT
	  SPLIT_PART(propertyaddress, ',', 1) AS Address
	, SPLIT_PART(propertyaddress, ',', 2) AS City
FROM 
	nashvillehousing

-- Adding Updated "PropertyAddress" Columns (Address, City) to NashvilleHousing table
ALTER TABLE nashvillehousing
ADD address_updated varchar(255)
;

UPDATE nashvillehousing
SET address_updated = SPLIT_PART(propertyaddress, ',', 1)

ALTER TABLE nashvillehousing
ADD city_updated varchar(255)
;

UPDATE nashvillehousing
SET city_updated = SPLIT_PART(propertyaddress, ',', 2)

-- Verifying table updates

SELECT *
FROM
	nashvillehousing
	
-- Breaking out "OwnerAddress" into individual columns (Address, City, State)

SELECT
	owneraddress
FROM
	nashvillehousing
ORDER BY
	parcelid
	
ALTER TABLE nashvillehousing
ADD owner_address_updated varchar(255)
;

UPDATE nashvillehousing
SET owner_address_updated = SPLIT_PART(owneraddress, ',', 1)

ALTER TABLE nashvillehousing
ADD owner_city_updated varchar(255)
;

UPDATE nashvillehousing
SET owner_city_updated = SPLIT_PART(owneraddress, ',', 2)

ALTER TABLE nashvillehousing
ADD owner_state_updated varchar(255)
;

UPDATE nashvillehousing
SET owner_state_updated = SPLIT_PART(owneraddress, ',', 3)

-- Verifying table updates

SELECT *
FROM
	nashvillehousing
	
-----------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold As Vacant" Field

SELECT 
	DISTINCT(soldasvacant)
	, COUNT(soldasvacant) AS record_count
FROM
	nashvillehousing
GROUP BY
	soldasvacant
ORDER BY
	record_count
	
	
SELECT
	soldasvacant
, CASE
		WHEN soldasvacant = 'Y' THEN 'Yes'
		WHEN soldasvacant = 'N' THEN 'No'
		ELSE soldasvacant
  END AS sold_as_vacant_updated
FROM
	nashvillehousing


UPDATE nashvillehousing
SET soldasvacant = CASE
						WHEN soldasvacant = 'Y' THEN 'Yes'
						WHEN soldasvacant = 'N' THEN 'No'
						ELSE soldasvacant
				   END

-----------------------------------------------------------------------------------

-- Delete unused columns

ALTER TABLE nashvillehousing
  DROP COLUMN owneraddress
, DROP COLUMN taxdistrict
, DROP COLUMN propertyaddress

-----------------------------------------------------------------------------------

-- Remove Duplicate records

-- Creating a table with the same structure as the target table "nashvillehousing"

CREATE TABLE nashville_housing (LIKE nashvillehousing);


-- Inserting Distinct records from the source table "nashvillehousing" into the new table "nashville_housing"

INSERT INTO nashville_housing(
	  uniqueid
	, parcelid
	, landuse
	, saledate
	, saleprice
	, legalreference
	, soldasvacant
	, ownername
	, acreage
	, landvalue
	, buildingvalue
	, totalvalue
	, yearbuilt
	, bedrooms
	, fullbath
	, halfbath
	, address_updated
	, city_updated
	, owner_address_updated
	, owner_city_updated
	, owner_state_updated
)
SELECT DISTINCT ON (parcelid
				  , address_updated
				  , saleprice
				  , saledate
				  , legalreference
				   )
				    uniqueid
				  , parcelid
				  , landuse
				  , saledate
				  , saleprice
				  , legalreference
				  , soldasvacant
				  , ownername
				  , acreage
				  , landvalue
				  , buildingvalue
				  , totalvalue
				  , yearbuilt
				  , bedrooms
				  , fullbath
				  , halfbath
				  , address_updated
				  , city_updated
				  , owner_address_updated
				  , owner_city_updated
				  , owner_state_updated
FROM nashvillehousing
;

-- Verifying the new tables records against the source table

SELECT *
FROM nashville_housing

SELECT *
FROM nashvillehousing

/*
Dropping the Source table with duplicate records and keeping the newly updated table "Nashville_housing" 
with Distinct records only
*/

DROP TABLE nashvillehousing

-----------------------------------------------------------------------------------

-- Cleaning Completed

SELECT *
FROM nashville_housing