# Copyright 2025 The ElementOS Project
# SPDX-License-Identifier: Apache-2.0

# Inherit from common AOSP product
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Device identifier
PRODUCT_DEVICE := r8s
PRODUCT_NAME := element_r8s
PRODUCT_BRAND := samsung
PRODUCT_MODEL := SM-G780F
PRODUCT_MANUFACTURER := samsung

# Boot animation
TARGET_SCREEN_HEIGHT := 2400
TARGET_SCREEN_WIDTH := 1080

# Inherit common ElementOS vendor
$(call inherit-product, vendor/elementos/config/common.mk)
