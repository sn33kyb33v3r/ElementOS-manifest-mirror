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

# ElementOS vendor configuration

# Privacy-focused defaults
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.privacy.droidguard=0 \
    ro.privacy.analytics=0 \
    ro.privacy.location=0 \
    ro.privacy.telephony=0 \
    ro.privacy.sensors=0 \
    ro.privacy.camera=0 \
    ro.privacy.microphone=0

# Disable Google services completely
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.google.gmsversion=0 \
    ro.google.clientidbase=0 \
    ro.google.services=0

# Security enhancements
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.security.cfi=1 \
    ro.security.rap=1 \
    ro.security.stackprotector=1 \
    ro.security.fortify=1 \
    ro.security.selinux=1 \
    ro.security.secureboot=1

# Reproducible builds
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.build.date.utc=1640995200 \
    ro.build.date=20220101.000000 \
    ro.build.version.incremental=E000001

# F-Droid as default app store
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.fdroid.autoinstall=1 \
    ro.fdroid.privileged=1

# ElementOS branding
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.elementos.version=1.0 \
    ro.elementos.build.type=community \
    ro.elementos.security.patch=$(shell date +%Y-%m-%d)

# Disable telemetry
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.config.analytics=0 \
    ro.config.metrics=0 \
    ro.config.crashreport=0

# Network security
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.net.dns.secure=1 \
    ro.net.ipv6.privacy=1 \
    ro.net.wifi.scan=0

# USB security
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.usb.mtp=0x2e82 \
    ro.usb.mtp_adb=0x2e76 \
    ro.usb.ptp=0x2e83 \
    ro.usb.ptp_adb=0x2e84

# Default packages
PRODUCT_PACKAGES += \
    ElementInitialSetup \
    ElementPrivacyDashboard \
    ElementF-Droid \
    ElementUpdater \
    ElementSettingsProvider

# Overlays
PRODUCT_PACKAGES += \
    ElementRROOverlay

# Themes
PRODUCT_PACKAGES += \
    ElementThemesStub

# Permissions
PRODUCT_COPY_FILES += \
    vendor_elementos/config/privapp-permissions-elementos.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/privapp-permissions-elementos.xml

# Config
PRODUCT_COPY_FILES += \
    vendor_elementos/config/elementos-config.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/elementos-config.xml

# Prebuilt apps
PRODUCT_COPY_FILES += \
    vendor_elementos/prebuilt/F-Droid.apk:$(TARGET_COPY_OUT_SYSTEM)/app/F-Droid/F-Droid.apk \
    vendor_elementos/prebuilt/F-DroidPrivilegedExtension.apk:$(TARGET_COPY_OUT_SYSTEM)/priv-app/F-DroidPrivilegedExtension/F-DroidPrivilegedExtension.apk

# Enable dex preopt
PRODUCT_DEXPREOPT_SPEED_APPS += \
    SystemUI \
    Settings \
    ElementPrivacyDashboard

# Disable Google services
PRODUCT_PACKAGES += \
    GmsCore \
    GoogleFeedback \
    GoogleOneTimeInitializer \
    GooglePartnerSetup \
    GoogleQuickSearchBox \
    GoogleServicesFramework \
    HotwordEnrollment \
    MarkupGoogle \
    PlayAutoInstallConfig \
    PrebuiltGmail \
    PrebuiltGoogleTelemetry \
    PrebuiltKeep \
    PrebuiltNewsWeather \
    PrebuiltPixelBridge \
    PrebuiltGmsCore \
    SetupWizardPrebuilt \
    SpeechServicesByGoogle \
    TagGoogle \
    Turbo \
    Wellbeing \
    YouTube

# Remove Google packages
PRODUCT_PACKAGES_REMOVE += \
    GmsCore \
    GoogleFeedback \
    GoogleOneTimeInitializer \
    GooglePartnerSetup \
    GoogleQuickSearchBox \
    GoogleServicesFramework \
    HotwordEnrollment \
    MarkupGoogle \
    PlayAutoInstallConfig \
    PrebuiltGmail \
    PrebuiltGoogleTelemetry \
    PrebuiltKeep \
    PrebuiltNewsWeather \
    PrebuiltPixelBridge \
    PrebuiltGmsCore \
    SetupWizardPrebuilt \
    SpeechServicesByGoogle \
    TagGoogle \
    Turbo \
    Wellbeing \
    YouTube

# ElementOS specific overlays
PRODUCT_PACKAGE_OVERLAYS += \
    vendor_elementos/overlays/common

# Build flags
PRODUCT_BUILD_FLAGS += \
    --exclude-from-all-users \
    --exclude-from-recovery

# Security flags
PRODUCT_SECURITY_FLAGS += \
    -fstack-protector-strong \
    -fPIC \
    -fPIE

# Global settings
PRODUCT_GLOBAL_SETTINGS += \
    --enable-privacy-mode \
    --disable-analytics \
    --disable-telemetry \
    --enable-security-hardening

# End of ElementOS vendor configuration