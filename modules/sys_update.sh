#!/bin/bash
# 适配 Ubuntu/Debian/CentOS/Alpine/Fedora/Arch

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

fix_dpkg() {
    echo -e "${YELLOW}修复dpkg锁定/损坏问题...${NC}"
    rm -f /var/lib/dpkg/lock-frontend
    rm -f /var/lib/dpkg/lock
    dpkg --configure -a 2>/dev/null
    apt -f install -y 2>/dev/null
}

clear
echo -e "${BLUE}=============================================${NC}"
echo -e "${PURPLE}              系统清理                       ${NC}"
echo -e "${BLUE}=============================================${NC}"
echo -e ""

echo -e "${GREEN}正在检测系统并清理...${NC}"
echo -e ""

if command -v dnf &>/dev/null; then
    echo -e "${CYAN}📦 DNF系统清理中...${NC}"
    rpm --rebuilddb
    dnf autoremove -y
    dnf clean all
    dnf makecache
    journalctl --rotate
    journalctl --vacuum-time=1s
    journalctl --vacuum-size=500M

elif command -v yum &>/dev/null; then
    echo -e "${CYAN}📦 YUM系统清理中...${NC}"
    rpm --rebuilddb
    yum autoremove -y
    yum clean all
    yum makecache
    journalctl --rotate
    journalctl --vacuum-time=1s
    journalctl --vacuum-size=500M

elif command -v apt &>/dev/null; then
    echo -e "${CYAN}📦 APT系统清理中...${NC}"
    fix_dpkg
    apt autoremove --purge -y
    apt clean -y
    apt autoclean -y
    journalctl --rotate
    journalctl --vacuum-time=1s
    journalctl --vacuum-size=500M

elif command -v apk &>/dev/null; then
    echo -e "${CYAN}📦 APK系统清理中...${NC}"
    echo -e "${YELLOW}清理包管理器缓存...${NC}"
    apk cache clean
    echo -e "${YELLOW}删除系统日志...${NC}"
    rm -rf /var/log/* 2>/dev/null
    echo -e "${YELLOW}删除APK缓存...${NC}"
    rm -rf /var/cache/apk/* 2>/dev/null
    echo -e "${YELLOW}删除临时文件...${NC}"
    rm -rf /tmp/* 2>/dev/null

elif command -v pacman &>/dev/null; then
    echo -e "${CYAN}📦 PACMAN系统清理中...${NC}"
    pacman -Rns $(pacman -Qdtq) --noconfirm 2>/dev/null
    pacman -Scc --noconfirm
    journalctl --rotate
    journalctl --vacuum-time=1s
    journalctl --vacuum-size=500M

elif command -v zypper &>/dev/null; then
    echo -e "${CYAN}📦 ZYPPER系统清理中...${NC}"
    zypper clean --all
    zypper refresh
    journalctl --rotate
    journalctl --vacuum-time=1s
    journalctl --vacuum-size=500M

elif command -v opkg &>/dev/null; then
    echo -e "${CYAN}📦 OPKG系统清理中...${NC}"
    echo -e "${YELLOW}删除系统日志...${NC}"
    rm -rf /var/log/* 2>/dev/null
    echo -e "${YELLOW}删除临时文件...${NC}"
    rm -rf /tmp/* 2>/dev/null

elif command -v pkg &>/dev/null; then
    echo -e "${CYAN}📦 PKG系统清理中...${NC}"
    echo -e "${YELLOW}清理未使用的依赖...${NC}"
    pkg autoremove -y
    echo -e "${YELLOW}清理包管理器缓存...${NC}"
    pkg clean -y
    echo -e "${YELLOW}删除系统日志...${NC}"
    rm -rf /var/log/* 2>/dev/null
    echo -e "${YELLOW}删除临时文件...${NC}"
    rm -rf /tmp/* 2>/dev/null

else
    echo -e "${RED}❌ 未知的包管理器!${NC}"
    echo -e "\n${BLUE}=============================================${NC}"
    echo -e "${CYAN}按任意键退出...${NC}"
    read -n 1 -s
    echo -e "\n"
    exit 1
fi

# 结束标识
echo -e "\n${BLUE}=============================================${NC}"
echo -e "${GREEN}✅ 系统清理完成！${NC}"
echo -e "${BLUE}=============================================${NC}"
echo -e "\n${CYAN}按任意键退出...${NC}"
read -n 1 -s
echo -e "\n"