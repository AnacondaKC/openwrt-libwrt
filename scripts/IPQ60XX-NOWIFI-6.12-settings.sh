#!/bin/bash

#================================================================================
# OpenWrt First Boot Initialization Script for Bypass Router (Side Router)
#================================================================================

# 请在这里修改为你自己的网络配置
#================================================================================
# 旁路由的静态IP地址 (必须与主路由在同一网段, 且不能在主路由的DHCP范围内)
BYPASS_IPADDR='192.168.7.2'

# 主路由的IP地址 (你的家庭网络网关)
MAIN_GATEWAY='192.168.7.1'

# 子网掩码 (通常是 255.255.255.0)
NETMASK='255.255.255.0'

# DNS服务器 (可以设置为主路由IP, 或公共DNS)
DNS_SERVER='192.168.7.1'
#================================================================================


# 1. 配置LAN口网络
#--------------------------------------------------------------------------------
echo "Setting up LAN interface..."
uci set network.lan.proto='static'
uci set network.lan.ipaddr="$BYPASS_IPADDR"
uci set network.lan.netmask="$NETMASK"
uci set network.lan.gateway="$MAIN_GATEWAY"
uci set network.lan.dns="$DNS_SERVER"
# 禁用桥接，因为我们是单网口设备作为旁路由
uci delete network.lan.type


# 2. 关闭并忽略DHCP服务 (旁路由模式最关键的一步!)
#--------------------------------------------------------------------------------
echo "Disabling DHCP server..."
# 关闭LAN口的DHCP服务
uci set dhcp.lan.ignore='1'


# 3. 关闭IPv6相关服务 (简化旁路由网络)
#--------------------------------------------------------------------------------
echo "Disabling IPv6 services..."
# 关闭IPv6的DHCP服务
uci set dhcp.lan.dhcpv6='disabled'
# 关闭IPv6的路由通告
uci set dhcp.lan.ra='disabled'
# 彻底禁用 network 配置中的 IPv6 ULA 前缀
sed -i 's/^[^#].*option ula_prefix/#&/' /etc/config/network


# 4. 设置默认主题为 argon
#--------------------------------------------------------------------------------
echo "Setting default theme to argon..."
uci set luci.main.mediaurlbase='/luci-static/argon'


# 5. 保存所有配置
#--------------------------------------------------------------------------------
echo "Committing all changes..."
uci commit network
uci commit dhcp
uci commit luci

echo "Initialization complete. The device will reboot if necessary."

exit 0
