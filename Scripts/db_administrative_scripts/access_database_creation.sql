DO -- check for each role, if exists then skip, else create
$do$
BEGIN
   IF EXISTS ( -- create bndy user
      SELECT FROM pg_catalog.pg_roles
      WHERE  rolname = 'bndy') THEN

      RAISE NOTICE 'Role "bndy" already exists. Skipping.';
   ELSE
      CREATE ROLE bndy LOGIN PASSWORD 'AdminPass123' NOSUPERUSER; 
   END IF;

  IF EXISTS ( -- create acplan user
      SELECT FROM pg_catalog.pg_roles
      WHERE  rolname = 'acplan') THEN

      RAISE NOTICE 'Role "acplan" already exists. Skipping.';
   ELSE
      CREATE ROLE acplan LOGIN PASSWORD 'AdminPass123' NOSUPERUSER;
   END IF;

 IF EXISTS ( -- create trans user
      SELECT FROM pg_catalog.pg_roles
      WHERE  rolname = 'trans') THEN

      RAISE NOTICE 'Role "trans" already exists. Skipping.';
   ELSE
      CREATE ROLE trans LOGIN PASSWORD 'AdminPass123' NOSUPERUSER; 
   END IF;
   
  IF EXISTS ( -- create ges_editor user
      SELECT FROM pg_catalog.pg_roles
      WHERE  rolname = 'ges_editor') THEN

      RAISE NOTICE 'Role "ges_editor" already exists. Skipping.';
   ELSE
      CREATE ROLE ges_editor LOGIN PASSWORD 'EditorPass123' NOSUPERUSER; 
   END IF;

 IF EXISTS ( -- create ges_reader user 
      SELECT FROM pg_catalog.pg_roles
      WHERE  rolname = 'ges_reader') THEN

      RAISE NOTICE 'Role "ges_reader" already exists. Skipping.';
   ELSE
      CREATE ROLE ges_reader LOGIN PASSWORD 'EditorPass123' NOSUPERUSER; 
   END IF;

END
$do$;

BEGIN;
SAVEPOINT CREATE_SCHEMAS;

-- Set the database role to POSTGRES for administrative operations
SET ROLE POSTGRES;
-- Create the PostGIS extension if it's not already installed
-- Needed for working with geometry and geography types in spatial tables
CREATE EXTENSION IF NOT EXISTS postgis;

-- Create schemas if they do not already exist
-- Schemas organize tables and other database objects by domain
-- To ensure ownership works consistently, use authorization
CREATE SCHEMA IF NOT EXISTS admin;
CREATE SCHEMA IF NOT EXISTS econ;
CREATE SCHEMA IF NOT EXISTS edu;
CREATE SCHEMA IF NOT EXISTS elev;
CREATE SCHEMA IF NOT EXISTS envi;
CREATE SCHEMA IF NOT EXISTS health;
CREATE SCHEMA IF NOT EXISTS acplan;
CREATE SCHEMA IF NOT EXISTS soci;
CREATE SCHEMA IF NOT EXISTS trans;
CREATE SCHEMA IF NOT EXISTS utilcom;
CREATE SCHEMA IF NOT EXISTS bndy;
--ROLLBACK TO SAVEPOINT CREATE_SCHEMAS;

SAVEPOINT RBAC;
-- Grant USAGE on schemas to ges_editor
GRANT USAGE ON SCHEMA BNDY TO ges_editor;
GRANT USAGE ON SCHEMA ACPLAN TO ges_editor;
GRANT USAGE ON SCHEMA TRANS TO ges_editor;

-- Grant all privileges on the PUBLIC schema to BNDY user
GRANT ALL PRIVILEGES ON SCHEMA public TO BNDY;
-- Grant all privileges on all tables within the PUBLIC schema
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO BNDY;
-- Grant all privileges on all sequences within the PUBLIC schema
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO BNDY;
-- Grant all privileges on all functions within the PUBLIC schema
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO BNDY;


