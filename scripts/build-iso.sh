#!/bin/bash
# shirOS — build script.
# Wrapper sobre live-build. Verifica deps, limpia, compila, mueve ISO.
#
# Uso:
#   sudo ./scripts/build-iso.sh                # build default (0.1.0-shir, amd64)
#   sudo SHIROS_VERSION=0.2.0 ./scripts/build-iso.sh
#   sudo ./scripts/build-iso.sh --clean        # solo limpia
#   sudo ./scripts/build-iso.sh --no-cache     # ignora chroot/cache de builds previos
#
# Requisitos del host:
#   - Debian 12+ o Ubuntu 22.04+
#   - live-build, debootstrap, xorriso, squashfs-tools
#   - >= 20 GB libres
#   - Acceso a internet (debootstrap baja paquetes)

set -euo pipefail

# ─────────────────────────────────────────────────────────────
# Constantes
# ─────────────────────────────────────────────────────────────

SHIROS_VERSION="${SHIROS_VERSION:-0.1.10-shir}"
SHIROS_ARCH="${SHIROS_ARCH:-amd64}"
SHIROS_DIST="${SHIROS_DIST:-bookworm}"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${REPO_ROOT}/build"

REQUIRED_PACKAGES=(
    live-build
    debootstrap
    xorriso
    squashfs-tools
    mtools
    isolinux
    syslinux-common
    grub-pc-bin
    grub-efi-amd64-bin
    dosfstools
)

# ─────────────────────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────────────────────

log()  { printf '\033[1;34m[shirOS]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[shirOS]\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31m[shirOS]\033[0m %s\n' "$*" >&2; exit 1; }

require_root() {
    if [ "$(id -u)" -ne 0 ]; then
        die "Este script requiere root (live-build necesita chroot). Usá: sudo $0"
    fi
}

