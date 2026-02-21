#!/bin/bash
# 系统信息查询模块
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# ========== 核心改动：先清屏 ==========
clear

echo -e "${GREEN}=========================================${NC}"
echo -e "${YELLOW}            系统信息查询结果              ${NC}"
echo -e "${GREEN}=========================================${NC}"

# 系统发行版
echo -e "${BLUE}1. 系统版本：${NC}$(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | sed 's/"//g')"
# 内核版本
echo -e "${BLUE}2. 内核版本：${NC}$(uname -r)"
# CPU信息
echo -e "${BLUE}3. CPU型号：${NC}$(cat /proc/cpuinfo | grep 'model name' | head -1 | cut -d: -f2 | sed 's/^ //g')"
# 内存信息
echo -e "${BLUE}4. 内存总量：${NC}$(free -h | grep Mem | awk '{print $2}')"
# 已用内存
echo -e "${BLUE}5. 已用内存：${NC}$(free -h | grep Mem | awk '{print $3}')"
# 硬盘信息
echo -e "${BLUE}6. 硬盘总容量：${NC}$(df -h / | grep / | awk '{print $2}')"
# 已用硬盘
echo -e "${BLUE}7. 已用硬盘：${NC}$(df -h / | grep / | awk '{print $3}')"
# 开机时间
echo -e "${BLUE}8. 系统运行时间：${NC}$(uptime -p | sed 's/up //g')"
# 公网IP
echo -e "${BLUE}9. 公网IP地址：${NC}$(curl -s ip.sb)"

echo -e "${GREEN}=========================================${NC}"
echo -e "\n${CYAN}按任意键返回主菜单...${NC}"
read -n 1 -s