-- Grant all privileges on the PUBLIC schema to ACPLAN user
GRANT ALL PRIVILEGES ON SCHEMA public TO ACPLAN;
-- Grant all privileges on all tables within the PUBLIC schema
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ACPLAN;
-- Grant all privileges on all sequences within the PUBLIC schema
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO ACPLAN;
-- Grant all privileges on all functions within the PUBLIC schema
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO ACPLAN;

-- Grant all privileges on the PUBLIC schema to TRANS user
GRANT ALL PRIVILEGES ON SCHEMA public TO TRANS;
-- Grant all privileges on all tables within the PUBLIC schema
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO TRANS;
-- Grant all privileges on all sequences within the PUBLIC schema
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO TRANS;
-- Grant all privileges on all functions within the PUBLIC schema
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO TRANS;

-- Grant all privileges on BNDY schema to BNDY user
GRANT ALL PRIVILEGES ON SCHEMA BNDY TO BNDY;
-- Grant all privileges on all tables within the BNDY schema
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA BNDY TO BNDY;
-- Grant all privileges on all sequences within the BNDY schema
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA BNDY TO BNDY;
-- Grant all privileges on all functions within the BNDY schema
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA BNDY TO BNDY;

-- Grant all privileges on ACPLAN schema to ACPLAN user
GRANT ALL PRIVILEGES ON SCHEMA ACPLAN TO ACPLAN;
-- Grant all privileges on all tables within the ACPLAN schema
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA ACPLAN TO ACPLAN;
-- Grant all privileges on all sequences within the ACPLAN schema
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA ACPLAN TO ACPLAN;
-- Grant all privileges on all functions within the ACPLAN schema
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA ACPLAN TO ACPLAN;

-- Grant all privileges on TRANS schema to TRANS user
GRANT ALL PRIVILEGES ON SCHEMA TRANS TO TRANS;
-- Grant all privileges on all tables within the TRANS schema
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA TRANS TO TRANS;
-- Grant all privileges on all sequences within the TRANS schema
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA TRANS TO TRANS;
-- Grant all privileges on all functions within the TRANS schema
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA TRANS TO TRANS;

-- Grant future privileges on new tables in the public schema to BNDY
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT ALL PRIVILEGES ON TABLES TO BNDY;
-- Grant future privileges on new sequences in the public schema
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT ALL PRIVILEGES ON SEQUENCES TO BNDY;
-- Grant future privileges on new functions in the public schema
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT ALL PRIVILEGES ON FUNCTIONS TO BNDY;

-- Grant future privileges on new tables in the public schema to ACPLAN
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT ALL PRIVILEGES ON TABLES TO ACPLAN;
-- Grant future privileges on new sequences in the public schema
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT ALL PRIVILEGES ON SEQUENCES TO ACPLAN;
-- Grant future privileges on new functions in the public schema
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT ALL PRIVILEGES ON FUNCTIONS TO ACPLAN;

-- Grant future privileges on new tables in the public schema to TRANS
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT ALL PRIVILEGES ON TABLES TO TRANS;
-- Grant future privileges on new sequences in the public schema
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT ALL PRIVILEGES ON SEQUENCES TO TRANS;
-- Grant future privileges on new functions in the public schema
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT ALL PRIVILEGES ON FUNCTIONS TO TRANS;

-- Grant table-level privileges on all tables in the schema
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
ON ALL TABLES IN SCHEMA BNDY TO ges_editor;
-- Grant future privileges on tables in the schema
ALTER DEFAULT PRIVILEGES IN SCHEMA BNDY
FOR USER BNDY
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLES TO ges_editor;
-- Grant future privileges on sequences in the schema
ALTER DEFAULT PRIVILEGES IN SCHEMA BNDY
FOR USER BNDY
GRANT USAGE, SELECT, UPDATE ON SEQUENCES TO ges_editor;

