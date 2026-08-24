-- Pone la rama de test (ptafsiwlhxomgqmdmidf) al día con producción.
--
-- La rama de test se quedó atrás: le faltaban las tres tablas de catálogo
-- geográfico, `ciudad_id`, las coordenadas de REQ-008 y `precios_adicionales`.
-- Sin esto el admin no arranca contra test y no hay forma de probar nada.
--
-- Idempotente: se puede volver a correr sin romper nada.
-- Aplicado el 2026-08-24.

-- 1. Catálogo geográfico -----------------------------------------------------

create table if not exists public.paises (
  id        uuid primary key default gen_random_uuid(),
  nombre    text not null,
  codigo    text,
  activo    boolean not null default true,
  creado_en timestamptz not null default now()
);

create table if not exists public.provincias (
  id        uuid primary key default gen_random_uuid(),
  pais_id   uuid not null references public.paises(id) on delete cascade,
  nombre    text not null,
  activo    boolean not null default true,
  creado_en timestamptz not null default now()
);

create table if not exists public.ciudades (
  id           uuid primary key default gen_random_uuid(),
  provincia_id uuid not null references public.provincias(id) on delete cascade,
  nombre       text not null,
  activo       boolean not null default true,
  creado_en    timestamptz not null default now()
);

alter table public.paises     enable row level security;
alter table public.provincias enable row level security;
alter table public.ciudades   enable row level security;

-- Catálogo público de solo lectura: cualquiera puede listar ciudades, nadie
-- las modifica desde el cliente.
drop policy if exists paises_select on public.paises;
create policy paises_select on public.paises for select using (true);
drop policy if exists provincias_select on public.provincias;
create policy provincias_select on public.provincias for select using (true);
drop policy if exists ciudades_select on public.ciudades;
create policy ciudades_select on public.ciudades for select using (true);

grant select on public.paises, public.provincias, public.ciudades
  to anon, authenticated;

-- 2. Columnas que faltaban ---------------------------------------------------

alter table public.solicitudes_servicio
  add column if not exists ciudad_id uuid,
  add column if not exists latitud   numeric(10,7),
  add column if not exists longitud  numeric(10,7);

alter table public.servicios
  add column if not exists precios_adicionales jsonb;

do $$
begin
  if not exists (select 1 from pg_constraint
                 where conname = 'solicitudes_servicio_ciudad_id_fkey') then
    alter table public.solicitudes_servicio
      add constraint solicitudes_servicio_ciudad_id_fkey
      foreign key (ciudad_id) references public.ciudades(id) on delete set null;
  end if;

  if not exists (select 1 from pg_constraint
                 where conname = 'solicitudes_servicio_latitud_valida') then
    alter table public.solicitudes_servicio
      add constraint solicitudes_servicio_latitud_valida
      check (latitud is null or (latitud >= -90 and latitud <= 90));
  end if;

  if not exists (select 1 from pg_constraint
                 where conname = 'solicitudes_servicio_longitud_valida') then
    alter table public.solicitudes_servicio
      add constraint solicitudes_servicio_longitud_valida
      check (longitud is null or (longitud >= -180 and longitud <= 180));
  end if;

  -- Media coordenada no ubica nada: o van las dos o no va ninguna.
  if not exists (select 1 from pg_constraint
                 where conname = 'solicitudes_servicio_coordenadas_completas') then
    alter table public.solicitudes_servicio
      add constraint solicitudes_servicio_coordenadas_completas
      check ((latitud is null) = (longitud is null));
  end if;
end $$;

create index if not exists idx_solicitudes_ciudad
  on public.solicitudes_servicio(ciudad_id);

-- 3. Datos del catálogo ------------------------------------------------------
-- Con los mismos UUID que producción, para que un `ciudad_id` copiado de una
-- base valga en la otra.

insert into public.paises (id,nombre,codigo,activo) values
  ('d598a5ae-66d5-4d52-aee6-f3c8f85a6c45','Colombia','CO',true)
  on conflict (id) do nothing;

insert into public.provincias (id,pais_id,nombre,activo) values
  ('2480c2c3-8b47-4e42-865f-e779390edfd9','d598a5ae-66d5-4d52-aee6-f3c8f85a6c45','Antioquia',true),
  ('77a6bd77-eed1-4df7-a8c6-552bf6569f4a','d598a5ae-66d5-4d52-aee6-f3c8f85a6c45','Bogotá D.C.',true),
  ('6e466fe3-fe04-4cf2-a3e3-11a5dd036259','d598a5ae-66d5-4d52-aee6-f3c8f85a6c45','Valle del Cauca',true)
  on conflict (id) do nothing;

insert into public.ciudades (id,provincia_id,nombre,activo) values
  ('f5154bda-e89d-4e67-9fae-1607468a5b37','77a6bd77-eed1-4df7-a8c6-552bf6569f4a','Bogotá D.C.',true),
  ('98d2d054-f983-427f-a900-223313ab5fc1','6e466fe3-fe04-4cf2-a3e3-11a5dd036259','Cali',true),
  ('81d3c865-419d-456f-a5c1-ccfe45a0c9a6','2480c2c3-8b47-4e42-865f-e779390edfd9','Medellín',true)
  on conflict (id) do nothing;
