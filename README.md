# 🥭 alarm-matisse3g

**Arch Linux ARM para Samsung Galaxy Tab 4 SM-T531 (matisse3g)**

Kernel mainline `msm8226-mainline` 6.16.y + Arch Linux ARM armv7h + XFCE.

## ⚡ Stack

| Componente | Fuente |
|------------|--------|
| **Kernel** | [`msm8226-mainline/linux`](https://github.com/msm8226-mainline/linux) — branch `qcom-msm8226-6.16.y` |
| **Rootfs** | [Arch Linux ARM](https://archlinuxarm.org) armv7h |
| **Bootloader** | [`msm8916-mainline/lk2nd`](https://github.com/msm8916-mainline/lk2nd) v0.15.0+ |
| **WiFi driver** | `wcn36xx` (mainline, no necesita parches) |
| **WiFi firmware** | Extraído de stock Android (no redistribuible) |
| **Desktop** | Consola base (tú instalas XFCE después) |

## 📦 Archivos del Release

Cada build produce:

```
alarm-matisse3g-v1-latest.tar.gz
├── lk2nd-msm8226.img           → Bootloader secundario
├── lk2nd-msm8226.img.sha256
├── alarm-matisse3g-rootfs.img   → Sistema completo (partición SYSTEM)
├── alarm-matisse3g-rootfs.img.sha256
└── FLASH.txt                    → Instrucciones de flasheo
```

## 🔧 Flasheo

### Hardware necesario
- PC con Linux/macOS/Windows y [Heimdall](https://glassechidna.com.au/heimdall/)
- Cable USB
- SM-T531 con TWRP instalado

### Pasos

1. **Backup de particiones en TWRP** (BOOT, SYSTEM, EFS, MODEM)

2. **Apagar la tablet**

3. **Entrar a Download Mode:**
   ```
   Power + Home + VolDown
   ```

4. **Flashear lk2nd** (UNA SOLA VEZ — nunca más):
   ```bash
   heimdall flash --BOOT lk2nd-msm8226.img --no-reboot
   ```

5. **DESCONECTAR USB** y reiniciar manualmente a Download Mode otra vez

6. **Flashear sistema:**
   ```bash
   heimdall flash --SYSTEM alarm-matisse3g-rootfs.img
   ```

7. **REINICIAR** → lk2nd arranca kernel mainline desde SYSTEM

## 📶 WiFi

El WiFi necesita firmware **no libre** extraído de Android stock.

### Extraer firmware
```bash
# Conectate via USB con la tablet en TWRP/Android
adb shell
cp /system/vendor/firmware/wlan/prima/* /sdcard/
cp /system/vendor/firmware/wcnss.* /sdcard/
exit
adb pull /sdcard/WCNSS_qcom_wlan_nv.bin .
adb pull /sdcard/WCNSS_qcom_cfg.ini .
adb pull /sdcard/wcnss.mdt .
```

### Instalar en Arch
```bash
sudo mkdir -p /lib/firmware/wlan/prima /lib/firmware/qcom
sudo cp WCNSS_qcom_wlan_nv.bin /lib/firmware/wlan/prima/
sudo cp WCNSS_qcom_cfg.ini /lib/firmware/wlan/prima/
sudo cp wcnss.* /lib/firmware/qcom/
sudo modprobe wcn36xx
```

## 🖥️ Instalar XFCE
```bash
sudo pacman -Syu
sudo pacman -S xfce4 xfce4-goodies lightdm lightdm-gtk-greeter \
    networkmanager network-manager-applet \
    firefox mousepad ristretto
sudo systemctl enable lightdm NetworkManager
sudo systemctl start lightdm
```

## 🛠️ Optimizaciones para 1.5GB RAM
```bash
# zram swap
echo "zram" | sudo tee /etc/modules-load.d/zram.conf
echo 'options zram num_devices=1' | sudo tee /etc/modprobe.d/zram.conf
echo 'KERNEL=="zram0", ATTR{disksize}="512M", TAG+="systemd"' | \
    sudo tee /etc/udev/rules.d/99-zram.rules

# swappiness bajo
echo "vm.swappiness=10" | sudo tee /etc/sysctl.d/99-swappiness.conf

# Deshabilitar servicios innecesarios
sudo systemctl disable bluetooth cups avahi-daemon systemd-resolved
```

## 🏗️ Estructura del Repo

```
.github/workflows/
├── scan-kernel.yml    # Workflow 1: investiga el kernel
└── build.yml          # Workflow 2: build + release

overlay/etc/           # Configs que se copian al rootfs
├── extlinux/extlinux.conf
├── fstab
├── hostname
├── modprobe.d/wcn36xx.conf
├── modules-load.d/wcn36xx.conf
├── systemd/network/wlan0.network
└── ...

firmware/              # Scripts para extraer firmware
scripts/               # Helpers local
```

## 🔗 URLs Clave

| Qué | URL |
|-----|-----|
| Kernel source | https://github.com/msm8226-mainline/linux |
| lk2nd | https://github.com/msm8916-mainline/lk2nd |
| Arch ARM | https://archlinuxarm.org |
| Rootfs ARMv7 | https://os.archlinuxarm.org/os/ArchLinuxARM-armv7-latest.tar.gz |

## 🥭 Licencia

GPL-2.0 (kernel), GPL-3.0 (scripts), MIT (overlay).
