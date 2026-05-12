# ADR 0003 — Apps default, política de updates, antivirus, soporte remoto

- **Fecha:** 2026-05-12
- **Estado:** Aceptado
- **Decidido por:** founder

## Contexto

Tras armar el scaffold inicial, quedaron 6 decisiones pendientes (ver `PLAN.md §3` versión inicial) que afectan:
- qué apps preinstalar
- qué se ofrece on-demand
- política de seguridad y compliance
- soporte IT remoto

Estas decisiones impactan: tamaño de la ISO, tickets de soporte de IT, postura de seguridad y experiencia del usuario final.

## Decisiones

### 1. Browser default: Firefox ESR (preinstalado) + Brave (opcional)

**Decisión:** Firefox ESR es el browser default. Brave queda como instalación on-demand vía welcome wizard.

**Razón:** Firefox ESR (Extended Support Release) recibe **solo parches de seguridad** durante ~1 año sin cambios de UI. Eso reduce tickets de soporte tipo "se movió un botón" — crítico cuando estás soportando vendedores no-técnicos. Brave queda disponible para quienes necesiten un motor Chromium (algunas web apps corporativas exigen Chromium-based).

### 2. RustDesk: preinstalado, configurado como servicio

**Decisión:** RustDesk se preinstala y se enable como systemd service en cada equipo shirOS.

**Razón:** En una flota corporativa el soporte remoto es esencial. RustDesk es liviano, FOSS, y permite levantar un **relay server propio** para que el tráfico nunca salga de la infra de la empresa. Alternativas (TeamViewer, AnyDesk) son propietarias y requieren licencias.

**Implementación:**
- El `.deb` de RustDesk no está en repos Debian. Lo proveemos via `build/config/packages.chroot/` (live-build instala automáticamente todo `.deb` que esté ahí).
- `scripts/fetch-rustdesk-deb.sh` descarga la última release desde GitHub API.
- El hook `0010-enable-services.hook.chroot` activa `rustdesk.service` si el paquete está instalado.
- En v0.2: documentar cómo apuntar a un relay self-hosted vía `/etc/rustdesk/config.toml`.

### 3. Apps de comunicación: on-demand (Web Launchers preinstalados)

**Decisión:** No preinstalamos clientes nativos de Teams/WhatsApp/Slack. En su lugar, preinstalamos **Web Launchers** (`.desktop` files que abren la app web en una ventana nueva de Firefox).

**Razón:** Cada cliente nativo pesa 100-300 MB. Preinstalarlos todos engorda la ISO y desperdicia disco para apps que no todos usan. Las versiones web son funcionalmente equivalentes para 95% de los casos (chat, calls básicas, files). Quien necesite el cliente nativo (mejor screen share, uso offline) lo instala desde el welcome wizard.

**Web Launchers preinstalados** (en `/usr/share/applications/shiros-*.desktop`):
- Microsoft Teams (Web)
- WhatsApp Web
- Slack (Web)
- Outlook (Web)
- Office 365
- Gmail
- Google Workspace
- Google Meet
- Zoom (Web)

**On-demand vía welcome wizard** (Flatpak):
- Brave Browser
- Google Chrome
- Zoom desktop
- Slack desktop
- Microsoft Teams (teams_for_linux fork)
- OnlyOffice (suite offline compat MS Office)

### 4. VPN: incluir los 3 protocolos comunes

**Decisión:** Preinstalar plugins de NetworkManager para **OpenVPN, OpenConnect (Cisco AnyConnect), WireGuard, L2TP**.

**Razón:** Los plugins pesan poco (~5 MB total combinados). En empresas argentinas te encontrás con cualquiera de estos protocolos según el proveedor (Cisco, Fortinet, OpenVPN custom, WireGuard moderno). Tener todos preconfigurados ahorra fricción inicial.

**Paquetes:**
- `network-manager-openvpn-gnome`, `openvpn`
- `network-manager-openconnect-gnome`, `openconnect`
- `network-manager-l2tp-gnome`
- `wireguard`, `wireguard-tools` (WireGuard tiene soporte nativo en NetworkManager moderno)

