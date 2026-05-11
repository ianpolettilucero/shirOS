# Hardware Target — shirOS

## Filosofía

shirOS apunta a **PCs corporativas argentinas con hardware mixto**. La ISO es única; el sistema se adapta al hardware detectado al arranque.

## Tier 1 — Soporte garantizado

Hardware que probamos y certificamos antes de cada release.

### Notebooks

| Modelo | Notas |
|---|---|
| Lenovo ThinkPad T-series (T440, T450, T460, T470, T480) | Workhorse corporativo en AR. WiFi Intel + Ethernet. |
| Lenovo IdeaPad 3 / 5 | Familia común retail. |
| Dell Latitude (E5xxx, E6xxx, 7xxx) | Frecuente en empresas. |
| Dell Vostro 14/15 | Económicos, comunes. |
| HP ProBook 4xx / 6xx | Comunes en bancos y aseguradoras. |
| HP EliteBook | Hardware más caro pero soporte completo. |

### Desktops / All-in-one

| Modelo | Notas |
|---|---|
| Dell OptiPlex (3xxx, 5xxx, 7xxx) | Workstations comunes. |
| HP ProDesk / EliteDesk | Frecuentes en oficinas. |
| Lenovo ThinkCentre M-series | |
| All-in-one HP / Lenovo | Pantalla integrada — testear extender a externo. |

### Genéricos / Clones

PCs armadas con:
- CPU: Intel i3/i5/i7 (gen 4 a gen 12) o AMD Ryzen 3/5/7
- GPU: integrada (Intel HD, UHD, Iris, Iris Xe, AMD Vega, Radeon)
- RAM: DDR3/DDR4, 4-16 GB
- Storage: HDD SATA, SSD SATA, NVMe

## Tier 2 — Debería funcionar (no garantizado)

- GPUs NVIDIA: drivers nouveau OK para uso básico. NVIDIA propietario instalable post-install.
- WiFi raro: si falla, instalar firmware específico via `apt`.
- Bluetooth raro: BlueZ cubre la mayoría.
- Webcams USB: UVC estándar (la mayoría).

## Tier 3 — Mejor esfuerzo

- Hardware muy nuevo (chips < 6 meses): puede requerir kernel backport.
- Hardware muy viejo (< 2010): puede no tener drivers nonfree.
- Tarjetas WiFi raras (Broadcom viejas, Realtek 88x2bu, etc.): requieren dkms.

## Lo que NO soportamos

- ARM (Raspberry Pi, Chromebooks ARM) — roadmap futuro.
- POWER, RISC-V.
- Apple Silicon (M1/M2/M3): roadmap muy futuro vía Asahi.
- Hardware con TPM mandatorio (algunas notebooks corporate Win11) — funciona pero el TPM no se usa.

## Requisitos por tier de configuración

| Configuración | RAM | Disco | CPU | Storage |
|---|---|---|---|---|
| **Mínima** (sólo browser) | 2 GB | 12 GB | Cualquier x86_64 dual-core | HDD OK |
| **Recomendada** | 4 GB | 32 GB | Quad-core 2015+ | SSD |
| **Cómoda** | 8 GB+ | 64 GB+ | Quad-core 2018+ | NVMe |

## Detección y adaptación automática

shirOS detecta y adapta:

- **CPU sin SSE4.2** → desactiva animaciones de XFCE.
- **GPU sin aceleración** → llxc software rendering, sin Plymouth animado.
- **HDD detectado** → desactiva preload, ajusta cache de I/O.
- **< 4 GB RAM** → desactiva indexer de archivos, reduce swap.
- **WiFi con firmware faltante** → notifica al usuario con instrucciones.
- **NVIDIA GPU detectada** → muestra dialog para instalar driver propietario.

## Periféricos probados

### Impresoras

| Marca | Modelo común en AR | Soporte |
|---|---|---|
| HP   | LaserJet 1020, P1102, M1132, M125 | ✓ HPLIP |
| HP   | DeskJet 2050, 2375, Ink Tank | ✓ |
| Epson| L3110, L4150, L5190, L120, L380 | ✓ |
| Canon| PIXMA G2010, G3010, MG2510 | ✓ |
| Brother | DCP-1602, HL-1212W | ✓ |
| Samsung | M2020, ML-1610 | ✓ |
| Xerox | Workcentre 3045 | ✓ |
| Ricoh | SP-200, SP-220 | ✓ via driverless |

### Monitores

Cualquier monitor con HDMI, DisplayPort o VGA detectado automáticamente via EDID.

Resoluciones probadas:
- 1366x768 (notebooks viejas)
- 1920x1080 (estándar AR)
- 2560x1440 (workstations)
- 3840x2160 (4K)

Multi-monitor: detección automática hot-plug (ver `shiros-monitor-autosetup`).

### Periféricos USB

- Mouse / teclados: hotplug nativo del kernel.
- Pendrives: auto-mount en `/media/$USER/`.
- USB-to-Ethernet: drivers comunes incluidos.
- Webcams UVC: PipeWire + `cheese`.
- Headsets USB / Jabra / Logitech: auto-detect.
- Lectores RFID / chip card (DNI argentino): driver pcsc-tools (opcional).

### Bluetooth

Audio Bluetooth: PipeWire + bluez. Probado con:
- Auriculares JBL, Sony, Edifier
- Speakers JBL Flip, Charge
- Mouse y teclado Bluetooth

## Wifi específico en Argentina

WiFi chipsets comunes en notebooks corporate AR (todos OK con firmware incluido):

- Intel Wireless 7260, 8260, 8265, 9560, AX200, AX201, AX211
- Realtek RTL8723BE, RTL8821CE, RTL8852AE
- Atheros AR9485, AR9462
- Broadcom BCM4313, BCM4352 (requiere `firmware-b43-installer`)

## Reportá hardware nuevo

Si shirOS no funciona perfecto en tu hardware, abrí un issue en GitHub con:

```
sudo lshw -short
inxi -Fxxxz
lspci -knn
lsusb
```
