#!/usr/bin/make -f
# Makefile para alarm-matisse3g
# Targets para build local en begonia o CI

SHELL := /bin/bash
KERNEL_BRANCH ?= qcom-msm8226-6.16.y
LK2ND_TAG ?= v0.15.0
CROSS_COMPILE ?= arm-linux-gnueabihf-
JOBS ?= $(shell nproc)

.PHONY: all kernel modules dtbs lk2nd rootfs-image clean

all: kernel lk2nd

# ── Kernel ──
kernel:
	@echo "==> Cloning msm8226-mainline..."
	@test -d linux || git clone --depth=1 --branch=$(KERNEL_BRANCH) https://github.com/msm8226-mainline/linux.git linux
	@echo "==> Configuring..."
	cd linux && make ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE) qcom_defconfig
	cd linux && ./scripts/config --module CONFIG_WCN36XX
	cd linux && ./scripts/config --enable  CONFIG_QCOM_WCNSS_CTRL
	cd linux && ./scripts/config --enable  CONFIG_QCOM_WCNSS_PIL
	cd linux && ./scripts/config --module CONFIG_BT_HCIUART
	cd linux && ./scripts/config --enable  CONFIG_BT_HCIUART_BCM
	cd linux && ./scripts/config --enable  CONFIG_CFG80211
	cd linux && ./scripts/config --module CONFIG_MAC80211
	cd linux && ./scripts/config --enable  CONFIG_RFKILL
	cd linux && ./scripts/config --enable  CONFIG_EXT4_FS
	cd linux && ./scripts/config --set-val CONFIG_CMA_SIZE_MBYTES 64
	@echo "==> Building zImage..."
	cd linux && make -j$(JOBS) ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE) zImage
	@echo "==> Building DTBs..."
	cd linux && make -j$(JOBS) ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE) dtbs
	$(MAKE) modules

modules:
	@echo "==> Building modules..."
	cd linux && make -j$(JOBS) ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE) modules
	rm -rf modules-install
	cd linux && make ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE) modules_install INSTALL_MOD_PATH=../modules-install

dtbs: kernel

lk2nd:
	@echo "==> Getting lk2nd..."
	@if wget --spider https://github.com/msm8916-mainline/lk2nd/releases/download/$(LK2ND_TAG)/lk2nd-msm8226.img 2>/dev/null; then \
		wget -O lk2nd-msm8226.img https://github.com/msm8916-mainline/lk2nd/releases/download/$(LK2ND_TAG)/lk2nd-msm8226.img; \
	else \
		git clone --depth=1 --branch=$(LK2ND_TAG) https://github.com/msm8916-mainline/lk2nd.git; \
		cd lk2nd && make TOOLCHAIN_PREFIX=$(CROSS_COMPILE) lk2nd-msm8226; \
		cp build-lk2nd-msm8226/lk2nd-msm8226.img ..; \
	fi

rootfs-image:
	@echo "==> Creating rootfs image..."
	@./scripts/build-rootfs.sh

clean:
	rm -rf linux lk2nd modules-install lk2nd-msm8226.img
	rm -f alarm-matisse3g-rootfs.img alarm-rootfs.raw

flash-lk2nd:
	heimdall flash --BOOT lk2nd-msm8226.img --no-reboot

flash-system:
	heimdall flash --SYSTEM alarm-matisse3g-rootfs.img
