# ROADMAP.md

# MedicoApp — Roadmap Oficial

Versión del documento: 2.0

Última actualización: 2026-06-05

---

# Estado Actual del Proyecto

## Versión Actual

v1.0.0 — COMPLETADA ✅

Estado:

Producción Local

---

## Funcionalidades Implementadas

### Autenticación

* Login
* Registro
* JWT

### Expediente Médico

* Consultas
* Recetas
* Fotografías de recetas

### Doctores

* CRUD completo

### Inventario

* Alta
* Edición
* Eliminación
* Stock bajo

### Tratamientos

* Generación automática de tomas
* Confirmación de tomas
* Omisión de tomas
* Cancelación de tratamientos

### Dashboard

* Resumen general

### Perfil

* Gestión de información personal

### Infraestructura

* SQLite Offline
* Sincronización automática
* Notificaciones locales

---

# v2.0.0 — PRODUCCIÓN EN LA NUBE

Prioridad: CRÍTICA

Objetivo:

Validar MedicoApp en condiciones reales de uso mediante infraestructura en la nube.

---

## Backend

* [ ] Publicar API .NET en Railway
* [ ] Configurar variables de entorno
* [ ] Configurar HTTPS
* [ ] Configurar logs de aplicación

---

## Base de Datos

* [ ] Crear base de datos productiva
* [ ] Ejecutar migraciones
* [ ] Configurar respaldos

---

## Flutter

* [ ] Configurar URL de producción
* [ ] Mejorar manejo de errores
* [ ] Validar recuperación de conexión

---

## QA

* [ ] Pruebas WiFi
* [ ] Pruebas 4G
* [ ] Pruebas 5G
* [ ] Validación offline
* [ ] Validación de sincronización

Estado:

PENDIENTE

---

# v2.1.0 — AUTOMATIZACIÓN MÉDICA

Prioridad: ALTA

Objetivo:

Reducir la captura manual de información.

---

## OCR de Recetas

* [ ] Capturar receta
* [ ] Extraer texto
* [ ] Detectar medicamentos
* [ ] Detectar dosis
* [ ] Detectar frecuencia
* [ ] Detectar duración del tratamiento

---

## Inventario Inteligente

* [ ] Predicción de consumo
* [ ] Estimación de duración restante
* [ ] Alertas preventivas de compra

---

## Dashboard Avanzado

* [ ] Próximas tomas
* [ ] Medicamentos por vencer
* [ ] Estadísticas rápidas
* [ ] Accesos rápidos

Estado:

PLANIFICADA

---

# v2.2.0 — EXPEDIENTE MÉDICO

Prioridad: ALTA

Objetivo:

Construir un expediente médico personal completo.

---

## Antecedentes Médicos

* [ ] Tipo de sangre
* [ ] Alergias
* [ ] Enfermedades crónicas
* [ ] Cirugías
* [ ] Vacunas

---

## Perfil Médico

* [ ] Resumen clínico
* [ ] Información de emergencia
* [ ] Contactos de emergencia

Estado:

PLANIFICADA

---

# v2.3.0 — ESTUDIOS MÉDICOS

Prioridad: MEDIA

Objetivo:

Centralizar documentos médicos.

---

## Estudios

* [ ] Laboratorios
* [ ] Rayos X
* [ ] Resonancias
* [ ] Ultrasonidos
* [ ] Tomografías

---

## Gestión de Archivos

* [ ] PDF
* [ ] Imágenes
* [ ] Organización por categorías

Estado:

PLANIFICADA

---

# v2.4.0 — PRODUCTIVIDAD Y EXPORTACIÓN

Prioridad: MEDIA

Objetivo:

Facilitar el intercambio de información médica.

---

## Exportación

* [ ] PDF de expediente médico
* [ ] PDF de tratamientos
* [ ] PDF de consultas

---

## Compartir Información

* [ ] Compartir expediente
* [ ] Compartir recetas
* [ ] Compartir estudios

Estado:

PLANIFICADA

---

# v3.0.0 — MEDICOAPP INTELIGENTE

Prioridad: ESTRATÉGICA

Objetivo:

Convertir MedicoApp en un asistente personal de salud inteligente.

---

## Inteligencia Artificial

* [ ] Interpretación de recetas
* [ ] Resumen clínico automático
* [ ] Asistente personal de salud

---

## Notificaciones Push

* [ ] Firebase Cloud Messaging
* [ ] Recordatorios remotos

---

## Widgets

### Android

* [ ] Próxima toma
* [ ] Confirmación rápida

### iOS

* [ ] Resumen diario

Estado:

VISIÓN FUTURA

---

# Backlog Futuro

Funcionalidades en evaluación para versiones posteriores.

* Telemedicina
* Agenda de citas
* Integración con Smartwatch
* Integración con Google Fit
* Integración con Apple Health
* Backup automático en la nube
* Portal Web
* Gestión familiar de pacientes
* Multiusuario

Estado:

BACKLOG

---

# Reglas de Versionado

## PATCH (x.x.1)

Corrección de errores.

Ejemplo:

* v2.0.1
* v2.0.2

---

## MINOR (x.1.x)

Nuevas funcionalidades compatibles.

Ejemplo:

* v2.1.0
* v2.2.0

---

## MAJOR (1.x.x)

Cambios importantes de producto o arquitectura.

Ejemplo:

* v2.0.0 → Salida a producción
* v3.0.0 → MedicoApp Inteligente

---

# Próximo Objetivo Oficial

## Versión Objetivo

v2.0.0 — Producción en la Nube

## Meta

Permitir que MedicoApp funcione completamente fuera del entorno local y validar su operación mediante Internet real.
