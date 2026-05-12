# shirOS — Arquitectura Técnica

Documento de referencia para desarrolladores. Para visión y plan general ver [`PLAN.md`](./PLAN.md).

## 1. Pipeline de build

```
┌──────────────────────────────────────────────────────────────┐
│  scripts/build-iso.sh                                         │
│                                                               │
│  1. Verifica deps (live-build, debootstrap, xorriso)          │
│  2. cd build/                                                 │
│  3. lb clean                                                  │
│  4. lb config       ◄── lee auto/config                       │
│  5. lb build        ◄── corre debootstrap + chroot + xorriso  │
│  6. Mueve ISO a build/shiros-<version>-amd64.iso              │
│  7. Genera SHA256                                              │
└──────────────────────────────────────────────────────────────┘
```

## 2. Cómo live-build arma la ISO

`live-build` ensambla la ISO en 3 fases:

1. **bootstrap**: corre `debootstrap` para crear un rootfs mínimo Debian en `chroot/`.
2. **chroot**: dentro del rootfs, instala los paquetes de `config/package-lists/*.list.chroot`, corre los hooks de `config/hooks/normal/*.hook.chroot` y copia el overlay de `config/includes.chroot/`.
3. **binary**: arma el ISO9660 booteable con `xorriso`, copia `config/includes.binary/`, instala GRUB EFI + legacy.

## 3. Estructura `build/`

```
build/
├── auto/
│   ├── config    # wrapper sobre `lb config` (define los flags principales)
│   ├── build     # wrapper sobre `lb build`
│   └── clean     # wrapper sobre `lb clean`
└── config/
    ├── package-lists/
    │   ├── shiros-core.list.chroot        # base CLI + system tools
    │   ├── shiros-desktop.list.chroot     # XFCE + display stack
    │   ├── shiros-apps.list.chroot        # browser, mail, utilities
    │   ├── shiros-drivers.list.chroot     # firmware, microcode, printers
    │   ├── shiros-fonts.list.chroot       # tipografías
    │   └── shiros-installer.list.chroot   # Calamares
    ├── hooks/normal/
    │   ├── 0010-enable-services.hook.chroot
    │   ├── 0020-apply-branding.hook.chroot
    │   ├── 0030-shiros-defaults.hook.chroot
    │   └── 0040-cleanup.hook.chroot
    ├── includes.chroot/                   # overlay sobre rootfs
    │   ├── etc/
    │   │   ├── os-release
    │   │   ├── lightdm/
    │   │   ├── calamares/
    │   │   ├── skel/.config/xfce4/...
    │   │   └── udev/rules.d/
    │   └── usr/
    │       ├── bin/
    │       │   ├── shiros-welcome
    │       │   ├── shiros-monitor-autosetup
    │       │   └── shiros-display-quickmenu
    │       └── share/
    │           ├── backgrounds/shiros/
    │           ├── plymouth/themes/shiros/
    │           └── applications/
    ├── includes.binary/                   # overlay sobre la ISO
    │   └── isolinux/
    └── bootloaders/                       # branding GRUB
```

## 4. Hooks (chroot)

Los hooks corren dentro del chroot post-instalación de paquetes. Convención de naming: `NNNN-nombre.hook.chroot` (numerado para orden de ejecución).

| Hook | Función |
|---|---|
| `0010-enable-services` | `systemctl enable lightdm bluetooth cups NetworkManager avahi-daemon` |
| `0020-apply-branding` | Copia themes GTK/icons, registra Plymouth theme, configura GRUB theme |
| `0030-shiros-defaults` | Setea defaults de XFCE (panel, wallpaper), configura PipeWire, locale |
| `0040-cleanup` | Limpia `apt-cache`, logs, archivos temporales para reducir tamaño ISO |

## 5. Calamares — flujo de instalación

```
welcome → locale → keyboard → partition → users → summary → install → finished
```

Configurado en `installer/settings.conf` → empaquetado como `/etc/calamares/settings.conf` en la ISO.

Módulos críticos:
- `partition`: ofrece auto-partition (full disk) o **manual** + detecta Windows para dual-boot.
- `bootloader`: instala GRUB sin tocar el bootloader Windows existente.
- `users`: crea cuenta + opciones autologin / sudo.
- `finished`: ofrece reboot post-install.

Branding en `installer/branding/shiros/`:
- `branding.desc`: define textos, colores, logo.
- `show.qml`: slideshow durante install (tips, screenshots).
- `*.png`: logo, banner.

## 6. Boot — flujo

```
┌──────────────┐    ┌──────────────┐    ┌────────────────────┐
│ BIOS / UEFI  │ → │ GRUB shirOS  │ → │ Linux kernel + init │
└──────────────┘    └──────────────┘    └────────────────────┘
                                                 │
                                                 ▼
                                       ┌──────────────────────┐
                                       │ Plymouth splash       │
                                       │ (shirOS logo)         │
                                       └──────────────────────┘
                                                 │
                                                 ▼
                                       ┌──────────────────────┐
                                       │ systemd → multi-user  │
                                       └──────────────────────┘
                                                 │
                                                 ▼
                                       ┌──────────────────────┐
                                       │ lightdm greeter       │
                                       └──────────────────────┘
                                                 │
                                                 ▼
                                       ┌──────────────────────┐
                                       │ XFCE session          │
                                       │  + autostart:         │
                                       │    - nm-applet        │
                                       │    - blueman-applet   │
                                       │    - shiros-monitor-  │
                                       │      autosetup        │
                                       │    - shiros-welcome   │
                                       │      (1st boot only)  │
                                       └──────────────────────┘
```

Tiempo objetivo: BIOS POST → escritorio < 20s en SSD, < 45s en HDD.

## 7. Auto-setup de monitor

`shiros-monitor-autosetup` (script bash en `/usr/bin/`):

1. Lee outputs de `xrandr --query`.
2. Calcula hash de EDIDs conectados.
3. Busca `~/.config/shiros/displays.json` con preferencias para ese hash.
4. Si existe, aplica via `xrandr`.
5. Si no, aplica default: extender hacia la derecha del display interno.
6. Guarda hash + config aplicada.

Triggered por:
- Autostart al login (`/etc/xdg/autostart/shiros-monitor-autosetup.desktop`).
- udev rule en `/etc/udev/rules.d/95-shiros-monitor.rules` (hot-plug HDMI/DP).

## 8. Updates

- **APT sources**: Debian Bookworm main + contrib + non-free + non-free-firmware + backports.
- **shirOS repo**: extra repo en `/etc/apt/sources.list.d/shiros.list` (futuro, para meta-packages propios).
- **Política**: `unattended-upgrades` instala automáticamente security updates. Feature updates notifican al usuario via `gnome-software`.
- **Rollback**: `timeshift` snapshot automático pre-upgrade del kernel.

## 9. Versionado

Esquema `MAJOR.MINOR.PATCH-codename`:
- `0.1.0-shir` — primer release alpha
- `0.2.0-shir` — beta con multi-monitor estable
- `1.0.0-shir` — primer release GA

Codename inicial fijo en "shir" hasta v1.0. Después, codenames con gatos (cada release un gato diferente — `shir`, `tom`, `mia`, ...).

## 10. CI / build automation

Roadmap:
- GitHub Actions workflow que construye ISO en cada push a `main`.
- Upload de artifact con la ISO + checksums.
- Test smoke en QEMU automático (boot, login, app launch).
- Releases automáticos al tag `v*`.
