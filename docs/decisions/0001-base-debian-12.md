# ADR 0001 — Base: Debian 12 (Bookworm) stable

- **Fecha:** 2026-05-11
- **Estado:** Aceptado
- **Decidido por:** founder

## Contexto

shirOS necesita una base Linux para construir encima. Las opciones consideradas:

1. **Debian 12 stable** (Bookworm, soporte hasta 2028)
2. **Ubuntu 24.04 LTS** (Noble, soporte hasta 2029, pero con snaps y telemetría)
3. **Arch Linux** (rolling, ultra liviano pero inestable)
4. **Alpine Linux** (musl libc, incompat con apps corporate como Teams/Zoom)

## Decisión

**Debian 12 stable (Bookworm)**.

## Razones

| Criterio | Debian | Ubuntu | Arch | Alpine |
|---|---|---|---|---|
| Estabilidad |  ✓✓✓ | ✓✓ | ✗ | ✓ |
| Sin telemetría | ✓ | ✗ (Ubuntu Advantage, etc.) | ✓ | ✓ |
| Compat apps corporativas | ✓✓✓ | ✓✓✓ | ✓✓ | ✗ (musl) |
| Tamaño base | ✓✓ | ✓ | ✓✓✓ | ✓✓✓✓ |
| Comunidad y soporte | ✓✓✓ | ✓✓✓ | ✓✓ | ✓ |
| Repos amplios | ✓✓✓ (~60k pkgs) | ✓✓✓ | ✓✓ AUR | ✓ |
| Familiaridad para mantener distro derivada | ✓✓✓ | ✓✓ | ✗ | ✗ |
| live-build oficial | ✓ | ✗ | ✗ | ✗ |

Debian gana porque:
- Es la base de Ubuntu y de muchas derivadas exitosas (Mint LMDE, MX, Tails) → existe un camino conocido.
- `live-build` es la herramienta oficial Debian para derivar live ISOs.
- No tiene snaps forzados (Ubuntu sí — y los snaps son lentos en HDD, problema para nuestro target).
- Sin telemetría ni cuentas obligatorias.
- Free software default + non-free firmware fácilmente activable (necesario para WiFi corporativo).

## Consecuencias

- **Versión Debian fija**: nos quedamos en Bookworm hasta junio 2026, después migrar a Trixie (Debian 13).
- **Kernel relativamente viejo**: Debian 12 viene con kernel 6.1 LTS. Para hardware muy nuevo necesitaremos `backports`.
- **systemd**: aceptamos systemd como init (no hay debate aquí).
- **Esquema de versionado independiente**: shirOS versiona por su propia roadmap (0.1, 0.2, ..., 1.0) no por Debian.
