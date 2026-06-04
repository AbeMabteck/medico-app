# DECISIONS_LOG.md

# MedicoApp — Registro de Decisiones

Versión del documento: 1.0

Última actualización: 2026-06-05

---

# Objetivo

Registrar decisiones importantes tomadas durante el desarrollo de MedicoApp.

Este documento ayuda a entender por qué se eligieron ciertas soluciones de producto, diseño, arquitectura o tecnología.

---

# Decisiones

## 2026-06-05 — MedicoApp como Asistente Personal de Salud

### Decisión

Definir MedicoApp como un asistente personal de salud.

### Motivo

La app no debe limitarse únicamente a medicamentos o historial clínico. Debe integrar consultas, recetas, inventario, tratamientos, recordatorios, estudios y futuras funciones inteligentes.

### Impacto

* Product Vision.
* Roadmap.
* UX/UI.
* Arquitectura futura.
* Módulos v2.1, v2.2, v2.3 y v3.0.

---

## 2026-06-05 — Usar “Expediente” en lugar de “Historial”

### Decisión

La navegación principal usará el término “Expediente”.

### Motivo

“Expediente” representa mejor el conjunto de consultas, recetas, estudios, antecedentes médicos y datos clínicos del usuario.

“Historial” puede interpretarse como algo más limitado o ambiguo.

### Impacto

* UI/UX.
* Navegación principal.
* Documentación.
* Futuros módulos.
* No requiere cambios inmediatos en base de datos.
* No requiere cambios inmediatos en API.

---

## 2026-06-05 — Dashboard como Centro de Control

### Decisión

El Dashboard será la pantalla principal más importante de MedicoApp.

### Motivo

El usuario debe ver rápidamente información crítica sin navegar por múltiples pantallas.

### Información prioritaria

* Próxima toma.
* Inventario bajo.
* Tratamientos activos.
* Próxima consulta.
* Recetas recientes.
* Estudios médicos.
* Recordatorios del día.

### Impacto

* UI/UX.
* Flutter.
* API futura.
* Dashboard avanzado v2.1.

---

## 2026-06-05 — Tema Claro y Tema Oscuro

### Decisión

MedicoApp soportará tema claro, tema oscuro y opción de seguir el tema del sistema.

### Motivo

El tema claro será más accesible para la mayoría de usuarios, incluyendo adultos mayores.

El tema oscuro ofrecerá una experiencia moderna, premium y cómoda para usuarios que prefieren modo oscuro.

### Configuración recomendada

```text
Seguir sistema
```

### Impacto

* UI_UX_GUIDELINES.md.
* Flutter ThemeData.
* Diseño de componentes.
* Accesibilidad.

---

## 2026-06-05 — Tema Claro como Experiencia Principal

### Decisión

El tema claro será considerado la experiencia principal de MedicoApp.

### Motivo

Es más legible, amigable y accesible para usuarios generales.

### Impacto

* Diseño predeterminado.
* Pruebas de accesibilidad.
* Mockups base.

---

## 2026-06-05 — Tema Oscuro como Experiencia Premium

### Decisión

El tema oscuro será diseñado como una experiencia propia, no como una simple inversión de colores.

### Motivo

El modo oscuro debe sentirse moderno, elegante y tecnológico sin sacrificar legibilidad.

### Impacto

* UI_UX_GUIDELINES.md.
* Paleta oscura.
* Componentes Flutter.
* Diseño de tarjetas.

---

## 2026-06-05 — Botón Central de Acción Rápida

### Decisión

La navegación inferior incluirá un botón central de acción rápida.

### Motivo

El usuario debe poder agregar información médica rápidamente desde cualquier sección principal.

### Acciones propuestas

* Agregar consulta.
* Agregar receta.
* Agregar medicamento.
* Agregar tratamiento.
* Agregar estudio.

### Impacto

* Dashboard.
* Bottom Navigation.
* UX.
* Flutter.

---

## 2026-06-05 — No Crear Tabla “Expediente” por Ahora

### Decisión

El concepto “Expediente” será una agrupación funcional y visual, no una tabla única en la base de datos.

### Motivo

El expediente se compone de varias entidades:

* Consultas.
* Recetas.
* Estudios.
* Antecedentes.
* Alergias.
* Vacunas.

Crear una tabla única de expediente podría complicar innecesariamente el modelo.

### Impacto

* DATABASE_SCHEMA.md.
* API_SPECIFICATION.md.
* Diseño de base de datos futura.
* No afecta la base actual.

---

## 2026-06-05 — v2.0 Enfocada en Nube, no en Nuevas Funciones

### Decisión

La versión v2.0.0 se enfocará en publicar MedicoApp en la nube.

### Motivo

Antes de agregar OCR, IA o nuevas funcionalidades, se debe validar que la app funcione correctamente en Internet real.

### Impacto

* Railway.
* SQL Server en nube.
* URL de producción en Flutter.
* Pruebas WiFi, 4G y 5G.
* Validación offline/sync en condiciones reales.

---

## 2026-06-05 — Documentar Antes de Codificar

### Decisión

Antes de tocar Flutter, API .NET o SQL Server, se crearán y revisarán los documentos principales del proyecto.

### Documentos

* PRODUCT_VISION.md
* ROADMAP.md
* UI_UX_GUIDELINES.md
* DATABASE_SCHEMA.md
* API_SPECIFICATION.md
* DECISIONS_LOG.md

### Motivo

Evitar inconsistencias, retrabajo y decisiones improvisadas.

### Impacto

* Mejor planeación.
* Mejor arquitectura.
* Mejor mantenimiento.
* Mayor claridad para futuros colaboradores.

---

# Formato para Nuevas Decisiones

Usar esta estructura:

```md
## YYYY-MM-DD — Título de la Decisión

### Decisión

Descripción clara de la decisión tomada.

### Motivo

Razón principal por la cual se tomó la decisión.

### Impacto

- Área afectada 1.
- Área afectada 2.
- Área afectada 3.
```

---

# Nota

Este documento debe actualizarse cada vez que se tome una decisión importante que afecte producto, UX, base de datos, API, arquitectura, seguridad o roadmap.
