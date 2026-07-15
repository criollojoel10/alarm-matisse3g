#!/bin/bash
# scripts/flash.sh — Helper para flashear alarm-matisse3g (userdata target)
set -e

echo "🥭 alarm-matisse3g - Flash Helper"
echo "================================="
echo ""
echo "1) Flash lk2nd (UNA SOLA VEZ)"
echo "2) Flash rootfs a USERDATA (recomendado)"
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
        echo "y luego flashea USERDATA."
        ;;
    2)
        if [ ! -f alarm-matisse3g-rootfs.img ]; then
            echo "ERROR: alarm-matisse3g-rootfs.img no encontrado"
            exit 1
        fi
        echo ""
        echo "⚠️  Necesitas lk2nd v23+ YA flasheado en BOOT."
        echo "   Prende la tablet sola → lk2nd arranca → cae a fastboot."
        echo ""
        echo "Flasheando rootfs a USERDATA..."
        echo ""
        echo "   fastboot flash userdata alarm-matisse3g-rootfs.img"
        echo "   fastboot erase system"
        echo "   fastboot reboot"
        echo ""
        heimdall flash --USERDATA alarm-matisse3g-rootfs.img || {
            echo ""
            echo "❌ Heimdall puede fallar con sparse images >2GB."
            echo "   Usa fastboot en vez de Heimdall:"
            echo "   fastboot flash userdata alarm-matisse3g-rootfs.img"
            echo "   fastboot erase system"
            echo "   fastboot reboot"
        }
        ;;
    q) exit 0 ;;
    *) echo "Opción inválida" ;;
esac
