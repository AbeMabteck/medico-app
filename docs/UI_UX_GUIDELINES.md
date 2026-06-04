# UI_UX_GUIDELINES.md

# MedicoApp — Guía UI/UX

Versión del documento: 1.0

Última actualización: 2026-06-05

---

# Objetivo del Documento

Este documento define las reglas visuales y de experiencia de usuario para MedicoApp.

Su propósito es mantener una interfaz consistente, profesional, accesible y alineada con la visión del producto.

MedicoApp debe sentirse como un asistente personal de salud, no como un sistema hospitalario ni administrativo.

---

# Personalidad Visual

MedicoApp debe transmitir:

* Confianza.
* Salud.
* Organización.
* Tecnología.
* Simplicidad.
* Tranquilidad.

La aplicación debe ser moderna, pero sin perder claridad para usuarios adultos o personas con bajo nivel técnico.

---

# Principios UI/UX

## Simplicidad

La información importante debe mostrarse de forma clara y directa.

Las pantallas no deben saturarse con demasiados textos, botones o datos técnicos.

---

## Accesibilidad

La aplicación debe ser fácil de leer y usar.

Se deben considerar usuarios adultos mayores o personas poco familiarizadas con aplicaciones móviles.

---

## Claridad Visual

Cada tarjeta, botón o estado debe comunicar claramente su función.

No se debe depender únicamente del color para transmitir información importante.

---

## Consistencia

Los componentes visuales deben mantener el mismo estilo en toda la aplicación.

Botones, tarjetas, íconos, formularios y mensajes deben seguir una misma línea visual.

---

## Prevención

La interfaz debe ayudar al usuario a evitar errores, olvidos y confusiones.

Los estados importantes deben ser visibles desde el Dashboard.

---

# Temas Oficiales

MedicoApp contará con soporte para tema claro y tema oscuro.

## Configuración Recomendada

* Tema claro.
* Tema oscuro.
* Seguir sistema.

La opción recomendada por defecto será:

```text
Seguir sistema
```

---

# Tema Claro

El tema claro será el tema principal y recomendado para la mayoría de usuarios.

Debe transmitir limpieza, salud, tranquilidad y accesibilidad.

## Paleta de Colores

| Uso              | Color          | Hex     |
| ---------------- | -------------- | ------- |
| Primario         | Azul médico    | #2563EB |
| Secundario       | Verde salud    | #10B981 |
| Advertencia      | Ámbar          | #F59E0B |
| Error            | Rojo suave     | #EF4444 |
| Fondo principal  | Gris muy claro | #F8FAFC |
| Tarjetas         | Blanco         | #FFFFFF |
| Texto principal  | Gris oscuro    | #1F2937 |
| Texto secundario | Gris medio     | #6B7280 |
| Borde suave      | Gris claro     | #E5E7EB |

---

# Tema Oscuro

El tema oscuro será una alternativa visual premium y moderna.

Debe transmitir tecnología, elegancia y comodidad visual.

## Paleta de Colores

| Uso              | Color               | Hex     |
| ---------------- | ------------------- | ------- |
| Primario         | Azul brillante      | #3B82F6 |
| Secundario       | Verde esmeralda     | #10B981 |
| Advertencia      | Ámbar               | #F59E0B |
| Error            | Rojo suave          | #EF4444 |
| Fondo principal  | Azul grafito oscuro | #0F172A |
| Tarjetas         | Gris azulado oscuro | #1E293B |
| Texto principal  | Blanco suave        | #F8FAFC |
| Texto secundario | Gris azulado claro  | #CBD5E1 |
| Borde suave      | Gris oscuro         | #334155 |

---

# Tipografía

## Fuente Recomendada

```text
Inter
```

Motivos:

* Alta legibilidad.
* Apariencia moderna.
* Excelente comportamiento en pantallas móviles.
* Buena compatibilidad con interfaces profesionales.

---

## Jerarquía Tipográfica

| Elemento          | Tamaño recomendado | Peso     |
| ----------------- | -----------------: | -------- |
| Título principal  |               24px | Bold     |
| Título de sección |               20px | SemiBold |
| Título de tarjeta |               16px | SemiBold |
| Texto normal      |        14px - 16px | Regular  |
| Texto secundario  |        13px - 14px | Regular  |
| Botones           |        14px - 16px | SemiBold |

