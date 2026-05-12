# shirOS Fleet Metrics — guía para el admin de IT

> **TL;DR:** shirOS es *silent by default*. No envía nada a ningún lado. Si querés monitorear tu flota (Grafana/Prometheus), activá este hook con un comando.

## Filosofía

shirOS no recolecta ni envía telemetría a Anthropic / Debian / ningún servidor externo. El usuario final no ve ningún diálogo de "compartir datos de uso" porque **no hay datos para compartir**.

Para empresas que necesitan monitoreo de flota (uptime, uso de disco, RAM, network), `prometheus-node-exporter` viene instalado pero **disabled**. El admin IT lo activa explícitamente con `shiros-fleet`.

## Modelos soportados

### 1. Pull (Prometheus scrape — recomendado para redes corporativas con LAN/VPN persistente)

Prometheus consulta a cada PC vía HTTP en intervalos regulares.

```
┌──────────────┐   scrape    ┌─────────────────────┐
│ Prometheus   │ ──────────► │ shirOS-PC-Juan      │
│ corp Server  │             │ node_exporter:9100  │
└──────────────┘             └─────────────────────┘
       │
       ▼
┌──────────────┐
│ Grafana      │
└──────────────┘
```

**Activar en una PC:**

```bash
sudo shiros-fleet enable-pull --listen=0.0.0.0:9100
```

Verificá:
```bash
curl http://<ip-de-la-pc>:9100/metrics
```

**Prometheus side** (en tu prometheus.yml):
```yaml
scrape_configs:
  - job_name: 'shiros-fleet'
    static_configs:
      - targets:
          - 'shiros-juan.empresa.local:9100'
          - 'shiros-ana.empresa.local:9100'
          - 'shiros-carlos.empresa.local:9100'
```

**Restricciones:**
- Las PCs deben ser reachables desde Prometheus (LAN, VPN site-to-site, o tunneling).
- Sin auth nativa. Restringí con firewall corporativo o VPN.

### 2. Push (Pushgateway — recomendado para laptops móviles / dial-out)

Cada PC envía periódicamente sus métricas a un Pushgateway central. Útil cuando las PCs están en redes hogareñas, en movimiento, o detrás de NAT.

```
┌─────────────────────┐   POST     ┌──────────────┐
│ shirOS-PC-Juan      │ ─────────► │ Pushgateway  │
│ shiros-fleet-push   │            └──────────────┘
└─────────────────────┘                   │
                                          ▼
                                  ┌──────────────┐
                                  │ Prometheus   │
                                  └──────────────┘
                                          │
                                          ▼
                                  ┌──────────────┐
                                  │ Grafana      │
                                  └──────────────┘
```

**Activar en una PC:**

```bash
sudo shiros-fleet enable-push \
    --url=https://pushgw.empresa.local/metrics/job/shiros \
    --interval=5m
```

(El hostname se agrega automáticamente como label `instance`.)

**Restricciones:**
- El pushgateway no tiene auth nativa — ponele un nginx con basic auth, mTLS, o mantenelo en VPN.
- La PC necesita conectividad outbound HTTPS hacia el pushgateway.
- Es push-based: si la PC está apagada, no hay métricas (no es alerting confiable).

## Comandos `shiros-fleet`

```
shiros-fleet status                       # ver estado actual
shiros-fleet enable-pull [opciones]       # activar modo pull
shiros-fleet enable-push --url=... [opt]  # activar modo push
shiros-fleet disable                      # apagar todo (vuelve a silent)
shiros-fleet test                         # imprime las métricas actuales
```

`enable-pull` opciones:
- `--listen=ADDR:PORT` — por default `127.0.0.1:9100` (solo localhost, sin uso real).
  Para que Prometheus scrape la PC, usar `0.0.0.0:9100`. Cuidado con firewall.

`enable-push` opciones:
- `--url=URL` — endpoint del pushgateway. Obligatorio.
- `--interval=Xm` — frecuencia, default 5m. Acepta formatos `30s`, `2m`, `1h`, etc.
- `--user=USER --password=PASS` — basic auth.

## Seguridad

| Riesgo | Mitigación |
|---|---|
| node_exporter expone métricas sensibles (procesos, network, etc.) | Restringir al usuario IT vía firewall corporativo + VPN. |
| Pushgateway sin auth | Poner nginx + basic auth o mTLS por delante. |
| Logs de métricas filtran hostnames | Usar instance label genérico (anonymous-uuid) si es requerimiento de privacidad. |
| Tráfico HTTP en claro | **Usar HTTPS siempre**. node_exporter no termina TLS nativo — poner nginx en frente o usar stunnel. |
| Las métricas revelan hardware del usuario | Es info corporativa legítima, pero comunicalo en la política interna. |

## Buena práctica: deployment masivo

Para activar fleet metrics en toda la flota sin tocar PC por PC, hay 3 opciones:

1. **Preseed en la ISO**: customizar `build/config/includes.chroot/etc/shiros/fleet.conf`
   con la URL del pushgateway antes de buildear la ISO corporativa.

2. **Ansible / SaltStack**: push de `/etc/shiros/fleet.conf` + `shiros-fleet enable-push` por SSH.

3. **RustDesk one-shot**: si ya tenés RustDesk en la flota (decisión 0003), podés
   asistir remotamente a cada PC para activarlo.

## Apagar el hook completamente (paranoia mode)

Si no querés ni la posibilidad de fleet metrics:

```bash
sudo apt purge prometheus-node-exporter
sudo rm -rf /etc/shiros /usr/bin/shiros-fleet
sudo rm /etc/systemd/system/shiros-fleet-push.*
```

Después de eso, la PC no tiene ninguna capability de exportar métricas a ningún lado.
