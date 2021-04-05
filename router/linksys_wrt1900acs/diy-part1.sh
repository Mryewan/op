#!/bin/bash
#========================================================================================================================
# https://github.com/ophub/op
# Description: Automatically Build OpenWrt for Linksys WRT1900ACS
# Function: Diy script (Before Update feeds, Modify the default IP, hostname, theme, add/remove software packages, etc.)
# Copyright (C) 2020 https://github.com/P3TERX/Actions-OpenWrt
# Copyright (C) 2020 https://github.com/ophub/op
#========================================================================================================================

#Clone SSRPlus source code
git clone https://github.com/fw876/helloworld packages/SSRPlus
#git lua-maxminddb 依赖
git clone https://github.com/jerrykuku/lua-maxminddb.git package/lua-maxminddb
#Clone  vssr
git clone https://github.com/jerrykuku/luci-app-vssr.git package/luci-app-vssr-plus

#passwall依赖及下载源码
git clone https://github.com/yiguihai/luci-app-passwall-plus.git package/luci-app-passwall-plus

#luci-app-ssr-plus依赖包下载源码
#git clone https://github.com/romantices/luci-app-ssr-plus-jo-1.git package/luci-app-ssr-plus
#git clone https://github.com/maxlicheng/luci-app-ssr-plus.git package/luci-app-ssr-plus

#luci-app-v2ray-server
git clone https://github.com/esirplayground/luci-app-v2ray-server.git package/luci-app-v2ray-server

#Clone OpenAppFilter source code
git clone https://github.com/destan19/OpenAppFilter package/OpenAppFilter

#L大源码
git clone https://github.com/coolsnowwolf/lede.git package/lede
git clone https://github.com/liuran001/openwrt-packages.git package/openwrt-packages
#git clone https://github.com/kenzok8/openwrt-packages.git package/openwrt-packages

#ipk全固件
#git clone https://github.com/liuran001/openwrt-packages.git package/openwrt-packages

# Uncomment a feed source
sed -i 's/#src-git helloworld/src-git helloworld/g' ./feeds.conf.default
# sed -i 's/\"#src-git\"/\"src-git\"/g' feeds.conf.default

# Add a feed source
# sed -i '$a src-git lienol https://github.com/Lienol/openwrt-package' feeds.conf.default
#sed -i '$a src-git kenzo https://github.com/kenzok8/openwrt-packages' feeds.conf.default
#sed -i '$a src-git liuran001_packages https://github.com/liuran001/openwrt-packages' feeds.conf.default
