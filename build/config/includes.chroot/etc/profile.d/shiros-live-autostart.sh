# shirOS — auto-launch XFCE en el primer login de tty1 durante boot live.
# Solo aplica si:
#   - estamos en TTY1 (donde el getty drop-in puso el autologin)
#   - no hay sesión X corriendo ya
#   - el user es 'live' (no afectar al sistema instalado)
#   - boot=live está en cmdline (no afectar al sistema instalado tampoco)

if [ "$XDG_VTNR" = "1" ] && [ -z "$DISPLAY" ] && [ "$(id -un 2>/dev/null)" = "live" ] && grep -q '\bboot=live\b' /proc/cmdline 2>/dev/null; then
    # Esperar un segundo a que se asienten servicios (NetworkManager, etc.)
    sleep 1
    exec startxfce4
fi
