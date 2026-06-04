# API_SPECIFICATION.md

# MedicoApp — Especificación de API

Versión del documento: 1.0

Última actualización: 2026-06-05

---

# Objetivo

Documentar los endpoints actuales y futuros de la API de MedicoApp.

Este documento servirá como referencia para mantener alineados:

* Flutter
* ASP.NET Core Web API
* SQL Server
* Documentación técnica
* Roadmap del producto

---

# Información General

## Backend

ASP.NET Core Web API (.NET 10)

## Formato

JSON

## Autenticación

JWT Bearer Token

## URL local

```text
http://192.168.1.109:5224/api
```

## URL producción

Pendiente de definir en v2.0.0.

---

# Reglas Generales de API

## Endpoints Protegidos

Todos los endpoints protegidos deben requerir:

```text
Authorization: Bearer {token}
```

---

## Respuestas

Las respuestas deben ser claras, consistentes y fáciles de consumir desde Flutter.

---

## Seguridad

Cada endpoint debe validar que los datos consultados pertenezcan al usuario autenticado.

Ningún usuario debe poder consultar, modificar o eliminar información médica de otro usuario.

---

# Endpoints Actuales

---

# Auth

## POST /api/Auth/register

Registra un nuevo usuario.

### Autenticación

No requiere JWT.

### Uso

Crear cuenta nueva.

---

## POST /api/Auth/login

Inicia sesión.

### Autenticación

No requiere JWT.

### Uso

Validar credenciales y devolver token JWT.

---

# Perfil

## GET /api/Perfil

Obtiene el perfil del usuario autenticado.

### Autenticación

JWT requerido.

---

## PUT /api/Perfil

Actualiza datos del perfil del usuario autenticado.

### Autenticación

JWT requerido.

---

# Doctores

## GET /api/Doctores

Obtiene todos los doctores del usuario autenticado.

### Autenticación

JWT requerido.

---

## GET /api/Doctores/{id}

Obtiene un doctor específico.

### Autenticación

JWT requerido.

---

## POST /api/Doctores

Crea un nuevo doctor.

### Autenticación

JWT requerido.

---

## PUT /api/Doctores/{id}

Actualiza un doctor existente.

### Autenticación

JWT requerido.

---

## DELETE /api/Doctores/{id}

Elimina o desactiva un doctor.

### Autenticación

JWT requerido.

---

# Consultas

## GET /api/Consultas

Obtiene todas las consultas del usuario autenticado.

### Autenticación

JWT requerido.

---

## GET /api/Consultas/{id}

Obtiene una consulta específica con sus recetas.

### Autenticación

JWT requerido.

---

## POST /api/Consultas

Crea una nueva consulta médica.

### Autenticación

JWT requerido.

---

## PUT /api/Consultas/{id}

Actualiza una consulta existente.

### Autenticación

JWT requerido.

---

## DELETE /api/Consultas/{id}

Elimina una consulta.

### Autenticación

JWT requerido.

---

# Recetas

## POST /api/Recetas

Sube una receta con foto o archivo.

### Autenticación

JWT requerido.

### Formato

multipart/form-data

---

## GET /api/Recetas/{id}

Obtiene una receta específica.

### Autenticación

JWT requerido.

---

## DELETE /api/Recetas/{id}

Elimina una receta y su archivo asociado.

### Autenticación

JWT requerido.

---

# Inventario

## GET /api/Inventario

Obtiene el inventario completo del usuario.

### Autenticación

JWT requerido.

---

## GET /api/Inventario/{id}

Obtiene un elemento específico del inventario.

### Autenticación

JWT requerido.

---

## GET /api/Inventario/stock-bajo

Obtiene medicamentos con stock bajo.

### Autenticación

JWT requerido.

---

## GET /api/Inventario/catalogo

Obtiene el catálogo de medicamentos.

### Autenticación

JWT requerido.

---

## POST /api/Inventario/catalogo

Agrega un medicamento al catálogo.

### Autenticación

JWT requerido.

---

## POST /api/Inventario

Agrega un medicamento al inventario.

### Autenticación

JWT requerido.

---

## PUT /api/Inventario/{id}

Actualiza un elemento del inventario.

### Autenticación

JWT requerido.

---

## DELETE /api/Inventario/{id}

Elimina un elemento del inventario.

### Autenticación

JWT requerido.

---

# Tratamientos

## GET /api/Tratamientos

Obtiene todos los tratamientos del usuario.

### Autenticación

JWT requerido.

---

## GET /api/Tratamientos/activos

Obtiene tratamientos activos.

### Autenticación

JWT requerido.

---

