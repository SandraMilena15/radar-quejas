# Radar de Quejas – PagoYa

Agente de IA que clasifica las quejas de una fintech, detecta qué motivo está
creciendo y prioriza las que tienen riesgo de fraude o de vencer el plazo, con
revisión humana antes de enviar el informe semanal.

> Estado: en construcción (semana 1 de 8). PagoYa es una empresa ficticia.

## El problema
En 2025 la Superintendencia Financiera recibió 2,76 millones de quejas, un
récord; cerca del 39 % fueron por transacciones no reconocidas.
[Ver fuentes y canvas completo](docs/canvas_radar_quejas.md)

## Cómo funciona (diseño)
1. SQL limpia los datos y enmascara información sensible.
2. Un modelo de IA pequeño clasifica cada queja con una taxonomía definida.
3. SQL calcula los KPI: quejas por motivo, en riesgo y vencidas.
4. La IA redacta los hallazgos a partir de esas cifras.
5. Una analista revisa las quejas de prioridad alta antes de enviar el informe.

## Datos
Todos los datos son **sintéticos**: 2.000 quejas en 4 semanas, generadas con
IA y calibradas con proporciones de la SFC. Incluyen errores de ortografía,
ironía, comentarios vacíos y un patrón sembrado para probar la detección.
El motivo real está en un archivo separado para evaluar el clasificador sin
que lo vea. [Diccionario de datos](data/diccionario_datos.md)

| Validación | Resultado |
|---|---|
| Filas únicas | 2.000 |
| Periodo | 28 sep – 25 oct 2026 (4 semanas completas; fecha de corte 29 oct) |
| Transacción no reconocida | 39 % (780 quejas) |
| Comentarios vacíos | 5 % (100 quejas) |
| Pico sembrado en semana 4 | Sí: +60,6 % en no reconocidas con tarjeta por app frente al promedio de las semanas 1 a 3 |

## Avance
- [x] Semana 1: canvas, base de conocimiento y dataset sintético validado
- [x] Semana 2 (en curso): clasificador en n8n con salida estructurada en JSON
- [ ] Semana 3: base de datos en Supabase y vistas SQL de KPI
- [ ] Semana 4: interfaz, dashboard y video demo

## Primera medición (20 quejas, Claude Haiku 5.5)
| Medida | Resultado |
|---|---|
| Precisión por motivo | 19/20 (95 %) |
| Quejas graves no detectadas | 0 de 9 |
| Errores escalados a revisión por duda | 1 de 1 |

El único error fue un caso ambiguo que el modelo marcó con duda; la regla de
negocio lo subió a prioridad alta para revisión humana.
[Ver medición](evals/medicion_clasificacion_20.xlsx)

## Autora
Sandra Milena López · [LinkedIn](https://linkedin.com/in/smilenalopezpuentes)
