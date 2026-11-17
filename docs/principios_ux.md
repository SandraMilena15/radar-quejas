# Principios de UX e IA responsable — Radar de Quejas

## 1. Filosofía del producto

Radar de Quejas es una solución de análisis operativo que utiliza SQL, Business Intelligence e Inteligencia Artificial para identificar patrones en las quejas de clientes, detectar riesgos y facilitar la toma de decisiones.

Su filosofía se basa en una premisa:

**La IA ayuda a identificar y comprender los problemas, pero las personas conservan el control sobre las decisiones.**

El sistema debe proporcionar información confiable, mostrar sus fuentes, reconocer sus limitaciones y permitir la intervención humana cuando exista incertidumbre o riesgo.

### Principios rectores

#### 1. Capacidades y límites claros
La IA puede clasificar quejas, resumir información e identificar patrones. No debe aprobar reembolsos, responder directamente a clientes ni ejecutar decisiones críticas sin autorización humana.

#### 2. Transparencia de la información
Cada indicador debe permitir identificar su fuente de datos, fecha de corte y criterio de cálculo. El usuario debe poder comprender de dónde proviene la información presentada.

#### 3. Confianza proporcional a la evidencia
Cuando la IA no tenga suficiente información o seguridad para clasificar una queja, debe identificarla como un caso que requiere revisión humana. No debe forzar una clasificación para completar el proceso.

#### 4. Honestidad ante la incertidumbre
Si el sistema no encuentra información suficiente para responder una consulta, debe reconocerlo explícitamente. No debe inventar datos ni completar información faltante mediante suposiciones.

#### 5. Corrección y trazabilidad
La analista debe poder corregir clasificaciones incorrectas. El sistema debe conservar el resultado original, el resultado corregido, el responsable y la fecha de modificación.

#### 6. Supervisión y responsabilidad humana
La analista o Líder de CX conserva la autoridad sobre las decisiones críticas. Los informes y las acciones que puedan generar consecuencias operativas deben contar con aprobación humana.

#### 7. Diferenciación entre hechos e hipótesis
Los indicadores calculados mediante SQL deben presentarse como hechos verificables. Las explicaciones generadas por IA deben identificarse como hipótesis que requieren validación.

---

## 2. Decisiones de diseño del producto

Los principios anteriores se traducen en las siguientes reglas de comportamiento:

| Situación | Comportamiento esperado |
|---|---|
| Clasificación con incertidumbre | Enviar el caso a revisión humana. |
| Clasificación con evidencia suficiente | Presentar la categoría sugerida y su nivel de confianza. |
| Incremento de un motivo de queja | Mostrar el porcentaje calculado y su periodo de comparación. |
| Explicación de un incremento | Presentar la explicación de IA como hipótesis, no como causa confirmada. |
| Consulta sin información disponible | Informar que no existen datos suficientes. |
| Clasificación incorrecta | Permitir corrección y conservar el historial. |
| Informe generado por IA | Solicitar aprobación humana antes de su publicación. |
| Consulta de un indicador | Mostrar fuente, fecha de corte y criterio de cálculo. |

### Ejemplo: incremento de quejas del 60,6 %

**Dato verificable:**

El motivo de quejas no reconocidas presentó un incremento del 60,6 % frente al periodo de comparación.

**Hipótesis generada por IA:**

El incremento podría estar relacionado con dificultades en el proceso de reconocimiento de transacciones dentro de la aplicación.

**Validación requerida:**

La analista debe revisar la información operativa antes de confirmar la posible causa.

La interfaz debe diferenciar visualmente estos tres elementos para evitar que una interpretación se confunda con un resultado estadístico.

---

## 3. Reglas de confianza y control humano

### Clasificación de quejas

El sistema debe contemplar tres situaciones:

- **Clasificación aceptable:** la IA presenta una categoría sugerida con evidencia suficiente.
- **Clasificación con duda:** la IA identifica incertidumbre y solicita revisión humana.
- **Información insuficiente:** el sistema no puede determinar una categoría confiable y debe solicitar validación.

Los umbrales de confianza deben definirse y validarse mediante pruebas del clasificador. No se deben establecer porcentajes arbitrarios.

