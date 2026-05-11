# shirOS

Sistema operativo Linux corporativo liviano y rápido, basado en **Debian 12** + **XFCE**. Pensado para empresas argentinas con hardware mixto y usuarios no técnicos.

> Nombrado en homenaje a Shir, un gato gris y blanco.

## Características

- **Liviano**: idle ~600 MB RAM, boot < 20s.
- **Simple**: UI familiar Windows-like, sin configuración técnica necesaria.
- **Compatible**: detecta automáticamente impresoras, monitores externos, WiFi.
- **Instalación guiada**: wizard de 5 pasos con dual-boot o instalación nativa.
- **Visual característica**: paleta gris/blanco, tipografía Inter, plymouth y greeter custom.

## Stack

| Capa | Componente |
|---|---|
| Base | Debian 12 (Bookworm) stable |
| Escritorio | XFCE 4.18 |
| Display server | X11 |
| Audio | PipeWire |
| Display manager | LightDM |
| Installer | Calamares |
| Build tool | live-build |

Ver [`PLAN.md`](./PLAN.md) para el plan maestro completo y [`docs/`](./docs/) para detalles.

## Estructura del repo

```
shirOS/
├── PLAN.md              # Plan maestro
├── ARCHITECTURE.md      # Detalle técnico
├── docs/                # Documentación end-user y branding
├── build/               # Configuración live-build
├── branding/            # Assets visuales (logo, wallpaper, themes)
├── installer/           # Configuración Calamares
└── scripts/             # Build, test e instalación
```

## Build local

Requisitos: Debian 12 / Ubuntu 24.04 host con `live-build` instalado.

```bash
sudo apt install live-build live-config live-boot
./scripts/build-iso.sh
```

La ISO resultante queda en `build/shiros-<version>-amd64.iso`.

## Test en QEMU

```bash
./scripts/test-iso-qemu.sh build/shiros-*.iso
```

## Estado

Pre-alpha. Ver [`PLAN.md` §10 Roadmap](./PLAN.md#10-roadmap).

## Licencia

GPLv3 para el sistema, MIT para scripts custom. Ver [`LICENSE`](./LICENSE).