check_dependencies() {
    log "Verificando dependencias del host..."
    local missing=()
    for pkg in "${REQUIRED_PACKAGES[@]}"; do
        if ! dpkg-query -W -f='${Status}' "${pkg}" 2>/dev/null | grep -q 'install ok installed'; then
            missing+=("${pkg}")
        fi
    done
    if [ ${#missing[@]} -gt 0 ]; then
        warn "Faltan paquetes: ${missing[*]}"
        warn "Instalalos con: sudo apt install ${missing[*]}"
        die "Aborto. Instalá las deps y volvé a correr el script."
    fi
}

check_disk_space() {
    local available_gb
    available_gb=$(df -BG "${BUILD_DIR}" | awk 'NR==2 {gsub(/G/,"",$4); print $4}')
    if [ "${available_gb}" -lt 15 ]; then
        warn "Solo hay ${available_gb}GB libres en ${BUILD_DIR}. Recomendado: >= 20 GB."
        warn "El build puede fallar. Continuá bajo tu propio riesgo. (Ctrl+C para cancelar)"
        sleep 5
    fi
}

ensure_scripts_executable() {
    chmod +x "${BUILD_DIR}/auto/config" \
             "${BUILD_DIR}/auto/build" \
             "${BUILD_DIR}/auto/clean"
    chmod +x "${BUILD_DIR}/config/hooks/normal/"*.hook.chroot 2>/dev/null || true
    find "${BUILD_DIR}/config/includes.chroot/usr/bin" -type f -exec chmod +x {} \; 2>/dev/null || true
    find "${BUILD_DIR}/config/includes.chroot/usr/local/sbin" -type f -exec chmod +x {} \; 2>/dev/null || true
    find "${BUILD_DIR}/config/includes.chroot/lib/live/config" -type f -exec chmod +x {} \; 2>/dev/null || true
}

generate_version_files() {
    # Genera os-release, lsb-release e issue con la versión actual.
    # Estos archivos NO se commitean en git (.gitignored) — siempre se
    # generan fresh por cada build. Así el filename del .iso y el contenido
    # de /etc/os-release siempre matchean.
    log "Generando archivos de versión (v=${SHIROS_VERSION})..."
    local etc="${BUILD_DIR}/config/includes.chroot/etc"
    mkdir -p "${etc}"

    cat > "${etc}/os-release" <<EOF
PRETTY_NAME="shirOS ${SHIROS_VERSION} (Shir)"
NAME="shirOS"
VERSION_ID="${SHIROS_VERSION}"
VERSION="${SHIROS_VERSION} (Shir)"
VERSION_CODENAME=shir
ID=shiros
ID_LIKE=debian
HOME_URL="https://github.com/ianpolettilucero/shiros"
SUPPORT_URL="https://github.com/ianpolettilucero/shiros/issues"
BUG_REPORT_URL="https://github.com/ianpolettilucero/shiros/issues"
LOGO=shiros-logo
EOF

    cat > "${etc}/lsb-release" <<EOF
DISTRIB_ID=shirOS
DISTRIB_RELEASE=${SHIROS_VERSION}
DISTRIB_CODENAME=shir
DISTRIB_DESCRIPTION="shirOS ${SHIROS_VERSION} (Shir)"
EOF

    cat > "${etc}/issue" <<EOF
shirOS ${SHIROS_VERSION} \\n \\l

EOF
    cp "${etc}/issue" "${etc}/issue.net"
}

ensure_rustdesk_deb() {
    local pkg_dir="${BUILD_DIR}/config/packages.chroot"
    mkdir -p "${pkg_dir}"
    if ls "${pkg_dir}"/rustdesk*.deb >/dev/null 2>&1; then
        log "RustDesk .deb presente."
        return
    fi
    warn "No hay rustdesk*.deb en ${pkg_dir}"
    warn "RustDesk se preinstala (decisión 0003) — necesito el .deb."
    if [ -x "${REPO_ROOT}/scripts/fetch-rustdesk-deb.sh" ]; then
        log "Intentando bajar automáticamente..."
        if "${REPO_ROOT}/scripts/fetch-rustdesk-deb.sh"; then
            log "RustDesk .deb descargado."
            return
        fi
        warn "Fetch falló. Bajalo manual de https://github.com/rustdesk/rustdesk/releases/latest"
        warn "y copialo a ${pkg_dir}/"
        warn "Continuando sin RustDesk (la ISO se buildea pero sin esa app)."
    fi
}

clean_build() {
    log "Limpiando builds previos..."
    cd "${BUILD_DIR}"
    if [ -x auto/clean ]; then
        ./auto/clean || true
    fi
    rm -rf .build cache/contents.chroot cache/packages.chroot
}

deep_clean() {
    log "Limpieza profunda (cache incluida)..."
    cd "${BUILD_DIR}"
    if [ -x auto/clean ]; then
        ./auto/clean --purge || true
    fi
    rm -rf .build cache chroot binary
}

run_build() {
    log "Configurando live-build (v=${SHIROS_VERSION}, arch=${SHIROS_ARCH}, dist=${SHIROS_DIST})"
    cd "${BUILD_DIR}"
    export SHIROS_VERSION SHIROS_ARCH SHIROS_DIST
    ./auto/config

    log "Compilando ISO (puede tardar 20-40 minutos)..."
    ./auto/build
}

move_artifacts() {
    cd "${BUILD_DIR}"
    local iso_file
    iso_file=$(ls -1 *.iso 2>/dev/null | head -n1 || true)
    if [ -z "${iso_file}" ]; then
        die "No se encontró ningún .iso después del build. Revisá build.log."
    fi

    local out_name="shiros-${SHIROS_VERSION}-${SHIROS_ARCH}.iso"
    if [ "${iso_file}" != "${out_name}" ]; then
        mv -v "${iso_file}" "${out_name}"
    fi

    log "Generando SHA256..."
    sha256sum "${out_name}" > "${out_name}.sha256"

    local size_mb
    size_mb=$(du -m "${out_name}" | cut -f1)
    log "✓ ISO lista: ${BUILD_DIR}/${out_name} (${size_mb} MB)"
    log "  Checksum:  ${BUILD_DIR}/${out_name}.sha256"
}

# ─────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────

case "${1:-}" in
    --clean)
        require_root
        clean_build
        exit 0
        ;;
    --deep-clean|--no-cache)
        require_root
        deep_clean
        exit 0
        ;;
    -h|--help)
        sed -n '2,/^set -e/p' "$0" | grep -E '^#' | sed 's/^# \?//'
        exit 0
        ;;
esac

require_root
check_dependencies
check_disk_space
ensure_scripts_executable
generate_version_files
ensure_rustdesk_deb
clean_build
run_build
move_artifacts

log "Done. Probá la ISO con: ./scripts/test-iso-qemu.sh ${BUILD_DIR}/shiros-${SHIROS_VERSION}-${SHIROS_ARCH}.iso"
