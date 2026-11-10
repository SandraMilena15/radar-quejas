-- =========================================================
-- Radar de Quejas (PagoYa) · Esquema de base de datos
-- Base: Supabase (PostgreSQL)
-- =========================================================

-- 1. Dimensión: taxonomía de motivos (la regla de prioridad como dato)
create table dim_motivo (
  motivo     text primary key,
  prioridad  text not null check (prioridad in ('Alta', 'Media', 'Baja')),
  definicion text not null
);

insert into dim_motivo (motivo, prioridad, definicion) values
  ('Transacción no reconocida',    'Alta',  'El cliente dice que no hizo ni autorizó un movimiento.'),
  ('Transacción mal aplicada',     'Alta',  'El cliente sí hizo la operación, pero el dinero no llegó, llegó incompleto o se cobró dos veces.'),
  ('Cobro de comisiones',          'Media', 'Cuota de manejo, comisiones o cargos que el cliente considera indebidos.'),
  ('Demora en atención',           'Media', 'Tiempos de espera altos o reclamos sin respuesta.'),
  ('Falla en app o canal digital', 'Baja',  'No puede ingresar o usar la app, la web o la línea, sin dinero afectado.'),
  ('Otro',                         'Baja',  'Preguntas o solicitudes que no son una queja de los motivos anteriores.'),
  ('Sin clasificar',               'Baja',  'Comentario vacío o ilegible.');

-- 2. Hechos: quejas tal como llegan del sistema de origen
create table quejas (
  id_solicitud     text primary key,
  fecha_radicacion date not null,
  canal            text not null check (canal in ('App', 'Línea telefónica', 'Correo', 'SFC')),
  producto         text not null check (producto in ('Tarjeta', 'Cuenta', 'Transferencia')),
  id_cliente       text not null,
  comentario       text,
  fecha_respuesta  date,
  check (fecha_respuesta is null or fecha_respuesta >= fecha_radicacion)
);

-- 3. Evaluación: respuestas correctas (el agente NUNCA lee esta tabla)
create table etiquetas_reales (
  id_solicitud   text primary key references quejas (id_solicitud),
  motivo_real    text not null references dim_motivo (motivo),
  prioridad_real text
);

-- 4. Hechos: clasificaciones de la IA (una queja puede tener varias)
create table clasificaciones (
  id             bigint generated always as identity primary key,
  id_solicitud   text not null references quejas (id_solicitud),
  motivo_ia      text not null references dim_motivo (motivo),
  sentimiento    text check (sentimiento in ('Negativo', 'Neutral', 'Positivo')),
  con_duda       boolean not null default false,
  resumen        text,
  modelo         text not null,
  version_prompt text not null,
  clasificado_en timestamptz not null default now()
);
create index idx_clasificaciones_solicitud on clasificaciones (id_solicitud);

-- 5. Auditoría: decisiones de la revisión humana
create table revisiones (
  id             bigint generated always as identity primary key,
  revisado_en    timestamptz not null default now(),
  revisor        text not null,
  estado         text not null check (estado in ('Aprobado', 'Devuelto', 'Sin revisión')),
  ids_a_corregir text,
  comentarios    text
);

-- 6. Seguridad: bloquear el acceso público a todas las tablas
alter table dim_motivo       enable row level security;
alter table quejas           enable row level security;
alter table etiquetas_reales enable row level security;
alter table clasificaciones  enable row level security;
alter table revisiones       enable row level security;
