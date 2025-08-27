-- Lists all parcels in the main dataset
select * from acplan."PARCELS";

-- Rechecks the new development view
SELECT * FROM ACPLAN."V_NEW_DEV";

-- Filters new parcels with bus access
SELECT * FROM ACPLAN."V_RESI_BUS_ACCESS" where bus_access_flag = 1;

-- Filters new parcels with train access
SELECT * FROM ACPLAN."V_RESI_TRAIN_ACCESS" where train_access_flag = 1;

-- All tract polygons (used for spatial joins)
SELECT * FROM BNDY."TRACT_BOUNDARY";

-- Parcels with no bus or train access
SELECT * FROM ACPLAN."V_RESI_WITHOUT_TRANSIT";

-- Parcels located more than 5 miles from any train station
SELECT * FROM ACPLAN."V_NOTRAINSTATION_5MI";

-- Count of new parcels with train access
SELECT COUNT * OF TRAIN_ACCESS_FLAG 
FROM ACPLAN."V_RESI_TRAIN_ACCESS";

-- Aggregated bus access by tract
SELECT * FROM ACPLAN."V_TRACT_BUS_ACCESS_PCT";

-- Tracts where no new parcels have any transit access
SELECT * FROM ACPLAN."V_TRACTS_WITH_NO_TRANSIT";

-- Another view for parcels with no access (redundant check)
SELECT * FROM  ACPLAN."V_RESI_NO_TRANSIT_ACCESS";



-- Grants permission for editing tract boundaries
GRANT INSERT, SELECT, UPDATE, DELETE ON bndy."TRACT_BOUNDARY" TO ges_editor;

-- Grants usage access to schemas
GRANT USAGE ON SCHEMA acplan, bndy, trans TO ges_editor;

-- Grants read-only access to all tables for editing role
GRANT SELECT ON ALL TABLES IN SCHEMA acplan, bndy, trans TO ges_editor;

-- Grants future table privileges for editing role
ALTER DEFAULT PRIVILEGES IN SCHEMA acplan, bndy, trans
FOR USER acplan, bndy, trans
GRANT SELECT ON TABLES TO ges_editor;

-- Lists all geometry columns and their SRIDs
SELECT f_table_schema, f_table_name, f_geometry_column, srid, type 
FROM geometry_columns
WHERE f_table_schema IN ('acplan', 'bndy', 'trans');



-- which residential facilities have either of the transit facilities
CREATE OR REPLACE VIEW ACPLAN."V_RESI_WITH_TRANSIT" AS
SELECT
  b.account_id,
  b.geom,
  b.bus_access_flag,
  t.train_access_flag
FROM ACPLAN."V_RESI_BUS_ACCESS" b
JOIN ACPLAN."V_RESI_TRAIN_ACCESS" t USING (account_id)
WHERE b.bus_access_flag = 1 AND t.train_access_flag = 1;


-- Filters only newly built residential parcels
SELECT * 
FROM acplan."PARCELS"
WHERE yr_built >= 2020
  AND lu_code_flag = 1;

-- Calculates the percentage of new parcels that are residential
SELECT
  COUNT(*) FILTER (WHERE lu_code_flag = 1)::FLOAT / COUNT(*) * 100 AS residential_pct
FROM acplan."PARCELS"
WHERE yr_built >= 2020;

-- Determines bus access (500m) for new parcels using MTA and RideOn
SELECT 
  p.account_id,
  p.geom,
  CASE 
    WHEN b.account_id IS NOT NULL THEN 1
    ELSE 0
  END AS bus_access_flag
FROM acplan."V_NEW_DEV" p
LEFT JOIN (
  SELECT DISTINCT p.account_id
  FROM acplan."V_NEW_DEV" p
  JOIN trans."MTABUS" mta ON ST_DWithin(p.geom, mta.geom, 500)
  UNION
  SELECT DISTINCT p.account_id
  FROM acplan."V_NEW_DEV" p
  JOIN trans."RIDEON" r ON ST_DWithin(p.geom, r.geom, 500)
) b ON p.account_id = b.account_id;

-- Lists all records in the bus access view
SELECT * FROM ACPLAN."V_RESI_BUS_ACCESS";

-- Counts parcels by bus access flag (1 = access, 0 = no access)
SELECT bus_access_flag,
COUNT(*) AS parcel_count
FROM acplan."V_RESI_BUS_ACCESS"
GROUP BY bus_access_flag;


-- Lists all user-created tables
SELECT * FROM geometry_columns;
SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema NOT IN ('pg_catalog', 'information_schema');

-- Recreates the view for new parcels with train access within 1 mile
CREATE OR REPLACE VIEW acplan."V_RESI_TRAIN_ACCESS" AS
SELECT
  p.account_id,
  p.geom,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM (
        SELECT geom FROM trans."MARC"
        UNION ALL
        SELECT geom FROM trans."AMTRAK"
        UNION ALL
        SELECT geom FROM trans."WMATA"
      ) AS trains
      WHERE ST_DWithin(p.geom, trains.geom, 1609)
    )
    THEN 1
    ELSE 0
  END AS train_access_flag
FROM acplan."V_NEW_DEV" AS p;

-- Summarizes parcels by train access flag
SELECT train_access_flag, COUNT(*) 
FROM acplan."V_RESI_TRAIN_ACCESS" 
GROUP BY train_access_flag;

-- Copies tract data into permanent boundary table
INSERT INTO bndy."TRACT_BOUNDARY" (objectid, name, tractfips, countyfips, geom)
SELECT objectid, name, tractfips, countyfips, geom
FROM bndy."TEMP_TRACT_BOUNDARY";


-- Counts MARC stations in Montgomery County
SELECT COUNT(*) AS MARC_COUNT
FROM TRANS."MARC" t
JOIN BNDY."COUNTY_BOUNDARY" c ON c.county_name = 'Montgomery County'
WHERE ST_Within(t.geom, c.geom);

-- Counts AMTRAK stations in Montgomery County
SELECT COUNT(*) AS AMTRAK_COUNT
FROM TRANS."AMTRAK" t
JOIN BNDY."COUNTY_BOUNDARY" c ON c.county_name = 'Montgomery County'
WHERE ST_Within(t.geom, c.geom);

-- Counts WMATA stations in Montgomery County
SELECT COUNT(*) AS WMATA_COUNT
FROM TRANS."WMATA" t
JOIN BNDY."COUNTY_BOUNDARY" c ON c.county_name = 'Montgomery County'
WHERE ST_Within(t.geom, c.geom);

-- Counts MTA bus stops in Montgomery County
SELECT COUNT(*) AS MTABUS_COUNT
FROM TRANS."MTABUS" t
JOIN BNDY."COUNTY_BOUNDARY" c ON c.county_name = 'Montgomery County'
WHERE ST_Within(t.geom, c.geom);

-- Counts RideOn bus stops in Montgomery County
SELECT COUNT(*) AS RIDEON_COUNT
FROM TRANS."RIDEON" t
JOIN BNDY."COUNTY_BOUNDARY" c ON c.county_name = 'Montgomery County'
WHERE ST_Within(t.geom, c.geom);