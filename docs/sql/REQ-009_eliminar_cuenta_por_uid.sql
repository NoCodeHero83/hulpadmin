-- Extrae el cuerpo de eliminar_mi_cuenta() a _eliminar_cuenta(p_uid uuid).
--
-- Por qué: para el borrado masivo de proveedores hace falta invocar la misma
-- lógica sobre cuentas ajenas. Duplicar el cuerpo en un script suelto sería
-- garantizar que las dos copias se separen en cuanto alguien toque una.
--
-- La seguridad no cambia para las apps: `eliminar_mi_cuenta()` sigue sin
-- parámetros y sigue sacando el uuid de auth.uid(), así que nadie puede pedir
-- el borrado de otra persona. `_eliminar_cuenta` NO recibe grant a
-- `authenticated`: solo la alcanza quien ya tiene acceso de servicio.
--
-- Aplicado el 2026-08-24.

create or replace function public._eliminar_cuenta(p_uid uuid)
 returns json
 language plpgsql
 security definer
 set search_path to 'public', 'auth'
as $function$
declare
  c_lapida        constant uuid := '00000000-0000-0000-0000-000000000000';
  v_uid           uuid := p_uid;
  v_email         text;
  v_rol           text;
  v_solicitudes   int := 0;
  v_transacciones int := 0;
  v_recibos       int := 0;
  v_perfil        int := 0;
begin
  if v_uid is null then
    raise exception 'Hace falta un uuid' using errcode = '22004';
  end if;

  -- Sin esto, pasar ese uuid vaciaría el historial de todos.
  if v_uid = c_lapida then
    raise exception 'La cuenta lapida no se puede eliminar' using errcode = '42501';
  end if;

  select rol into v_rol from public.usuarios where id = v_uid;
  select email into v_email from auth.users where id = v_uid;

  -- =========================================================================
  -- A. REASIGNAR A LA LÁPIDA
  --    Va primero: en cuanto se borre la fila de usuarios, estas cascadas se
  --    disparan. Lo que aquí no se salve, se pierde.
  -- =========================================================================

  -- Lado CLIENTE: usuario_id es NOT NULL y CASCADE, así que o va a la lápida
  -- o la solicitud entera se destruye con sus recibos, pagos y reseñas.
  update public.solicitudes_servicio
     set usuario_id = c_lapida
   where usuario_id = v_uid;
  get diagnostics v_solicitudes = row_count;

  -- Lado PROVEEDOR: aquí va NULL, no la lápida, y es a propósito.
  --
  -- trigger_crear_chat_al_asignar_proveedor corre AFTER UPDATE y, cuando el
  -- profesional cambia a un valor NO NULO, borra todos los mensajes del chat.
  -- Si ese chat tiene un recibo asociado (recibos.mensaje_id), el DELETE choca
  -- contra recibos_mensaje_id_fkey y aborta el borrado de cuenta entero.
  -- Poniendo NULL la condición del trigger no se cumple y no se dispara.
  update public.solicitudes_servicio
     set profesional_id = null
   where profesional_id = v_uid;

  -- Pagos. transacciones.usuario_id es NO ACTION y NOT NULL: si queda una
  -- sola fila apuntando al usuario, el DELETE final aborta la transacción.
  update public.transacciones
     set usuario_id = c_lapida
   where usuario_id = v_uid;
  get diagnostics v_transacciones = row_count;

  -- Recibos emitidos como proveedor: son el comprobante del CLIENTE.
  update public.recibos
     set proveedor_id = c_lapida
   where proveedor_id = v_uid;
  get diagnostics v_recibos = row_count;

  -- Reputación: la reseña escrita le sirve al proveedor, y la recibida le
  -- sirve al cliente. Se conservan sin autor identificable.
  update public.resenas        set usuario_id   = c_lapida where usuario_id   = v_uid;
  update public.resenas        set proveedor_id = c_lapida where proveedor_id = v_uid;
  update public.calificaciones set usuario_id   = c_lapida where usuario_id   = v_uid;
  update public.calificaciones set proveedor_id = c_lapida where proveedor_id = v_uid;

  -- Los mensajes se quedan para que la contraparte conserve el hilo legible.
  update public.mensajes_chat
     set remitente_id = c_lapida
   where remitente_id = v_uid;

  -- =========================================================================
  -- B. ANONIMIZAR TICKETS DE SOPORTE
  -- =========================================================================
  update public.soporte
     set nombre_proveedor   = 'Cuenta eliminada',
         telefono_proveedor = null,
         email_proveedor    = null
   where id_proveedor = v_uid::text;

  if v_email is not null then
    update public.soporte
       set nombre_usuario   = 'Cuenta eliminada',
           telefono_usuario = null,
           email_usuario    = null
     where email_usuario = v_email;
  end if;

  -- =========================================================================
  -- C. BORRAR LO EXCLUSIVAMENTE PERSONAL
  --    conversaciones NO tiene FK: aquí es imprescindible.
  -- =========================================================================
  delete from public.tarjetas_guardadas    where usuario_id = v_uid;
  delete from public.metodos_pago          where usuario_id = v_uid;
  delete from public.cuentas_bancarias     where usuario_id = v_uid;
  delete from public.certificaciones       where usuario_id = v_uid;
  delete from public.referencias_laborales where usuario_id = v_uid;
  delete from public.profesional_servicios where usuario_id = v_uid;
  delete from public.favoritos             where usuario_id = v_uid;
  delete from public.conversaciones        where usuario_id = v_uid;
  delete from public.cleanup_programado    where usuario_id = v_uid;
  delete from public.user_notifications    where user_id    = v_uid;

  delete from public.notificaciones
   where usuario_id = v_uid or proveedor_id = v_uid;

  delete from public.usuarios_externos where id = v_uid;

  delete from public.usuarios where id = v_uid;
  get diagnostics v_perfil = row_count;

  -- =========================================================================
  -- D. Cuenta de autenticación, al final.
  -- =========================================================================
  delete from auth.users where id = v_uid;

  return json_build_object(
    'ok', true,
    'uid', v_uid,
    'rol', v_rol,
    'perfil_borrado', v_perfil > 0,
    'solicitudes_preservadas', v_solicitudes,
    'transacciones_preservadas', v_transacciones,
    'recibos_preservados', v_recibos
  );
end;
$function$;

-- Nadie desde una app: esta función acepta un uuid ajeno.
revoke all on function public._eliminar_cuenta(uuid) from public, anon, authenticated;

-- El envoltorio que sí usan las apps. Sin parámetros a propósito: el usuario
-- sale de auth.uid(), así que es imposible pedir el borrado de otra persona.
create or replace function public.eliminar_mi_cuenta()
 returns json
 language plpgsql
 security definer
 set search_path to 'public', 'auth'
as $function$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'No hay sesion activa' using errcode = '28000';
  end if;
  return public._eliminar_cuenta(v_uid);
end;
$function$;

grant execute on function public.eliminar_mi_cuenta() to authenticated;
