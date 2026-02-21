#!/bin/bash
# 适配 Ubuntu/Debian/CentOS/Alpine/Fedora/Arch/Kali

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 清理屏幕并显示标题
clear
echo -e "${BLUE}=============================================${NC}"
echo -e "${PURPLE}              系统清理                       ${NC}"
echo -e "${BLUE}=============================================${NC}"
echo -e ""

# 识别系统发行版
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
elif [ -f /etc/redhat-release ]; then
    OS="centos"
elif [ -f /etc/alpine-release ]; then
    OS="alpine"
else
    OS="unknown"
fi

echo -e "${GREEN}🔍 检测到系统：${OS}，开始清理...${NC}"
echo -e "---------------------------------------------"

# ========== 通用清理项（所有系统都执行） ==========
echo -e "\n${YELLOW}1. 清理系统临时文件...${NC}"
# 清理/tmp目录（保留正在使用的文件）
find /tmp -type f -atime +1 -delete 2>/dev/null
find /tmp -type d -empty -delete 2>/dev/null

# 清理用户临时目录
rm -rf ~/.cache/* 2>/dev/null
rm -rf ~/.tmp/* 2>/dev/null

echo -e "${GREEN}✅ 临时文件清理完成${NC}"

echo -e "\n${YELLOW}2. 清理系统日志（保留最近7天）...${NC}"
# 清理旧日志
find /var/log -name "*.log" -type f -mtime +7 -delete 2>/dev/null
find /var/log -name "*.gz" -type f -mtime +7 -delete 2>/dev/null
find /var/log -name "*.old" -type f -mtime +7 -delete 2>/dev/null

# 截断超大日志文件（避免删除关键日志）
for log in /var/log/syslog /var/log/messages /var/log/auth.log; do
    if [ -f "$log" ] && [ $(du -m "$log" | awk '{print $1}') -gt 100 ]; then
        > "$log" 2>/dev/null
    fi
done
echo -e "${GREEN}✅ 系统日志清理完成${NC}"

# ========== 发行版专属清理项 ==========
echo -e "\n${YELLOW}3. 清理包管理器缓存...${NC}"
case $OS in
    ubuntu|debian|kali|raspbian)
        # Debian/Ubuntu系列
        apt autoremove -y --purge 2>/dev/null
        apt clean 2>/dev/null
        apt autoclean 2>/dev/null
        ;;
    centos|rhel|almalinux|rocky|fedora)
        # RHEL/CentOS/Fedora系列
        yum clean all 2>/dev/null
        dnf clean all 2>/dev/null
        rm -rf /var/cache/yum/* 2>/dev/null
        ;;
    arch|manjaro)
        # Arch系列
        pacman -Sc --noconfirm 2>/dev/null
        rm -rf /var/cache/pacman/pkg/* 2>/dev/null
        ;;
    alpine)
        # Alpine系列
        apk cache clean 2>/dev/null
        ;;
    *)
        echo -e "${YELLOW}⚠️  暂不支持该系统的包缓存清理${NC}"
        ;;
esac
echo -e "${GREEN}✅ 包管理器缓存清理完成${NC}"

# ========== 额外优化项 ==========
echo -e "\n${YELLOW}4. 清理无用进程和内存缓存...${NC}"
# 释放内存缓存
sync && echo 3 > /proc/sys/vm/drop_caches 2>/dev/null
# 清理僵尸进程
ps aux | grep -w defunct | grep -v grep | awk '{print $2}' | xargs kill -9 2>/dev/null

echo -e "${GREEN}✅ 进程/内存缓存清理完成${NC}"

# 结束标识
echo -e "\n${BLUE}=============================================${NC}"
echo -e "${GREEN}🎉 系统清理全部完成！${NC}"
echo -e "${BLUE}💡 清理释放的空间可通过 df -h 查看${NC}"
echo -e "${BLUE}=============================================${NC}"
echo -e "\n${CYAN}按任意键退出...${NC}"

read -n 1 -s
echo -e "\n"