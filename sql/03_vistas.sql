-- =========================================================
-- Radar de Quejas (PagoYa) · Parámetros y vistas de KPI
-- Correr después de 01_esquema.sql
-- =========================================================

-- 1. Parámetros: fecha de corte y festivos
--    (en producción la fecha de corte sería current_date)
create table parametros (
  nombre text primary key,
  valor  date not null
);
insert into parametros values ('fecha_corte', '2026-10-29');

create table festivos (
  fecha       date primary key,
  descripcion text not null
);
insert into festivos values ('2026-10-12', 'Día de la Raza');

alter table parametros enable row level security;
alter table festivos   enable row level security;

-- Las vistas usan security_invoker para respetar el RLS de las tablas:
-- así no quedan expuestas en la API pública de Supabase.

-- 2. Vista: cada queja con su semana, días hábiles y estado de plazo
--    (el semáforo del día 2 de la semana 2, ahora en SQL)
--    dias_habiles: desde el día siguiente a la radicación hasta la respuesta,
--    o hasta la fecha de corte si la queja sigue abierta
create view v_quejas_plazo with (security_invoker = true) as
select
  q.*,
  date_trunc('week', q.fecha_radicacion)::date as semana,
  h.dias_habiles,
  case
    when q.fecha_respuesta is not null then 'Respondida'
    when h.dias_habiles > 8            then 'Vencida'
    when h.dias_habiles >= 6           then 'En riesgo'
    else 'En plazo'
  end as estado_plazo
from quejas q
cross join (select valor as fecha_corte from parametros where nombre = 'fecha_corte') c
cross join lateral (
  select count(*)::int as dias_habiles
  from generate_series(q.fecha_radicacion + 1,
                       coalesce(q.fecha_respuesta, c.fecha_corte),
                       interval '1 day') as d
  where extract(isodow from d) < 6                       -- lunes a viernes
    and d::date not in (select fecha from festivos)      -- sin festivos
) h;

-- 3. Vista: la clasificación más reciente de cada queja, con su prioridad
--    La prioridad sale de dim_motivo; si la IA dudó, sube a Alta (política del canvas)
create view v_clasificacion_actual with (security_invoker = true) as
select distinct on (c.id_solicitud)
  c.id_solicitud,
  c.motivo_ia,
  c.sentimiento,
  c.con_duda,
  c.resumen,
  case when c.con_duda then 'Alta' else d.prioridad end as prioridad,
  c.modelo,
  c.version_prompt,
  c.clasificado_en
from clasificaciones c
join dim_motivo d on d.motivo = c.motivo_ia
order by c.id_solicitud, c.clasificado_en desc;

-- 4. KPI: quejas por motivo y semana, con variación frente a la semana anterior
create view v_kpi_motivo_semanal with (security_invoker = true) as
with base as (
  select p.semana, c.motivo_ia, count(*) as quejas
  from v_quejas_plazo p
  join v_clasificacion_actual c using (id_solicitud)
  group by p.semana, c.motivo_ia
)
select
  semana,
  motivo_ia,
  quejas,
  lag(quejas) over (partition by motivo_ia order by semana) as quejas_semana_anterior,
  round(100.0 * (quejas - lag(quejas) over (partition by motivo_ia order by semana))
        / nullif(lag(quejas) over (partition by motivo_ia order by semana), 0), 1) as variacion_pct
from base;

-- 5. KPI: semáforo de plazos de las quejas abiertas, por canal
create view v_kpi_plazos with (security_invoker = true) as
select
  canal,
  count(*) filter (where estado_plazo <> 'Respondida') as abiertas,
  count(*) filter (where estado_plazo = 'Vencida')     as vencidas,
  count(*) filter (where estado_plazo = 'En riesgo')   as en_riesgo,
  count(*) filter (where estado_plazo = 'En plazo')    as en_plazo,
  round(100.0 * count(*) filter (where estado_plazo in ('Vencida', 'En riesgo'))
        / nullif(count(*) filter (where estado_plazo <> 'Respondida'), 0), 1) as pct_vencidas_o_en_riesgo
from v_quejas_plazo
group by canal;

-- 6. KPI: tiempo de respuesta y cumplimiento del plazo, por producto
create view v_kpi_tiempo_respuesta with (security_invoker = true) as
select
  producto,
  count(*) filter (where estado_plazo = 'Respondida') as respondidas,
  round(avg(dias_habiles) filter (where estado_plazo = 'Respondida'), 1) as dias_habiles_promedio,
  round(100.0 * count(*) filter (where estado_plazo = 'Respondida' and dias_habiles <= 8)
        / nullif(count(*) filter (where estado_plazo = 'Respondida'), 0), 1) as pct_respondidas_en_plazo
from v_quejas_plazo
group by producto;

-- 7. Evaluación: precisión de la IA contra las respuestas correctas
--    (solo para medir; el agente no consulta esta vista)
create view v_eval_precision with (security_invoker = true) as
select
  c.modelo,
  c.version_prompt,
  count(*) as evaluadas,
  count(*) filter (where c.motivo_ia = e.motivo_real) as aciertos,
  round(100.0 * count(*) filter (where c.motivo_ia = e.motivo_real) / count(*), 1) as precision_pct,
  count(*) filter (where e.prioridad_real = 'Alta' and c.prioridad <> 'Alta') as graves_no_detectadas
from v_clasificacion_actual c
join etiquetas_reales e using (id_solicitud)
group by c.modelo, c.version_prompt;
