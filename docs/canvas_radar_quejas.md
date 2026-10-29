# Canvas – Radar de Quejas (PagoYa)
28 oct 2026 · Autora: Sandra Milena López

> Un agente que clasifica las quejas semanales de PagoYa, detecta qué motivo
> está creciendo y prioriza las que tienen riesgo de fraude o de vencer el plazo,
> con revisión humana antes de enviar el informe.

## 1. Problema de negocio
Las quejas del sistema financiero colombiano están en récord y la causa número
uno son las transacciones que el cliente no reconoce o que quedaron mal
aplicadas. En PagoYa hoy no hay forma sistemática de saber cuáles quejas son
de prioridad alta ni de separar las causas de fondo.

**Contexto externo (sistema financiero colombiano, no PagoYa):**
- En 2025 la Superintendencia Financiera (SFC) recibió 2,76 millones de quejas,
  un récord [1].
- Cerca del 39 % fueron por transacciones no reconocidas [2].
- El 7,8 % fue por dificultad para hacer transacciones o consultas en canales
  digitales [1].

**Fuentes** (consultadas el 28 de octubre de 2026):
- [1] Infobae (26 feb 2026), con datos del Informe Periódico de Quejas de la SFC:
  https://www.infobae.com/colombia/2026/02/26/explota-la-inconformidad-bancaria-en-colombia-276-millones-de-quejas-y-bancolombia-lidera-el-ranking/
- [2] Forbes Colombia (26 feb 2026), con datos del Informe Periódico de Quejas
  de la SFC: https://forbes.co/2026/02/26/economia-y-finanzas/finanzas-personales/bancos-con-mas-quejas-en-2025-en-colombia/

## 2. Usuario y decisión
- **Usuario principal:** Líder de Customer Experience.
- **Decisión que toma con el resultado:** priorizar qué motivos y canales
  investigar cada semana, y cuáles escalar a Operaciones para análisis de causa
  raíz (Proyecto 2: Conciliador de Pagos, que cruza los datos transaccionales).
- **Frecuencia:** semanal. Informe de clasificación de quejas y dashboard con hallazgos y seguimiento de KPI.
- **Costo de equivocarse:** ALTO.
  - No detectar una transacción no reconocida: posible pérdida por fraude (~$230.000 por caso, supuesto) y riesgo de vencer el plazo de 15 días hábiles de la SFC.
  - Alarma falsa: ~15 min de analista (~$6.000 por caso, supuesto).
  - Conclusión: el error grave cuesta ~38 veces más (230.000 / 6.000). Por eso una persona revisa todas las quejas de prioridad alta y, ante la duda, el sistema sube la prioridad.
- **Relación con el bloqueo inmediato:** este radar es un análisis semanal y **no reemplaza** el proceso operativo que, según la política, bloquea el producto en menos de 1 hora y abre la investigación de fraude. Ver decisión pendiente en la sección 8.

## 3. Input
**Datos de entrada**
- Base semanal de quejas, con estos campos mínimos:
  - `id_solicitud`
  - `fecha_radicacion`
  - `canal` (app, línea telefónica, correo, SFC)
  - `producto` (tarjeta, cuenta, transferencia)
  - `id_cliente` (anonimizado, para medir reincidencia)
  - `comentario` (texto libre)
  - `fecha_respuesta` (vacía si sigue abierta)
- Número de clientes activos del mes (para la tasa por 10.000 clientes).
- **Volumen estimado:** 500 quejas por semana.
- **Problemas de calidad esperados:** comentarios vacíos, mala ortografía, datos sensibles dentro del comentario, comentarios que no permiten identificar el problema real, ironía.
- **Tratamiento de calidad:**
  - Comentario vacío o ilegible → se marca "sin clasificar" y va a revisión humana.
  - Datos sensibles (números de cuenta, documentos, tarjetas) → se enmascaran con reglas SQL **antes** de enviar el texto a la IA.

**Base de conocimiento (contexto que usa la IA en el paso 4)**
- `taxonomia_motivos.md`: 6 motivos, reglas para casos dudosos y prioridades.
- `politica_respuesta.md`: plazos (8 días hábiles internos, 15 para quejas
  de la SFC), alerta de queja en riesgo (6 días), reglas de fraude y reembolsos.
- `glosario_cx.md`: definiciones de CX.

