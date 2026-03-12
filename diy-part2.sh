#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Modify default IP
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

# Modify default theme
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
#sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate
# ==============================================
# 强制锁定目标设备为 Zyxel NWA130BE（核心修正）
# ==============================================
cd $GITHUB_WORKSPACE/openwrt || exit 1

# 1. 删除所有 IPQ53xx 设备的配置（清空原有设备选择）
sed -i '/CONFIG_TARGET_qualcommax_ipq53xx_DEVICE_/d' .config

# 2. 强制写入 NWA130BE 设备配置
echo 'CONFIG_TARGET_qualcommax_ipq53xx_DEVICE_zyxel_nwa130be=y' >> .config

# 3. 重新生成 defconfig，确保配置生效
make defconfig

# 可选：打印确认信息，方便日志验证
echo "✅ 已强制锁定目标设备为 Zyxel NWA130BE"
grep 'CONFIG_TARGET_qualcommax_ipq53xx_DEVICE_' .config
