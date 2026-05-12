# scripts/post-install/

Scripts que corren después de la instalación, ya sea en el primer boot del usuario o invocados desde el welcome wizard.

Los binarios reales están en `build/config/includes.chroot/usr/bin/`:

- [`shiros-welcome`](../../build/config/includes.chroot/usr/bin/shiros-welcome) — wizard de primer boot (zenity).
- [`shiros-monitor-autosetup`](../../build/config/includes.chroot/usr/bin/shiros-monitor-autosetup) — auto-config multi-monitor.
- [`shiros-display-quickmenu`](../../build/config/includes.chroot/usr/bin/shiros-display-quickmenu) — menú rápido tipo Win+P.

Este directorio queda reservado para futuros scripts de post-install que no sean ejecutables del sistema (ej. helpers de CI, migraciones).
