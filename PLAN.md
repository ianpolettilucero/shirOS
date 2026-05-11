# shirOS — Plan Maestro

> Sistema operativo Linux corporativo liviano, enfocado en simplicidad, velocidad y compatibilidad. Pensado para el mercado argentino: PCs corporativas con hardware mixto (low-end a moderno), usuarios no técnicos, equipos de ventas.

## 1. Visión

**Problema:** Vendedores y empleados corporativos en Argentina pierden tiempo peleando con PCs lentas y software complejo. Windows con bloatware, antivirus pesados y actualizaciones forzadas degradan la experiencia.

**Solución:** Un Linux corporativo, simple, rápido y predecible, con:
- Boot en menos de 20s incluso en HDD.
- UI familiar (panel inferior, menú estilo Windows).
- Apps web por defecto (Google Workspace / Microsoft 365) — sin instalar suites pesadas.
- Detección automática de impresoras, monitores externos y periféricos USB.
- Instalación guiada con wizard de 5 pasos (similar a Windows).
- Tema visual característico (paleta gris/blanco, en homenaje al gato Shir).

## 2. Decisiones técnicas (confirmadas)

| Componente | Elección | Justificación |
|---|---|---|
| **Base** | Debian 12 (Bookworm) stable | Estable, FOSS, sin telemetría, base sólida para derivar. |
| **Init** | systemd | Estándar Debian, mejor soporte y diagnóstico. |
| **Escritorio** | XFCE 4.18 | ~400MB RAM, ultra customizable, look familiar Windows-like. |
| **Display server** | X11 (Xorg) | Mejor compat con drivers viejos y multi-monitor heterogéneo. Wayland queda para v2. |
| **Compositor** | xfwm4 (built-in) | Liviano, soporta tearing-free básico. |
| **Display manager** | LightDM + lightdm-gtk-greeter | Liviano, branding fácil. |
| **Audio** | PipeWire (con compat PulseAudio/JACK) | Modern, mejor latencia, drop-in replacement. |
| **Red** | NetworkManager + nm-applet | Estándar corporativo, soporta VPN. |
| **Impresión** | CUPS + system-config-printer + driverless | Auto-detección de impresoras de red. |
| **Bluetooth** | BlueZ + blueman | Estable. |
| **Instalador** | Calamares | Wizard moderno, soporta dual-boot, usado por Manjaro/Mint/KDE Neon. |
| **Build tool** | live-build (Debian oficial) | Estándar para derivar Debian, reproducible. |
| **Hardware target** | Mix amplio (2GB RAM mínimo, 8GB+ recomendado) | Single ISO que detecta y se adapta. |
| **Suite oficina** | Web (Google Docs / Office 365) vía PWA | Reduce peso, evita problemas de compat .docx. |

## 3. Decisiones pendientes (para confirmar)

Estas no bloquean el scaffold inicial pero sí afectan paquetes finales:

1. **Browser default**: ¿Firefox ESR (corporate-stable, FOSS), Brave (privacy+Chromium compat) o ambos preinstalados?
2. **Gestión remota IT**: ¿RustDesk preinstalado para que el soporte IT pueda asistir remotamente? (Recomendado.)
3. **Apps de comunicación**: ¿Preinstalar wrappers PWA de Teams/WhatsApp/Slack o que el usuario los instale on-demand?
4. **VPN corporativo**: ¿Incluir openconnect (Cisco AnyConnect compat), wireguard y openvpn por default?
5. **Antivirus**: ¿ClamAV scheduled scan o nada? Linux normalmente no lo necesita pero el corporativo lo suele exigir.
6. **Política de updates**: ¿Auto-instalar security updates (recomendado) o sólo notificar?
7. **Telemetría/diagnóstico**: ¿Algún mecanismo opt-in para que el equipo central reciba reportes de fallos? Privacy-first por default.

## 4. Identidad visual

**Origen del nombre:** Shir es el gato gris y blanco del fundador. La paleta refleja esa estética felina/minimalista.

| Elemento | Valor |
|---|---|
| **Paleta primaria** | `#F5F5F5` (blanco hueso), `#9CA3AF` (gris medio), `#374151` (gris oscuro) |
| **Acento** | `#3B82F6` (azul confianza corporativo) |
| **Tipografía sistema** | Inter / sin Inter, Cantarell |
| **Tipografía mono** | JetBrains Mono |
| **Logo** | Silueta minimalista de gato + wordmark "shirOS" |
| **Wallpaper default** | Gradiente gris suave con patrón geométrico |
| **GTK theme** | Custom basado en Arc-Lighter |
| **Icon theme** | Papirus modificado con tints grises |
| **Plymouth (boot)** | Logo monocromo + spinner minimal |
| **Cursor** | Capitaine Cursors |

## 5. Stack de aplicaciones