## GET /api/Tratamientos/{id}

Obtiene un tratamiento específico.

### Autenticación

JWT requerido.

---

## GET /api/Tratamientos/{id}/tomas

Obtiene las tomas de un tratamiento.

### Autenticación

JWT requerido.

---

## GET /api/Tratamientos/tomas/proximas

Obtiene las próximas tomas programadas.

### Autenticación

JWT requerido.

---

## POST /api/Tratamientos

Crea un tratamiento y genera tomas automáticamente.

### Autenticación

JWT requerido.

---

## PUT /api/Tratamientos/{id}/cancelar

Cancela un tratamiento activo.

### Autenticación

JWT requerido.

---

## POST /api/Tratamientos/tomas/{id}/confirmar

Confirma una toma y descuenta inventario.

### Autenticación

JWT requerido.

---

## POST /api/Tratamientos/tomas/{id}/omitir

Omite una toma programada.

### Autenticación

JWT requerido.

---

# Endpoints Futuros Propuestos

Los siguientes endpoints no deben implementarse todavía. Quedan documentados para planeación futura.

---

# v2.1.0 — OCR de Recetas

## POST /api/Recetas/{id}/ocr

Procesa una receta mediante OCR.

### Autenticación

JWT requerido.

### Propósito

Extraer texto de la imagen o archivo de receta.

---

## GET /api/Recetas/{id}/ocr

Obtiene el resultado OCR de una receta.

### Autenticación

JWT requerido.

---

## POST /api/Recetas/{id}/ocr/confirmar

Confirma los medicamentos detectados por OCR.

### Autenticación

JWT requerido.

### Propósito

Permitir que el usuario revise y confirme los datos detectados antes de crear tratamientos.

---

## POST /api/Recetas/{id}/ocr/crear-tratamientos

Crea tratamientos a partir de los medicamentos confirmados por OCR.

### Autenticación

JWT requerido.

---

# v2.1.0 — Inventario Inteligente

## GET /api/Inventario/prediccion-consumo

Obtiene predicción de consumo del inventario.

### Autenticación

JWT requerido.

---

## GET /api/Inventario/alertas-compra

Obtiene alertas de medicamentos que podrían agotarse pronto.

### Autenticación

JWT requerido.

---

# v2.2.0 — Expediente Médico

## GET /api/Expediente/resumen

Obtiene un resumen del expediente médico del usuario.

### Autenticación

JWT requerido.

### Incluye

* Consultas recientes.
* Recetas.
* Tratamientos activos.
* Alergias.
* Antecedentes.
* Estudios recientes.

---

## GET /api/Antecedentes

Obtiene antecedentes médicos.

### Autenticación

JWT requerido.

---

## POST /api/Antecedentes

Crea un antecedente médico.

### Autenticación

JWT requerido.

---

## PUT /api/Antecedentes/{id}

Actualiza un antecedente médico.

### Autenticación

JWT requerido.

---

## DELETE /api/Antecedentes/{id}

Elimina o desactiva un antecedente médico.

### Autenticación

JWT requerido.

---

## GET /api/Alergias

Obtiene alergias del usuario.

### Autenticación

JWT requerido.

---

## POST /api/Alergias

Crea una alergia.

### Autenticación

JWT requerido.

---

## PUT /api/Alergias/{id}

Actualiza una alergia.

### Autenticación

JWT requerido.

---

## DELETE /api/Alergias/{id}

Elimina o desactiva una alergia.

### Autenticación

JWT requerido.

---

## GET /api/Vacunas

Obtiene vacunas del usuario.

### Autenticación

JWT requerido.

---

## POST /api/Vacunas

Crea una vacuna.

### Autenticación

JWT requerido.

---

## PUT /api/Vacunas/{id}

Actualiza una vacuna.

### Autenticación

JWT requerido.

---

## DELETE /api/Vacunas/{id}

Elimina una vacuna.

### Autenticación

JWT requerido.

---

## GET /api/ContactosEmergencia

Obtiene contactos de emergencia.

### Autenticación

JWT requerido.

---

## POST /api/ContactosEmergencia

Crea un contacto de emergencia.

### Autenticación

JWT requerido.

---

## PUT /api/ContactosEmergencia/{id}

Actualiza un contacto de emergencia.

### Autenticación

JWT requerido.

---

## DELETE /api/ContactosEmergencia/{id}

Elimina un contacto de emergencia.

### Autenticación

JWT requerido.

---

# v2.3.0 — Estudios Médicos

## GET /api/Estudios

Obtiene estudios médicos del usuario.

### Autenticación

JWT requerido.

---