-- Grant table-level privileges on all tables in the schema
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
ON ALL TABLES IN SCHEMA ACPLAN TO ges_editor;
-- Grant future privileges on tables in the schema
ALTER DEFAULT PRIVILEGES IN SCHEMA ACPLAN
FOR USER ACPLAN
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLES TO ges_editor;
-- Grant future privileges on sequences in the schema
ALTER DEFAULT PRIVILEGES IN SCHEMA ACPLAN
FOR USER ACPLAN
GRANT USAGE, SELECT, UPDATE ON SEQUENCES TO ges_editor;

-- Grant table-level privileges on all tables in the schema
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
ON ALL TABLES IN SCHEMA TRANS TO ges_editor;
-- Grant future privileges on tables in the schema
ALTER DEFAULT PRIVILEGES IN SCHEMA TRANS
FOR USER TRANS
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLES TO ges_editor;
-- Grant future privileges on sequences in the schema
ALTER DEFAULT PRIVILEGES IN SCHEMA TRANS
FOR USER TRANS
GRANT USAGE, SELECT, UPDATE ON SEQUENCES TO ges_editor;

-- Grant table-level privileges on all tables in the schema
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
ON ALL TABLES IN SCHEMA PUBLIC TO ges_editor;
-- Grant future privileges on tables in the schema
ALTER DEFAULT PRIVILEGES IN SCHEMA PUBLIC
FOR USER POSTGRES
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLES TO ges_editor;
-- Grant future privileges on sequences in the schema
ALTER DEFAULT PRIVILEGES IN SCHEMA PUBLIC
FOR USER POSTGRES
GRANT USAGE, SELECT, UPDATE ON SEQUENCES TO ges_editor;

-- Grant table-level privileges on all tables in the schema
GRANT SELECT
ON ALL TABLES IN SCHEMA BNDY TO ges_reader;
-- Grant future privileges on tables in the schema
ALTER DEFAULT PRIVILEGES IN SCHEMA BNDY
FOR USER BNDY
GRANT SELECT ON TABLES TO ges_reader;
-- Grant future privileges on sequences in the schema
ALTER DEFAULT PRIVILEGES IN SCHEMA BNDY
FOR USER BNDY
GRANT USAGE, SELECT ON SEQUENCES TO ges_reader;

-- Grant table-level privileges on all tables in the schema
GRANT SELECT
ON ALL TABLES IN SCHEMA ACPLAN TO ges_reader;
-- Grant future privileges on tables in the schema
ALTER DEFAULT PRIVILEGES IN SCHEMA ACPLAN
FOR USER ACPLAN
GRANT SELECT ON TABLES TO ges_reader;
-- Grant future privileges on sequences in the schema
ALTER DEFAULT PRIVILEGES IN SCHEMA ACPLAN
FOR USER ACPLAN
GRANT USAGE, SELECT ON SEQUENCES TO ges_reader;


-- Grant table-level privileges on all tables in the schema
GRANT SELECT
ON ALL TABLES IN SCHEMA TRANS TO ges_reader;
-- Grant future privileges on tables in the schema
ALTER DEFAULT PRIVILEGES IN SCHEMA TRANS
FOR USER TRANS
GRANT SELECT ON TABLES TO ges_reader;
-- Grant future privileges on sequences in the schema
ALTER DEFAULT PRIVILEGES IN SCHEMA TRANS
FOR USER TRANS
GRANT USAGE, SELECT ON SEQUENCES TO ges_reader;


-- Grant table-level privileges on all tables in the schema
GRANT SELECT
ON ALL TABLES IN SCHEMA PUBLIC TO ges_reader;
-- Grant future privileges on tables in the schema
ALTER DEFAULT PRIVILEGES IN SCHEMA PUBLIC
FOR USER POSTGRES
GRANT SELECT ON TABLES TO ges_reader;
-- Grant future privileges on sequences in the schema
ALTER DEFAULT PRIVILEGES IN SCHEMA PUBLIC
FOR USER POSTGRES
GRANT USAGE, SELECT ON SEQUENCES TO ges_reader;


