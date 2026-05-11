# Cómo instalar shirOS

Guía paso a paso para usuarios finales. Si sos desarrollador, ver [`ARCHITECTURE.md`](../ARCHITECTURE.md).

## Requisitos mínimos

| | Mínimo | Recomendado |
|---|---|---|
| **CPU**     | Intel/AMD 64-bit (x86_64), 2 cores | i3/Ryzen 3 o superior, 4 cores |
| **RAM**     | 2 GB | 4 GB+ |
| **Disco**   | 12 GB libres | 32 GB+ (SSD ideal) |
| **Gráficos**| Cualquier GPU con drivers Linux | GPU Intel/AMD integrada |
| **USB**     | Puerto USB-A para pendrive de instalación | |

## 1. Descargar la ISO

Descargá la última versión desde [GitHub Releases](https://github.com/ianpolettilucero/shiros/releases).

Verificá el SHA256:

```bash
sha256sum shiros-0.1.0-shir-amd64.iso
# Debe coincidir con shiros-0.1.0-shir-amd64.iso.sha256
```

## 2. Crear el USB booteable

### Desde Windows

1. Descargá [Rufus](https://rufus.ie/) (~1 MB).
2. Conectá un pendrive de 4 GB o más (se va a borrar).
3. Abrí Rufus, seleccioná:
   - Dispositivo: tu pendrive
   - Selección de arranque: la ISO de shirOS
   - Esquema de partición: GPT
   - Sistema destino: UEFI (no CSM)
4. Click en **EMPEZAR**. Esperá ~5 minutos.

### Desde macOS / Linux

```bash
# Identificar el pendrive (¡cuidado de no equivocarte!)
lsblk        # Linux
diskutil list # macOS

# Escribir la ISO (reemplazar /dev/sdX por tu pendrive)
sudo dd if=shiros-0.1.0-shir-amd64.iso of=/dev/sdX bs=4M status=progress conv=fsync
sync
```

## 3. Bootear desde el USB

1. Conectá el pendrive a la PC objetivo.
2. Reiniciá la PC.
3. Apenas arranca, presioná la **tecla de boot menu** de tu marca:

| Marca | Tecla |
|---|---|
| Acer, ASRock, ASUS desktop | `F2`, `F8` o `F12` |
| ASUS notebook | `Esc` |
| Dell | `F12` |
| HP | `Esc` o `F9` |
| Lenovo notebook | `F12` o `Fn+F12` |
| Lenovo ThinkPad | `F12` |
| MSI | `F11` |
| Samsung | `F12` |
| Toshiba | `F12` |

4. Seleccioná tu pendrive en el menú de boot.

> **Si no aparece la opción**: entrá al BIOS/UEFI (`F2` o `Del` al arrancar), desactivá **Secure Boot** (temporalmente) y activá **USB Boot**.

## 4. Probar shirOS (live, sin instalar)

shirOS arranca en modo "live": funciona desde el pendrive sin tocar tu disco. Probá:

- Que tu WiFi se conecte.
- Que la pantalla se vea bien.
- Que el touchpad/mouse anda.
- Que detecte tu impresora o monitor externo.

Si todo OK, **doble click en "Instalar shirOS"** en el escritorio.

## 5. Wizard de instalación

El wizard tiene **5 pasos** + resumen. Tiempo total: ~15 min.

### Paso 1: Idioma
Elegí "Español (Argentina)". El sistema ya viene seteado por default a Argentina.

### Paso 2: Región y hora
"Buenos Aires" por default. Si estás en otra zona, ajustá.

### Paso 3: Teclado
"Español Latinoamericano" por default. Probá escribir `ñ` y acentos en el cuadro de prueba.

### Paso 4: Disco

Acá es donde elegís cómo instalar. Cuatro opciones:

#### Opción A — Borrar todo e instalar shirOS

Borra todo el disco e instala shirOS solo. **Vas a perder todos los datos del disco.** Hacé backup primero.

Recomendado si: la PC es nueva, o ya no usás Windows.

#### Opción B — Instalar al lado de Windows (DUAL-BOOT)

shirOS detecta Windows y ofrece compartir el disco. Vas a poder elegir al encender la PC con cuál sistema arrancar.

shirOS hace lo siguiente:
1. Achica la partición de Windows (sin perder datos).
2. Crea una partición nueva para shirOS en el espacio liberado.
3. Instala GRUB (un menú de arranque) que te deja elegir al booteo.

**Antes de hacer esto:**
- Apagá Windows correctamente (no hibernate, no fast boot). Reiniciá Windows una vez completamente.
- Desactivá BitLocker si lo tenés.
- Hacé backup de archivos importantes igual.

#### Opción C — Reemplazar partición existente

Para usuarios avanzados que ya tienen Linux instalado.

#### Opción D — Manual

Para usuarios con conocimiento técnico que quieren hacer su propio layout. shirOS te muestra GParted-style.

### Paso 5: Tu usuario

- Nombre completo: como querés que aparezca.
- Usuario: tu login (sin espacios, todo en minúscula).
- Contraseña: mínimo 4 caracteres, pero usá una larga.
- Nombre de la PC: opcional, `shiros-pc` por default.

### Resumen + Instalar

Revisá. Click en **Instalar**. Tarda 5-15 minutos según tu disco.

## 6. Primer boot

1. Sacá el pendrive cuando la PC reinicie.
2. Si elegiste dual-boot, vas a ver el menú GRUB:
   - **shirOS** (default — bootea automáticamente en 3s)
   - **Windows** (flecha abajo + Enter)
3. Login con tu usuario.
4. shirOS arranca y aparece el **Welcome wizard** que te ayuda con:
   - WiFi (si no está conectado)
   - Apps adicionales (Chrome, Zoom, Slack, etc.)
   - Configuración de pantallas
5. Listo. Disfrutalo.

## Problemas comunes

### No bootea desde el USB
- Verificá que **Secure Boot** esté desactivado.
- Probá el otro puerto USB (a veces solo uno bootea).
- Reescribí la ISO al pendrive (puede estar corrupta).

### WiFi no funciona
- shirOS incluye firmware para 95% de chips comunes. Si igual no anda:
  - Conectá por cable Ethernet.
  - Abrí Terminal y corré: `sudo apt update && sudo apt install firmware-iwlwifi firmware-realtek firmware-atheros`

### No veo Windows en el menú GRUB
- Reiniciá una vez. Si igual no aparece:
  - Abrí Terminal: `sudo update-grub` y reiniciá.
  - Si persiste, abrí un issue en GitHub con la salida de `sudo fdisk -l`.

### Monitor externo no detecta
- Probá presionar **Super+P** (la tecla Windows + P).
- Si no aparece, abrí "Configurar pantallas" en el menú.
