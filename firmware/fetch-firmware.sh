#!/bin/bash
# fetch-firmware.sh — Extraer firmware WCNSS (WiFi+BT) de Android stock
# para alarm-matisse3g (SM-T531)
#
# Uso:
#   1. Bootear a TWRP o Android stock
#   2. Conectar USB
#   3. Ejecutar este script

set -e

echo "🥭 alarm-matisse3g - Firmware WiFi/BT Extractor"
echo "================================================"

# ── 1. Intentar desde TWRP/Android con adb ──
if command -v adb &>/dev/null && adb devices | grep -q "device$"; then
    echo "[*] Dispositivo detectado via adb"
    TMPDIR=$(mktemp -d)
    
    FIRMWARE_PATHS=(
        "/system/vendor/firmware/wlan/prima/WCNSS_qcom_wlan_nv.bin"
        "/system/vendor/firmware/wlan/prima/WCNSS_qcom_cfg.ini"
        "/system/vendor/firmware/wcnss.mdt"
        "/system/vendor/firmware/wcnss.b00"
        "/system/vendor/firmware/wcnss.b01"
        "/system/vendor/firmware/wcnss.b02"
        "/system/vendor/firmware/wcnss.b03"
        "/system/vendor/firmware/wcnss.b04"
        "/system/vendor/firmware/wcnss.b05"
        "/system/vendor/firmware/wcnss.b06"
    )
    
    for f in "${FIRMWARE_PATHS[@]}"; do
        echo "  → Pulling $f"
        adb pull "$f" "$TMPDIR/" 2>/dev/null || echo "    (not found)"
    done
    
    echo "[*] Firmware extraído a: $TMPDIR"
    ls -la "$TMPDIR"
    
    echo ""
    echo "[*] Para instalar en Arch:"
    echo "    sudo mkdir -p /lib/firmware/wlan/prima /lib/firmware/qcom"
    echo "    sudo cp $TMPDIR/WCNSS_qcom_wlan_nv.bin /lib/firmware/wlan/prima/"
    echo "    sudo cp $TMPDIR/WCNSS_qcom_cfg.ini /lib/firmware/wlan/prima/"
    echo "    sudo cp $TMPDIR/wcnss.* /lib/firmware/qcom/"
    echo "    sudo modprobe wcn36xx"
    
# ── 2. Fallback: instrucciones manuales ──
else
    echo "[!] adb no disponible o no detecta dispositivo"
    echo ""
    echo "Instrucciones manuales:"
    echo ""
    echo "1. Desde TWRP con USB conectado:"
    echo "   adb shell"
    echo "   cd /system/vendor/firmware"
    echo "   tar czf /sdcard/wcnss-firmware.tar.gz wlan/prima/ wcnss.*"
    echo "   exit"
    echo "   adb pull /sdcard/wcnss-firmware.tar.gz"
    echo ""
    echo "2. O descargar stock ROM desde samfw.com, extraer system.img"
    echo "   y copiar de system/vendor/firmware/"
    echo ""
    echo "3. Una vez tengas los archivos:"
    echo "   sudo mkdir -p /lib/firmware/wlan/prima /lib/firmware/qcom"
    echo "   sudo cp WCNSS_qcom_wlan_nv.bin /lib/firmware/wlan/prima/"
    echo "   sudo cp WCNSS_qcom_cfg.ini /lib/firmware/wlan/prima/"
    echo "   sudo cp wcnss.* /lib/firmware/qcom/"
    echo "   sudo modprobe wcn36xx"
fi
