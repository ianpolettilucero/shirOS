# installer/

> Esta carpeta queda como referencia. La configuración real de Calamares vive en:
>
> [`build/config/includes.chroot/etc/calamares/`](../build/config/includes.chroot/etc/calamares/)

live-build copia automáticamente todo lo que está en `build/config/includes.chroot/` al rootfs de la ISO, por lo que los configs deben estar en ese path para que terminen en `/etc/calamares/` del sistema instalado.

## Archivos clave

| Archivo | Función |
|---|---|
| [`settings.conf`](../build/config/includes.chroot/etc/calamares/settings.conf) | Define orden de módulos del wizard. |
| `modules/welcome.conf` | Pantalla de bienvenida + requirements check. |
| `modules/locale.conf` | Selección de idioma/zona horaria. |
| `modules/keyboard.conf` | Selección de teclado. |
| `modules/partition.conf` | Partition manager (auto + manual + dual-boot). |
| `modules/users.conf` | Creación de usuario. |
| `modules/displaymanager.conf` | Configura LightDM en el sistema instalado. |
| `modules/bootloader.conf` | Instala GRUB. |
| `modules/finished.conf` | Pantalla final. |
| `branding/shiros/branding.desc` | Branding del wizard (logo, colores, strings). |
| `branding/shiros/show.qml` | Slideshow durante install. |
| `branding/shiros/slide{1-4}.svg` | Imágenes del slideshow. |

## Docs Calamares

- https://github.com/calamares/calamares/wiki
- https://github.com/calamares/calamares/tree/calamares/src/modules