## GET /api/Estudios/{id}

Obtiene un estudio médico específico.

### Autenticación

JWT requerido.

---

## POST /api/Estudios

Crea un estudio médico.

### Autenticación

JWT requerido.

---

## PUT /api/Estudios/{id}

Actualiza un estudio médico.

### Autenticación

JWT requerido.

---

## DELETE /api/Estudios/{id}

Elimina un estudio médico.

### Autenticación

JWT requerido.

---

## POST /api/Estudios/{id}/archivos

Sube archivos relacionados con un estudio médico.

### Autenticación

JWT requerido.

### Formato

multipart/form-data

---

## GET /api/Estudios/{id}/archivos

Obtiene archivos asociados a un estudio médico.

### Autenticación

JWT requerido.

---

## DELETE /api/Estudios/archivos/{archivoId}

Elimina un archivo de estudio médico.

### Autenticación

JWT requerido.

---

# v2.4.0 — Exportaciones

## POST /api/Exportaciones/expediente

Genera PDF del expediente médico.

### Autenticación

JWT requerido.

---

## POST /api/Exportaciones/consulta/{id}

Genera PDF de una consulta específica.

### Autenticación

JWT requerido.

---

## POST /api/Exportaciones/tratamiento/{id}

Genera PDF de un tratamiento específico.

### Autenticación

JWT requerido.

---

## GET /api/Exportaciones

Obtiene documentos exportados por el usuario.

### Autenticación

JWT requerido.

---

## DELETE /api/Exportaciones/{id}

Elimina o desactiva una exportación generada.

### Autenticación

JWT requerido.

---

# v3.0.0 — MedicoApp Inteligente

## POST /api/IA/resumen-clinico

Genera resumen clínico automático del usuario.

### Autenticación

JWT requerido.

---

## POST /api/IA/analizar-receta/{id}

Analiza una receta usando inteligencia artificial.

### Autenticación

JWT requerido.

---

## POST /api/IA/sugerencias

Genera sugerencias preventivas basadas en datos del usuario.

### Autenticación

JWT requerido.

---

# Reglas de Nombres

## Controladores

Usar nombres claros y consistentes:

```text
AuthController
PerfilController
DoctoresController
ConsultasController
RecetasController
InventarioController
TratamientosController
```

Para futuros módulos:

```text
ExpedienteController
AntecedentesController
AlergiasController
VacunasController
EstudiosController
ExportacionesController
```

---

# Reglas de Seguridad

Todos los endpoints protegidos deben:

1. Validar JWT.
2. Obtener UserId desde el token.
3. Filtrar información por UserId.
4. Evitar exposición de datos entre usuarios.
5. Validar permisos antes de modificar o eliminar información.

---

# Reglas para Archivos

Los endpoints que manejen archivos deberán:

* Validar tipo de archivo.
* Validar tamaño máximo.
* Guardar ruta segura.
* Evitar nombres inseguros.
* Asociar archivo al usuario correcto.
* Permitir eliminación controlada.

---

# Reglas para Flutter

Flutter deberá consumir la API mediante servicios separados por módulo:

```text
auth_service.dart
perfil_service.dart
consulta_service.dart
doctor_service.dart
receta_service.dart
inventario_service.dart
tratamiento_service.dart
```

Servicios futuros sugeridos:

```text
expediente_service.dart
antecedente_service.dart
alergia_service.dart
vacuna_service.dart
estudio_service.dart
exportacion_service.dart
ocr_service.dart
```

---

# Offline y Sincronización

Cada nuevo endpoint que cree, edite o elimine información deberá evaluarse contra el modo offline.

Antes de agregar un módulo nuevo se debe definir:

* Tabla SQLite local.
* Estado de sincronización.
* Conflictos posibles.
* Fecha de última modificación.
* Estrategia de subida a API.

---

# Pendientes de Validación

Antes de implementar nuevos endpoints se debe validar:

* Modelo de datos en `DATABASE_SCHEMA.md`.
* Compatibilidad con Flutter.
* Compatibilidad con SQLite.
* Manejo de archivos en producción.
* Reglas de seguridad.
* Respuestas de error consistentes.

---

# Resumen

La API actual soporta correctamente MedicoApp v1.0.0.

Las futuras versiones deberán extender la API gradualmente:

```text
v2.1.0
OCR e inventario inteligente

v2.2.0
Expediente médico

v2.3.0
Estudios médicos

v2.4.0
Exportaciones

v3.0.0
Inteligencia artificial
```

Ningún endpoint futuro deberá implementarse sin antes validar impacto en base de datos, Flutter, seguridad y sincronización offline.
