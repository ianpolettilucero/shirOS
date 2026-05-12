# shirOS — Guía de Branding

## Origen del nombre

**Shir** es el gato gris y blanco del fundador. La identidad visual del sistema operativo se inspira en su pelaje (gris medio, blanco hueso, detalles oscuros).

## Paleta

| Token | Hex | Uso |
|---|---|---|
| `gray-50`  | `#F9FAFB` | Background principal claro |
| `gray-100` | `#F5F5F7` | Background secundario |
| `gray-200` | `#E5E7EB` | Borders, divisores |
| `gray-300` | `#D1D5DB` | Disabled |
| `gray-400` | `#9CA3AF` | **Gris Shir** — color "marca" del gato |
| `gray-700` | `#374151` | Texto secundario, silueta gato |
| `gray-900` | `#1F2937` | Texto principal, dark background |
| `blue-500` | `#3B82F6` | **Acento corporativo** — botones, links, "OS" del wordmark |
| `blue-100` | `#DBEAFE` | Backgrounds suaves de acento |
| `green-500`| `#10B981` | Success / online |
| `red-500`  | `#EF4444` | Error / destructive |
| `amber-500`| `#F59E0B` | Warning |

**Regla de oro:** 90% grises, 10% azul. El azul es para llamar la atención. Si todo es azul, nada lo es.

## Tipografía

| Rol | Familia | Notas |
|---|---|---|
| Sistema UI | **Inter** | Variable weight 400/500/600/700 |
| Monoespaciada | **JetBrains Mono** | Terminal, código |
| Fallback | Cantarell, Helvetica Neue, Arial | Si Inter no carga |

**Tamaños base:**
- UI body: 10pt (XFCE default), 14px (web)
- Títulos: 1.5x body
- Caption: 0.85x body

## Logo

### Variantes

| Archivo | Uso |
|---|---|
| [`branding/logo/shiros-logo.svg`](../branding/logo/shiros-logo.svg) | Logo completo (gato + wordmark a color). Para hero, headers, splash. |
| [`branding/logo/shiros-icon.svg`](../branding/logo/shiros-icon.svg) | Solo icono cuadrado (gato dentro de círculo). Para favicons, app icons, social. |
| [`branding/logo/shiros-mono.svg`](../branding/logo/shiros-mono.svg) | Monocromo `currentColor`. Para print, plymouth, places donde no hay color. |

### Reglas de uso

- **Espacio libre mínimo**: 1x la altura del icono alrededor del logo.
- **Tamaño mínimo**: 48px de ancho (icono) / 120px (logo completo).
- **No deformar**: mantener ratio.
- **No re-colorear**: usar `shiros-mono.svg` con `currentColor` si necesitás un solo color.
- **No agregar sombra, glow, gradiente** al logo.

### Anatomía del logo completo

```
┌─────────────────────────────────────────────┐
│   /\___/\                                    │
│  (  ^.^  )    shirOS                         │
│   \  =  /     ────────                       │
│    └─┘                                       │
└─────────────────────────────────────────────┘
  Cat icon       Wordmark
  gray-700       gray-900 + blue-500 ("OS")
```

## Wallpaper

| Archivo | Uso |
|---|---|
| [`branding/wallpapers/shiros-default.svg`](../branding/wallpapers/shiros-default.svg) | Wallpaper sesión usuario. Claro, gradiente gris, silueta sutil del gato. |
| [`branding/wallpapers/shiros-greeter.svg`](../branding/wallpapers/shiros-greeter.svg) | Wallpaper login screen. Oscuro, glow azul, para contraste con formulario. |

## Iconos sistema

- **Icon theme base**: Papirus (sin modificar por ahora).
- **Cursor theme**: Adwaita 24px.
- **Roadmap v0.2**: crear `shiros-icon-theme` extendiendo Papirus con tints grises.

## Sonidos

- **Login/logout**: silencio.
- **Notificaciones**: tema `freedesktop` (sutil).
- **Boot**: silencio (no startup sound).

Filosofía: el sistema debe ser visualmente presente pero **silencioso**. Es para escritorios corporativos compartidos.

## Tono de voz (UI copy)

- **Idioma**: Español (Argentina). Voseo OK ("instalá", "configurá").
- **Concreto**: "Conectá WiFi" mejor que "Por favor, conéctese a una red inalámbrica".
- **Cálido pero profesional**: "¡Bienvenido!" sí; "Hola amigo 👋" no.
- **Sin tecnicismos innecesarios**: "Pantallas" en vez de "monitores externos", "Archivos" en vez de "file manager".
- **Errores**: explicar qué pasó + qué hacer. "No se pudo conectar al WiFi. Verificá que el adaptador esté encendido."

## Plymouth (boot animation)

Diseño v1 (placeholder — implementar en Fase 2):
- Background: gradient gray oscuro (igual al greeter).
- Centro: logo `shiros-mono.svg` blanco.
- Spinner: 3 puntos pulsando debajo del logo.
- Sin texto del kernel salvo en modo failsafe.

## GRUB theme

Diseño v1:
- Background: gradient gris oscuro.
- Menú: caja con borde gris, items con hover azul.
- Logo `shiros-logo.svg` en top-center.

## Calamares branding

Ver [`installer/branding/shiros/branding.desc`](../installer/branding/shiros/branding.desc).