---

# Navegación Principal

La navegación oficial será inferior mediante Bottom Navigation Bar.

## Módulos Principales

```text
Inicio
Expediente
Inventario
Tratamientos
Perfil
```

---

## Descripción de Cada Módulo

### Inicio

Centro de control del usuario.

Debe mostrar la información médica más importante del día.

---

### Expediente

Agrupa la información médica del usuario.

Incluye:

* Consultas.
* Recetas.
* Estudios.
* Antecedentes médicos.

---

### Inventario

Controla los medicamentos disponibles.

Incluye:

* Stock actual.
* Stock bajo.
* Medicamentos vencidos.
* Medicamentos por vencer.

---

### Tratamientos

Gestiona tratamientos activos e históricos.

Incluye:

* Próximas tomas.
* Confirmar toma.
* Omitir toma.
* Cancelar tratamiento.

---

### Perfil

Gestiona información del usuario y configuración.

Incluye:

* Datos personales.
* Tema de la app.
* Preferencias.
* Cierre de sesión.

---

# Botón de Acción Principal

La aplicación utilizará un botón central de acción rápida.

## Icono

```text
+
```

## Comportamiento

Al presionarlo, deberá abrir un menú rápido con las acciones principales.

## Acciones

* Agregar consulta.
* Agregar receta.
* Agregar medicamento.
* Agregar tratamiento.
* Agregar estudio.

---

# Dashboard Oficial

El Dashboard será la pantalla más importante de MedicoApp.

Debe funcionar como centro de control del usuario.

---

## Objetivo del Dashboard

Mostrar de forma rápida:

* Próxima toma.
* Estado del inventario.
* Tratamientos activos.
* Próxima consulta.
* Recetas recientes.
* Estudios médicos.
* Recordatorios del día.

---

## Estructura Recomendada

```text
Saludo personalizado

Próxima toma

Resumen rápido:
- Inventario
- Consulta
- Tratamientos
- Recetas
- Estudios
- Recordatorios

Consejo o alerta relevante

Navegación inferior
```

---

## Ejemplo Conceptual

```text
Hola Abraham 👋

Próxima toma
Diclofenaco
08:00 PM

Inventario
2 medicamentos con stock bajo

Tratamientos
3 activos

Próxima consulta
15 Junio

Recordatorios
5 hoy
```

---

# Tarjetas

Las tarjetas serán el componente visual principal de MedicoApp.

## Reglas

* Bordes redondeados.
* Espaciado amplio.
* Íconos claros.
* Títulos legibles.
* Información secundaria breve.
* Estados visuales cuando aplique.

---

## Radio de Borde

```text
16px - 24px
```

---

## Elevación

En tema claro:

* Sombras suaves.
* Fondo blanco.

En tema oscuro:

* Sin sombras fuertes.
* Diferencia por contraste de superficie.

---

# Estados Visuales

## Inventario

| Estado        | Color | Uso                 |
| ------------- | ----- | ------------------- |
| Sin problemas | Verde | Stock suficiente    |
| Stock bajo    | Ámbar | Debe comprar pronto |
| Agotado       | Rojo  | No hay medicamento  |
| Por vencer    | Ámbar | Caducidad próxima   |
| Vencido       | Rojo  | No debe usarse      |

---

## Tratamientos

| Estado     | Color | Uso                    |
| ---------- | ----- | ---------------------- |
| Activo     | Verde | Tratamiento en curso   |
| Pendiente  | Ámbar | Toma pendiente         |
| Completado | Azul  | Tratamiento finalizado |
| Omitido    | Gris  | Toma no realizada      |
| Cancelado  | Rojo  | Tratamiento cancelado  |

---

# Iconografía

Los íconos deben ser simples, reconocibles y consistentes.

## Recomendaciones

* Usar íconos lineales o semi-rellenos.
* Evitar íconos demasiado detallados.
* Mantener el mismo estilo en toda la aplicación.

## Íconos sugeridos

