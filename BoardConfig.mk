#
# BoardConfig for Samsung Galaxy Tab S6 LTE (SM-T865) - gts6l
# SoC: Qualcomm SM8150 (Snapdragon 855) / platform "msmnile"
# Stock kernel: Linux 4.14.190, stock firmware T865XXS6DWH2 (Android 11 / OneUI 3.1.1 base)
#

DEVICE_PATH := device/samsung/gts6l

ALLOW_MISSING_DEPENDENCIES := true

# ---------------------------------------------------------------- Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := generic
TARGET_CPU_VARIANT_RUNTIME := kryo385

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv8-2a
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := cortex-a75
TARGET_2ND_CPU_VARIANT_RUNTIME := cortex-a75

# ------------------------------------------------------------------ Bootloader
TARGET_BOOTLOADER_BOARD_NAME := msmnile
TARGET_BOARD_PLATFORM := msmnile
TARGET_BOARD_PLATFORM_GPU := qcom-adreno640
TARGET_NO_BOOTLOADER := true
TARGET_USES_UEFI := false
TARGET_OTA_ASSERT_DEVICE := gts6l,gts6lxx,SM-T865

# --------------------------------------------------------------------- Kernel
# The DTBO (4 overlays, 1052625 bytes) IS embedded in the stock recovery
# image as recovery_dtbo (boot header v1), extracted to prebuilt/dtbo.img.
BOARD_INCLUDE_RECOVERY_DTBO := true
BOARD_PREBUILT_DTBOIMAGE := $(DEVICE_PATH)/prebuilt/dtbo.img
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/kernel
TARGET_KERNEL_ARCH := arm64
TARGET_KERNEL_HEADER_ARCH := arm64

BOARD_BOOT_HEADER_VERSION := 1
BOARD_KERNEL_BASE := 0x00000000
BOARD_KERNEL_PAGESIZE := 4096
BOARD_KERNEL_OFFSET := 0x00008000
BOARD_RAMDISK_OFFSET := 0x02000000
BOARD_KERNEL_TAGS_OFFSET := 0x01e00000
BOARD_KERNEL_SECOND_OFFSET := 0x00000000

BOARD_KERNEL_CMDLINE := console=null androidboot.hardware=qcom androidboot.console=ttyMSM0
BOARD_KERNEL_CMDLINE += androidboot.memcg=1 lpm_levels.sleep_disabled=1
BOARD_KERNEL_CMDLINE += video=vfb:640x400,bpp=32,memsize=3072000
BOARD_KERNEL_CMDLINE += msm_rtb.filter=0x237 service_locator.enable=1 swiotlb=2048
BOARD_KERNEL_CMDLINE += androidboot.usbcontroller=a600000.dwc3
BOARD_KERNEL_CMDLINE += firmware_class.path=/vendor/firmware_mnt/image loop.max_part=7

# Board name found in the stock boot image header
BOARD_MKBOOTIMG_ARGS := --board SRPSC20B006

#  kernel supports gzip, bzip2 and LZMA initramfs (no LZ4/XZ).
BOARD_RAMDISK_USE_LZMA := true

# ----------------------------------------------------------------- Partitions
# Partition size comes from the AVB footer location of the stock recovery.img
# (file size == partition size). Verify on device with:
#   blockdev --getsize64 /dev/block/by-name/recovery
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 82792448
BOARD_FLASH_BLOCK_SIZE := 262144

BOARD_BUILD_SYSTEM_ROOT_IMAGE := true
BOARD_SYSTEMIMAGE_PARTITION_TYPE := ext4
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true
BOARD_HAS_LARGE_FILESYSTEM := true
TARGET_COPY_OUT_VENDOR := vendor
TARGET_COPY_OUT_PRODUCT := product

TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/recovery.fstab
TARGET_USES_MKE2FS := true
BOARD_SUPPRESS_SECURE_ERASE := true
RECOVERY_SDCARD_ON_DATA := true

# --------------------------------------------------------------- Platform / SPL
#  faked on purpose so that decryption works with any ROM
PLATFORM_VERSION := 16.1.0
PLATFORM_VERSION_LAST_STABLE := $(PLATFORM_VERSION)
PLATFORM_SECURITY_PATCH := 2099-12-31
VENDOR_SECURITY_PATCH := $(PLATFORM_SECURITY_PATCH)
BOOT_SECURITY_PATCH := $(PLATFORM_SECURITY_PATCH)

# ------------------------------------------------------------------------ AVB
# Samsung vbmeta must be disabled 
BOARD_AVB_ENABLE := false

# --------------------------------------------------------------- Crypto (FBE)
# The vendor side (keymaster / gatekeeper / qseecomd) is NOT part of the
# recovery image, so decryption of /data depends on /vendor blobs being
# available. Enabled so the framework is built in.
TW_INCLUDE_CRYPTO := true
TW_INCLUDE_CRYPTO_FBE := true
TW_INCLUDE_FBE_METADATA_DECRYPT := true
BOARD_USES_QCOM_FBE_DECRYPTION := true
BOARD_USES_METADATA_PARTITION := false

# ------------------------------------------------------------------- Recovery UI
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
# Panel is 2560x1600. Stock recovery uses ROTATION_LEFT, i.e. the panel is
# to 90 / 180 / 270
TW_THEME := portrait_hdpi
# NOTE: the real theme used is recovery/root/twres/ shipped in this device
# tree, which overrides whatever OrangeFox's own build copies here (device
# tree recovery/root/* is layered on top of the base build - same mechanism
# already used for init.recovery.usb.rc).
TW_ROTATION := 0

# Touch calibration for TW_ROTATION=0 (landscape), calculated from a top-left
RECOVERY_TOUCHSCREEN_SWAP_XY := true
RECOVERY_TOUCHSCREEN_FLIP_Y := true
TW_BRIGHTNESS_PATH := "/sys/class/backlight/panel0-backlight/brightness"
TW_MAX_BRIGHTNESS := 255
TW_DEFAULT_BRIGHTNESS := 100
TW_INPUT_BLACKLIST := "hbtp_vm"
TW_EXTRA_LANGUAGES := true
TW_USE_TOOLBOX := true

# --------------------------------------------------------------- Samsung extras
TW_HAS_DOWNLOAD_MODE := true
TW_NO_REBOOT_BOOTLOADER := true
TARGET_RECOVERY_QCOM_RTC_FIX := true

# Battery: newer TWRP/OrangeFox read the level through the health HAL, which
# reports a fixed 0 or 100 on this device even though
# /sys/class/power_supply/battery/capacity is correct. Use the legacy sysfs read.
TW_USE_LEGACY_BATTERY_SERVICES := false

# (Samsung VID/PID, MTP via mtp.gs0)
TW_EXCLUDE_DEFAULT_USB_INIT := true
# Samsung kernel exposes the MTP gadget
TW_MTP_DEVICE := /dev/usb_mtp_gadget

# ----------------------------------------------------------------- Filesystems
TW_INCLUDE_NTFS_3G := false
TW_INCLUDE_FUSE_EXFAT := true
TW_INCLUDE_RESETPROP := true
TW_INCLUDE_REPACKTOOLS := true
TARGET_USES_LOGD := true
TWRP_INCLUDE_LOGCAT := true

# ------------------------------------------------------------------------ Debug
TARGET_RECOVERY_DEVICE_DIRS += $(DEVICE_PATH)
