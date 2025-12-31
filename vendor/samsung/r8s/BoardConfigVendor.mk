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

# BoardConfigVendor.mk for Samsung Galaxy S20 FE (r8s)

# Vendor path
BOARD_VENDOR := samsung

# Proprietary files
BOARD_PROPRIETARY_DEVICE_DIR := vendor/samsung/r8s

# HAL paths
TARGET_HAL_PATH := hardware/samsung

# Graphics
BOARD_USES_DRM_HWCOMPOSER := true
BOARD_USES_GRALLOC1 := true
BOARD_USES_ION := true

# Camera
BOARD_USE_SAMSUNG_CAMERAFORMAT_NV21 := true

# Audio
BOARD_USES_ALSA_AUDIO := true
BOARD_USES_GENERIC_AUDIO := false

# Bluetooth
BOARD_HAVE_BLUETOOTH := true
BOARD_HAVE_BLUETOOTH_BCM := true

# GPS
TARGET_NO_RPC := true

# WiFi
BOARD_WLAN_DEVICE := bcmdhd
BOARD_WPA_SUPPLICANT_DRIVER := NL80211
BOARD_WPA_SUPPLICANT_PRIVATE_LIB := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
BOARD_HOSTAPD_DRIVER := NL80211
BOARD_HOSTAPD_PRIVATE_LIB := lib_driver_cmd_$(BOARD_WLAN_DEVICE)

# NFC
BOARD_NFC_CHIPSET := pn547

# Fingerprint
BOARD_USES_FINGERPRINT := true

# Sensors
BOARD_USES_SENSORS := true

# Lights
BOARD_USES_LIGHTS := true

# Power
BOARD_USES_POWERHAL := true

# Vibrator
BOARD_USES_VIBRATOR := true

# Thermal
BOARD_USES_THERMALHAL := true

# USB
BOARD_USES_USBHAL := true

# DRM
BOARD_USES_DRM := true

# Widevine
BOARD_USES_WIDEVINE := true

# Neural networks
BOARD_USES_NEURALNETWORKS := true

# TEE
BOARD_USES_TEE := true

# Keymaster
BOARD_USES_KEYMASTER := true

# Gatekeeper
BOARD_USES_GATEKEEPER := true

# Trust HAL
BOARD_USES_TRUSTHAL := true

# Health HAL
BOARD_USES_HEALTHHAL := true

# Storage
BOARD_USES_STORAGEHAL := true

# USB gadget
BOARD_USES_USB_GADGET := true

# End of BoardConfigVendor.mk