## 4. Proceso
| Paso | Qué hace | Responsable | Por qué ese responsable |
|---|---|---|---|
| 1 | Define y carga la base de conocimiento (glosario, política, taxonomía) y registra su fecha de actualización | Analista | Conoce el proceso de atención y define el criterio de clasificación |
| 2 | Define las instrucciones del sistema del asistente de IA (incluye: ante la duda, subir la prioridad) | Analista | El criterio humano es crucial |
| 3 | ETL: toma la base semanal, valida campos, trata vacíos y enmascara datos sensibles; deja el formato `id_solicitud` + `comentario` | SQL/reglas | Lógica exacta y repetible; protege datos personales |
| 4 | Clasifica cada comentario en uno de los 6 motivos, asigna prioridad según la taxonomía e indica si hay duda | IA | Entiende texto libre, ironía y mala ortografía |
| 5 | Une la clasificación con la base original (fecha, canal, producto, cliente). Cuenta quejas por motivo, canal, producto y prioridad; calcula días hábiles abiertos, quejas en riesgo (6 días), vencimientos (8 y 15 días), reincidencia (2 o más en 30 días) y tasa por 10.000 clientes | SQL/reglas | Cálculo exacto, auditable y repetible |
| 6 | Redacta hallazgos y alertas a partir de las vistas SQL del paso 5; no calcula ni modifica cifras | IA | Rapidez y claridad; los números siempre salen de SQL |
| 7 | Revisa todas las quejas de prioridad alta y las marcadas con duda; valida hallazgos y define planes de acción | Analista | Evita costos altos; criterio humano |

## 5. Output
- **Qué entrega:** informe semanal con número de casos clasificados, por motivo, canal, producto y prioridad; quejas en riesgo y vencidas; dashboard con KPI y planes de acción.
- **Formato:** correo con alerta informativa + dashboard en Power BI.
- **A quién y cuándo:** Líder de Customer Experience, cada lunes antes de las 10:00 a.m. (plazo de la política).

## 6. Aprobación humana
- **Pasos 1 y 2:** el analista define y aprueba la base de conocimiento y las instrucciones antes de operar, y las revisa cuando cambie la política o la taxonomía.
- **Paso 7:** antes de enviar el informe, revisa el 100 % de prioridad alta, los casos con duda y los hallazgos.
- **Muestra de control de calidad:** 50 quejas al azar por semana (10 %), para medir la precisión del modelo.

## 7. KPI de éxito
**Línea base:** hoy el analista revisa 20 de 500 quejas en ~4 horas; el 96 % restante no se clasifica ni se analiza.

| Tipo | KPI | Meta |
|---|---|---|
| Negocio | Tasa de quejas por 10.000 clientes activos | Por definir con el líder de CX |
| Negocio | % de quejas respondidas dentro del plazo (8 días internos / 15 días SFC) | Por definir |
| Negocio | % de quejas en riesgo que se resuelven antes del vencimiento | Por definir |
| Sistema | Precisión de clasificación, medida sobre la muestra revisada por el analista | ≥ 95 % |
| Sistema | Quejas graves no detectadas (de cada 100 de prioridad alta, cuántas se escapan) | ≤ 2 |
| Sistema | Costo de clasificar las 500 quejas semanales | Menos de USD 1 |

NPS se mantiene como indicador de contexto, pero no se mide con este radar porque ningún documento ni campo lo incluye.

## 8. Riesgos y límites
**Riesgos**
- Datos personales dentro del comentario (mitigación: enmascarar en el paso 3).
- Clasificación errada, sobre todo entre "Transacción no reconocida" y "Transacción mal aplicada" (mitigación: revisión humana de toda la prioridad alta).
- Comentarios que no describen el problema real (mitigación: la IA los marca "con duda" y pasan a revisión humana).
- La IA inventa cifras o causas en los hallazgos (mitigación: solo usa datos de las vistas SQL y el analista valida antes de enviar).
- Base de conocimiento desactualizada o con vacíos; la taxonomía es simplificada y no es el catálogo oficial de la SFC (mitigación: revisión de los documentos cada vez que cambie la política, con fecha de actualización).
- Retraso: el informe es semanal y una queja de fraude puede esperar hasta 7 días para aparecer.

**Límites**
- La IA solo clasifica y redacta; no decide, no responde al cliente ni aprueba reembolsos.
- Solo usa la base de conocimiento cargada.
- Prototipo con datos sintéticos; el plan gratis de la API no es apto para datos reales de clientes.

**Decisión pendiente para el líder de CX:** ¿se ejecuta la clasificación de "Transacción no reconocida" a diario o con una alerta inmediata, para no depender del informe de los lunes? Por ahora queda fuera de alcance.

## 9. Fuera de alcance
- Responder o contactar al cliente.
- Aprobar reembolsos (solo el equipo de Operaciones, según la política).
- Bloquear productos o abrir investigaciones de fraude (lo hace el proceso operativo existente).
- Enviar alertas a otras líneas de negocio.
- Alerta diaria o inmediata de transacciones no reconocidas (decisión pendiente del líder de CX; candidata para una siguiente fase).
