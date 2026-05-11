# Plymouth theme — shirOS

Boot splash mostrado entre GRUB → kernel boot → display manager.

## Archivos

Los archivos reales del theme están en:
[`build/config/includes.chroot/usr/share/plymouth/themes/shiros/`](../../../build/config/includes.chroot/usr/share/plymouth/themes/shiros/)

- `shiros.plymouth` — descriptor del theme (referencia el script).
- `shiros.script` — lógica del splash (logo + dots animados).
- `logo.png` — **TODO**: generar desde `branding/logo/shiros-mono.svg` con `rsvg-convert -w 256 shiros-mono.svg -o logo.png` y copiar al path del theme.

## Diseño

- Background: gradient gris oscuro a casi negro (`#1F2937` → `#111827`).
- Logo centrado, blanco/mono, 256px.
- 3 puntos pulsando debajo del logo (animación sinusoidal desfasada).
- Sin texto del kernel salvo failsafe boot.

## Setear como default

Lo hace el hook `0020-apply-branding.hook.chroot` con:

```bash
plymouth-set-default-theme -R shiros
```

## Test

```bash
plymouthd --debug --debug-file=/tmp/plymouth-debug.log
plymouth show-splash
plymouth quit
```
