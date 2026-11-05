#
# OrangeFox build flags for gts6l (Samsung Galaxy Tab S6 LTE, SM-T865)
#
FDEVICE="gts6l"

fox_get_target_device() {
	local chkdev=$(echo "$BASH_SOURCE" | grep -w $FDEVICE)
	if [ -n "$chkdev" ]; then
		FOX_BUILD_DEVICE="$FDEVICE"
	else
		chkdev=$(set | grep BASH_ARGV | grep -w $FDEVICE)
		[ -n "$chkdev" ] && FOX_BUILD_DEVICE="$FDEVICE"
	fi
}

if [ -z "$1" -a -z "$FOX_BUILD_DEVICE" ]; then
	fox_get_target_device
fi

if [ "$1" = "$FDEVICE" -o "$FOX_BUILD_DEVICE" = "$FDEVICE" ]; then
	export ALLOW_MISSING_DEPENDENCIES=true
	export LC_ALL="C"

	# Device identity
	export TARGET_DEVICE_ALT="gts6l,gts6lxx,SM-T865"
	export FOX_BUILD_DEVICE="$FDEVICE"

	# Non-A/B device with a dedicated recovery partition
	export FOX_RECOVERY_INSTALL_PARTITION="/dev/block/bootdevice/by-name/recovery"
	export FOX_RECOVERY_BOOT_PARTITION="/dev/block/bootdevice/by-name/boot"

	# Keep the ramdisk small (kernel ~47 MiB + dtbo 1 MiB, partition ~79 MiB)
	export FOX_DELETE_AROMAFM=1
	export FOX_DELETE_INITD_ADDON=1
	export FOX_REMOVE_AAPT=1
	export FOX_USE_NANO_EDITOR=1
	export FOX_USE_TAR_BINARY=1
	export FOX_USE_SED_BINARY=1
	export FOX_USE_XZ_UTILS=1
	export FOX_USE_BASH_SHELL=1
	export FOX_ASH_IS_BASH=1
	export FOX_REPLACE_BUSYBOX_PS=1

	# Magisk / boot patching
	export OF_USE_MAGISKBOOT=1
	export OF_USE_MAGISKBOOT_FOR_ALL_PATCHES=1

	# Tablet specifics
	export OF_NO_TREBLE_COMPATIBILITY_CHECK=1
	export OF_USE_GREEN_LED=0
	export OF_FLASHLIGHT_ENABLE=0
	export OF_CLASSIC_LEDS_FUNCTION=0

	# Build info
	export FOX_VARIANT="SM-T865"
	export OF_MAINTAINER="Unofficial"

	# Info
	echo "Configured OrangeFox flags for $FDEVICE"
fi
