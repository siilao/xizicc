#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # 重置颜色

# 清理屏幕并显示标题
clear
echo -e "${BLUE}=============================================${NC}"
echo -e "${PURPLE}            系统信息查询                   ${NC}"
echo -e "${BLUE}=============================================${NC}\n"

# ========== 1. 基础系统信息 ==========
echo -e "${GREEN}【1. 基础系统信息】${NC}"
echo -e "---------------------------------------------"

# 系统发行版
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_NAME="$NAME $VERSION"
elif [ -f /etc/redhat-release ]; then
    OS_NAME=$(cat /etc/redhat-release)
elif [ -f /etc/issue ]; then
    OS_NAME=$(cat /etc/issue | head -n1 | sed -e 's/\\n//g' -e 's/\\l//g' -e 's/ //g')
else
    OS_NAME="未知系统"
fi
echo -e "${YELLOW}系统发行版：${NC}$OS_NAME"

# 内核版本
KERNEL=$(uname -r)
echo -e "${YELLOW}内核版本：${NC}$KERNEL"

# 系统架构
ARCH=$(uname -m)
echo -e "${YELLOW}系统架构：${NC}$ARCH"

# 主机名
HOSTNAME=$(hostname)
echo -e "${YELLOW}主机名：${NC}$HOSTNAME"

# 系统运行时间
UPTIME=$(uptime -p | sed 's/up //g')
echo -e "${YELLOW}运行时间：${NC}$UPTIME"

# 系统启动时间
BOOT_TIME=$(who -b | awk '{print $3, $4}')
echo -e "${YELLOW}启动时间：${NC}$BOOT_TIME"

# ========== 2. 硬件资源信息 ==========
echo -e "\n${GREEN}【2. 硬件资源信息】${NC}"
echo -e "---------------------------------------------"

# CPU信息
CPU_MODEL=$(cat /proc/cpuinfo | grep 'model name' | head -n1 | cut -d: -f2 | sed -e 's/^[ \t]*//')
CPU_CORES=$(grep -c ^processor /proc/cpuinfo)
CPU_THREADS=$(nproc)
echo -e "${YELLOW}CPU型号：${NC}$CPU_MODEL"
echo -e "${YELLOW}CPU核心数：${NC}$CPU_CORES (线程数：$CPU_THREADS)"

# 内存信息
if command -v free &>/dev/null; then
    MEM_TOTAL=$(free -h | grep Mem | awk '{print $2}')
    MEM_USED=$(free -h | grep Mem | awk '{print $3}')
    MEM_FREE=$(free -h | grep Mem | awk '{print $4}')
    MEM_USAGE=$(free | grep Mem | awk '{printf("%.1f%%", $3/$2*100)}')
    echo -e "${YELLOW}内存总量：${NC}$MEM_TOTAL"
    echo -e "${YELLOW}已用内存：${NC}$MEM_USED (使用率：$MEM_USAGE)"
    echo -e "${YELLOW}空闲内存：${NC}$MEM_FREE"
else
    echo -e "${YELLOW}内存信息：${NC}无法获取"
fi

# 磁盘信息
if command -v df &>/dev/null; then
    DISK_TOTAL=$(df -h --total | grep total | awk '{print $2}')
    DISK_USED=$(df -h --total | grep total | awk '{print $3}')
    DISK_FREE=$(df -h --total | grep total | awk '{print $4}')
    DISK_USAGE=$(df -h --total | grep total | awk '{print $5}')
    echo -e "${YELLOW}磁盘总量：${NC}$DISK_TOTAL"
    echo -e "${YELLOW}已用磁盘：${NC}$DISK_USED (使用率：$DISK_USAGE)"
    echo -e "${YELLOW}空闲磁盘：${NC}$DISK_FREE"
else
    echo -e "${YELLOW}磁盘信息：${NC}无法获取"
fi

# ========== 3. 网络信息 ==========
echo -e "\n${GREEN}【3. 网络信息】${NC}"
echo -e "---------------------------------------------"

# 公网IP（IPv4）
IPV4=$(curl -s --max-time 5 ip.sb -4 || curl -s --max-time 5 ifconfig.me -4 || echo "未获取到")
echo -e "${YELLOW}公网IPv4：${NC}$IPV4"

# 公网IP（IPv6）
IPV6=$(curl -s --max-time 5 ip.sb -6 || curl -s --max-time 5 ifconfig.me -6 || echo "未获取到/未开启")
echo -e "${YELLOW}公网IPv6：${NC}$IPV6"

# 网卡信息
echo -e "${YELLOW}网卡列表：${NC}"
ip link show | grep -E '^[0-9]' | while read -r line; do
    NIC=$(echo $line | awk '{print $2}' | sed 's/://')
    IP=$(ip addr show $NIC | grep 'inet ' | awk '{print $2}' | head -n1 || echo "无IPv4")
    IP6=$(ip addr show $NIC | grep 'inet6 ' | awk '{print $2}' | head -n1 || echo "无IPv6")
    echo -e "  - $NIC: $IP | $IP6"
done

# ========== 4. 其他信息 ==========
echo -e "\n${GREEN}【4. 其他信息】${NC}"
echo -e "---------------------------------------------"

# 当前用户
CURRENT_USER=$(whoami)
echo -e "${YELLOW}当前登录用户：${NC}$CURRENT_USER"

# 时区
TIMEZONE=$(timedatectl show -p Timezone --value 2>/dev/null || date +%Z)
echo -e "${YELLOW}系统时区：${NC}$TIMEZONE"

# 语言编码
LANG=$(locale | grep LANG= | cut -d= -f2)
echo -e "${YELLOW}语言编码：${NC}$LANG"

# 防火墙状态
if command -v ufw &>/dev/null; then
    FIREWALL=$(ufw status | head -n1)
elif command -v firewall-cmd &>/dev/null; then
    FIREWALL=$(firewall-cmd --state 2>/dev/null || echo "未运行")
else
    FIREWALL="未检测到防火墙"
fi
echo -e "${YELLOW}防火墙状态：${NC}$FIREWALL"

# 结束标识
echo -e "\n${BLUE}=============================================${NC}"
echo -e "${GREEN}✅ 系统信息查询完成！${NC}"
echo -e "${BLUE}=============================================${NC}"
