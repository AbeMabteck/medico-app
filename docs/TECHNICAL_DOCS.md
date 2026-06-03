# MedicoApp — Documentación Técnica

**Versión:** 1.0.0  
**Fecha:** 2026-06-03  
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
8. [Estructura del proyecto](#8-estructura-del-proyecto)
9. [Configuración del entorno](#9-configuración-del-entorno)
10. [Control de versiones](#10-control-de-versiones)

---

## 1. Descripción general

MedicoApp es una aplicación móvil multiplataforma (iOS y Android) para la gestión médica personal. Permite al usuario llevar un control de sus consultas médicas, medicamentos en inventario y tratamientos activos con recordatorios automáticos.

### Módulos principales

| Módulo | Descripción |
|---|---|
| Historial clínico | Registro de consultas médicas, doctores, síntomas, diagnósticos y recetas |
| Inventario | Control de medicamentos disponibles con alertas de stock bajo |
| Tratamientos | Control de tomas programadas con descuento automático del inventario |

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
| Control de versiones | Git + GitHub | — |

---

## 3. Arquitectura del sistema

```
┌─────────────────────────────────┐
│         Flutter App             │
│  • UI/UX multiplataforma        │
│  • Notificaciones locales       │
│  • Caché local                  │
└────────────┬────────────────────┘
             │ HTTP / REST / JSON
┌────────────▼────────────────────┐
│        .NET Web API             │
│  • Controllers                  │
│  • JWT Authentication           │
│  • Entity Framework Core        │
│  • Manejo de archivos (fotos)   │
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
**Servidor local:** localhost  
**Motor:** SQL Server 2025 Developer Edition  

### Diagrama de tablas

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

### Descripción de tablas

#### Users
Tabla principal de usuarios. Soporta multiusuario desde el diseño inicial.

| Campo | Tipo | Descripción |
|---|---|---|
| Id | INT PK | Identificador único |
| Nombre | NVARCHAR(100) | Nombre completo |
| Email | NVARCHAR(150) UNIQUE | Correo electrónico |
| PasswordHash | NVARCHAR(255) | Contraseña encriptada con BCrypt |
| Telefono | NVARCHAR(20) | Teléfono opcional |
| FechaNacimiento | DATE | Fecha de nacimiento |
| TipoSangre | NVARCHAR(5) | Tipo de sangre (ej. O+) |
| Activo | BIT | Estado del usuario |
| CreatedAt | DATETIME2 | Fecha de creación |
| UpdatedAt | DATETIME2 | Fecha de última actualización |

#### Doctors
Registro de médicos asociados a un usuario.

| Campo | Tipo | Descripción |
|---|---|---|
| Id | INT PK | Identificador único |
| UserId | INT FK | Referencia al usuario |
| Nombre | NVARCHAR(100) | Nombre del doctor |
| Especialidad | NVARCHAR(100) | Especialidad médica |
| Consultorio | NVARCHAR(200) | Dirección o nombre del consultorio |
| Telefono | NVARCHAR(20) | Teléfono de contacto |
| Activo | BIT | Soft delete |

#### Consultas
Historial de visitas médicas.

| Campo | Tipo | Descripción |
|---|---|---|
| Id | INT PK | Identificador único |
| UserId | INT FK | Referencia al usuario |
| DoctorId | INT FK NULL | Doctor que atendió (opcional) |
| Fecha | DATE | Fecha de la consulta |
| Motivo | NVARCHAR(300) | Motivo de la visita |
| Sintomas | NVARCHAR(1000) | Síntomas presentados |
| Diagnostico | NVARCHAR(1000) | Diagnóstico del médico |
| Notas | NVARCHAR(1000) | Notas adicionales |

#### Recetas
Fotos de recetas médicas asociadas a una consulta.

| Campo | Tipo | Descripción |
|---|---|---|
| Id | INT PK | Identificador único |
| ConsultaId | INT FK | Consulta a la que pertenece |
| FotoPath | NVARCHAR(500) | Ruta del archivo en el servidor |
| Notas | NVARCHAR(500) | Notas sobre la receta |

#### MedicamentosCatalogo
Catálogo global de medicamentos. No está ligado a un usuario específico.

| Campo | Tipo | Descripción |
|---|---|---|
| Id | INT PK | Identificador único |
| Nombre | NVARCHAR(150) | Nombre comercial |
| NombreGenerico | NVARCHAR(150) | Nombre genérico |
| Presentacion | NVARCHAR(100) | Forma farmacéutica (tabletas, cápsulas, etc.) |
| Concentracion | NVARCHAR(100) | Concentración (ej. 500mg) |

#### Inventario
Stock de medicamentos por usuario.

| Campo | Tipo | Descripción |
|---|---|---|
| Id | INT PK | Identificador único |
| UserId | INT FK | Referencia al usuario |
| MedicamentoId | INT FK | Referencia al catálogo |
| CantidadActual | INT | Unidades disponibles |
| CantidadMinima | INT | Umbral de alerta de stock bajo |
| Unidad | NVARCHAR(50) | Unidad de medida (tabletas, ml, etc.) |
| FechaCaducidad | DATE | Fecha de caducidad |
| LugarCompra | NVARCHAR(200) | Farmacia o lugar de compra |
| Precio | DECIMAL(10,2) | Precio pagado |
| Status | NVARCHAR(20) | disponible / agotado / por_vencer / vencido |

#### Tratamientos
Tratamientos médicos activos e históricos.

| Campo | Tipo | Descripción |
|---|---|---|
| Id | INT PK | Identificador único |
| UserId | INT FK | Referencia al usuario |
| RecetaId | INT FK NULL | Receta que originó el tratamiento |
| MedicamentoId | INT FK | Medicamento del tratamiento |
| Dosis | NVARCHAR(100) | Descripción de la dosis |
| FrecuenciaHoras | INT | Intervalo entre tomas en horas |
| DuracionDias | INT | Duración total del tratamiento |
| FechaInicio | DATE | Fecha de inicio |
| FechaFin | DATE | Fecha de fin calculada |
| Status | NVARCHAR(20) | activo / completado / cancelado |

#### Tomas
Registro individual de cada toma programada.

| Campo | Tipo | Descripción |
|---|---|---|
| Id | INT PK | Identificador único |
| TratamientoId | INT FK | Tratamiento al que pertenece |
| HoraProgramada | DATETIME2 | Hora en que debe tomarse |
| HoraTomada | DATETIME2 NULL | Hora real en que se tomó |
| Status | NVARCHAR(20) | pendiente / tomada / omitida / retrasada |
| DescontadoInventario | BIT | Indica si ya se descontó del inventario |

---

## 5. API .NET

### Configuración base

- **Puerto local:** 5224
- **URL base:** `http://localhost:5224`
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
4. Cliente almacena el token
5. Cliente incluye el token en cada request:
   Authorization: Bearer {token}
6. API valida el token en cada endpoint protegido
```

### Encriptación de contraseñas

Las contraseñas se encriptan con **BCrypt** (salt automático) antes de guardarse en la base de datos. Nunca se almacena la contraseña en texto plano.

---

## 7. Endpoints

### Auth

| Método | Endpoint | Auth | Descripción |
|---|---|---|---|
| POST | /api/Auth/register | ❌ | Registro de nuevo usuario |
| POST | /api/Auth/login | ❌ | Inicio de sesión |

### Doctores

| Método | Endpoint | Auth | Descripción |
|---|---|---|---|
| GET | /api/Doctores | ✅ | Lista todos los doctores del usuario |
| GET | /api/Doctores/{id} | ✅ | Obtiene un doctor por ID |
| POST | /api/Doctores | ✅ | Crea un nuevo doctor |
| PUT | /api/Doctores/{id} | ✅ | Actualiza un doctor |
| DELETE | /api/Doctores/{id} | ✅ | Desactiva un doctor (soft delete) |

### Consultas

| Método | Endpoint | Auth | Descripción |
|---|---|---|---|
| GET | /api/Consultas | ✅ | Lista todas las consultas del usuario |
| GET | /api/Consultas/{id} | ✅ | Obtiene una consulta con sus recetas |
| POST | /api/Consultas | ✅ | Registra una nueva consulta |
| PUT | /api/Consultas/{id} | ✅ | Actualiza una consulta |
| DELETE | /api/Consultas/{id} | ✅ | Elimina una consulta |

### Recetas

| Método | Endpoint | Auth | Descripción |
|---|---|---|---|
| POST | /api/Recetas | ✅ | Crea receta con foto (multipart/form-data) |
| GET | /api/Recetas/{id} | ✅ | Obtiene una receta |
| DELETE | /api/Recetas/{id} | ✅ | Elimina receta y archivo físico |

### Inventario

| Método | Endpoint | Auth | Descripción |
|---|---|---|---|
| GET | /api/Inventario | ✅ | Lista todo el inventario del usuario |
| GET | /api/Inventario/{id} | ✅ | Obtiene un item del inventario |
| GET | /api/Inventario/stock-bajo | ✅ | Lista medicamentos con stock bajo |
| GET | /api/Inventario/catalogo | ✅ | Lista el catálogo de medicamentos |
| POST | /api/Inventario/catalogo | ✅ | Agrega medicamento al catálogo |
| POST | /api/Inventario | ✅ | Agrega medicamento al inventario |
| PUT | /api/Inventario/{id} | ✅ | Actualiza item del inventario |
| DELETE | /api/Inventario/{id} | ✅ | Elimina item del inventario |

### Tratamientos

| Método | Endpoint | Auth | Descripción |
|---|---|---|---|
| GET | /api/Tratamientos | ✅ | Lista todos los tratamientos |
| GET | /api/Tratamientos/activos | ✅ | Lista tratamientos activos |
| GET | /api/Tratamientos/{id} | ✅ | Obtiene un tratamiento con stats |
| GET | /api/Tratamientos/{id}/tomas | ✅ | Lista todas las tomas de un tratamiento |
| GET | /api/Tratamientos/tomas/proximas | ✅ | Tomas pendientes en las próximas 24 horas |
| POST | /api/Tratamientos | ✅ | Crea tratamiento y genera tomas automáticamente |
| PUT | /api/Tratamientos/{id}/cancelar | ✅ | Cancela un tratamiento activo |
| POST | /api/Tratamientos/tomas/{id}/confirmar | ✅ | Confirma una toma y descuenta inventario |
| POST | /api/Tratamientos/tomas/{id}/omitir | ✅ | Marca una toma como omitida |

---

## 8. Estructura del proyecto

```
medico-app/
├── src/
│   ├── MedicoApp.API/                  ← API .NET
│   │   ├── Controllers/
│   │   │   ├── AuthController.cs
│   │   │   ├── ConsultasController.cs
│   │   │   ├── DoctoresController.cs
│   │   │   ├── InventarioController.cs
│   │   │   ├── RecetasController.cs
│   │   │   └── TratamientosController.cs
│   │   ├── Data/
│   │   │   └── AppDbContext.cs
│   │   ├── Helpers/
│   │   │   └── JwtHelper.cs
│   │   ├── Models/
│   │   │   ├── DTOs/
│   │   │   │   ├── AuthDTOs.cs
│   │   │   │   ├── ConsultaDTOs.cs
│   │   │   │   ├── DoctorDTOs.cs
│   │   │   │   ├── InventarioDTOs.cs
│   │   │   │   └── TratamientoDTOs.cs
│   │   │   └── Entities/
│   │   │       ├── Consulta.cs
│   │   │       ├── Doctor.cs
│   │   │       ├── Inventario.cs
│   │   │       ├── MedicamentoCatalogo.cs
│   │   │       ├── Receta.cs
│   │   │       ├── Toma.cs
│   │   │       ├── Tratamiento.cs
│   │   │       └── User.cs
│   │   ├── Services/
│   │   │   └── Interfaces/
│   │   ├── Uploads/
│   │   │   └── Recetas/               ← Fotos de recetas
│   │   ├── appsettings.json
│   │   └── Program.cs
│   └── medico_app/                    ← App Flutter
│       └── lib/
│           └── main.dart
└── README.md
```

---

## 9. Configuración del entorno

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

### Extensiones VS Code instaladas

- `dart-code.dart-code` — Soporte Dart
- `dart-code.flutter` — Soporte Flutter
- `eamodio.gitlens` — Git avanzado
- `ms-dotnettools.csharp` — Soporte C#

---

## 10. Control de versiones

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
| feat: configuracion inicial API .NET con entidades y DbContext | Estructura base de la API |
| feat: proyecto Flutter inicial | Creación del proyecto móvil |
| feat: modulo de autenticacion con JWT y BCrypt | Login y registro |
| feat: modulo historial clinico - doctores, consultas y recetas | Módulo clínico completo |
| feat: modulo inventario con catalogo de medicamentos | Inventario completo |
| feat: modulo tratamientos y tomas con descuento automatico de inventario | Módulo de tratamientos completo |

---

*Documentación generada el 2026-06-03. Se actualiza conforme avanza el desarrollo.*
