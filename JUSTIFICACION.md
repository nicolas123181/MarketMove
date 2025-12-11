# JUSTIFICACIÓN DE HORAS Y DECISIONES TÉCNICAS
**Proyecto:** MarketMove App

## 1. Justificación de Horas (129 h)

La estimación de 129 horas se basa en un desglose realista de las tareas necesarias para un desarrollo profesional:

*   **Análisis y Diseño (25 h):** Es crucial dedicar tiempo a entender el problema y diseñar una solución correcta antes de programar. Esto evita errores costosos y retrabajos posteriores.
*   **Arquitectura (12 h):** Una buena base técnica (configuración de rutas, estado, carpetas) asegura que el proyecto sea escalable y mantenible. Ahorra tiempo en el futuro.
*   **Desarrollo Frontend (40 h):** Es la fase más extensa, ya que implica crear todas las interfaces visuales y la lógica de interacción con el usuario.
*   **Integración Backend (22 h):** Conectar con Supabase, gestionar la seguridad y los datos requiere cuidado y pruebas.
*   **Pruebas y Documentación (26 h):** Entregar un producto sin errores y bien documentado es parte de un servicio profesional.
*   **Entrega (4 h):** Preparar los entregables finales requiere tiempo de gestión.

## 2. Justificación de Decisiones Técnicas

### ¿Por qué Flutter?
*   **Eficiencia:** Permite desarrollar para Android e iOS simultáneamente, reduciendo el coste para el cliente casi a la mitad.
*   **Rendimiento:** Al compilar a código nativo, la aplicación es rápida y fluida, crucial para el uso diario en un comercio.

### ¿Por qué Supabase?
*   **Rapidez de implementación:** Ofrece base de datos y autenticación listas para usar, lo que acelera el desarrollo (ahorrando horas facturables).
*   **Coste:** Tiene un plan gratuito generoso, ideal para el inicio del proyecto del cliente.

### Arquitectura (Feature-first & Riverpod)
*   Organizar el código por funcionalidades (Ventas, Gastos...) hace que sea más fácil de entender y modificar.
*   **Riverpod** es una solución moderna y segura para gestionar el estado de la aplicación, evitando errores comunes en Flutter.