GRANT USAGE ON SCHEMA acplan TO ges_reader;
GRANT USAGE ON SCHEMA public TO ges_reader;
GRANT SELECT ON acplan."V_NEW_DEV", acplan."V_RESI_BUS_ACCESS", acplan."V_RESI_TRAIN_ACCESS"
TO ges_reader;

-- Required for visibility
GRANT USAGE ON SCHEMA acplan TO ges_reader;
GRANT USAGE ON SCHEMA trans TO ges_reader;
GRANT USAGE ON SCHEMA bndy TO ges_reader;
GRANT USAGE ON SCHEMA public TO ges_reader;

-- Required for reading the actual data
GRANT SELECT ON ALL TABLES IN SCHEMA acplan TO ges_reader;
GRANT SELECT ON ALL TABLES IN SCHEMA trans TO ges_reader;
GRANT SELECT ON ALL TABLES IN SCHEMA bndy TO ges_reader;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO ges_reader;

GRANT USAGE, CREATE ON SCHEMA bndy TO ges_editor;
GRANT INSERT, SELECT, UPDATE, DELETE ON bndy."TRACT_BOUNDARY" TO ges_editor;

GRANT INSERT, SELECT, UPDATE, DELETE ON bndy."TRACT_BOUNDARY" TO ges_editor;

GRANT USAGE ON SCHEMA acplan, bndy, trans TO ges_editor;

--ROLLBACK TO SAVEPOINT RBAC;
SAVEPOINT CREATE_DOMAINS;
-- Drop and recreate custom domains (data types with value restrictions)
-- Domains improve data consistency and validation at the database level
DROP DOMAIN IF EXISTS dJurscode CASCADE;
-- Create jurisdiction code domain, as detailed in data model
CREATE DOMAIN dJurscode AS VARCHAR(4)
CHECK (VALUE IN ('ALLE',
			'ANNE',
			'BACI',
			'BACO',
			'CALV',
			'CARO',
			'CARR',
			'CECI',
			'CHAR',
			'DORC',
			'FRED',
			'GARR',
			'HARF',
			'HOWA',
			'KENT',
			'MONT',
			'PRIN',
			'QUEE',
			'STMA',
			'SOME',
			'TALB',
			'WASH',
			'WICO',
			'WORC',
			'NA'
) AND VALUE IS NOT NULL);


DROP DOMAIN IF EXISTS dLandUseType CASCADE;
-- Create land use type domain, as detailed in data model
CREATE DOMAIN dLandUseType AS VARCHAR(33)
CHECK (VALUE IN ('Residential (R)',
			'Industrial (I)',
			'Apartments (M)',
			'Commercial (C)',
			'Agricultural (A)',
			'Commercial Residential (CR)',
			'Exempt (E)',
			'Exempt Commercial (EC)',
			'Residential Condominium (U)',
			'Country Club (CA)',
			'Commercial Condominium (CC)',
			'Residential Commercial (RC)',
			'Town House (TH)',
			'NA'
) AND VALUE IS NOT NULL);

DROP DOMAIN IF EXISTS dCountyName CASCADE;
-- Create county name domain, as detailed in data model
CREATE DOMAIN dCountyName AS VARCHAR(25)
CHECK (VALUE IN ('Allegany County',
			'Anne Arundel County',
			'Baltimore city',
			'Baltimore County',
			'Calvert County',
			'Caroline County',
			'Carroll County',
			'Cecil County',
			'Charles County',
			'Dorchester County',
			'Frederick County',
			'Garrett County',
			'Harford County',
			'Howard County',
			'Kent County',
			'Montgomery County',
			'Prince Georges County',
			'Queen Annes County',
			'Saint Marys County',
			'Seed School',
			'Somerset County',
			'Talbot County',
			'Washington County',
			'Wicomico County',
			'Worcester County',
			'NA'
) AND VALUE IS NOT NULL);


