# MarketMove App

**Cliente:** MarketMove S.L.  
**Desarrollado por:** Equipo de Desarrollo (2DAM)

## 📌 Descripción del Proyecto
Aplicación móvil desarrollada en Flutter para la gestión integral de pequeños comercios. Permite a los dueños de tiendas controlar sus ventas diarias, registrar gastos, gestionar el stock de productos y visualizar el balance económico de su negocio de forma sencilla e intuitiva.

## 👥 Integrantes del Equipo
*   [Tu Nombre / Integrante 1]
*   [Integrante 2]
*   [Integrante 3]

## 🚀 Fases del Proyecto
1.  **Análisis y Requisitos:** Definición de funcionalidades y alcance.
2.  **Diseño UX/UI:** Prototipado de pantallas y flujo de usuario.
3.  **Arquitectura:** Configuración del proyecto Flutter y estructura de carpetas.
4.  **Desarrollo Frontend:** Implementación de pantallas (Login, Ventas, Gastos, Stock, Balance).
5.  **Integración Backend:** Conexión con Supabase para autenticación y base de datos.
6.  **Pruebas:** Validación funcional y corrección de errores.
7.  **Entrega:** Documentación y simulación de publicación.

## 🛠️ Requisitos Técnicos
*   **Flutter SDK:** Versión estable más reciente (3.x).
*   **Dart SDK:** Compatible con Flutter 3.x.
*   **Editor:** VS Code o Android Studio.
*   **Backend:** Supabase (PostgreSQL).
*   **Gestión de Estado:** Riverpod.

## ▶️ Cómo Ejecutar el Proyecto

1.  **Clonar el repositorio:**
    ```bash
    git clone <url-del-repositorio>
    cd ProyectoNuevo
    ```

2.  **Instalar dependencias:**
    ```bash
    flutter pub get
    ```

3.  **Ejecutar la aplicación:**
    *   Selecciona un dispositivo (emulador o físico).
    *   Ejecuta el comando:
        ```bash
        flutter run
        ```

## 📂 Estructura del Proyecto
El proyecto sigue una arquitectura basada en características (Feature-first):

```
lib/
  src/
    features/       # Módulos funcionales (Auth, Ventas, Gastos, etc.)
    shared/         # Componentes y lógica reutilizable
assets/             # Imágenes e iconos
```
