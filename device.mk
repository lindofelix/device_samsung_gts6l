LOCAL_PATH := device/samsung/gts6l

PRODUCT_SOONG_NAMESPACES += $(LOCAL_PATH)

# First API level (ro.product.first_api_level=28 in stock)
PRODUCT_SHIPPING_API_LEVEL := 28

# Partitions are NOT dynamic on this device (system/vendor/product are
# plain by-name partitions), and it is not A/B.
PRODUCT_USE_DYNAMIC_PARTITIONS := false

PRODUCT_PLATFORM := msmnile

# Qualcomm FBE decryption helpers (only effective together with the
# vendor blobs present on /vendor of the device)
PRODUCT_PACKAGES += \
    qcom_decrypt \
    qcom_decrypt_fbe
