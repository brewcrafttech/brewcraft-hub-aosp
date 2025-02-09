#
# Copyright 2014 The Android Open-Source Project
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

# First lunching is R, api_level is 30
PRODUCT_SHIPPING_API_LEVEL := 30
PRODUCT_DTBO_TEMPLATE := $(LOCAL_PATH)/dt-overlay.in
PRODUCT_BOOT_DEVICE := fe330000.sdhci,fe320000.dwmmc
include device/rockchip/common/build/rockchip/DynamicPartitions.mk
include device/rockchip/rk3399/rk3399_ROCKPI4B_Android11_BrewHub/BoardConfig.mk
include device/rockchip/common/BoardConfig.mk
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base.mk)
# Inherit from those products. Most specific first.
$(call inherit-product, device/rockchip/rk3399/device.mk)
$(call inherit-product, device/rockchip/common/device.mk)

PRODUCT_CHARACTERISTICS := box

PRODUCT_NAME := rk3399_ROCKPI4B_Android11_BrewHub
PRODUCT_DEVICE := rk3399_ROCKPI4B_Android11_BrewHub
PRODUCT_BRAND := brewcraft.tech
PRODUCT_MODEL := brew-hub-1
PRODUCT_MANUFACTURER := brewcraft.tech
PRODUCT_AAPT_PREF_CONFIG := hdpi

PRODUCT_PACKAGES += \
    SoundRecorder

PRODUCT_PACKAGE_OVERLAYS += device/rockchip/rk3399/rk3399_ROCKPI4B_Android11_BrewHub/overlay
PRODUCT_PACKAGE_OVERLAYS += device/rockchip/rk3399/screen_always_on_overlay
# Get the long list of APNs
PRODUCT_COPY_FILES += vendor/rockchip/common/phone/etc/apns-full-conf.xml:system/etc/apns-conf.xml
PRODUCT_COPY_FILES += vendor/rockchip/common/phone/etc/spn-conf.xml:system/etc/spn-conf.xml
PRODUCT_PROPERTY_OVERRIDES += \
    ro.product.version = 1.0.0 \
    ro.product.ota.host = 192.168.1.1:8888 \
    ro.sf.lcd_density=280 \
    vendor.hwc.device.primary=DSI \
    vendor.hwc.device.extend=HDMI-A \
    persist.vendor.framebuffer.main=1920x1080@60 \
    persist.sys.root_access=3 \
