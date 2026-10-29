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
que lo vea.  [Diccionario de datos](data/diccionario_datos.md)

| Validación | Resultado |
|---|---|
| Filas únicas | 2.000 |
| Transacción no reconocida | 39 % |
| Pico sembrado en semana 4 | Sí, 60.21 % |

## Próximos pasos
- [ ] Semana 2: agente clasificador en n8n con salida estructurada
- [ ] Semana 3: base de datos en Supabase y vistas SQL de KPI
- [ ] Semana 4: interfaz, dashboard y video demo

## Autora
Sandra Milena López · [LinkedIn](https://linkedin.com/in/smilenalopezpuentes)