### Core (siempre preinstalado)
- `firefox-esr` — browser principal
- `thunderbird` — email (corporativo, soporta Exchange con add-on)
- `thunar` — file manager (XFCE)
- `mousepad` — text editor
- `xfce4-terminal` — terminal
- `xarchiver` — compresión
- `gnome-disk-utility` — manejo de discos
- `system-config-printer` — printers GUI
- `arandr` — multi-monitor GUI
- `blueman` — bluetooth GUI
- `pavucontrol` — volume mixer
- `gnome-screenshot` — screenshots
- `xfce4-screensaver`
- `network-manager-gnome` — wifi/VPN GUI
- `flatpak` + `plugin-xfce4-flatpak` — para instalar apps adicionales

### Apps corporativas (vía Flatpak post-install)
- `com.microsoft.Edge` (alternativa cuando Teams web no anda en Firefox)
- `com.google.Chrome`
- `us.zoom.Zoom`
- `com.slack.Slack`
- `com.anydesk.AnyDesk` / `com.rustdesk.RustDesk`
- `org.onlyoffice.desktopeditors` (si el usuario lo pide)

### Drivers / firmware
- `firmware-linux` + `firmware-linux-nonfree`
- `firmware-iwlwifi`, `firmware-realtek`, `firmware-atheros`, `firmware-brcm80211`
- `firmware-misc-nonfree`
- `intel-microcode`, `amd64-microcode`
- `mesa-utils`, `vulkan-tools`
- `printer-driver-all` (meta-package, todas las impresoras genéricas)
- `hplip` (HP, muy común en corporativo argentino)
- `sane`, `sane-utils` (escáneres)

### Utilidades sistema
- `htop`, `iotop`, `ncdu`
- `gparted`
- `gnome-disk-utility`
- `synaptic` (opcional, para usuarios avanzados)
- `gnome-software` o `plasma-discover` — store gráfico
- `gufw` — firewall GUI

### Fuentes
- `fonts-inter`
- `fonts-jetbrains-mono`
- `fonts-noto`, `fonts-noto-color-emoji`
- `ttf-mscorefonts-installer` (Arial, Times, Verdana — para compat docx)

## 6. Arquitectura del repo

```
shirOS/
├── README.md                  # Quick start
├── PLAN.md                    # Este documento
├── ARCHITECTURE.md            # Detalle técnico de build/deploy
├── docs/
│   ├── installation.md        # Guía de instalación end-user
│   ├── branding-guide.md      # Reglas de uso de marca
│   ├── target-hardware.md     # Requisitos y compat hardware
│   └── decisions/             # ADRs (Architecture Decision Records)
├── build/                     # live-build configuration
│   ├── auto/
│   │   ├── config             # lb config wrapper
│   │   ├── build              # lb build wrapper
│   │   └── clean              # lb clean wrapper
│   └── config/
│       ├── package-lists/     # Paquetes por categoría
│       ├── hooks/normal/      # Scripts que corren en chroot
│       ├── includes.chroot/   # Files overlay sobre la ISO
│       ├── includes.binary/   # Files del bootloader
│       ├── archives/          # APT sources extra
│       └── bootloaders/       # Branding GRUB/syslinux
├── branding/
│   ├── logo/                  # SVG en variantes
│   ├── wallpapers/
│   ├── plymouth/              # Boot animation
│   ├── gtk-theme/             # Tema GTK custom
│   ├── icon-theme/
│   └── lightdm/               # Greeter background
├── installer/                 # Configuración Calamares
│   ├── settings.conf
│   ├── modules/
│   └── branding/shiros/
├── scripts/
│   ├── build-iso.sh           # Wrapper top-level para build
│   ├── test-iso-qemu.sh       # Lanza la ISO en QEMU
│   ├── post-install/          # Scripts del wizard de bienvenida
│   └── ci/
└── .gitignore
```

## 7. Flujo de instalación (UX)

```
[ Boot desde USB ]
        │
        ▼
[ GRUB shirOS: Live | Install | Memtest ]
        │
        ▼ (default: Live)
[ Live session XFCE arranca en ~15s ]
        │
        ▼
[ Welcome dialog: "Probar shirOS" / "Instalar shirOS" ]
        │
        ▼ (Instalar)
[ Calamares wizard — 5 pasos ]
  1. Idioma (default: Español Argentina)
  2. Región/zona horaria (default: America/Argentina/Buenos_Aires)
  3. Teclado (default: Latin American)
  4. Disco:
     ┌─ Borrar todo e instalar shirOS
     ├─ Instalar al lado de [Windows/macOS] detectado (DUAL-BOOT)
     ├─ Reemplazar partición existente
     └─ Manual (avanzado)
  5. Usuario y contraseña
        │
        ▼
[ Resumen + Confirmar ]
        │
        ▼
[ Instalación (~5-10 min) con slideshow de tips ]
        │
        ▼
[ Reboot → shirOS instalado ]
        │
        ▼
[ Primer boot: shirOS Welcome ]
  - Conectar a WiFi
  - Activar privacy mode
  - Instalar apps adicionales (Chrome, Zoom, Slack, etc.)
  - Quick tour de la UI
```

## 8. Auto-detección de periféricos

