#
# Copyright (C) 2024 ElementOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# ElementOS product configuration for Samsung Galaxy S20 FE (r8s)

# Inherit from common AOSP
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit from device-specific configuration
$(call inherit-product, device/samsung/r8s/device.mk)

# Inherit from ElementOS vendor
$(call inherit-product, vendor_elementos/config/common.mk)

# Device identifiers
PRODUCT_DEVICE := r8s
PRODUCT_NAME := element_r8s
PRODUCT_BRAND := samsung
PRODUCT_MODEL := SM-G780F
PRODUCT_MANUFACTURER := samsung
PRODUCT_GMS_CLIENTID_BASE := android-samsung

# Build fingerprint
BUILD_FINGERPRINT := samsung/r8sxx/r8s:13/TP1A.220624.014/G780FXXU5CVK1:user/release-keys
PRIVATE_BUILD_DESC := "r8sxx-user 13 TP1A.220624.014 G780FXXU5CVK1 release-keys"

# Override build properties
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.build.fingerprint=$(BUILD_FINGERPRINT) \
    ro.bootimage.build.fingerprint=$(BUILD_FINGERPRINT) \
    ro.build.description=$(PRIVATE_BUILD_DESC)

# A/B update
AB_OTA_UPDATER := true
AB_OTA_PARTITIONS += \
    boot \
    system \
    vendor \
    product

# Dynamic partitions
PRODUCT_USE_DYNAMIC_PARTITIONS := true
PRODUCT_BUILD_SUPER_PARTITION := true

# Boot animation
TARGET_SCREEN_HEIGHT := 2400
TARGET_SCREEN_WIDTH := 1080
TARGET_BOOT_ANIMATION_RES := 1080

# Default properties
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.control_privacy_debug=1 \
    persist.sys.privacy_guard=1 \
    ro.url.legal=http://www.google.com/intl/%s/mobile/android/basic/phone-legal.html \
    ro.url.legal.android_privacy=http://www.google.com/intl/%s/mobile/android/basic/privacy.html \
    ro.com.google.clientidbase=android-samsung \
    ro.com.android.wifi-watchlist=GoogleGuest \
    ro.setupwizard.enterprise_mode=1 \
    ro.com.android.dateformat=MM-dd-yyyy \
    ro.com.android.dataroaming=false

# Default settings
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    persist.sys.timezone=UTC \
    persist.sys.language=en \
    persist.sys.country=US \
    persist.sys.localevar= \
    persist.sys.dalvik.vm.lib.2=libart.so \
    dalvik.vm.isa.arm64.variant=cortex-a76 \
    dalvik.vm.isa.arm64.features=default \
    dalvik.vm.isa.arm.variant=cortex-a76 \
    dalvik.vm.isa.arm.features=default

# Privacy features
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.privacy.droidguard=0 \
    ro.privacy.analytics=0 \
    ro.privacy.location=0 \
    ro.privacy.telephony=0 \
    ro.privacy.sensors=0

# Disable Google services
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.google.gmsversion=0 \
    ro.google.clientidbase=0

# Security features
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.security.cfi=1 \
    ro.security.rap=1 \
    ro.security.stackprotector=1 \
    ro.security.fortify=1

# Performance
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    dalvik.vm.heapstartsize=16m \
    dalvik.vm.heapgrowthlimit=256m \
    dalvik.vm.heapsize=512m \
    dalvik.vm.heaputilization=0.5 \
    dalvik.vm.heapidealfree=8388608 \
    dalvik.vm.heapconcurrentstart=2097152

# Graphics
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.opengles.version=196610 \
    ro.hardware.egl=mali

# Audio
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.config.ringtone=The_big_adventure.ogg \
    ro.config.notification_sound=Popcorn.ogg \
    ro.config.alarm_alert=Alarm_Beep_03.ogg

# Bluetooth
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.bluetooth.dun=true \
    ro.bluetooth.hfp=true \
    ro.bluetooth.sap=true

# WiFi
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    wifi.interface=wlan0

# USB
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.usb.mtp=0x2e82 \
    ro.usb.mtp_adb=0x2e76 \
    ro.usb.ptp=0x2e83 \
    ro.usb.ptp_adb=0x2e84 \
    ro.usb.bpt=0x2e8a \
    ro.usb.bpt_adb=0x2e8b

# NFC
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.nfc.port=I2C

# Telephony
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.telephony.default_network=9 \
    ro.telephony.call_ring.multiple=false

# Sensors
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.hardware.sensors=r8s

# Lights
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.hardware.lights=r8s

# Power
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.hardware.power=r8s

# Vibrator
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.hardware.vibrator=r8s

# Fingerprint
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.hardware.fingerprint=r8s

# Charger
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.charger.enable_suspend=true

# Recovery
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.recovery.ui=elevation

# ElementOS specific
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.elementos.version=1.0 \
    ro.elementos.device=${PRODUCT_DEVICE} \
    ro.elementos.maintainer=ElementOS \
    ro.elementos.build.type=community \
    ro.elementos.security.patch=$(shell date +%Y-%m-%d)

# Packages
PRODUCT_PACKAGES += \
    ElementInitialSetup \
    ElementPrivacyDashboard \
    ElementF-Droid \
    ElementUpdater

