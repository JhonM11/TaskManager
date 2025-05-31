📋 Task Manager – Flutter App

Una aplicación móvil sencilla para la gestión de tareas personales, construida en Flutter con gestión de estado mediante Riverpod. Permite a cada usuario:

- Iniciar sesión (sólo con nombre de usuario).

- Crear tareas con título, descripción, fecha vencimiento y prioridad (ALTA, MEDIA, BAJA).

- Marcar tareas como completadas o incompletas.

- Editar y eliminar tareas.

- Ver notificaciones amigables por cada acción.



▶️ Instrucciones de Ejecución


1: git clone git@github.com:JhonM11/TaskManager.git o descargar archivo .zip y descomprimir

2: cd task_manager

3: flutter pub get

4: flutter run



🧪 Ejecutar Pruebas Unitarias

flutter test


🏛️ Arquitectura del Proyecto

Este proyecto de gestor de tareas desarrollado en Flutter sigue una arquitectura modular, orientada a la mantenibilidad, escalabilidad y facilidad de pruebas. La estructura propuesta permite separar claramente la lógica de presentación, el manejo del estado, la lógica de negocio y el acceso a datos, facilitando así el desarrollo colaborativo y la evolución del sistema.

La base de este diseño está inspirada en el patrón MVVM (Modelo-Vista-ViewModel), contempalndo con los principios de Clean Architecture. 


Especificaciones:

- /models          → Definición de modelos de datos (entidades como Task y User)
- /screens         → Interfaces gráficas (pantallas login y tareas)
- /widgets         → Componentes reutilizables (task_item.dart)
- /providers       → Manejo del estado con Riverpod (taskprovider)
- /repository      → Fuente de datos simulada (FakeRepository)
- /services        → Capa intermedia para lógica de negocio (TaskService)
- /test            → Pruebas unitarias




📦 Dependencias Utilizadas


- flutter_riverpod: Manejo moderno de estado reactivo.

- shared_preferences: Almacenamiento local (guardar sesión del usuario).

- uuid: Generar identificadores únicos para cada tarea.

- intl: Formateo de fechas (usado para mostrar la fecha de vencimiento de tareas).

- another_flushbar: Manejo de notificaciones..