| Periférico | Mecanismo |
|---|---|
| **Monitor externo (HDMI/DP/VGA)** | `udev rule` + script `shiros-monitor-autosetup` que ejecuta `xrandr --auto` y aplica preferencia guardada (extender/clonar). |
| **Impresora USB** | CUPS + `cups-browsed` para descubrimiento automático IPP. |
| **Impresora de red** | `avahi-daemon` + IPP Everywhere (driverless). |
| **WiFi** | NetworkManager con firmware nonfree precargado. |
| **Bluetooth** | BlueZ + `bluetooth.service` enabled. |
| **Webcam / micrófono** | `v4l2` + PipeWire. |
| **Mouse / teclado USB** | Hotplug nativo del kernel. |
| **Pendrive** | `gvfs` + Thunar volume monitor + auto-mount en `/media/$USER/`. |
| **Touchpad** | `libinput` con perfiles por vendor. |
| **Scanner** | SANE + `simple-scan`. |

## 9. Multi-monitor (foco crítico)

El target corporativo usa frecuentemente 2 monitores (notebook + monitor externo en escritorios de ventas).

**Estrategia:**
1. Al boot, `shiros-monitor-autosetup` detecta displays activos vía `xrandr`.
2. Si hay un display externo + interno: por default extender hacia la derecha.
3. Guardar la preferencia del usuario por combinación de monitores (hash de EDIDs) en `~/.config/shiros/displays.json`.
4. Al hot-plug (udev rule), re-aplicar la preferencia guardada o aplicar default.
5. UI gráfica: `arandr` accesible desde un atajo del panel "Configurar pantallas".
6. Atajo de teclado `Super+P` → menú rápido Duplicar / Extender / Solo interno / Solo externo (similar a Win+P).

## 10. Roadmap

### Fase 1 — Scaffold (semana 1)
- [x] Decisiones técnicas
- [ ] Estructura de repo
- [ ] live-build config funcional
- [ ] Package lists
- [ ] Build de ISO mínima booteable
- [ ] Test en QEMU

### Fase 2 — Branding (semana 2)
- [ ] Logo SVG final
- [ ] Wallpaper default
- [ ] GTK theme custom
- [ ] Plymouth boot animation
- [ ] GRUB theme
- [ ] LightDM greeter custom

### Fase 3 — Instalador (semana 3)
- [ ] Calamares branding
- [ ] Configuración módulos (dual-boot, partition, users)
- [ ] Slideshow de instalación
- [ ] Test instalación nativo + dual-boot

### Fase 4 — UX corporativa (semana 4)
- [ ] Welcome wizard (primer boot)
- [ ] Multi-monitor autosetup
- [ ] Default apps + PWAs configuradas
- [ ] Wallpaper, fondo greeter, plymouth animados
- [ ] Documentación end-user

### Fase 5 — Testing & release (semana 5)
- [ ] Test en hardware real (3+ modelos: notebook viejo, desktop moderno, all-in-one)
- [ ] Test instalación dual-boot Windows 10/11
- [ ] Test impresoras HP/Epson/Brother comunes en AR
- [ ] CI automated builds
- [ ] Release v0.1.0 "Shir"

### Fase 6+ (futuro)
- Wayland (XFCE 4.20+)
- Wrapper de gestión flota (LDAP/AD opcional)
- ISO offline-installer (sin internet)
- ARM build (para netbooks/Chromebooks reciclados)

## 11. Criterios de éxito v1.0

- ✅ ISO de < 2.5 GB
- ✅ Boot live USB → escritorio usable en < 30s
- ✅ Boot instalado → login en < 20s (SSD) / < 45s (HDD)
- ✅ Idle RAM < 700 MB
- ✅ Instalación end-to-end en < 15 min
- ✅ Detecta el 95% de hardware corporativo común en AR
- ✅ Detecta y configura segundo monitor automáticamente
- ✅ Dual-boot con Windows funciona sin romper el bootloader original
- ✅ Usuario no técnico puede instalar sin asistencia

## 12. Riesgos y mitigaciones

| Riesgo | Mitigación |
|---|---|
| Firmware WiFi falta en hardware específico | Incluir `firmware-linux-nonfree` completo en la ISO. |
| Drivers GPU NVIDIA en notebooks | Detector post-install ofrece instalar `nvidia-driver` automáticamente. |
| Dual-boot rompe Windows | Calamares preserva el ESP y agrega entry GRUB sin reescribir el MBR de Windows. |
| Compat .docx web pierde formato | Documentar en welcome wizard que se puede instalar OnlyOffice. |
| Usuarios no encuentran apps | Welcome wizard incluye "App store" visual con un click. |
| Updates rompen el sistema | Snapshots con `timeshift` automáticos pre-update. |
| Argentina: internet inestable | APT cache local opcional + Flatpak con `--offline`. |

## 13. Distribución y soporte

- **Sitio**: shiros.com.ar (a registrar)
- **Repo público**: github.com/ianpolettilucero/shiros
- **Canal de releases**: GitHub Releases con ISO + checksums + signing
- **Soporte**: Discord/Telegram comunitario + Issues en GitHub
- **Modelo**: 100% FOSS bajo GPLv3 (o MIT para scripts custom)
