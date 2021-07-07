-- Database: nashvillehousing

-- DROP DATABASE nashvillehousing;

CREATE DATABASE nashvillehousing
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'English_United States.1252'
    LC_CTYPE = 'English_United States.1252'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;
-------------------------------------------------------------------------------------------------------------------	
CREATE TABLE nashville_housing (
	UniqueID SERIAL, 
	ParcelID INT,
	LandUse VARCHAR (100),
	PropertyAddress VARCHAR(200),
	SaleDate date,
	SalePrice numeric, 
	LegalReference varchar(200),
	SoldAsVacant varchar(10),
	OwnerName varchar(200),
	OwnerAddress varchar(200),
	Acreage	decimal,
	TaxDistrict varchar(200),
	LandValue numeric,
	BuildingValue numeric, 
	TotalValue numeric, 
	YearBuilt integer,
	Bedrooms integer,
	FullBath integer,
	HalfBath integer
)	

SELECT * FROM nashville_housing
----------------------------------------------------------------------------------------------------------
ALTER TABLE nashville_housing
ALTER COLUMN ParcelID SET DATA TYPE varchar
ALTER TABLE nashville_housing
ALTER COLUMN SalePrice SET DATA TYPE varchar

COPY nashville_housing FROM 'C:\Users\user\Desktop\SQL PROJECTS\Nashville Housing Data for Data Cleaning.csv' DELIMITER ',' CSV HEADER;
SELECT * FROM nashville_housing
-----------------------------------------------------------------------------------------------------------
-- standardize date format
ALTER TABLE nashville_housing
Add SaleDateConverted Date;

Update nashville_housing
SET SaleDateConverted = CONVERT(date, SaleDate)

-- it will work if we have a timeframe along with a date in our data

----------------------------------------------------------------------------------------------------------
-- Breaking out propertyaddress into Individual Columns (Address, City)
-- we have the address and the city name together we need to split them apart

select propertyaddress
      ,split_part(propertyaddress, ',', 1) property_address
      ,split_part(propertyaddress, ',', 2) property_city 
from nashville_housing

alter table nashville_housing
add column property_address varchar
update nashville_housing
set property_address = split_part(propertyaddress, ',', 1)

alter table nashville_housing
add column property_city varchar
update nashville_housing
set property_city = split_part(propertyaddress, ',', 2)

SELECT * FROM nashville_housing

----------------------------------------------------------------------------------------------------------

-- Populate Property Address data
-- there exist addresses that match but have different unique id so we need to join them 
-- in order to replace the null propertyaddress with the real propertyaddress
SELECT count(DISTINCT parcelid) FROM nashville_housing
select count (parcelid) from nashville_housing
--SELECT count(DISTINCT parcelid) FROM nashville_housing != select count (parcelid) from nashville_housing
SELECT a.propertyaddress, a.parcelid, a.uniqueid, b.propertyaddress, b.uniqueid
FROM nashville_housing a
join nashville_housing b
on a.parcelid = b.parcelid
AND a.uniqueid != b.uniqueid
where a.propertyaddress is null

UPDATE a
SET propertyaddress = ISNULL(a.propertyaddress, b.propertyaddress)
FROM nashville_housing a
join nashville_housing b
	on a.parcelid = b.parcelid
	AND a.uniqueid != b.uniqueid
where a.propertyaddress is null

----------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field
select DISTINCT soldasvacant, count(soldasvacant) from nashville_housing
group by soldasvacant
order by 2

select soldasvacant,
CASE when soldasvacant = 'N' then 'No'
	when soldasvacant = 'Y' then 'Yes'
	else soldasvacant
end
from nashville_housing

update nashville_housing 
set soldasvacant =
CASE when soldasvacant = 'N' then 'No'
	when soldasvacant = 'Y' then 'Yes'
	else soldasvacant
end

select * from nashville_housing

-----------------------------------------------------------------------------------------------------------
-- Breaking out propertyaddress into Individual Columns (Address, City)
-- we have the address and the city name together we need to split them apart

select propertyaddress
      ,split_part(owneraddress, ',', 1) owner_address
      ,split_part(owneraddress, ',', 2) owner_city 
	  ,split_part(owneraddress, ',', 3) owner_state 
from nashville_housing

alter table nashville_housing
add column owner_address varchar
update nashville_housing
set owner_address = split_part(owneraddress, ',', 1)

alter table nashville_housing
add column owner_city varchar
update nashville_housing
set owner_city = split_part(owneraddress, ',', 2)

alter table nashville_housing
add column owner_state varchar
update nashville_housing
set owner_state = split_part(owneraddress, ',', 3)

SELECT * FROM nashville_housing

-----------------------------------------------------------------------------------------------------------
-- delete rows that we will not use

Select *
From nashville_housing


ALTER TABLE nashville_housing
DROP COLUMN taxdistrict

ALTER TABLE nashville_housing
DROP COLUMN propertyaddress

ALTER TABLE nashville_housing
DROP COLUMN saledate

ALTER TABLE nashville_housing
DROP COLUMN owneraddress




	