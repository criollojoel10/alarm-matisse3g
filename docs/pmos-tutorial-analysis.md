# pmOS Community Tutorial Analysis — SM-T531 (matisse3g)

## Source
Community tutorial compiled from pmOS wiki, XDA forums, and user reports (Jul 2026).

## Key Findings vs Our Approach

### 1. ⚠️ Flash Target: SYSTEM ≠ userdata (CRITICAL CONFLICT)

| Source | Target | Tool |
|--------|--------|------|
| **This tutorial** | **SYSTEM** | Heimdall |
| Our repo (commit 86fe147) | userdata | fastboot |
| pmOS wiki (MSM8916) | userdata | fastboot |

**Analysis:** MSM8916 devices have fastboot via lk2nd — userdata works.
MSM8226 devices (this tutorial) use Heimdall → SYSTEM because the device's stock Android still occupies userdata.
**The tutorial says explicitly:** "La instalación publicada para Matisse utiliza lk2nd en BOOT y qcom-msm8226.img en SYSTEM porque el método automático de pmbootstrap flasher presentó problemas en este dispositivo."

**Resolution:** Splitting two approaches:
- **Phase 1 (first flash):** Heimdall → SYSTEM (per tutorial, proven on hardware)
- **Phase 2 (after lk2nd confirmed working):** fastboot → userdata (our method, once lk2nd provides fastboot)

### 2. lk2nd 23.0 is PRE-RELEASE
- SM-T531 support first appeared in v23.0
- Author warns it "may be broken on some devices"
- **Must test lk2nd alone FIRST** (no OS) — get logs, verify detection

### 3. Blue Screen is KNOWN
- Already reported by another user trying generic MSM8226 port on Matisse
- Cause: tc358764 bridge driver or incomplete framebuffer init
- `lk2nd.pass-simplefb` is the documented fix (already in our extlinux.conf ✅)

### 4. Firmware Path Difference
| Our repo | Tutorial |
|----------|----------|
| `/lib/firmware/wcnss/` | `/lib/firmware/postmarketos/wlan/prima/` |

WCN3660A needs `WCNSS_qcom_wlan_nv.bin` in that path. The tutorial references a community firmware repo: `gitlab.postmarketos.org/exkc/matisse3g-fw`

### 5. Order of Operations (from tutorial)

```
1. Backup everything (PIT, EFS, partitions, /sdcard)
2. Flash lk2nd only (Heimdall → BOOT)
3. Boot → fastboot devices → GET LOG
4. ONLY if log confirms correct DTB → install OS
5. pmbootstrap init (qcom/msm8226, console, no encryption)
6. Heimdall flash --SYSTEM rootfs.img
7. First boot: collect dmesg, check fb, battery, WiFi
8. Install WCN3660A firmware
9. Only then consider GUI
```

## Items to Update in Our Repo

- [ ] **FLASH.txt & flash.sh**: Add BOTH methods (SYSTEM for first flash via Heimdall, userdata for subsequent via fastboot)
- [ ] **firmware/fetch-firmware.sh**: Add WCNSS_qcom_wlan_nv.bin at pmOS path (`/lib/firmware/postmarketos/wlan/prima/`)
- [ ] **lk2nd log step**: Add instruction to get lk2nd log BEFORE installing OS
- [ ] **Warning about pre-release**: Document that lk2nd 23.0 is a pre-release
- [ ] **Blue screen**: Document that it's a known issue, not a brick
