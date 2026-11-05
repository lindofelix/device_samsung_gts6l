#
# Samsung Galaxy Tab S6 LTE (SM-T865) - gts6l
#

# Architecture: 64-bit with 32-bit secondary
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base_telephony.mk)

# Recovery (TWRP / OrangeFox) common configuration
$(call inherit-product, vendor/twrp/config/common.mk)

# Device configuration
$(call inherit-product, device/samsung/gts6l/device.mk)

PRODUCT_DEVICE := gts6l
PRODUCT_NAME := twrp_gts6l
PRODUCT_BRAND := samsung
PRODUCT_MODEL := SM-T865
PRODUCT_MANUFACTURER := samsung
PRODUCT_RELEASE_NAME := Samsung Galaxy Tab S6 LTE

# Stock fingerprint taken from the supplied recovery (prop.default)
PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="gts6lxx-user 11 RP1A.200720.012 T865XXS6DWH2 release-keys"

BUILD_FINGERPRINT := samsung/gts6lxx/gts6l:11/RP1A.200720.012/T865XXS6DWH2:user/release-keys