### Corrección de resultados

Toda corrección debe permitir identificar:

- Identificador de la queja.
- Clasificación original.
- Clasificación corregida.
- Usuario responsable.
- Fecha y hora de modificación.

### Aprobación de informes

Un informe generado automáticamente no debe considerarse aprobado por el simple hecho de haber sido generado.

Debe existir una acción explícita de aprobación o rechazo por parte de una persona autorizada.

---

## 4. Historias de usuario

### HU-01. Identificación de tendencias

**Como** Líder de CX, quiero identificar los motivos de quejas que más crecieron durante la semana, para priorizar las acciones del equipo.

Criterios de aceptación:
- Mostrar los motivos ordenados por crecimiento.
- Comparar con las tres semanas anteriores.
- Mostrar fuente y fecha de corte.

### HU-02. Aprobación de informes

**Como** Líder de CX, quiero revisar y aprobar el informe semanal antes de su publicación, para garantizar la calidad de la información.

Criterios de aceptación:
- Diferenciar indicadores de interpretaciones generadas por IA.
- Permitir aprobar o rechazar el informe.
- Registrar responsable y fecha de aprobación.

### HU-03. Revisión de clasificaciones dudosas

**Como** analista, quiero identificar las quejas que la IA no pudo clasificar con suficiente confianza, para revisarlas manualmente.

Criterios de aceptación:
- Disponer de un filtro para casos dudosos.
- Mostrar la categoría sugerida y la información de confianza disponible.
- Permitir consultar el texto original de la queja.

### HU-04. Corrección de clasificaciones

**Como** analista, quiero modificar una categoría incorrecta, para mejorar la calidad de los datos.

Criterios de aceptación:
- Permitir seleccionar una categoría nueva.
- Conservar la clasificación original.
- Registrar usuario, fecha y modificación.

### HU-05. Trazabilidad de decisiones

**Como** responsable de auditoría, quiero consultar el historial de clasificación, corrección y aprobación, para verificar las decisiones tomadas.

Criterios de aceptación:
- Identificar quién realizó cada acción.
- Consultar fecha y hora.
- Diferenciar las acciones automáticas de las intervenciones humanas.

---

## 5. Criterios de diseño para la interfaz

La interfaz de Radar debe cumplir los siguientes requisitos:

- Los indicadores principales deben mostrar su fecha de corte.
- Las alertas deben distinguirse mediante color y texto.
- Cada indicador debe mostrar su fuente.
- Los casos dudosos deben estar identificados y ser filtrables.
- Las clasificaciones deben poder corregirse.
- Las correcciones deben conservar trazabilidad.
- El informe debe requerir aprobación humana.
- El agente debe comunicar sus capacidades y limitaciones.
- Las consultas sin datos deben producir respuestas explícitas.
- Los indicadores y las hipótesis deben tener una presentación visual diferente.
- La interfaz debe comunicar claramente cuando no existen datos disponibles.

---

## 6. Principio central de arquitectura

Radar de Quejas mantiene una separación entre cálculo, interpretación y decisión:

1. **SQL:** calcula indicadores, consolida información y aplica reglas de negocio.
2. **Inteligencia Artificial:** clasifica, resume y propone interpretaciones a partir de la información disponible.
3. **Supervisión humana:** valida los resultados dudosos, corrige clasificaciones y aprueba decisiones críticas.

Esta separación busca reducir errores de interpretación, evitar decisiones automatizadas sin supervisión y garantizar que los resultados puedan ser revisados.

---

## 7. Estado de implementación

Los principios representan decisiones de diseño. Su cumplimiento debe verificarse mediante pruebas técnicas y de experiencia de usuario.

Cada funcionalidad debe clasificarse como:

- Implementada y validada.
- Implementada, pendiente de validación.
- Definida, pendiente de desarrollo.

El objetivo es mantener una relación verificable entre los principios del producto, las funcionalidades desarrolladas y los criterios de aceptación.

**Conclusión**

Radar de Quejas no busca automatizar todas las decisiones, sino mejorar la capacidad de una organización para identificar problemas, comprender sus causas potenciales y actuar oportunamente con información confiable y supervisión humana.
