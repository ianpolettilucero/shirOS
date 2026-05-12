#!/bin/bash
# shirOS — descarga el .deb de RustDesk más reciente desde GitHub Releases.
# Lo guarda en build/config/packages.chroot/ para que live-build lo incluya.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="${REPO_ROOT}/build/config/packages.chroot"
ARCH="${SHIROS_ARCH:-amd64}"

mkdir -p "${TARGET_DIR}"

# Si ya hay un rustdesk*.deb, no sobreescribir salvo --force.
if ls "${TARGET_DIR}"/rustdesk*.deb >/dev/null 2>&1 && [ "${1:-}" != "--force" ]; then
    echo "[shirOS] RustDesk .deb ya presente:"
    ls -1 "${TARGET_DIR}"/rustdesk*.deb
    echo "        Pasá --force para re-descargar."
    exit 0
fi

echo "[shirOS] Buscando última release de RustDesk en GitHub..."

# Mapping de arch shirOS → arch del asset RustDesk
case "${ARCH}" in
    amd64) ASSET_ARCH="x86_64" ;;
    arm64) ASSET_ARCH="aarch64" ;;
    *) echo "Arch no soportada: ${ARCH}" >&2; exit 1 ;;
esac

# Consultar API pública de GitHub.
API_URL="https://api.github.com/repos/rustdesk/rustdesk/releases/latest"

# Filtros para encontrar el .deb correcto:
#   - browser_download_url
#   - .deb extension
#   - matches our arch
#   - excluir flatpak/appimage si los hay
DEB_URL=$(curl -fsSL "${API_URL}" \
    | grep -E '"browser_download_url".*\.deb"' \
    | grep -E "${ASSET_ARCH}" \
    | grep -v -E 'suse|fedora|opensuse' \
    | head -n1 \
    | sed -E 's/.*"browser_download_url": *"([^"]+)".*/\1/')

if [ -z "${DEB_URL}" ]; then
    echo "ERROR: no encontré .deb de RustDesk para ${ASSET_ARCH}." >&2
    echo "       Bajalo manualmente de https://github.com/rustdesk/rustdesk/releases/latest" >&2
    echo "       y copialo a ${TARGET_DIR}/" >&2
    exit 1
fi

DEB_NAME=$(basename "${DEB_URL}")
TARGET="${TARGET_DIR}/${DEB_NAME}"

echo "[shirOS] Descargando ${DEB_NAME}..."
curl -fL --progress-bar -o "${TARGET}.tmp" "${DEB_URL}"
mv "${TARGET}.tmp" "${TARGET}"

echo "[shirOS] ✓ ${TARGET}"
echo "         $(du -h "${TARGET}" | cut -f1)"
