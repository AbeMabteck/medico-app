# DATABASE_SCHEMA.md

# MedicoApp — Esquema de Base de Datos

Versión del documento: 1.0

Última actualización: 2026-06-05

---

# Objetivo

Documentar la estructura actual y futura de la base de datos de MedicoApp.

Este documento servirá como referencia antes de realizar cambios en SQL Server, Entity Framework Core, modelos .NET, endpoints API o modelos Flutter.

---

# Base de Datos Actual

## Motor

SQL Server 2025 Developer Edition

## Nombre

MedicoAppDB

## Estado

v1.0.0 — Implementada

---

# Tablas Actuales

## Users

Almacena los usuarios registrados en la aplicación.

### Propósito

Gestionar autenticación, perfil e información básica del usuario.

### Datos esperados

* Id
* Nombre
* Email
* PasswordHash
* Telefono
* TipoSangre
* FechaNacimiento
* FechaCreacion
* Activo

---

## Doctors

Almacena los doctores registrados por cada usuario.

### Propósito

Permitir que el usuario relacione consultas con doctores específicos.

### Relación

* Un usuario puede tener muchos doctores.
* Cada doctor pertenece a un usuario.

### Datos esperados

* Id
* UserId
* Nombre
* Especialidad
* Consultorio
* Telefono
* Activo
* FechaCreacion

---

## Consultas

Almacena las visitas médicas registradas por el usuario.

### Propósito

Construir el historial clínico del usuario.

### Relación

* Una consulta pertenece a un usuario.
* Una consulta puede estar relacionada con un doctor.
* Una consulta puede tener una o varias recetas.

### Datos esperados

* Id
* UserId
* DoctorId
* FechaConsulta
* Sintomas
* Diagnostico
* Notas
* FechaCreacion

---

## Recetas

Almacena fotografías o archivos relacionados con recetas médicas.

### Propósito

Permitir guardar evidencia visual de recetas entregadas por médicos.

### Relación

* Una receta pertenece a una consulta.

### Datos esperados

* Id
* ConsultaId
* NombreArchivo
* RutaArchivo
* TipoArchivo
* FechaCreacion

---

## MedicamentosCatalogo

Catálogo general de medicamentos.

### Propósito

Evitar duplicidad de nombres y permitir reutilización de medicamentos en inventario y tratamientos.

### Relación

* Un medicamento del catálogo puede estar en muchos inventarios.
* Un medicamento del catálogo puede estar en muchos tratamientos.

### Datos esperados

* Id
* Nombre
* Presentacion
* Laboratorio
* Activo

---

## Inventario

Almacena los medicamentos disponibles del usuario.

### Propósito

Controlar stock, caducidad y disponibilidad de medicamentos.

### Relación

* Un usuario puede tener muchos medicamentos en inventario.
* Cada registro de inventario referencia un medicamento del catálogo.

### Datos esperados

* Id
* UserId
* MedicamentoId
* Cantidad
* Unidad
* StockMinimo
* FechaCaducidad
* LugarCompra
* Precio
* FechaCreacion
* Activo

---

## Tratamientos

Almacena tratamientos médicos creados por el usuario.

### Propósito

Gestionar medicamentos prescritos, frecuencia, duración y estado del tratamiento.

### Relación

* Un usuario puede tener muchos tratamientos.
* Un tratamiento referencia un medicamento del catálogo.
* Un tratamiento genera muchas tomas.

### Datos esperados

* Id
* UserId
* MedicamentoId
* Dosis
* FrecuenciaHoras
* DuracionDias
* FechaInicio
* FechaFin
* Estado
* Notas
* FechaCreacion

---

## Tomas

Almacena cada toma programada de un tratamiento.

### Propósito

Controlar recordatorios, confirmaciones y omisiones de medicamentos.

### Relación

* Una toma pertenece a un tratamiento.

### Datos esperados

* Id
* TratamientoId
* FechaHoraProgramada
* FechaHoraRealizada
* Estado
* Notas

---

# Relaciones Actuales

```text
Users
  ├── Doctors
  ├── Consultas
  │     └── Recetas
  ├── Inventario
  └── Tratamientos
        └── Tomas

MedicamentosCatalogo
  ├── Inventario
  └── Tratamientos
```

---

# Concepto de Expediente Médico

A partir de la nueva visión de producto, el módulo visual principal será:

```text
Expediente
```

Este concepto agrupa:

* Consultas.
* Recetas.
* Estudios médicos.
* Antecedentes médicos.
* Información clínica relevante.

## Nota Técnica

No se recomienda crear una tabla llamada `Expediente` por ahora.

El expediente debe entenderse como un concepto de interfaz y negocio que agrupa varias entidades relacionadas con la salud del usuario.

---

# Tablas Futuras Propuestas

Estas tablas aún no deben implementarse hasta que se trabaje formalmente en la versión correspondiente del roadmap.

---

# v2.2.0 — Expediente Médico

## MedicalBackgrounds

Almacena antecedentes médicos generales del usuario.

### Propósito

Registrar información médica relevante que no pertenece a una consulta específica.

### Datos propuestos

* Id
* UserId
* Tipo
* Descripcion
* FechaDiagnostico
* Notas
* Activo
* FechaCreacion
* FechaActualizacion

### Tipos sugeridos

* Enfermedad crónica
* Cirugía
* Condición médica
* Antecedente familiar
* Otro

---

## Allergies

Almacena alergias del usuario.

### Propósito

Permitir registrar alergias médicas importantes.

### Datos propuestos

* Id
* UserId
* Nombre
* Tipo
* Reaccion
* Severidad
* Notas
* Activo
* FechaCreacion