DROP DOMAIN IF EXISTS dFlagValue CASCADE;
-- Create flag value domain, as detailed in data model
CREATE DOMAIN dFlagValue AS INTEGER
CHECK (VALUE IN (0,1) AND VALUE IS NOT NULL);

--ROLLBACK TO SAVEPOINT CREATE_DOMAINS;

SAVEPOINT CREATE_TABLES;

--ROLLBACK TO CREATE_TABLES;
-- Create a junction table to map county codes to jurisdiction codes
SET ROLE POSTGRES;
DROP TABLE IF EXISTS PUBLIC."J_COUNTY_CODE_JURSCODE" CASCADE;
CREATE TABLE PUBLIC."J_COUNTY_CODE_JURSCODE" (
    county_code INT NOT NULL UNIQUE,
    jurscode dJurscode UNIQUE-- Apply the domain to the jurscode column
);

-- Insert jurisdiction codes and their associated county codes into the lookup table
INSERT INTO PUBLIC."J_COUNTY_CODE_JURSCODE" (county_code, jurscode)
VALUES
    (1, 'ALLE'),
    (2, 'ANNE'),
    (3, 'BACO'),
    (24, 'BACI'),
    (4, 'CALV'),
    (5, 'CARO'),
    (6, 'CARR'),
    (7, 'CECI'),
    (8, 'CHAR'),
    (9, 'DORC'),
    (10, 'FRED'),
    (11, 'GARR'),
    (12, 'HARF'),
    (13, 'HOWA'),
    (14, 'KENT'),
    (15, 'MONT'),
    (16, 'PRIN'),
    (17, 'QUEE'),
    (19, 'SOME'),
    (18, 'STMA'),
    (20, 'TALB'),
    (21, 'WASH'),
    (22, 'WICO'),
    (23, 'WORC');

-- Switch to ACPLAN role to create and manage parcel data
SET ROLE ACPLAN;
--Drop and recreate the PARCELS table (property data)
DROP TABLE IF EXISTS ACPLAN."PARCELS" CASCADE;
CREATE TABLE ACPLAN."PARCELS" (
    account_id VARCHAR(15) PRIMARY KEY,
    premise_addr VARCHAR(45) NOT NULL,
    premise_city VARCHAR(35) NOT NULL,
    premise_zip VARCHAR(5) NOT NULL,
    premise_state VARCHAR(2) NOT NULL,
    mailing_addr VARCHAR(45) NOT NULL,
    mailing_city VARCHAR(35) NOT NULL,
    mailing_zip VARCHAR(5) NOT NULL,
    jurscode dJursCode REFERENCES PUBLIC."J_COUNTY_CODE_JURSCODE"(JURSCODE), -- domain for jurisdiction code
    county_name dCountyName, -- domain for county name
    yr_built SMALLINT NOT NULL,
    lu_code dLandUseType, -- domain for land use type
    real_prop_link VARCHAR(255) NOT NULL,
    yr_built_flag dFlagValue, -- domain for flag values
	lu_code_flag dFlagValue, -- domain for flag values
    geom geometry(Point, 26985) NOT NULL, -- PostGIS point type with SRID 26985
	CONSTRAINT ENFORCE_SRID_GEOM_PARCELS CHECK(ST_SRID(geom)=26985) -- Ensure that the SRID is 26985
);
-- Create spatial index on parcel geometries for faster spatial queries
CREATE INDEX idx_parcel_geom ON ACPLAN."PARCELS" USING GIST (geom);