# Permissions
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.audio.low_latency.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.audio.low_latency.xml \
    frameworks/native/data/etc/android.hardware.audio.pro.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.audio.pro.xml \
    frameworks/native/data/etc/android.hardware.bluetooth.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth.xml \
    frameworks/native/data/etc/android.hardware.bluetooth_le.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth_le.xml \
    frameworks/native/data/etc/android.hardware.camera.flash-autofocus.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.flash-autofocus.xml \
    frameworks/native/data/etc/android.hardware.camera.front.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.front.xml \
    frameworks/native/data/etc/android.hardware.camera.full.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.full.xml \
    frameworks/native/data/etc/android.hardware.camera.raw.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.raw.xml \
    frameworks/native/data/etc/android.hardware.fingerprint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.fingerprint.xml \
    frameworks/native/data/etc/android.hardware.location.gps.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.location.gps.xml \
    frameworks/native/data/etc/android.hardware.nfc.hcef.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.hcef.xml \
    frameworks/native/data/etc/android.hardware.nfc.hce.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.hce.xml \
    frameworks/native/data/etc/android.hardware.nfc.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.xml \
    frameworks/native/data/etc/android.hardware.opengles.aep.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.opengles.aep.xml \
    frameworks/native/data/etc/android.hardware.sensor.accelerometer.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.accelerometer.xml \
    frameworks/native/data/etc/android.hardware.sensor.barometer.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.barometer.xml \
    frameworks/native/data/etc/android.hardware.sensor.compass.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.compass.xml \
    frameworks/native/data/etc/android.hardware.sensor.gyroscope.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.gyroscope.xml \
    frameworks/native/data/etc/android.hardware.sensor.hifi_sensors.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.hifi_sensors.xml \
    frameworks/native/data/etc/android.hardware.sensor.light.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.light.xml \
    frameworks/native/data/etc/android.hardware.sensor.proximity.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.proximity.xml \
    frameworks/native/data/etc/android.hardware.sensor.stepcounter.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.stepcounter.xml \
    frameworks/native/data/etc/android.hardware.sensor.stepdetector.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.stepdetector.xml \
    frameworks/native/data/etc/android.hardware.telephony.cdma.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.cdma.xml \
    frameworks/native/data/etc/android.hardware.telephony.gsm.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.gsm.xml \
    frameworks/native/data/etc/android.hardware.telephony.ims.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.ims.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.distinct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.multitouch.distinct.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.jazzhand.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.multitouch.jazzhand.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.multitouch.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.xml \
    frameworks/native/data/etc/android.hardware.usb.accessory.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.accessory.xml \
    frameworks/native/data/etc/android.hardware.usb.host.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.host.xml \
    frameworks/native/data/etc/android.hardware.vulkan.compute-0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.compute-0.xml \
    frameworks/native/data/etc/android.hardware.vulkan.level-1.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.level-1.xml \
    frameworks/native/data/etc/android.hardware.vulkan.version-1_1.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.version-1_1.xml \
    frameworks/native/data/etc/android.hardware.wifi.direct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.direct.xml \
    frameworks/native/data/etc/android.hardware.wifi.passpoint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.passpoint.xml \
    frameworks/native/data/etc/android.hardware.wifi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.xml \
    frameworks/native/data/etc/handheld_core_hardware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/handheld_core_hardware.xml

# Key layouts
PRODUCT_COPY_FILES += \
    device/samsung/r8s/keylayout/gpio-keys.kl:$(TARGET_COPY_OUT_VENDOR)/usr/keylayout/gpio-keys.kl \
    device/samsung/r8s/keylayout/sec_touchkey.kl:$(TARGET_COPY_OUT_VENDOR)/usr/keylayout/sec_touchkey.kl

# Thermal
PRODUCT_COPY_FILES += \
    device/samsung/r8s/thermal/thermal_info_config.json:$(TARGET_COPY_OUT_VENDOR)/etc/thermal_info_config.json

# Audio
PRODUCT_COPY_FILES += \
    device/samsung/r8s/audio/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration.xml \
    device/samsung/r8s/audio/audio_effects.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects.xml

# F-Droid privileged extension
PRODUCT_COPY_FILES += \
    vendor_elementos/prebuilt/F-Droid.apk:$(TARGET_COPY_OUT_SYSTEM)/app/F-Droid/F-Droid.apk \
    vendor_elementos/prebuilt/F-DroidPrivilegedExtension.apk:$(TARGET_COPY_OUT_SYSTEM)/priv-app/F-DroidPrivilegedExtension/F-DroidPrivilegedExtension.apk

# Overlays
PRODUCT_ENFORCE_RRO_TARGETS := *
PRODUCT_PACKAGES += \
    ElementRROOverlay

# Themes
PRODUCT_PACKAGES += \
    ElementThemesStub

# Vendor security patch level
VENDOR_SECURITY_PATCH := $(PLATFORM_SECURITY_PATCH)

# Build date
BUILD_DATE := $(shell date +%Y%m%d)

# Product characteristics
PRODUCT_CHARACTERISTICS := nosdcard

# AAPT config
PRODUCT_AAPT_CONFIG := normal
PRODUCT_AAPT_PREF_CONFIG := xxhdpi

# Device uses high-density artwork where available
PRODUCT_AAPT_CONFIG += xhdpi xxhdpi

# Priv-app permissions
PRODUCT_COPY_FILES += \
    device/samsung/r8s/config/privapp-permissions-elementos.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/privapp-permissions-elementos.xml

# Default apps
PRODUCT_PACKAGES += \
    messaging \
    Gallery2 \
    Etar \
    OpenCamera \
    Jelly \
    K9Mail \
    OsmAnd

# Import vendor makefiles
$(call inherit-product-if-exists, vendor/samsung/r8s/r8s-vendor.mk)