### Tipos sugeridos

* Medicamento
* Alimento
* Ambiental
* Otro

### Severidad sugerida

* Leve
* Moderada
* Grave

---

## Vaccines

Almacena vacunas registradas por el usuario.

### Propósito

Controlar historial de vacunación.

### Datos propuestos

* Id
* UserId
* Nombre
* FechaAplicacion
* Dosis
* LugarAplicacion
* Lote
* Notas
* FechaCreacion

---

## EmergencyContacts

Almacena contactos de emergencia.

### Propósito

Guardar contactos importantes para casos médicos.

### Datos propuestos

* Id
* UserId
* Nombre
* Parentesco
* Telefono
* Email
* EsPrincipal
* FechaCreacion

---

# v2.3.0 — Estudios Médicos

## MedicalStudies

Almacena estudios médicos del usuario.

### Propósito

Centralizar documentos como laboratorios, rayos X, ultrasonidos, resonancias y tomografías.

### Datos propuestos

* Id
* UserId
* ConsultaId
* TipoEstudio
* Nombre
* FechaEstudio
* Laboratorio
* ResultadoResumen
* Notas
* FechaCreacion

### Tipos sugeridos

* Laboratorio
* Rayos X
* Ultrasonido
* Resonancia
* Tomografía
* Otro

---

## MedicalStudyFiles

Almacena archivos asociados a estudios médicos.

### Propósito

Permitir adjuntar PDF o imágenes a un estudio médico.

### Datos propuestos

* Id
* MedicalStudyId
* NombreArchivo
* RutaArchivo
* TipoArchivo
* TamanoBytes
* FechaCreacion

---

# v2.1.0 — OCR de Recetas

## PrescriptionOcrResults

Almacena resultados del procesamiento OCR de recetas.

### Propósito

Guardar el texto detectado y permitir auditoría o corrección manual.

### Datos propuestos

* Id
* RecetaId
* TextoDetectado
* ConfianzaPromedio
* ProcesadoCorrectamente
* FechaProcesamiento
* Error

---

## PrescriptionOcrItems

Almacena posibles medicamentos detectados dentro de una receta.

### Propósito

Convertir texto detectado por OCR en datos estructurados que puedan crear tratamientos.

### Datos propuestos

* Id
* PrescriptionOcrResultId
* MedicamentoDetectado
* DosisDetectada
* FrecuenciaDetectada
* DuracionDetectada
* TextoOriginal
* ConfirmadoPorUsuario
* MedicamentoId

---

# v2.4.0 — Exportaciones

## ExportedDocuments

Almacena registros de documentos exportados.

### Propósito

Registrar PDFs generados como expediente, consultas o tratamientos.

### Datos propuestos

* Id
* UserId
* TipoDocumento
* RutaArchivo
* FechaGeneracion
* FechaExpiracion
* Activo

### Tipos sugeridos

* Expediente
* Consulta
* Tratamiento
* Inventario
* Estudio

---

# Consideraciones de Diseño

## Soft Delete

Cuando sea posible, usar campos como:

```text
Activo
FechaEliminacion
```

para evitar pérdida definitiva de información médica.

---

## Auditoría

En futuras versiones se recomienda agregar campos estándar:

```text
FechaCreacion
FechaActualizacion
CreadoPor
ActualizadoPor
```

### Recomendación para Tablas Actuales

Aunque varias tablas actuales ya cuentan con `FechaCreacion`, se recomienda evaluar la incorporación de `FechaActualizacion` en tablas principales como:

- Users
- Doctors
- Consultas
- Inventario
- Tratamientos

Esto será especialmente importante para:

- Sincronización offline.
- Resolución de conflictos.
- Auditoría de cambios.
- Migración a entorno de nube.

---

## Seguridad

La información médica es sensible.

Se recomienda considerar:

* JWT obligatorio en endpoints protegidos.
* Filtros por UserId.
* No exponer datos de otros usuarios.
* Cifrado o protección adicional para archivos sensibles.
* Backups seguros.

---

## Archivos

Actualmente las recetas usan archivos/fotos.

A futuro se recomienda unificar almacenamiento de archivos para:

* Recetas.
* Estudios.
* Exportaciones PDF.
* Otros documentos médicos.

Posibles servicios futuros:

* Azure Blob Storage.
* Cloudinary.
* Amazon S3.
* Storage propio del proveedor cloud.

---

# Reglas para Cambios de Base de Datos

Antes de modificar la base de datos se debe:

1. Actualizar este documento.
2. Definir impacto en API.
3. Definir impacto en Flutter.
4. Crear o actualizar entidades .NET.
5. Crear migraciones EF Core.
6. Validar endpoints.
7. Validar sincronización offline si aplica.
8. Probar en ambiente local.
9. Probar en ambiente de nube.

---

# Pendientes de Validación

Antes de implementar v2.1, v2.2 o v2.3 se debe revisar:

* Si la estructura actual de `Users` soporta toda la información médica personal.
* Si conviene separar datos médicos sensibles del perfil general.
* Si los archivos deben migrarse a almacenamiento en nube.
* Si la sincronización offline requiere nuevas tablas SQLite equivalentes.
* Si OCR debe ejecutarse en el dispositivo, en backend o mediante servicio externo.
* Si las tablas futuras requieren versionado o auditoría avanzada.

---

# Resumen

La base actual soporta correctamente MedicoApp v1.0.0.

Para las siguientes versiones se recomienda evolucionar la base de datos de forma gradual:

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

El concepto de `Expediente` debe manejarse inicialmente como una agrupación funcional y visual, no como una tabla única.
