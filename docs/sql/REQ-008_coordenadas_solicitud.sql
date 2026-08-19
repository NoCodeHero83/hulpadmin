-- ===========================================================================
-- REQ-008 — Coordenadas geograficas en solicitudes_servicio
--
-- Hasta ahora la unica referencia de lugar era `ubicacion`, texto libre que
-- escribe el admin. Sirve para leerlo, no para navegar: el proveedor no puede
-- abrir un punto exacto en Maps ni se puede calcular distancia.
--
-- Se AGREGAN las coordenadas, no se reemplaza el texto:
--   - `ubicacion` es NOT NULL y hay vistas y pantallas que ya lo leen.
--   - La direccion legible sigue siendo lo que el proveedor necesita ver;
--     el punto es para el enlace de navegacion.
--
-- Ambas nulables a proposito: las solicitudes que ya existen no tienen punto,
-- y capturarlo debe poder seguir siendo opcional. Toda la UI tolera el nulo.
--
-- PostGIS NO hace falta. Para pintar un punto y abrir Google Maps basta con
-- dos numeric. Solo tendria sentido si algun dia se quiere "proveedores cerca
-- de mi" con indice espacial.
-- ===========================================================================

alter table public.solicitudes_servicio
  add column if not exists latitud  numeric(10,7),
  add column if not exists longitud numeric(10,7);

-- Rango valido. Sin esto un error de tipeo (longitud y latitud invertidas,
-- que es el error clasico) pasa silencioso y manda al proveedor a otro pais.
do $$
begin
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

  -- O estan las dos o no esta ninguna: media coordenada no ubica nada y
  -- rompe cualquier consumidor que asuma que si hay latitud hay punto.
  if not exists (select 1 from pg_constraint
                  where conname = 'solicitudes_servicio_coordenadas_completas') then
    alter table public.solicitudes_servicio
      add constraint solicitudes_servicio_coordenadas_completas
      check ((latitud is null) = (longitud is null));
  end if;
end $$;

comment on column public.solicitudes_servicio.latitud  is
  'Latitud en grados decimales (WGS84). Nula si la solicitud no tiene punto capturado.';
comment on column public.solicitudes_servicio.longitud is
  'Longitud en grados decimales (WGS84). Nula si la solicitud no tiene punto capturado.';

-- ---------------------------------------------------------------------------
-- La vista que consume el admin y la app de proveedores no hereda las columnas
-- nuevas: hay que reemplazarla. Se agregan AL FINAL del select — create or
-- replace no permite renombrar ni reordenar lo que ya existe.
-- ---------------------------------------------------------------------------
create or replace view public.vw_solicitudes_servicios_completa as
 SELECT ss.id AS solicitud_id,
    ss.ticket,
    ss.usuario_id,
    ss.descripcion AS solicitud_descripcion,
    ss.informacion_adicional,
    ss.ubicacion,
    ss.fecha,
    ss.hora,
    ss.precio AS precio_solicitud,
    ss.precio_base,
    ss.precio_adicionales,
    COALESCE(ss.precio_base, ss.precio, 0::numeric) + COALESCE(ss.precio_adicionales, 0::numeric) AS precio_total,
    COALESCE(ss.precio_base, ss.precio, s.precio, 0::numeric) + COALESCE(ss.precio_adicionales, 0::numeric) AS precio_calculado,
    ss.estado AS estado_solicitud,
    ss.estado_pago,
    ss.creado_en AS solicitud_creada_en,
    u_cliente.id_usuario AS cliente_id_usuario,
    u_cliente.nombres AS cliente_nombres,
    u_cliente.apellidos AS cliente_apellidos,
    concat(u_cliente.nombres, ' ', u_cliente.apellidos) AS cliente_nombre_completo,
    u_cliente.telefono AS cliente_telefono,
    u_cliente.correo_electronico AS cliente_correo,
    u_cliente.direccion AS cliente_direccion,
    u_cliente.foto_perfil_url AS cliente_foto_perfil,
    ss.servicio_id,
    COALESCE(s.nombre, ss.servicio_nombre) AS servicio_nombre,
    s.descripcion AS servicio_descripcion,
    s.precio AS servicio_precio_base,
    s.estado AS servicio_estado,
    s.informacion_relevante AS servicio_informacion_relevante,
    s.fotos AS servicio_fotos,
    s.items AS servicio_items,
    ss.profesional_id,
    u_proveedor.id_usuario AS proveedor_id_usuario,
    u_proveedor.nombres AS proveedor_nombres,
    u_proveedor.apellidos AS proveedor_apellidos,
    concat(u_proveedor.nombres, ' ', u_proveedor.apellidos) AS proveedor_nombre_completo,
    u_proveedor.telefono AS proveedor_telefono,
    u_proveedor.correo_electronico AS proveedor_correo,
    u_proveedor.direccion AS proveedor_direccion,
    u_proveedor.foto_perfil_url AS proveedor_foto_perfil,
    u_proveedor.anios_experiencia AS proveedor_experiencia,
    u_proveedor.registro_tributario AS proveedor_registro_tributario,
    u_proveedor.verificado AS proveedor_verificado,
    u_proveedor.disponibilidad AS proveedor_disponible,
    sub.id AS subcategoria_id,
    sub.nombre AS subcategoria_nombre,
    sub.descripcion AS subcategoria_descripcion,
    cat.id AS categoria_id,
    cat.nombre AS categoria_nombre,
    cat.imagen_url AS categoria_imagen,
    r_solicitud.calificacion AS puntuacion,
    ( SELECT avg(r.calificacion) AS avg
           FROM resenas r
          WHERE r.proveedor_id = ss.profesional_id) AS proveedor_calificacion_promedio,
    ( SELECT count(*) AS count
           FROM resenas r
          WHERE r.proveedor_id = ss.profesional_id) AS proveedor_total_resenas,
    ( SELECT count(*) AS count
           FROM solicitudes_servicio ss2
          WHERE ss2.profesional_id = ss.profesional_id AND ss2.estado = 'completado'::text) AS proveedor_servicios_completados,
    c.nombre AS solicitud_ciudad,
    ss.latitud,
    ss.longitud
   FROM solicitudes_servicio ss
     LEFT JOIN usuarios u_cliente ON ss.usuario_id = u_cliente.id
     LEFT JOIN usuarios u_proveedor ON ss.profesional_id = u_proveedor.id
     LEFT JOIN servicios s ON ss.servicio_id = s.id
     LEFT JOIN subcategorias sub ON s.subcategoria_id = sub.id
     LEFT JOIN categorias cat ON sub.categoria_id = cat.id
     LEFT JOIN resenas r_solicitud ON r_solicitud.solicitud_servicio_id = ss.id
     LEFT JOIN ciudades c ON c.id = ss.ciudad_id
  WHERE ss.servicio_id IS NOT NULL
  ORDER BY ss.creado_en DESC;
