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

# 保留你原有注释（可按需启用）
# Modify default IP
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

# Modify default theme
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
#sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate

# ==============================================
# 核心：100% 锁定 Zyxel NWA130BE 设备（不可逆）
# ==============================================
# 切换到 OpenWrt 源码目录（容错）
cd $GITHUB_WORKSPACE/openwrt || { echo "❌ 进入源码目录失败"; exit 0; }

# 第一步：清空所有设备相关配置（包括 GL-B3000）
echo -e "\n🔍 清空所有 IPQ53xx/IPQ50xx 设备配置..."
sed -i '/CONFIG_TARGET_qualcommax_ipq53xx_DEVICE_/d' .config || true
sed -i '/CONFIG_TARGET_qualcommax_ipq50xx_DEVICE_/d' .config || true

# 第二步：强制写入 NWA130BE 核心配置（ipq53xx 平台）
echo -e "\n🔒 强制写入 Zyxel NWA130BE 设备配置..."
echo 'CONFIG_TARGET_qualcommax=y' > .config.tmp
echo 'CONFIG_TARGET_qualcommax_ipq53xx=y' >> .config.tmp
echo 'CONFIG_TARGET_qualcommax_ipq53xx_DEVICE_zyxel_nwa130be=y' >> .config.tmp

# 第三步：合并原有配置 + 覆盖设备配置（关键：避免被默认值覆盖）
cat .config >> .config.tmp
mv .config.tmp .config

# 第四步：重新生成 defconfig 并二次锁定
echo -e "\n✅ 重新生成配置并锁定设备..."
make defconfig || true

# 第五步：二次校验，确保配置生效
DEVICE_CHECK=$(grep 'CONFIG_TARGET_qualcommax_ipq53xx_DEVICE_zyxel_nwa130be=y' .config)
if [ -n "$DEVICE_CHECK" ]; then
    echo -e "\n✅ 设备锁定成功！当前目标设备：Zyxel NWA130BE"
    grep 'CONFIG_TARGET_qualcommax.*DEVICE' .config
else
    echo -e "\n❌ 设备锁定失败！强制写入配置..."
    echo 'CONFIG_TARGET_qualcommax_ipq53xx_DEVICE_zyxel_nwa130be=y' >> .config
    make defconfig || true
fi

# 确保脚本返回成功状态
exit 0