-- Switch to BNDY role to manage county boundary data
SET ROLE BNDY;
-- Drop and recreate the COUNTY_BOUNDARY table (county boundaries geometry)
DROP TABLE IF EXISTS BNDY."COUNTY_BOUNDARY" CASCADE;
CREATE TABLE BNDY."COUNTY_BOUNDARY" (
    county_code SMALLINT REFERENCES PUBLIC."J_COUNTY_CODE_JURSCODE"(COUNTY_CODE),
    county_name dCountyName,
    geom GEOMETRY(MULTIPOLYGON, 26985) NOT NULL,
	CONSTRAINT ENFORCE_SRID_GEOM_BOUNDARY CHECK(ST_SRID(geom)=26985) -- Ensure that the SRID is 26985
);
-- Create spatial index on county boundary geometries for efficient spatial operations
CREATE INDEX idx_county_bndy_geom ON BNDY."COUNTY_BOUNDARY" USING GIST (geom);

-- BY GIVING OWNERSHIP TO THE SCHEMA, DROP CAN BE DONE
ALTER TABLE BNDY."TRACT_BOUNDARY" OWNER TO bndy;

SET ROLE BNDY;
DROP TABLE IF EXISTS BNDY."TRACT_BOUNDARY" CASCADE;
CREATE TABLE BNDY."TRACT_BOUNDARY"(
	objectid SMALLINT PRIMARY KEY,
	name VARCHAR(7) NOT NULL,
	tractfips VARCHAR(6) NOT NULL,
	countyfips varchar(3) NOT NULL,
	geom GEOMETRY(POLYGON, 26985) NOT NULL,
	CONSTRAINT ENFORCE_SRID_GEOM_TRCT_BNDY CHECK(ST_SRID(geom) = 26985)
);
CREATE INDEX idx_tract_bndy_geom ON BNDY."TRACT_BOUNDARY" USING GIST (geom);

-- Switch to TRANS role to manage county boundary data
SET ROLE TRANS;
-- Drop and recreate the COUNTY_BOUNDARY table (county boundaries geometry)
DROP TABLE IF EXISTS TRANS."MARC" CASCADE;
CREATE TABLE TRANS."MARC" (
	objectid VARCHAR(4) PRIMARY KEY,
	station_name VARCHAR(40) NOT NULL,
	station_address VARCHAR(40) NOT NULL,
	station_city VARCHAR(20) NOT NULL,
	station_state VARCHAR(2) NOT NULL,
	station_zip  VARCHAR(5) NOT NULL,
	transit_mo VARCHAR(15) NOT NULL,
	line_name VARCHAR(10) NOT NULL,
	facility_t VARCHAR(8) NOT NULL,
	geom geometry(Point, 26985) NOT NULL, -- PostGIS point type with SRID 26985
	CONSTRAINT ENFORCE_SRID_GEOM_MARC CHECK(ST_SRID(geom)=26985) -- Ensure that the SRID is 26985
);
-- Create spatial index on county boundary geometries for efficient spatial operations
CREATE INDEX idx_marc_geom ON TRANS."MARC" USING GIST (geom);


SET ROLE TRANS;
DROP TABLE IF EXISTS TRANS."AMTRAK" CASCADE;
CREATE TABLE TRANS."AMTRAK"(
 objectid  VARCHAR(2) PRIMARY KEY,
 station_name VARCHAR(50) NOT NULL,
 station_type VARCHAR(4) NOT NULL,
 station_code VARCHAR(3) NOT NULL,
 station_addr VARCHAR(35) NOT NULL,
 station_city VARCHAR(14) NOT NULL,
 station_state VARCHAR(2) NOT NULL,
 station_zip VARCHAR(5) NOT NULL,
 geom geometry(Point, 26985) NOT NULL,
 CONSTRAINT ENFORCE_SRID_GEOM_AMTRACK  CHECK(ST_SRID(geom)=26985)
);

-- Create spatial index on county boundary geometries for efficient spatial operations
CREATE INDEX idx_amtrak_geom ON TRANS."AMTRAK" USING GIST (geom);


DROP TABLE IF EXISTS TRANS."MTABUS" CASCADE;
CREATE TABLE TRANS."MTABUS" (
 objectid VARCHAR(5) PRIMARY KEY,
 stop_name VARCHAR(60) NOT NULL,
 routes_served VARCHAR(63) NOT NULL,
 mode VARCHAR(16) NOT NULL,
 county VARCHAR(22) NOT NULL,
 geom geometry(Point, 26985) NOT NULL,
 CONSTRAINT ENFORCE_SRID_GEOM_MTABUS CHECK(ST_SRID(geom) = 26985)
);

