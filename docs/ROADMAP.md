# ROADMAP.md

# MedicoApp — Roadmap Oficial

Versión del documento: 1.0
Última actualización: 2026-06-04

---

# Visión del Producto

MedicoApp busca convertirse en una plataforma integral para la gestión médica personal, permitiendo a los usuarios centralizar su historial clínico, medicamentos, tratamientos, estudios médicos y seguimiento de salud en una sola aplicación.

El objetivo es evolucionar desde una aplicación de control médico personal hacia un expediente médico digital inteligente con capacidades de automatización y asistencia mediante inteligencia artificial.

---

# Estado Actual

## v1.0.0 — COMPLETADA ✅

### Autenticación

* Login
* Registro
* JWT

### Historial Clínico

* Consultas
* Recetas
* Fotos

### Doctores

* CRUD completo

### Inventario

* Alta
* Edición
* Eliminación
* Stock bajo

### Tratamientos

* Creación automática de tomas
* Confirmación de tomas
* Omisión de tomas
* Cancelación

### Dashboard

* Resumen general

### Perfil

* Información del usuario

### Infraestructura

* SQLite Offline
* Sincronización automática
* Notificaciones locales

Estado:
PRODUCCIÓN LOCAL

---

# v2.0.0 — DESPLIEGUE EN NUBE

Prioridad: CRÍTICA

Objetivo:
Validar la arquitectura completa en entorno real de Internet.

## Backend

* [ ] Publicar API .NET en Railway
* [ ] Configurar variables de entorno
* [ ] Configurar HTTPS
* [ ] Configurar logs

## Base de Datos

* [ ] Crear instancia productiva
* [ ] Ejecutar migraciones
* [ ] Respaldos automáticos

## Flutter

* [ ] Configurar URL producción
* [ ] Manejo de errores mejorado
* [ ] Validar reconexión

## QA

* [ ] Pruebas WiFi
* [ ] Pruebas 4G
* [ ] Pruebas 5G
* [ ] Validar sincronización offline

Estado:
PENDIENTE

---

# v2.1.0 — AUTOMATIZACIÓN MÉDICA

Prioridad: ALTA

Objetivo:
Reducir captura manual de información.

## OCR de Recetas

* [ ] Capturar receta
* [ ] Extraer texto
* [ ] Detectar medicamentos
* [ ] Detectar dosis
* [ ] Detectar frecuencia

## Inventario Inteligente

* [ ] Predicción de consumo
* [ ] Cálculo de duración restante
* [ ] Alertas preventivas

## Dashboard Avanzado

* [ ] Próximas tomas
* [ ] Medicamentos por vencer
* [ ] Estadísticas rápidas

Estado:
PLANIFICADA

---

# v2.2.0 — EXPEDIENTE MÉDICO

Prioridad: ALTA

Objetivo:
Crear expediente médico integral.

## Antecedentes

* [ ] Tipo de sangre
* [ ] Alergias
* [ ] Enfermedades crónicas
* [ ] Cirugías
* [ ] Vacunas

## Perfil Médico

* [ ] Resumen clínico
* [ ] Información de emergencia

Estado:
PLANIFICADA

---

# v2.3.0 — ESTUDIOS MÉDICOS

Prioridad: MEDIA

Objetivo:
Centralizar documentación médica.

## Estudios

* [ ] Laboratorios
* [ ] Rayos X
* [ ] Resonancias
* [ ] Ultrasonidos
* [ ] Tomografías

## Archivos

* [ ] PDF
* [ ] Imágenes
* [ ] Compartir documentos

Estado:
PLANIFICADA

---

# v2.4.0 — PRODUCTIVIDAD

Prioridad: MEDIA

Objetivo:
Facilitar intercambio de información médica.

## Exportaciones

* [ ] PDF expediente
* [ ] PDF tratamiento
* [ ] PDF consultas

## Compartir

* [ ] Compartir expediente
* [ ] Compartir recetas
* [ ] Compartir estudios

Estado:
PLANIFICADA

---

# v3.0.0 — MEDICOAPP INTELIGENTE

Prioridad: ESTRATÉGICA

Objetivo:
Incorporar automatización avanzada e inteligencia artificial.

## Inteligencia Artificial

* [ ] Interpretación de recetas
* [ ] Resumen clínico automático
* [ ] Asistente médico personal

## Notificaciones Push

* [ ] Firebase Cloud Messaging
* [ ] Recordatorios remotos

## Widget Android

* [ ] Próxima toma
* [ ] Confirmación rápida

## Widget iOS

* [ ] Resumen diario

Estado:
VISIÓN FUTURA

---

# Ideas en Evaluación

## Futuras Funcionalidades

* Telemedicina
* Agenda de citas
* Integración con smartwatch
* Integración con Google Fit
* Integración con Apple Health
* Respaldo automático en la nube
* Portal web

Estado:
BACKLOG

---

# Reglas de Versionado

PATCH (x.x.1)

* Corrección de errores

MINOR (x.1.x)

* Nuevas funcionalidades compatibles

MAJOR (1.x.x)

* Cambios importantes de arquitectura o producto

Ejemplos:

v2.0.1
Corrección de errores

v2.1.0
OCR de recetas

v3.0.0
IA médica
