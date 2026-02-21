#!/bin/bash
# 适配 Ubuntu/Debian/CentOS/Alpine/Fedora/Arch

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${BLUE}=============================================${NC}"
echo -e "${PURPLE}              系统更新                       ${NC}"
echo -e "${BLUE}=============================================${NC}"
echo -e ""

# 判断系统并更新
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
fi

echo -e "${GREEN}正在检测系统并更新...${NC}"
echo -e ""

case $OS in
    ubuntu|debian|kali|raspbian)
        apt update -y
        apt upgrade -y
        ;;
    centos|rhel|almalinux|rocky)
        yum update -y
        ;;
    fedora)
        dnf update -y
        ;;
    arch|manjaro)
        pacman -Syu --noconfirm
        ;;
    alpine)
        apk update
        apk upgrade
        ;;
    *)
        echo -e "${RED}不支持当前系统！${NC}"
        ;;
esac

# 结束标识
echo -e "\n${BLUE}=============================================${NC}"
echo -e "${GREEN}✅ 系统更新完成！${NC}"
echo -e "${BLUE}=============================================${NC}"
echo -e "\n${CYAN}按任意键退出...${NC}"
read -n 1 -s
echo -e "\n"