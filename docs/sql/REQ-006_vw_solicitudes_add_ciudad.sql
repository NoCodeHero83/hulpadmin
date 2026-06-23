-- =====================================================================
-- REQ-006 v1.0.0 — Columna "Ciudad" en el listado de Solicitudes
-- Objeto: vista public.vw_solicitudes_servicios_completa
-- Cambio: + LEFT JOIN ciudades c ON c.id = ss.ciudad_id
--         + c.nombre AS solicitud_ciudad  (nueva columna, al final)
--
-- Reglas (ver spec §4):
--   - LEFT JOIN (no INNER): una solicitud con ciudad_id NULL sigue apareciendo.
--   - No se renombra, elimina ni reordena ninguna columna existente.
--   - Aplicar primero en SANDBOX, validar, luego en PRODUCCIÓN.
--
-- NOTA: el alias de la solicitud es `ss` (la tabla servicios usa `s`).
-- =====================================================================

create or replace view public.vw_solicitudes_servicios_completa as
select
  ss.id as solicitud_id,
  ss.ticket,
  ss.usuario_id,
  ss.descripcion as solicitud_descripcion,
  ss.informacion_adicional,
  ss.ubicacion,
  ss.fecha,
  ss.hora,
  ss.precio as precio_solicitud,
  ss.precio_base,
  ss.precio_adicionales,
  COALESCE(ss.precio_base, ss.precio, 0::numeric) + COALESCE(ss.precio_adicionales, 0::numeric) as precio_total,
  COALESCE(ss.precio_base, ss.precio, s.precio, 0::numeric) + COALESCE(ss.precio_adicionales, 0::numeric) as precio_calculado,
  ss.estado as estado_solicitud,
  ss.estado_pago,
  ss.creado_en as solicitud_creada_en,
  u_cliente.id_usuario as cliente_id_usuario,
  u_cliente.nombres as cliente_nombres,
  u_cliente.apellidos as cliente_apellidos,
  concat(u_cliente.nombres, ' ', u_cliente.apellidos) as cliente_nombre_completo,
  u_cliente.telefono as cliente_telefono,
  u_cliente.correo_electronico as cliente_correo,
  u_cliente.direccion as cliente_direccion,
  u_cliente.foto_perfil_url as cliente_foto_perfil,
  ss.servicio_id,
  COALESCE(s.nombre, ss.servicio_nombre) as servicio_nombre,
  s.descripcion as servicio_descripcion,
  s.precio as servicio_precio_base,
  s.estado as servicio_estado,
  s.informacion_relevante as servicio_informacion_relevante,
  s.fotos as servicio_fotos,
  s.items as servicio_items,
  ss.profesional_id,
  u_proveedor.id_usuario as proveedor_id_usuario,
  u_proveedor.nombres as proveedor_nombres,
  u_proveedor.apellidos as proveedor_apellidos,
  concat(u_proveedor.nombres, ' ', u_proveedor.apellidos) as proveedor_nombre_completo,
  u_proveedor.telefono as proveedor_telefono,
  u_proveedor.correo_electronico as proveedor_correo,
  u_proveedor.direccion as proveedor_direccion,
  u_proveedor.foto_perfil_url as proveedor_foto_perfil,
  u_proveedor.anios_experiencia as proveedor_experiencia,
  u_proveedor.registro_tributario as proveedor_registro_tributario,
  u_proveedor.verificado as proveedor_verificado,
  u_proveedor.disponibilidad as proveedor_disponible,
  sub.id as subcategoria_id,
  sub.nombre as subcategoria_nombre,
  sub.descripcion as subcategoria_descripcion,
  cat.id as categoria_id,
  cat.nombre as categoria_nombre,
  cat.imagen_url as categoria_imagen,
  r_solicitud.calificacion as puntuacion,
  (
    select
      avg(r.calificacion) as avg
    from
      resenas r
    where
      r.proveedor_id = ss.profesional_id
  ) as proveedor_calificacion_promedio,
  (
    select
      count(*) as count
    from
      resenas r
    where
      r.proveedor_id = ss.profesional_id
  ) as proveedor_total_resenas,
  (
    select
      count(*) as count
    from
      solicitudes_servicio ss2
    where
      ss2.profesional_id = ss.profesional_id
      and ss2.estado = 'completado'::text
  ) as proveedor_servicios_completados,
  c.nombre as solicitud_ciudad                       -- NUEVO (REQ-006)
from
  solicitudes_servicio ss
  left join usuarios u_cliente on ss.usuario_id = u_cliente.id
  left join usuarios u_proveedor on ss.profesional_id = u_proveedor.id
  left join servicios s on ss.servicio_id = s.id
  left join subcategorias sub on s.subcategoria_id = sub.id
  left join categorias cat on sub.categoria_id = cat.id
  left join resenas r_solicitud on r_solicitud.solicitud_servicio_id = ss.id
  left join ciudades c on c.id = ss.ciudad_id        -- NUEVO (REQ-006)
where
  ss.servicio_id is not null
order by
  ss.creado_en desc;

-- ---------------------------------------------------------------------
-- Verificación rápida (opcional, ejecutar tras el CREATE):
--   select solicitud_id, ticket, solicitud_ciudad
--   from public.vw_solicitudes_servicios_completa
--   limit 20;
-- Las filas con ciudad_id NULL devolverán solicitud_ciudad = NULL
-- (la UI muestra "Sin ciudad").
-- ---------------------------------------------------------------------
