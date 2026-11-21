# Sistema de diseño y wireframes – Radar de Quejas

Wireframes de fidelidad media de las 2 pantallas del Radar. Resuelven las brechas
encontradas en la [auditoría de UX](../principios_ux.md).

| Pantalla | Usuario | Archivo |
|---|---|---|
| Panel semanal | Líder de CX | [panel_semanal.png](panel_semanal.png) |
| Bandeja de revisión | Analista | [bandeja_revision.png](bandeja_revision.png) |
| Archivo editable | — | [radar.excalidraw](radar.excalidraw) (abrir en excalidraw.com) |

**Flujo de usuario:** Panel → "Ver casos" o "Ir a revisión" → Bandeja de revisión →
la analista confirma o corrige → vuelve al panel → "Aprobar informe".

## 1. Brechas de la auditoría que resuelve el diseño
| Brecha | Solución en el wireframe |
|---|---|
| 1. Capacidades no visibles | Mensaje de bienvenida en el chat |
| 2. Sin fuente en los KPI | Fuente y fecha de corte debajo de cada KPI y gráfico |
| 3. No se ve por qué dudó la IA | Campo "Motivo de la duda" en la bandeja |
| 5. Sin registro de correcciones | Formulario de corrección con nota obligatoria + historial |
| 7. Dato vs. hipótesis | Etiquetas DATO (azul) e HIPÓTESIS IA · POR VALIDAR (morado) |

## 2. Reglas del sistema de diseño
| Elemento | Regla |
|---|---|
| Jerarquía | Patrón F: KPI arriba, alertas a la izquierda, detalle al centro, chat a la derecha |
| Rejilla | 12 columnas; cada KPI ocupa 3 (4 por fila) |
| Espaciado | Múltiplos de 8 px |
| Texto | 3 tamaños: título, subtítulo y cuerpo |
| Estados | Rojo = vencida o crítica · Naranja = en riesgo o con duda · Verde = en plazo. Siempre con texto, nunca solo color |
| Origen del contenido | Azul = DATO (sale de SQL) · Morado = HIPÓTESIS o SUGERENCIA de la IA (por validar) |
| Botones | Principal (relleno oscuro) = la decisión: "Aprobar informe", "Corregir y guardar". Secundario (borde) = navegar o confirmar |
| Componentes | Tarjeta KPI, fila de alerta, fila de queja, burbuja de chat, etiqueta de estado, botón principal y secundario |

## 3. Microcopy
| Situación | Texto |
|---|---|
| Bienvenida del chat | "Hola. Respondo preguntas sobre quejas, motivos, plazos y tiempos de respuesta, con datos del 28 sep al 25 oct de 2026. No modifico datos, no apruebo reembolsos ni respondo a clientes." |
| El chat no tiene el dato | "No tengo ese dato en el Radar: [qué falta]." + vistas consultadas |
| Semana sin quejas en riesgo | "No hay quejas en riesgo esta semana. Próxima revisión: lunes." |
| "Aprobar" con casos de prioridad alta sin revisar | "Quedan [n] casos de prioridad alta sin revisar. ¿Aprobar de todas formas?" [Revisar primero] [Aprobar] |
| Comentario vacío | "Comentario vacío: la IA no puede clasificarlo. Asígnale un motivo o márcalo como Sin clasificar." |
| Corrección guardada | "Motivo actualizado. El cambio quedó en el historial." |
| Corregir sin nota | "Escribe una nota corta: explica por qué cambias el motivo." |

## 4. Origen de las cifras del wireframe
Calculadas con el dataset sintético y la lógica de las vistas (corte 29 oct 2026):

| Cifra | Valor | Fuente |
|---|---|---|
| Quejas de la semana 4 | 527 (+7,3 % vs. promedio 491) | `kpi_motivo_semanal` |
| En riesgo / vencidas / abiertas | 88 / 435 / 600 | `kpi_plazos` |
| Pico no reconocida · tarjeta · app | 76 vs. 47,3 (+60,6 %) | etiquetas reales |
| Respuesta del chat | 78 vs. 48,3 (+61 %) | `quejas_detalle` (clasificación de la IA) |
| Precisión | 96,8 % en 250 quejas | `v_eval_precision` |
| Con duda | 202 de 2.000 | `quejas_detalle` |

Las filas de la bandeja y la queja Q00123 son **ilustrativas**.

## 5. Prueba de 5 segundos
Se mostró el panel 5 segundos a una persona sin contexto y se le preguntó qué recordaba,
si había algo urgente y qué haría primero.

| Pregunta | Respuesta |
|---|---|
| ¿Qué recuerdas? | (completar) |
| ¿Hay algo urgente? | (completar) |
| ¿Qué harías primero? | (completar) |
| Conclusión | (completar: ¿mencionó la alerta del pico? ¿Qué cambiarías?) |

## 6. Pendientes técnicos que exige el diseño
- **Motivo de la duda:** el clasificador debe devolver un campo nuevo (`motivo_duda`) en su salida estructurada.
- **Tabla de correcciones** en Supabase: `id_solicitud`, `motivo_original`, `motivo_corregido`, `nota`, `usuario`, `corregido_en`.
- **Enmascaramiento** de datos sensibles antes de mostrar o enviar el comentario a la IA.
