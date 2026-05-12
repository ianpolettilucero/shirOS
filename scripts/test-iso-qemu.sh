#!/bin/bash
# shirOS — test launcher para QEMU.
# Arranca la ISO con un disco virtual de 20 GB para probar instalación.
#
# Uso:
#   ./scripts/test-iso-qemu.sh build/shiros-0.1.0-shir-amd64.iso
#   ./scripts/test-iso-qemu.sh --uefi build/shiros-0.1.0-shir-amd64.iso

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DISK_IMG="${REPO_ROOT}/build/test-disk.qcow2"
DISK_SIZE="20G"
RAM_MB="${SHIROS_TEST_RAM:-4096}"
CPUS="${SHIROS_TEST_CPUS:-2}"

USE_UEFI=0
ISO_FILE=""

while [ $# -gt 0 ]; do
    case "$1" in
        --uefi) USE_UEFI=1 ;;
        --bios) USE_UEFI=0 ;;
        --fresh-disk) FRESH_DISK=1 ;;
        -h|--help)
            echo "Uso: $0 [--uefi|--bios] [--fresh-disk] <iso>"
            exit 0
            ;;
        *) ISO_FILE="$1" ;;
    esac
    shift
done

if [ -z "${ISO_FILE}" ]; then
    ISO_FILE=$(ls -1t "${REPO_ROOT}/build/"*.iso 2>/dev/null | head -n1 || true)
fi

if [ ! -f "${ISO_FILE}" ]; then
    echo "ERROR: ISO no encontrada. Pasala como argumento o ponela en build/" >&2
    exit 1
fi

command -v qemu-system-x86_64 >/dev/null 2>&1 || {
    echo "ERROR: qemu-system-x86_64 no instalado. sudo apt install qemu-system-x86" >&2
    exit 1
}

# Disco virtual
if [ ! -f "${DISK_IMG}" ] || [ "${FRESH_DISK:-0}" = "1" ]; then
    echo "[shirOS] Creando disco virtual ${DISK_SIZE}..."
    qemu-img create -f qcow2 "${DISK_IMG}" "${DISK_SIZE}"
fi

# UEFI firmware
UEFI_ARGS=()
if [ "${USE_UEFI}" = "1" ]; then
    OVMF_CODE=""
    for path in /usr/share/OVMF/OVMF_CODE.fd /usr/share/edk2/ovmf/OVMF_CODE.fd /usr/share/qemu/OVMF.fd; do
        if [ -f "${path}" ]; then OVMF_CODE="${path}"; break; fi
    done
    if [ -z "${OVMF_CODE}" ]; then
        echo "ERROR: OVMF (UEFI firmware) no encontrado. sudo apt install ovmf" >&2
        exit 1
    fi
    UEFI_ARGS=(-bios "${OVMF_CODE}")
fi

echo "[shirOS] Lanzando QEMU"
echo "  ISO:  ${ISO_FILE}"
echo "  Disk: ${DISK_IMG}"
echo "  RAM:  ${RAM_MB} MB,  CPUs: ${CPUS}"
echo "  Firmware: $([ "${USE_UEFI}" = "1" ] && echo UEFI || echo BIOS)"
echo

exec qemu-system-x86_64 \
    -name "shirOS test" \
    -enable-kvm \
    -cpu host \
    -smp "${CPUS}" \
    -m "${RAM_MB}" \
    -machine type=q35,accel=kvm \
    -boot order=dc,menu=on \
    -drive file="${DISK_IMG}",format=qcow2,if=virtio \
    -cdrom "${ISO_FILE}" \
    -vga virtio \
    -display gtk \
    -audiodev pa,id=snd0 \
    -device intel-hda \
    -device hda-output,audiodev=snd0 \
    -netdev user,id=net0 \
    -device virtio-net-pci,netdev=net0 \
    -usb \
    -device usb-tablet \
    "${UEFI_ARGS[@]}"
