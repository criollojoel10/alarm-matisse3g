#!/bin/bash
# scripts/flash.sh — Helper para flashear alarm-matisse3g
set -e

echo "🥭 alarm-matisse3g - Flash Helper"
echo "================================="
echo ""
echo "1) Flash lk2nd (UNA SOLA VEZ)"
echo "2) Flash SYSTEM image"
echo "q) Salir"
echo ""
read -p "Selecciona una opción: " opt

case "$opt" in
    1)
        if [ ! -f lk2nd-msm8226.img ]; then
            echo "ERROR: lk2nd-msm8226.img no encontrado"
            exit 1
        fi
        echo "Flasheando lk2nd en BOOT..."
        heimdall flash --BOOT lk2nd-msm8226.img --no-reboot
        echo ""
        echo "✅ lk2nd flasheado!"
        echo "Desconecta USB, reinicia manualmente a Download Mode otra vez"
        echo "y luego flashea SYSTEM."
        ;;
    2)
        if [ ! -f alarm-matisse3g-rootfs.img ]; then
            echo "ERROR: alarm-matisse3g-rootfs.img no encontrado"
            exit 1
        fi
        echo "Flasheando SYSTEM..."
        heimdall flash --SYSTEM alarm-matisse3g-rootfs.img
        echo ""
        echo "✅ SYSTEM flasheado!"
        echo "Reinicia la tablet. lk2nd booteará automáticamente."
        ;;
    q) exit 0 ;;
    *) echo "Opción inválida" ;;
esac