-- Create spatial index on county boundary geometries for efficient spatial operations
CREATE INDEX idx_mtabus_geom ON TRANS."MTABUS" USING GIST (geom);

DROP TABLE IF EXISTS TRANS."RIDEON" CASCADE;
CREATE TABLE TRANS."RIDEON" (
stop_code VARCHAR(5) PRIMARY KEY,
stop_name VARCHAR(54) NOT NULL,
town VARCHAR(18) NOT NULL,
geom geometry(Point, 26985) NOT NULL,
CONSTRAINT ENFORCE_SRID_GEOM_RIDEON CHECK(ST_SRID(geom) = 26985)
);
-- Create spatial index on county boundary geometries for efficient spatial operations
CREATE INDEX idx_rideon_geom ON TRANS."RIDEON" USING GIST (geom);

DROP TABLE IF EXISTS TRANS."WMATA" CASCADE;
CREATE TABLE TRANS."WMATA"(
gis_id VARCHAR(7) PRIMARY KEY,
station_name VARCHAR(44) NOT NULL,
station_addr VARCHAR(50) NOT NULL,
metroline VARCHAR(35) NOT NULL,
geom geometry(Point, 26985) NOT NULL,
CONSTRAINT ENFORCE_SRID_GEOM_WMATA CHECK(ST_SRID(geom) = 26985)
);
CREATE INDEX idx_wmata_geom ON TRANS."WMATA" USING GIST (geom);

--ROLLBACK TO SAVEPOINT CREATE_TABLES;
SAVEPOINT CREATE_VIEW;

SET ROLE ACPLAN;
--Where are the newly developed parcels (post-2020) located in Montgomery County
CREATE OR REPLACE VIEW ACPLAN."V_NEW_DEV" AS
SELECT
  account_id,
  premise_addr,
  premise_city,
  premise_zip,
  premise_state,
  mailing_addr,
  mailing_city,
  mailing_zip,
  jurscode,
  county_name,
  yr_built,
  lu_code,
  real_prop_link,
  yr_built_flag,
  lu_code_flag,
  geom::geometry(Point, 26985) AS geom
FROM ACPLAN."PARCELS"
WHERE yr_built >= 2020 AND lu_code_flag = 1;

set role postgres;
-- Allow access to the trans schema
GRANT USAGE ON SCHEMA trans TO acplan;

-- Allow reading the required tables
GRANT SELECT ON trans."MTABUS", trans."RIDEON" TO acplan;

SET ROLE TRANS;
-- Which newly developed residential parcels in Montgomery County have bus stops within 500 meters?
CREATE OR REPLACE VIEW ACPLAN."V_RESI_BUS_ACCESS" AS
SELECT 
  p.account_id,
   p.geom::geometry(Point, 26985) AS geom,
  CASE 
    WHEN b.account_id IS NOT NULL THEN 1
    ELSE 0
  END AS bus_access_flag
FROM ACPLAN."V_NEW_DEV" p
LEFT JOIN (
  SELECT DISTINCT p.account_id
  FROM ACPLAN."V_NEW_DEV" p
  JOIN trans."MTABUS" mta ON ST_DWithin(p.geom, mta.geom, 500)
  UNION
  SELECT DISTINCT p.account_id
  FROM acplan."V_NEW_DEV" p
  JOIN trans."RIDEON" r ON ST_DWithin(p.geom, r.geom, 500)
) b ON p.account_id = b.account_id;


SET ROLE TRANS;
-- Which newly developed residential parcels in Montgomery County have bus stops within 500 meters?
CREATE OR REPLACE VIEW ACPLAN."V_RESI_TRAIN_ACCESS" AS
SELECT
  p.account_id,
  p.geom::geometry(Point, 26985) AS geom,
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


