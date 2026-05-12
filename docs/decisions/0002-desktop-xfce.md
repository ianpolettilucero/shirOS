# ADR 0002 — Desktop Environment: XFCE 4.18

- **Fecha:** 2026-05-11
- **Estado:** Aceptado

## Contexto

Necesitamos un escritorio que sea:
- Liviano (target incluye PCs con 2-4 GB RAM).
- Familiar para usuarios Windows (panel inferior, menú estilo Start).
- Customizable visualmente (queremos branding distintivo).
- Estable y mantenido.

## Opciones

1. **XFCE 4.18** — clásico, liviano (~400MB RAM idle).
2. **Cinnamon** — más moderno, más pesado (~700MB), look Windows 10.
3. **KDE Plasma 6** — el más customizable pero requiere aprender Plasma.
4. **LXQt** — el más liviano (~300MB) pero menos pulido.
5. **GNOME** — descartado: workflow no-Windows-like, pesado.
6. **MATE** — viejo, fork de GNOME 2.

## Decisión

**XFCE 4.18**.

## Razones

- **RAM**: idle ~400MB. Permite que la PC con 2GB RAM siga teniendo headroom para Firefox + Slack.
- **Familiar**: panel + menú + system tray. Usuarios Windows entienden sin aprender.
- **Customización**: cada componente (panel, window manager, file manager) es independiente. Podemos modificar selectivamente.
- **xfconf**: API de config XML serializable → fácil de versionar nuestros defaults en el repo.
- **Estable**: 4.18 es estable desde diciembre 2022, sin grandes cambios disruptivos.
- **Compatibilidad GTK**: usa GTK 3, lo que abarca el 90% de apps Linux.

## Trade-offs aceptados

- XFCE se ve "viejo" sin trabajo de tema. Lo compensamos con un theme custom (Arc-based, en roadmap).
- No tiene animaciones modernas tipo GNOME/KDE. Es un *plus* para nuestro target (PCs lentas).
- Wayland todavía experimental en XFCE 4.18. Nos quedamos en X11 hasta XFCE 4.20.

## Consecuencias

- Display server: **X11** (no Wayland). Migración a Wayland en v0.3+.
- Window manager: **xfwm4**. Suficiente compositor para usuarios corporativos.
- Whisker menu (`xfce4-whiskermenu-plugin`) en lugar del menú XFCE default — UX más cercana a Windows.
