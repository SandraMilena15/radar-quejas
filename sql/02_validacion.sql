-- =========================================================
-- Radar de Quejas (PagoYa) · Validación de la carga de datos
-- Correr después de importar quejas_sinteticas.csv y etiquetas_reales.csv
-- =========================================================

-- 1. ¿Llegaron todas las filas?
select
  (select count(*) from quejas)           as quejas,     -- esperado: 2000
  (select count(*) from etiquetas_reales) as etiquetas;  -- esperado: 2000

-- 2. ¿La distribución de motivos coincide con el diccionario de datos?
select
  motivo_real,
  count(*) as quejas,
  round(100.0 * count(*) / sum(count(*)) over (), 1) as porcentaje
from etiquetas_reales
group by motivo_real
order by quejas desc;
-- esperado: 39 % no reconocida, 15 % comisiones, 14 % demora, 10 % otro,
--           9 % mal aplicada, 8 % falla en app, 5 % sin clasificar

-- 3. ¿Se mantiene el pico sembrado en la semana 4?
select
  date_trunc('week', q.fecha_radicacion)::date as semana,
  count(*) as no_reconocidas_tarjeta_app
from quejas q
join etiquetas_reales e using (id_solicitud)
where e.motivo_real = 'Transacción no reconocida'
  and q.producto = 'Tarjeta'
  and q.canal = 'App'
group by semana
order by semana;
-- esperado: 49, 50, 43 y 76 (pico en la semana del 19 de octubre)

-- 4. ¿Cuántas quejas están abiertas y cuántas sin comentario?
select
  count(*) filter (where fecha_respuesta is null) as abiertas,        -- esperado: 600
  count(*) filter (where comentario is null)      as sin_comentario   -- esperado: 100
from quejas;

-- 5. Prueba de integridad: debe FALLAR por el check del canal
-- insert into quejas (id_solicitud, fecha_radicacion, canal, producto, id_cliente)
-- values ('Q99999', '2026-10-20', 'WhatsApp', 'Tarjeta', 'C0001');
