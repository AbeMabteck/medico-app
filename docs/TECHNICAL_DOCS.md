# MedicoApp — Documentación Técnica

**Versión:** 1.1.0  
**Fecha:** 2026-06-04  
**Autor:** Abraham Rios  

---

## Índice

1. [Descripción general](#1-descripción-general)
2. [Stack tecnológico](#2-stack-tecnológico)
3. [Arquitectura del sistema](#3-arquitectura-del-sistema)
4. [Base de datos](#4-base-de-datos)
5. [API .NET](#5-api-net)
6. [Autenticación](#6-autenticación)
7. [Endpoints](#7-endpoints)
8. [Flutter — Estructura](#8-flutter--estructura)
9. [Flutter — Módulos](#9-flutter--módulos)
10. [Configuración del entorno](#10-configuración-del-entorno)
11. [Control de versiones](#11-control-de-versiones)
12. [Pendientes v2.0](#12-pendientes-v20)

---

## 1. Descripción general

MedicoApp es una aplicación móvil multiplataforma (iOS y Android) para la gestión médica personal. Permite al usuario llevar un control de sus consultas médicas, doctores, medicamentos en inventario y tratamientos activos con recordatorios automáticos.

### Módulos implementados

| Módulo | Descripción | Estado |
|---|---|---|
| Autenticación | Registro e inicio de sesión con JWT | ✅ Completo |
| Perfil | Ver y editar datos personales | ✅ Completo |
| Historial Clínico | Consultas médicas con fotos de recetas | ✅ Completo |
| Doctores | Registro de médicos | ✅ Completo |
| Inventario | Control de medicamentos disponibles | ✅ Completo |
| Tratamientos | Tomas programadas con notificaciones | ✅ Completo |

---

## 2. Stack tecnológico

| Capa | Tecnología | Versión |
|---|---|---|
| Mobile | Flutter | 3.44.1 |
| Lenguaje mobile | Dart | 3.12.1 |
| Backend | ASP.NET Core Web API | .NET 10.0 |
| Lenguaje backend | C# | 10 |
| Base de datos | SQL Server | 2025 Developer Edition |
| ORM | Entity Framework Core | Latest |
| Autenticación | JWT Bearer | — |
| Encriptación | BCrypt.Net-Next | — |
| Documentación API | Swagger / Swashbuckle | 6.9.0 |
| Notificaciones | flutter_local_notifications | 17.2.4 |
| Timezone | timezone | 0.9.4 |
| Control de versiones | Git + GitHub | — |

---

## 3. Arquitectura del sistema

```
┌─────────────────────────────────┐
│         Flutter App             │
│  • UI/UX multiplataforma        │
│  • Notificaciones locales       │
│  • Zona horaria: Mexico_City    │
└────────────┬────────────────────┘
             │ HTTP / REST / JSON
             │ IP: 192.168.1.109:5224
┌────────────▼────────────────────┐
│        .NET Web API             │
│  • Controllers                  │
│  • JWT Authentication           │
│  • Entity Framework Core        │
│  • Manejo de archivos (fotos)   │
│  • Escucha en 0.0.0.0:5224      │
└────────────┬────────────────────┘
             │
┌────────────▼────────────────────┐
│         SQL Server 2025         │
│  • 8 tablas relacionales        │
│  • Índices optimizados          │
└─────────────────────────────────┘
```

---

## 4. Base de datos

**Nombre:** MedicoAppDB  
**Servidor:** localhost  
**Motor:** SQL Server 2025 Developer Edition  

### Tablas

| Tabla | Descripción |
|---|---|
| Users | Usuarios de la app |
| Doctors | Médicos registrados por usuario |
| Consultas | Historial de visitas médicas |
| Recetas | Fotos de recetas por consulta |
| MedicamentosCatalogo | Catálogo global de medicamentos |
| Inventario | Stock de medicamentos por usuario |
| Tratamientos | Tratamientos médicos activos e históricos |
| Tomas | Registro individual de cada toma programada |

### Relaciones principales

```
Users
  ├── Doctors (UserId → FK)
  ├── Consultas (UserId → FK)
  │     └── Recetas (ConsultaId → FK)
  ├── Inventario (UserId → FK)
  └── Tratamientos (UserId → FK)
        └── Tomas (TratamientoId → FK)

MedicamentosCatalogo
  ├── Inventario (MedicamentoId → FK)
  └── Tratamientos (MedicamentoId → FK)
```

---

## 5. API .NET

### Configuración base

- **Puerto local:** 5224
- **URL base:** `http://localhost:5224`
- **URL red local:** `http://192.168.1.109:5224`
- **Swagger UI:** `http://localhost:5224/swagger`
- **Formato:** JSON
- **Autenticación:** JWT Bearer Token

### Cadena de conexión

```json
"ConnectionStrings": {
  "DefaultConnection": "Server=localhost;Database=MedicoAppDB;Trusted_Connection=True;TrustServerCertificate=True;"
}
```

### Configuración JWT

```json
"JwtSettings": {
  "SecretKey": "MedicoApp_SecretKey_2026_Cambiar_En_Produccion",
  "Issuer": "MedicoApp.API",
  "Audience": "MedicoApp.Mobile",
  "ExpirationHours": 24
}
```

> ⚠️ **Importante:** Cambiar el SecretKey antes de pasar a producción.

---

## 6. Autenticación

La API utiliza **JWT (JSON Web Tokens)** con una expiración de 24 horas.

### Flujo de autenticación

```
1. Cliente envía POST /api/Auth/register o /api/Auth/login
2. API valida credenciales
3. API genera token JWT firmado con HMACSHA256
4. Cliente almacena el token en SharedPreferences
5. Cliente incluye el token en cada request:
   Authorization: Bearer {token}
6. API valida el token en cada endpoint protegido
```

---

## 7. Endpoints

### Auth (sin JWT)

| Método | Endpoint | Descripción |
|---|---|---|
| POST | /api/Auth/register | Registro de nuevo usuario |
| POST | /api/Auth/login | Inicio de sesión |

### Perfil (JWT requerido)

| Método | Endpoint | Descripción |
|---|---|---|
| GET | /api/Perfil | Obtiene datos del usuario |
| PUT | /api/Perfil | Actualiza datos del usuario |

### Doctores (JWT requerido)

| Método | Endpoint | Descripción |
|---|---|---|
| GET | /api/Doctores | Lista todos los doctores |
| GET | /api/Doctores/{id} | Obtiene un doctor |
| POST | /api/Doctores | Crea un nuevo doctor |
| PUT | /api/Doctores/{id} | Actualiza un doctor |
| DELETE | /api/Doctores/{id} | Desactiva un doctor |

### Consultas (JWT requerido)

| Método | Endpoint | Descripción |
|---|---|---|
| GET | /api/Consultas | Lista todas las consultas |
| GET | /api/Consultas/{id} | Obtiene una consulta con recetas |
| POST | /api/Consultas | Registra una nueva consulta |
| PUT | /api/Consultas/{id} | Actualiza una consulta |
| DELETE | /api/Consultas/{id} | Elimina una consulta |

### Recetas (JWT requerido)

| Método | Endpoint | Descripción |
|---|---|---|
| POST | /api/Recetas | Crea receta con foto (multipart/form-data) |
| GET | /api/Recetas/{id} | Obtiene una receta |
| DELETE | /api/Recetas/{id} | Elimina receta y archivo físico |

### Inventario (JWT requerido)

| Método | Endpoint | Descripción |
|---|---|---|
| GET | /api/Inventario | Lista todo el inventario |
| GET | /api/Inventario/{id} | Obtiene un item |
| GET | /api/Inventario/stock-bajo | Items con stock bajo |
| GET | /api/Inventario/catalogo | Catálogo de medicamentos |
| POST | /api/Inventario/catalogo | Agrega al catálogo |
| POST | /api/Inventario | Agrega al inventario |
| PUT | /api/Inventario/{id} | Actualiza item |
| DELETE | /api/Inventario/{id} | Elimina item |

### Tratamientos (JWT requerido)

| Método | Endpoint | Descripción |
|---|---|---|
| GET | /api/Tratamientos | Lista todos los tratamientos |
| GET | /api/Tratamientos/activos | Lista tratamientos activos |
| GET | /api/Tratamientos/{id} | Obtiene un tratamiento |
| GET | /api/Tratamientos/{id}/tomas | Lista tomas del tratamiento |
| GET | /api/Tratamientos/tomas/proximas | Tomas en las próximas 24h |
| POST | /api/Tratamientos | Crea tratamiento y genera tomas |
| PUT | /api/Tratamientos/{id}/cancelar | Cancela un tratamiento |
| POST | /api/Tratamientos/tomas/{id}/confirmar | Confirma toma y descuenta inventario |
| POST | /api/Tratamientos/tomas/{id}/omitir | Omite una toma |

---

## 8. Flutter — Estructura

```
lib/
  constants/
    api_constants.dart          — URLs de la API
    app_theme.dart              — Colores y tema visual
  models/
    user_model.dart
    consulta_model.dart         — ConsultaModel, DoctorModel, RecetaModel
    inventario_model.dart       — InventarioModel, MedicamentoCatalogoModel
    tratamiento_model.dart      — TratamientoModel, TomaModel
  screens/
    auth/
      login_screen.dart
      register_screen.dart
    consultas/
      consultas_screen.dart
      nueva_consulta_screen.dart
      detalle_consulta_screen.dart
    doctores/
      doctores_screen.dart
      nuevo_doctor_screen.dart
    inventario/
      inventario_screen.dart
      agregar_inventario_screen.dart
    tratamientos/
      tratamientos_screen.dart
      nuevo_tratamiento_screen.dart
      detalle_tratamiento_screen.dart
    home_screen.dart
    perfil_screen.dart
  services/
    auth_service.dart
    consulta_service.dart
    doctor_service.dart
    inventario_service.dart
    notification_service.dart
    perfil_service.dart
    receta_service.dart
    tratamiento_service.dart
  main.dart
```

---

## 9. Flutter — Módulos

### Autenticación
- Login con email y contraseña
- Registro con datos personales
- Token JWT guardado en SharedPreferences
- SplashScreen con verificación de sesión y animación

### Perfil
- Ver datos del usuario
- Editar nombre, teléfono, tipo de sangre, fecha de nacimiento

### Historial Clínico
- Lista de consultas ordenadas por fecha
- Crear consulta con doctor, fecha, síntomas, diagnóstico
- Ver detalle completo de consulta
- Subir fotos de recetas (cámara o galería)

### Doctores
- Lista de doctores registrados
- Agregar doctor con especialidad y consultorio
- Eliminar doctor (soft delete)

### Inventario
- Lista con cantidad, status y stock mínimo
- Agregar medicamento del catálogo
- Status automático: disponible, agotado, por_vencer, vencido
- Alerta visual cuando stock está bajo

### Tratamientos
- Lista de activos e historial completo
- Crear tratamiento con medicamento, dosis, frecuencia y duración
- Generación automática de tomas al crear tratamiento
- Confirmar toma → descuenta inventario automáticamente
- Omitir toma
- Cancelar tratamiento
- Notificaciones locales para cada toma programada
- Zona horaria: America/Mexico_City

---

## 10. Configuración del entorno

### Requisitos

| Herramienta | Versión | Uso |
|---|---|---|
| Windows | 11 Pro | Sistema operativo |
| Git | 2.54.0 | Control de versiones |
| Visual Studio Code | 1.122.1 | Editor Flutter |
| Flutter SDK | 3.44.1 | Desarrollo móvil |
| Android Studio | Latest | Emulador Android |
| Visual Studio Professional | 2026 | Desarrollo API .NET |
| SQL Server | 2025 Developer | Base de datos |
| SSMS | Latest | Administración DB |
| Bruno | Latest | Pruebas de API |
| scrcpy | Latest | Espejo de pantalla del celular |

### Dispositivo de prueba
- **Modelo:** Redmi Note 12 5G
- **Android:** 14 (API 34)
- **Conexión:** WiFi via adb
- **IP celular:** 192.168.1.77
- **Comando conexión:** `adb connect 192.168.1.77:5555`
- **Comando scrcpy:** `.\scrcpy.exe --tcpip=192.168.1.77:5555`

### Variables de entorno
- adb configurado en PATH via perfil de PowerShell
- Perfil en: `C:\Users\abe\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1`

### Usuario de prueba
- **Email:** abrahamrios63@gmail.com
- **Password:** 123456

---

## 11. Control de versiones

### Estrategia GitFlow

```
main        → Código estable / producción
develop     → Desarrollo activo
feature/*   → Nuevas funcionalidades
hotfix/*    → Correcciones urgentes
```

### Repositorio
- **URL:** https://github.com/AbeMabteck/medico-app
- **Rama activa:** develop
- **Visibilidad:** Privado

### Historial de commits

| Commit | Descripción |
|---|---|
| feat: configuracion inicial API .NET con entidades y DbContext | Estructura base API |
| feat: proyecto Flutter inicial | Creación proyecto móvil |
| feat: modulo de autenticacion con JWT y BCrypt | Login y registro |
| feat: modulo historial clinico - doctores, consultas y recetas | Módulo clínico API |
| feat: modulo inventario con catalogo de medicamentos | Inventario API |
| feat: modulo tratamientos y tomas con descuento automatico | Tratamientos API |
| feat: estructura base Flutter con pantallas de autenticacion | Flutter base |
| feat: conexion Flutter con API real y login funcionando | Login conectado |
| feat: modulo historial clinico completo en Flutter | Historial Flutter |
| feat: modulo inventario completo en Flutter | Inventario Flutter |
| feat: modulo tratamientos completo en Flutter | Tratamientos Flutter |
| feat: notificaciones locales para recordatorio de tomas | Notificaciones |
| feat: subir fotos de recetas y modulo doctores completo | Fotos y doctores |
| feat: pantalla de perfil de usuario | Perfil |
| feat: splash screen mejorado y AppBar con nombre de usuario | UI mejorada |

---

## 12. Pendientes v2.0

| Funcionalidad | Descripción | Prioridad |
|---|---|---|
| Modo offline | Guardar datos localmente y sincronizar al recuperar internet | Alta |
| Dashboard | Pantalla de inicio con resumen de tomas pendientes y stock bajo | Media |
| Publicación App Store | Preparar para iOS | Media |
| Publicación Play Store | Preparar para Android | Media |
| Notificaciones push | Servidor de notificaciones para múltiples usuarios | Baja |
| Backup en la nube | Azure Blob Storage para fotos de recetas | Baja |

---

*Documentación actualizada el 2026-06-04.*
