-- =========================================================
-- Radar de Quejas (PagoYa) · Capa de reportes para el agente
-- Correr después de 03_vistas.sql
--
-- Idea: el agente NO consulta tablas. Solo lee vistas de un esquema
-- "reportes", con un usuario de solo lectura. Así, aunque escriba SQL,
-- no puede ver comentarios ni datos de clientes, no puede leer las
-- respuestas correctas y no puede modificar nada.
-- =========================================================

-- 0. Ajuste de las vistas de public que usará el agente
--    Las vistas con security_invoker revisan los permisos de QUIEN consulta.
--    Como el agente no tiene (ni debe tener) permiso sobre las tablas, las
--    vistas de reportes no podrían leerlas. Por eso:
--    a) estas vistas pasan a ejecutarse con los permisos de su dueño, y
--    b) se les quita el acceso a los roles públicos de Supabase (anon y
--       authenticated), para que NO queden expuestas en la API pública.
alter view public.v_quejas_plazo          set (security_invoker = false);
alter view public.v_clasificacion_actual  set (security_invoker = false);
alter view public.v_kpi_motivo_semanal    set (security_invoker = false);
alter view public.v_kpi_plazos            set (security_invoker = false);
alter view public.v_kpi_tiempo_respuesta  set (security_invoker = false);

revoke all on public.v_quejas_plazo, public.v_clasificacion_actual,
              public.v_kpi_motivo_semanal, public.v_kpi_plazos,
              public.v_kpi_tiempo_respuesta
  from anon, authenticated;

-- 1. Esquema separado (Supabase no lo expone en su API pública)
create schema reportes;

-- 2. Vistas para el agente: solo datos agregados o sin información personal
create view reportes.kpi_motivo_semanal as
select semana, motivo_ia as motivo, quejas, quejas_semana_anterior, variacion_pct
from public.v_kpi_motivo_semanal;

create view reportes.kpi_plazos as
select * from public.v_kpi_plazos;

create view reportes.kpi_tiempo_respuesta as
select * from public.v_kpi_tiempo_respuesta;

create view reportes.quejas_detalle as
select
  p.id_solicitud,
  p.semana,
  p.fecha_radicacion,
  p.canal,
  p.producto,
  p.estado_plazo,
  p.dias_habiles,
  c.motivo_ia as motivo,
  c.prioridad,
  c.con_duda,
  c.resumen            -- resumen de la IA, sin el comentario original ni el cliente
from public.v_quejas_plazo p
left join public.v_clasificacion_actual c using (id_solicitud);

comment on view reportes.kpi_motivo_semanal  is 'Quejas por motivo y semana (lunes), con variación % frente a la semana anterior.';
comment on view reportes.kpi_plazos          is 'Quejas abiertas por canal: vencidas (>8 días hábiles), en riesgo (6-8) y en plazo.';
comment on view reportes.kpi_tiempo_respuesta is 'Por producto: quejas respondidas, días hábiles promedio y % respondidas en plazo.';
comment on view reportes.quejas_detalle      is 'Una fila por queja, sin comentario ni cliente. motivo/prioridad vienen de la clasificación más reciente.';

-- 3. Usuario de solo lectura para el agente
--    Cambia la contraseña por una propia y guárdala en tu gestor de contraseñas
create role agente_radar login password 'CAMBIA-ESTA-CONTRASEÑA';

grant usage  on schema reportes to agente_radar;
grant select on all tables in schema reportes to agente_radar;

-- Guardas adicionales: todo en solo lectura y consultas de máximo 5 segundos
alter role agente_radar set default_transaction_read_only = on;
alter role agente_radar set statement_timeout = '5s';

-- 4. Comprobación (correr como administrador): solo deben salir las 4 vistas de reportes
select table_schema, table_name, privilege_type
from information_schema.role_table_grants
where grantee = 'agente_radar';

-- 5. Comprobación: estas vistas NO deben aparecer para anon ni authenticated
select table_name, grantee
from information_schema.role_table_grants
where table_schema = 'public'
  and table_name like 'v\_%'
  and grantee in ('anon', 'authenticated');
