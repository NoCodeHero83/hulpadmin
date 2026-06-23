-- ============================================================
-- Migration 0001: Tablas geográficas paises / provincias / ciudades
-- + FK ciudad_id en solicitudes_servicio
-- Ejecutar en: Supabase SQL Editor (sandbox y luego producción)
-- ============================================================

-- ── 1. Tabla paises ───────────────────────────────────────
CREATE TABLE IF NOT EXISTS paises (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre     text NOT NULL,
  codigo     text,                        -- ISO 3166-1 alpha-2, ej: 'CO'
  activo     boolean NOT NULL DEFAULT true,
  creado_en  timestamptz NOT NULL DEFAULT now()
);

-- ── 2. Tabla provincias ───────────────────────────────────
CREATE TABLE IF NOT EXISTS provincias (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  pais_id    uuid NOT NULL REFERENCES paises(id) ON DELETE CASCADE,
  nombre     text NOT NULL,
  activo     boolean NOT NULL DEFAULT true,
  creado_en  timestamptz NOT NULL DEFAULT now()
);

-- ── 3. Tabla ciudades ─────────────────────────────────────
CREATE TABLE IF NOT EXISTS ciudades (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  provincia_id uuid NOT NULL REFERENCES provincias(id) ON DELETE CASCADE,
  nombre       text NOT NULL,
  activo       boolean NOT NULL DEFAULT true,
  creado_en    timestamptz NOT NULL DEFAULT now()
);

-- ── 4. FK en solicitudes_servicio ─────────────────────────
ALTER TABLE solicitudes_servicio
  ADD COLUMN IF NOT EXISTS ciudad_id uuid REFERENCES ciudades(id) ON DELETE SET NULL;

-- ── 5. RLS: lectura pública (anon y authenticated) ────────
ALTER TABLE paises     ENABLE ROW LEVEL SECURITY;
ALTER TABLE provincias ENABLE ROW LEVEL SECURITY;
ALTER TABLE ciudades   ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "paises_select"     ON paises;
DROP POLICY IF EXISTS "provincias_select" ON provincias;
DROP POLICY IF EXISTS "ciudades_select"   ON ciudades;

CREATE POLICY "paises_select"
  ON paises FOR SELECT USING (true);

CREATE POLICY "provincias_select"
  ON provincias FOR SELECT USING (true);

CREATE POLICY "ciudades_select"
  ON ciudades FOR SELECT USING (true);

-- ── 6. Seed: Colombia ─────────────────────────────────────
WITH ins_pais AS (
  INSERT INTO paises (nombre, codigo)
  VALUES ('Colombia', 'CO')
  ON CONFLICT DO NOTHING
  RETURNING id
),

ins_provincias AS (
  INSERT INTO provincias (pais_id, nombre)
  SELECT id, unnest(ARRAY[
    'Bogotá D.C.',
    'Antioquia',
    'Valle del Cauca',
    'Atlántico',
    'Bolívar',
    'Santander',
    'Risaralda',
    'Caldas',
    'Cundinamarca',
    'Nariño'
  ])
  FROM ins_pais
  RETURNING id, nombre
)

INSERT INTO ciudades (provincia_id, nombre)
SELECT p.id, c.nombre
FROM ins_provincias p
JOIN (VALUES
  ('Bogotá D.C.',    'Bogotá D.C.'),
  ('Antioquia',      'Medellín'),
  ('Antioquia',      'Bello'),
  ('Antioquia',      'Itagüí'),
  ('Valle del Cauca','Cali'),
  ('Valle del Cauca','Buenaventura'),
  ('Atlántico',      'Barranquilla'),
  ('Atlántico',      'Soledad'),
  ('Bolívar',        'Cartagena'),
  ('Santander',      'Bucaramanga'),
  ('Santander',      'Floridablanca'),
  ('Risaralda',      'Pereira'),
  ('Caldas',         'Manizales'),
  ('Cundinamarca',   'Soacha'),
  ('Nariño',         'Pasto')
) AS c(departamento, nombre) ON p.nombre = c.departamento;

-- ── 7. Índices ────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_provincias_pais_id      ON provincias(pais_id);
CREATE INDEX IF NOT EXISTS idx_ciudades_provincia_id   ON ciudades(provincia_id);
CREATE INDEX IF NOT EXISTS idx_ciudades_activo         ON ciudades(activo);
CREATE INDEX IF NOT EXISTS idx_solicitudes_ciudad_id   ON solicitudes_servicio(ciudad_id);