### 5. ClamAV: SÍ, scan semanal con schedule inteligente

**Decisión:** Preinstalar ClamAV. Scheduled scan **Lunes 9 AM** vía systemd timer, con `nice 19` y `IOSchedulingClass=idle`. **NO** habilitar `clamd` (on-access scan).

**Razón:** Linux corporativo *no necesita* antivirus en sentido técnico, pero las auditorías de seguridad (ISO 27001, SOC2 lite, requerimientos de bancos / aseguradoras / fintech) exigen "antivirus activo". ClamAV cumple el requisito de compliance. El schedule semanal con baja prioridad lo hace invisible para el usuario.

**Implementación:**
- `clamav` + `clamav-freshclam` (signature updates) preinstalados.
- `shiros-clamav-scan.service` (systemd oneshot): freshclam + clamscan de `/home`, `/tmp`, `/var/tmp` (no sistema — improductivo en Linux).
- `shiros-clamav-scan.timer`: `OnCalendar=Mon *-*-* 09:00:00`, `Persistent=true` (catch-up si la PC estaba apagada), `RandomizedDelaySec=30min` (no martillar la red corporativa).
- `Nice=19`, `IOSchedulingClass=idle`, `CPUSchedulingPolicy=idle` para no afectar UX.

### 6. Updates: auto-install security only / notify others

**Decisión:** `unattended-upgrades` instala automáticamente **sólo** parches de Debian Security. Updates de feature/main quedan a discreción del usuario (notificación vía `gnome-software`).

**Razón:** Un parche de kernel o de OpenSSL no puede esperar — riesgo de RCE / privilege escalation. Pero un upgrade de Firefox que requiere reboot puede esperar a que el usuario decida (no querés que se reboote en medio de una venta).

**Implementación:**
- `/etc/apt/apt.conf.d/20auto-upgrades`: enable periódico (daily list update + unattended-upgrade run).
- `/etc/apt/apt.conf.d/52shiros-unattended`: `Origins-Pattern` restringido a `Debian-Security` solamente.
- `Automatic-Reboot=false`: nunca rebootear sin que el usuario lo pida.
- `Skip-Updates-On-Metered-Connections=true`: no quemar datos en conexiones tarifadas.

## Consecuencias

- **Tamaño ISO**: bajo control (~2-2.5 GB target). PWAs son ~1KB cada una, RustDesk ~30MB, ClamAV ~150MB con signatures. Ningún cliente nativo de chat preinstalado.
- **Tickets soporte IT**: bajan (Firefox ESR sin cambios disruptivos + RustDesk para asistencia remota inmediata).
- **Compliance**: pasamos auditorías que exigen "antivirus" (ClamAV cuenta).
- **Privacidad**: el tráfico de soporte IT puede quedar dentro de la empresa si se levanta un relay RustDesk propio.
- **Carga corporativa de mantenimiento**: hay que actualizar el `.deb` de RustDesk periódicamente (script lo automatiza).

## Riesgos y mitigaciones

| Riesgo | Mitigación |
|---|---|
| RustDesk corre como servicio y expone la PC | RustDesk requiere ID + password único por sesión; sin accept del usuario nadie se conecta. En v0.2: integrar con relay corporativo. |
| Apps web son inútiles sin internet | Caso esperado: vendedores corporativos siempre online. Para offline ofrecemos OnlyOffice on-demand. |
| Auto-update security puede romper paquete crítico | `Remove-Unused-Kernel-Packages=true` + `Automatic-Reboot=false`: el usuario aplica el reboot cuando quiere. Timeshift snapshot pre-update permite rollback. |
| ClamAV signature updates fallan offline | freshclam reintenta cada hora. Si fallan 7 días seguidos, log warning (no bloquea uso del sistema). |
| Brave/Chromium se desactualiza si se instala via Flatpak | Flatpak auto-update está activado por default. |