-- Residential areas with no access to facilities
CREATE OR REPLACE VIEW ACPLAN."V_RESI_NO_TRANSIT_ACCESS" AS
SELECT 
  p.account_id,
  p.geom
FROM ACPLAN."V_NEW_DEV" p
WHERE NOT EXISTS (
  -- Nearby bus stops (within 500 meters)
  SELECT 1 
  FROM trans."MTABUS" b 
  WHERE ST_DWithin(p.geom, b.geom, 500)
  UNION
  SELECT 1 
  FROM trans."RIDEON" r 
  WHERE ST_DWithin(p.geom, r.geom, 500)
)
AND NOT EXISTS (
  -- Nearby train stations (within 1 mile = 1609 meters)
  SELECT 1 
  FROM (
    SELECT geom FROM trans."MARC"
    UNION ALL
    SELECT geom FROM trans."AMTRAK"
    UNION ALL
    SELECT geom FROM trans."WMATA"
  ) AS trains
  WHERE ST_DWithin(p.geom, trains.geom, 1609)
);

-- residential areas that do not have transit stations within 5 miles
CREATE OR REPLACE VIEW ACPLAN."V_NOTRAINSTATION_5MI" AS 
SELECT p.account_id, p.geom
FROM ACPLAN."V_NEW_DEV" p
WHERE NOT EXISTS( 
SELECT 1 FROM(
	SELECT geom FROM TRANS."MARC" 
	UNION ALL
	SELECT 	geom FROM TRANS."AMTRAK"
	UNION ALL
	SELECT geom FROM TRANS."WMATA"
) AS all_train_transit
WHERE ST_Dwithin(p.geom, all_train_transit.geom, 8046.72) -- 5 miles in meters
 );

-- Percentage of tracts with parcels access to bus facilities
SET ROLE ACPLAN;
CREATE OR REPLACE VIEW ACPLAN."V_TRACT_BUS_ACCESS_PCT" AS
SELECT 
t.tractfips,
COUNT(p.account_id) AS total_parcels,
SUM(p.bus_access_flag) AS parcels_with_bus_access,
ROUND(SUM(p.bus_access_flag)::numeric / COUNT(p.account_id) * 100, 2) AS percent_bus_access,
t.geom
FROM bndy."TRACT_BOUNDARY" t
JOIN ACPLAN."V_RESI_BUS_ACCESS" p
ON ST_Within(p.geom, t.geom)
GROUP BY t.tractfips,  t.geom;

-- Percentage of tracts with parcels access to train facilities
CREATE OR REPLACE VIEW ACPLAN."V_TRACT_TRAIN_ACCESS_PCT" AS
SELECT 
t.tractfips,
COUNT(p.account_id) AS total_parcels,
SUM(p.train_access_flag) AS parcels_with_bus_access,
ROUND(SUM(p.train_access_flag)::numeric / COUNT(p.account_id) * 100, 2) AS percent_train_access,
t.geom
FROM bndy."TRACT_BOUNDARY" t
JOIN ACPLAN."V_RESI_TRAIN_ACCESS" p
ON ST_Within(p.geom, t.geom)
GROUP BY t.tractfips,  t.geom;

-- Find the tracts with parcels with no access to transit facilities
CREATE OR REPLACE VIEW ACPLAN."V_TRACTS_WITH_NO_TRANSIT" AS
SELECT 
  t.tractfips,
  t.countyfips,
  COUNT(p.account_id) AS no_transit_parcels,
  ROUND(COUNT(p.account_id)::numeric * 100 / 6376, 2) AS pct_no_transit,
  t.geom
FROM BNDY."TRACT_BOUNDARY" t
JOIN ACPLAN."V_RESI_NO_TRANSIT_ACCESS" p
  ON ST_Within(p.geom, t.geom)
GROUP BY t.tractfips, t.countyfips, t.geom;



COMMIT;








