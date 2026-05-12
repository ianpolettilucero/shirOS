# build/config/packages.chroot/

live-build instala automáticamente los `.deb` que estén en este directorio durante la fase chroot.

## Uso

Para incluir paquetes que **no están en los repos Debian** en la ISO, copiá los `.deb` acá antes de correr `scripts/build-iso.sh`.

Los `.deb` no se commitean al repo (están en `.gitignore`). Cada build trae sus binarios.

## RustDesk (preinstalado por decisión 0003)

shirOS preinstala **RustDesk** para que el equipo de IT pueda dar soporte remoto. RustDesk no está en repos Debian; se distribuye como `.deb` desde GitHub Releases.

Hay 2 formas de obtener el `.deb`:

### Opción A — Automático (recomendado)

```bash
./scripts/fetch-rustdesk-deb.sh
```

El script consulta la API pública de GitHub para descubrir la última release y baja el `.deb` para `amd64`. Lo guarda acá.

### Opción B — Manual

1. Andá a https://github.com/rustdesk/rustdesk/releases/latest
2. Bajá el archivo `rustdesk-X.Y.Z-x86_64.deb`
3. Copiá el `.deb` a este directorio.

## Verificación

Antes del build, debe existir al menos un `.deb` acá:

```bash
ls build/config/packages.chroot/*.deb
```

Si no hay `.deb`, `scripts/build-iso.sh` te avisa y te ofrece ejecutar el fetch automáticamente.

## Otros paquetes custom

Si querés sumar más paquetes (ej. drivers de impresora propietarios de un fabricante), simplemente copiá su `.deb` acá. live-build los instala con `apt install -- ./*.deb`.
