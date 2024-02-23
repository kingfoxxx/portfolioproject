--cleaning data in sql queries

SELECT * FROM public.vashvilledatas;

--standardize saledate

SELECT sale_date, sale_date::date
FROM public.vashvilledatas;

UPDATE public.vashvilledatas
SET sale_date = CAST(sale_date AS DATE);

select sale_date, sale_date::date 
from public.vashvilledatas;

--populate property address data
SELECT *
FROM public.vashvilledatas
--where property_address is null;
order by parcel_id;

SELECT a.parcel_id AS parcel_id_a, 
       COALESCE(a.property_address, b.property_address) AS property_address,
       b.parcel_id AS parcel_id_b, 
       b.property_address AS property_address_b
FROM public.vashvilledatas AS a
JOIN public.vashvilledatas AS b
ON a.parcel_id = b.parcel_id
AND a.legal_reference <> b.legal_reference
where a.property_address is null;

UPDATE public.vashvilledatas AS a
SET property_address = COALESCE(a.property_address, b.property_address)
FROM public.vashvilledatas AS b
WHERE a.parcel_id = b.parcel_id
AND a.legal_reference <> b.legal_reference;

SELECT a.parcel_id AS parcel_id_a, 
       COALESCE(a.property_address, b.property_address) AS property_address,
       b.parcel_id AS parcel_id_b, 
       b.property_address AS property_address_b
FROM public.vashvilledatas AS a
JOIN public.vashvilledatas AS b
ON a.parcel_id = b.parcel_id
AND a.legal_reference <> b.legal_reference
where a.property_address is null;

UPDATE public.vashvilledatas AS a
SET property_address = b.property_address
FROM public.vashvilledatas AS b
WHERE a.parcel_id = b.parcel_id
AND a.legal_reference <> b.legal_reference
AND a.property_address IS NULL;

SELECT *
FROM public.vashvilledatas
WHERE property_address is NULL;

UPDATE public.vashvilledatas AS a
SET property_address = COALESCE(a.property_address, b.property_address)
FROM public.vashvilledatas AS b
WHERE a.parcel_id = b.parcel_id
AND a.legal_reference <> b.legal_reference
AND a.property_address IS NULL;

SELECT a.parcel_id AS parcel_id_a, 
       COALESCE(a.property_address, b.property_address) AS property_address,
       b.parcel_id AS parcel_id_b, 
       b.property_address AS property_address_b
FROM public.vashvilledatas AS a
JOIN public.vashvilledatas AS b
ON a.parcel_id = b.parcel_id
AND a.legal_reference <> b.legal_reference
where a.property_address is null;

UPDATE public.vashvilledatas AS a
SET property_address = COALESCE(a.property_address, b.property_address, 'Nashville North')
FROM public.vashvilledatas AS b
WHERE a.parcel_id = b.parcel_id
AND a.legal_reference <> b.legal_reference
AND a.property_address IS NULL
AND b.property_address IS NULL;

SELECT a.parcel_id AS parcel_id_a, 
       COALESCE(a.property_address, b.property_address) AS property_address,
       b.parcel_id AS parcel_id_b, 
       b.property_address AS property_address_b
FROM public.vashvilledatas AS a
JOIN public.vashvilledatas AS b
ON a.parcel_id = b.parcel_id
AND a.legal_reference <> b.legal_reference
where a.property_address is null;

SELECT *
FROM public.vashvilledatas
WHERE property_address is NULL;

UPDATE public.vashvilledatas
SET property_address = COALESCE(property_address, 'Nashville Town')
WHERE property_address IS NULL;

SELECT *
FROM public.vashvilledatas
WHERE property_address is NULL;

SELECT a.parcel_id AS parcel_id_a, 
       COALESCE(a.property_address, b.property_address) AS property_address,
       b.parcel_id AS parcel_id_b, 
       b.property_address AS property_address_b
FROM public.vashvilledatas AS a
JOIN public.vashvilledatas AS b
ON a.parcel_id = b.parcel_id
AND a.legal_reference <> b.legal_reference
where a.property_address is null;


--breaking out address intoindividual columns(address, cities, states)
SELECT property_address
FROM public.vashvilledatas;


SELECT owner_address
FROM public.vashvilledatas;

--change true anf false to yes and no
select distinct(sold_as_vacant), count(sold_as_vacant)
FROM public.vashvilledatas
group by sold_as_vacant
order by 2;

SELECT 
    CASE 
        WHEN sold_as_vacant = 'true' THEN True
        WHEN sold_as_vacant = 'false' THEN False
    END AS sold_as_vacant
FROM 
    public.vashvilledatas;
	
UPDATE vashvilledatas
SET sold_as_vacant = CASE 
                        WHEN sold_as_vacant = 'true' THEN True
                        WHEN sold_as_vacant = 'false' THEN False
                     END;


select distinct(sold_as_vacant), count(sold_as_vacant)
FROM public.vashvilledatas
group by sold_as_vacant
order by 2;

--removing duplication
WITH rownumCTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY parcel_id,
                            property_address,
                            sale_price,
                            sale_date,
                            legal_reference
           ) AS row_num
    FROM public.vashvilledatas
)
DELETE FROM public.vashvilledatas
WHERE (parcel_id, property_address, sale_price, sale_date, legal_reference) IN (
    SELECT parcel_id, property_address, sale_price, sale_date, legal_reference
    FROM rownumCTE
    WHERE row_num > 1
);

WITH rownumCTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY parcel_id,
                            property_address,
                            sale_price,
                            sale_date,
                            legal_reference
           ) AS row_num
    FROM public.vashvilledatas
)
SELECT *
FROM rownumCTE
WHERE row_num > 1
ORDER BY property_address;


--delete unused columns

SELECT * FROM public.vashvilledatas;

-- Alter the table to drop the column 'tax_district'
ALTER TABLE public.vashvilledatas
DROP COLUMN tax_district;








