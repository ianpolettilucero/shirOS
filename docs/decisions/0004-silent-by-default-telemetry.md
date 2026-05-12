# ADR 0004 — Silent by Default + Opt-in Fleet Metrics

- **Fecha:** 2026-05-12
- **Estado:** Aceptado
- **Decidido por:** founder

## Contexto

Última decisión que quedaba abierta de la fase de planning (`PLAN.md §3`): si shirOS debía enviar algún tipo de telemetría / diagnóstico, y en qué condiciones.

El contexto corporativo argentino es particular:
- Las empresas quieren monitorear su flota (uptime, espacio en disco, RAM, conectividad).
- Los empleados quieren que su PC no "fume" data hacia destinos desconocidos.
- Las áreas de cumplimiento exigen política clara de tratamiento de datos.
- shirOS arrancó con ethos de "simple y predecible" — no podemos romper esa promesa.

## Decisión

**shirOS es Silent by Default.**

Concretamente:
1. **Ninguna instalación de shirOS envía datos a Anthropic, Debian, Mozilla, ni a ningún servidor externo.**
2. Los mecanismos opcionales de telemetría de los componentes upstream (Firefox studies, popularity-contest, etc.) se desactivan en el build.
3. **Sí dejamos preparado un hook opt-in** para que el admin IT corporativo conecte la PC a su propio dashboard de monitoreo interno (Prometheus + Grafana, típicamente). El usuario final **no** ve ningún diálogo y no tiene que aceptar nada.

## Implementación

### Bloqueos a telemetría externa

| Origen | Acción |
|---|---|
| `popularity-contest` (Debian usage stats) | `apt purge` en hook 0010 si por alguna razón llega a quedar instalado. `--apt-recommends false` en `auto/config` lo evita en primera instancia. |
| Firefox telemetry / studies / Pocket | Enterprise policy en `/etc/firefox-esr/policies/policies.json`: `DisableTelemetry=true`, `DisableFirefoxStudies=true`, `DisablePocket=true`, `DisableFeedbackCommands=true`. Sin onboarding screen. |
| `whoopsie` / `apport` (Ubuntu crash reporter) | No los instalamos (es Debian, no Ubuntu). |
| Snap telemetry | No instalamos snapd. |
| Search engine "Suggestions" en Firefox | Default search: DuckDuckGo (no envía queries a Google/Mozilla). |

### Hook opt-in para IT (fleet metrics)

| Componente | Función |
|---|---|
| `prometheus-node-exporter` (paquete) | Instalado **disabled + masked** por default. El binario está, el service no corre. |
| `/usr/bin/shiros-fleet` (CLI) | El admin IT activa el modo deseado: `enable-pull` o `enable-push`. |
| `/etc/shiros/fleet.conf` | Config file (vacío por default). El CLI lo modifica al activar. |
| `/etc/shiros/fleet.README.md` | Documentación para el admin IT con diagramas, ejemplos Prometheus/Grafana, consideraciones de seguridad. |
| `shiros-fleet-push.service` + `.timer` | Job systemd (masked por default) que pushea métricas a un Pushgateway corporativo. Se desenmascara con `shiros-fleet enable-push`. |

### Modos soportados

1. **Pull** (`enable-pull --listen=0.0.0.0:9100`): Prometheus corporativo scrapea cada PC vía HTTP. Recomendado para flotas con LAN/VPN persistente.
2. **Push** (`enable-push --url=https://pushgw.empresa.local/...`): cada PC envía métricas a un Pushgateway central cada X minutos. Recomendado para laptops móviles y dial-out.
3. **Disabled** (default): nada activado. shirOS no expone métricas a nadie.

### Deployment masivo

Para activar fleet metrics en cientos de PCs sin tocar cada una:
- **Preseed**: customizar `/etc/shiros/fleet.conf` en `build/config/includes.chroot/` antes de buildear la ISO corporativa.
- **Ansible / Salt**: distribuir el config + correr `shiros-fleet enable-push`.
- **RustDesk one-shot**: usar RustDesk (decisión 0003) para asistir remotamente.

## Razones

- **Trust**: corre en miles de PCs de no-técnicos. Cualquier rumor de "shirOS espía" mata el producto. Mejor *no poder* espiar que *no querer* espiar.
- **Compliance**: Argentina tiene Ley 25.326 de Protección de Datos Personales. "No recolecto datos" es la postura más simple y limpia legalmente.
- **Diferenciador**: muchas distros corporate / Windows tienen telemetría agresiva. Esto es un mensaje de marca claro.
- **Sin pelea con IT**: el equipo de infra puede igual tener su Grafana de flota — solo que pasa por su servidor, no el nuestro.

## Consecuencias

- **No vamos a tener crash reports automáticos**. Si una PC corchea, el usuario tiene que abrir un issue manual. Aceptable: la base Debian estable cruchea muy poco.
- **No vamos a saber qué hardware tiene la gente**. Las decisiones de soporte de hardware salen de feedback explícito (issues, foros) no de stats.
- **No podemos hacer A/B testing** de UX. Aceptable: estamos copiando UX probada (Windows-like) y este no es producto SaaS.
- **El IT corporativo tiene que armar su Prometheus/Grafana**. Es trabajo de ellos, no nuestro. Documentamos cómo bien.

## Riesgos y mitigaciones

| Riesgo | Mitigación |
|---|---|
| Admin IT activa pull en `0.0.0.0:9100` sin firewall → métricas expuestas a internet | `shiros-fleet` warning explícito cuando se usa listen no-localhost. Docs reiteran "firewall corporativo o VPN-only access". |
| Admin envía credenciales del Pushgateway en `--password` y queda en `/etc/shiros/fleet.conf` legible por root only | Docs recomiendan mTLS o VPN en vez de basic auth para casos serios. |
| User técnico advanced descubre el CLI y lo activa sin permiso | `shiros-fleet enable-*` requiere root (`sudo`). Es un acto deliberado. |
| Compromiso de la cuenta del admin IT → fleet exposed | Mismo nivel de riesgo que cualquier herramienta de gestión. Mitigado por las buenas prácticas estándar (sudo logs, audit). |
| Promethei o pushgateways quedan expuestos a internet | Fuera del scope de shirOS. Responsabilidad del admin de infra corporate. |

## Política pública

Para `shiros.com.ar/privacidad` cuando se launchee:

> **shirOS no recolecta ni envía información sobre vos, tu uso, tu hardware o tu ubicación.** Tampoco lo hace ningún componente que viene preinstalado: Firefox tiene telemetría desactivada por política, Debian no instala popularity-contest, no hay Snap ni equivalente. Si trabajás en una empresa que tiene su propio sistema de monitoreo (Grafana/Prometheus) tu administrador puede activar un hook opt-in en `/usr/bin/shiros-fleet`. Vos no tenés que aceptar ningún diálogo.