| Módulo         | Icono conceptual      |
| -------------- | --------------------- |
| Inicio         | Casa                  |
| Expediente     | Carpeta               |
| Inventario     | Pastilla              |
| Tratamientos   | Reloj / Alarma        |
| Perfil         | Usuario               |
| Recetas        | Documento médico      |
| Estudios       | Archivo / Microscopio |
| Notificaciones | Campana               |

---

# Formularios

Los formularios deben ser simples y claros.

## Reglas

* Evitar formularios demasiado largos.
* Agrupar campos relacionados.
* Mostrar validaciones claras.
* Usar labels visibles.
* No depender solo del placeholder.

---

## Campos

Los inputs deben tener:

* Bordes suaves.
* Altura mínima cómoda.
* Texto legible.
* Espaciado suficiente.

---

# Botones

## Botón Primario

Uso:

* Guardar.
* Confirmar.
* Crear.
* Continuar.

Color:

```text
Azul primario
```

---

## Botón Secundario

Uso:

* Cancelar.
* Volver.
* Acciones alternativas.

---

## Botón Destructivo

Uso:

* Eliminar.
* Cancelar tratamiento.
* Cerrar sesión.

Color:

```text
Rojo suave
```

---

# Mensajes y Alertas

Los mensajes deben ser humanos, claros y breves.

## Ejemplos

Correcto:

```text
Tu tratamiento fue guardado correctamente.
```

Evitar:

```text
Operación ejecutada con éxito.
```

Correcto:

```text
Este medicamento está agotado.
```

Evitar:

```text
Stock inválido.
```

---

# Accesibilidad

## Reglas mínimas

* Texto mínimo recomendado: 14px.
* Botones mínimos: 48px de alto.
* Contraste suficiente.
* No depender únicamente del color.
* Íconos acompañados de texto cuando sea necesario.
* Evitar textos médicos complejos cuando se pueda usar lenguaje sencillo.

---

# Modo Oscuro

El modo oscuro no debe ser solo una inversión de colores.

Debe diseñarse como una experiencia propia.

## Reglas

* Usar fondos oscuros suaves.
* Evitar negro puro absoluto en todas las superficies.
* Mantener buen contraste.
* Reducir sombras.
* Usar bordes o diferencias de superficie.

---

# Animaciones

Las animaciones deben ser sutiles.

## Usos recomendados

* Splash Screen.
* Carga de datos.
* Confirmación de toma.
* Estados vacíos.
* Transiciones suaves.

## Evitar

* Animaciones largas.
* Efectos que retrasen tareas.
* Movimiento excesivo.

---

# Estados Vacíos

Cada módulo debe tener un estado vacío claro.

## Ejemplos

### Sin tratamientos

```text
Aún no tienes tratamientos activos.
Agrega uno para recibir recordatorios.
```

### Sin inventario

```text
Aún no tienes medicamentos registrados.
Agrega tus medicamentos para controlar tu stock.
```

### Sin consultas

```text
Aún no has registrado consultas.
Guarda tus visitas médicas para construir tu expediente.
```

---

# Referencia Visual Oficial

La dirección visual aprobada para MedicoApp combina:

* Tema claro amigable y accesible.
* Tema oscuro moderno y premium.
* Tarjetas redondeadas.
* Navegación inferior.
* Botón central de acción rápida.
* Estados visuales por color.
* Dashboard como centro de control.

---

# Decisiones UI/UX Aprobadas

## Navegación

Se utilizará:

```text
Inicio
Expediente
Inventario
Tratamientos
Perfil
```

En lugar de:

```text
Inicio
Historial
Inventario
Tratamientos
Perfil
```

Motivo:

"Expediente" representa mejor el conjunto de consultas, recetas, estudios y antecedentes médicos.

---

## Tema Predeterminado

La app deberá soportar:

* Claro.
* Oscuro.
* Seguir sistema.

Configuración recomendada:

```text
Seguir sistema
```

---

# Regla General

Cada nueva pantalla debe responder:

```text
¿Esta interfaz ayuda al usuario a entender y gestionar su salud de forma simple, clara y confiable?
```

Si la respuesta es no, el diseño debe revisarse.
