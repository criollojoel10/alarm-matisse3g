#!/bin/bash
# scripts/build-rootfs.sh — Crea la imagen rootfs para alarm-matisse3g
set -e

ROOTFS_URL="http://os.archlinuxarm.org/os/ArchLinuxARM-armv7-latest.tar.gz"
IMAGE_SIZE_MB="${1:-2200}"

echo "==> Downloading Arch Linux ARM rootfs..."
wget -q "$ROOTFS_URL" -O ArchLinuxARM-armv7-latest.tar.gz
wget -q "$ROOTFS_URL.md5" -O ArchLinuxARM-armv7-latest.tar.gz.md5
md5sum -c ArchLinuxARM-armv7-latest.tar.gz.md5

echo "==> Extracting..."
sudo mkdir -p rootfs
sudo tar -xpf ArchLinuxARM-armv7-latest.tar.gz -C rootfs/

echo "nameserver 1.1.1.1" | sudo tee rootfs/etc/resolv.conf

if [ -d overlay/ ]; then
    echo "==> Applying overlay..."
    sudo cp -rv overlay/* rootfs/
fi

if [ -d modules-install/lib/modules/ ]; then
    echo "==> Installing kernel modules..."
    MODDIR=$(ls -d modules-install/lib/modules/*/ 2>/dev/null | head -1)
    if [ -n "$MODDIR" ]; then
        sudo cp -rv "$MODDIR" rootfs/lib/modules/
    fi
fi

if [ -f linux/arch/arm/boot/zImage ]; then
    echo "==> Installing kernel + DTBs..."
    sudo mkdir -p rootfs/boot rootfs/boot/dtbs
    sudo cp linux/arch/arm/boot/zImage rootfs/boot/
    sudo cp linux/arch/arm/boot/dts/qcom/msm8226*.dtb rootfs/boot/dtbs/ 2>/dev/null || true
    sudo cp linux/arch/arm/boot/dts/qcom/qcom-msm8226*.dtb rootfs/boot/dtbs/ 2>/dev/null || true
fi

sudo chown -R root:root rootfs/etc 2>/dev/null || true

echo "==> Creating ext4 sparse image (${IMAGE_SIZE_MB}MB)..."
dd if=/dev/zero of=alarm-rootfs.raw bs=1M count=0 seek=${IMAGE_SIZE_MB}
sudo mkfs.ext4 -O ^metadata_csum,^64bit -F alarm-rootfs.raw
sudo mount -o loop alarm-rootfs.raw /mnt
sudo cp -a rootfs/* /mnt/
sudo umount /mnt

if command -v img2simg &>/dev/null; then
    img2simg alarm-rootfs.raw alarm-matisse3g-rootfs.img
else
    echo "img2simg not found, keeping raw image"
    mv alarm-rootfs.raw alarm-matisse3g-rootfs.img
fi

sha256sum alarm-matisse3g-rootfs.img > alarm-matisse3g-rootfs.img.sha256
echo "==> Done: alarm-matisse3g-rootfs.img ($(ls -lh alarm-matisse3g-rootfs.img | awk '{print $5}'))"
