-- Rollback 0001_geo_tables (nombres singulares)
ALTER TABLE solicitudes_servicio DROP COLUMN IF EXISTS ciudad_id;
DROP TABLE IF EXISTS ciudad;
DROP TABLE IF EXISTS provincia;
DROP TABLE IF EXISTS pais;