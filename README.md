# 🚀 MarketMove

![Logo](assets/images/logo.png)

**MarketMove** es una solución integral desarrollada en Flutter para la gestión moderna de pequeños y medianos comercios. Diseñada para optimizar el control de ventas, gastos e inventario, ofreciendo una experiencia de usuario fluida y herramientas poderosas de análisis en tiempo real.

---

## ✨ Características Principales

### 👥 Gestión de Roles y Permisos
El sistema cuenta con una robusta gestión de usuarios basada en roles:

*   **👑 Superadmin:**
    *   Panel de control global.
    *   Gestión completa de propietarios (Owners).
    *   **Modo Impersonación:** Capacidad de acceder a la vista de cualquier negocio para soporte y gestión.
    *   Visualización de métricas globales.
*   **👔 Owner (Propietario):**
    *   Control total de su negocio.
    *   Gestión de empleados.
    *   Acceso a todas las estadísticas financieras (Ventas, Gastos, Balance).
    *   Exportación completa de reportes.
*   **👤 Employee (Empleado):**
    *   Registro de ventas y gastos propios.
    *   Vista limitada a sus propias transacciones.
    *   Sin acceso a datos sensibles del negocio.

### 📊 Dashboard y Analíticas
*   **Gráficos Interactivos:** Visualización de ingresos vs gastos mensuales, semanales y diarios.
*   **KPIs en Tiempo Real:** Balance total, número de ventas, alertas de stock bajo.
*   **Filtros Avanzados:** Análisis por día, semana, mes o histórico completo.

### 📦 Gestión de Inventario
*   Control de productos con imágenes.
*   Sistema de categorías.
*   Alertas automáticas de **Stock Bajo**.
*   Búsqueda rápida y filtrado.

### 📑 Reportes y Exportación
*   **Generación de Excel (.xlsx):** Sistema inteligente de reportes.
*   **Filtros de Seguridad:** 
    *   Los empleados descargan solo sus registros.
    *   Los dueños descargan el reporte completo del negocio.
*   Prevención de descargas duplicadas mediante *Debounce*.

### 🔒 Seguridad y Rendimiento
*   **Supabase Backend:** Autenticación robusta y base de datos PostgreSQL en tiempo real.
*   **Row Level Security (RLS):** Políticas de seguridad a nivel de base de datos optimizadas para garantizar que cada usuario vea solo lo que le corresponde.
*   **Caché Local:** Implementación de caché en providers para minimizar llamadas a la base de datos y acelerar la carga.

---

## 🛠️ Stack Tecnológico

*   **Frontend:** [Flutter](https://flutter.dev/) (Dart)
*   **Backend:** [Supabase](https://supabase.com/) (PostgreSQL + Auth)
*   **Gestión de Estado:** [Riverpod](https://riverpod.dev/) 2.0
*   **Enrutamiento:** [GoRouter](https://pub.dev/packages/go_router)
*   **Gráficos:** [fl_chart](https://pub.dev/packages/fl_chart)
*   **Exportación:** [excel](https://pub.dev/packages/excel)

---

## 🚀 Instalación y Puesta en Marcha

### Prerrequisitos
*   Flutter SDK instalado.
*   Cuenta en Supabase.
*   Git.

### Pasos

1.  **Clonar el repositorio**
    ```bash
    git clone https://github.com/tu-usuario/MarketMove.git
    cd ProyectoNuevo
    ```

2.  **Configurar Variables de Entorno**
    Crea un archivo `.env` en la raíz del proyecto:
    ```env
    SUPABASE_URL=tu_url_de_supabase
    SUPABASE_ANON_KEY=tu_anon_key
    ```

3.  **Configurar Base de Datos**
    Ejecuta los scripts SQL proporcionados en el editor SQL de Supabase para configurar las tablas, triggers y políticas de seguridad:
    *   `database_schema.sql` (Estructura base)
    *   `fix_rls_performance.sql` (Políticas de seguridad optimizadas)

4.  **Instalar Dependencias**
    ```bash
    flutter pub get
    ```

5.  **Ejecutar**
    ```bash
    flutter run -d chrome  # Para web
    # O selecciona tu emulador preferido
    ```

---

## 📂 Estructura del Proyecto

El proyecto sigue una arquitectura **Feature-First** para mejorar la escalabilidad y mantenibilidad:

```
lib/src/
├── features/           # Módulos funcionales
│   ├── admin/          # Panel de Superadmin
│   ├── auth/           # Login, Registro y Autenticación
│   ├── gastos/         # Gestión de Gastos
│   ├── productos/      # Inventario y Productos
│   ├── resumen/        # Dashboard y Home
│   └── ventas/         # Gestión de Ventas
├── shared/             # Código compartido
│   ├── models/         # Modelos de datos
│   ├── providers/      # Providers globales (Auth, Theme)
│   ├── utils/          # Utilidades (Excel, Formateadores)
│   └── widgets/        # Widgets reutilizables
└── l10n/               # Internacionalización (Español/Inglés)
```

---

## 👨‍💻 Equipo de Desarrollo

Desarrollado con ❤️ por el equipo de **2DAM**.

---

© 2025 MarketMove S.L. Todos los derechos reservados.
