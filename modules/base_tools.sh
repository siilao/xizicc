#!/bin/bash
# 科技lion 风格 - 基础工具安装
# 适配 Ubuntu/Debian/CentOS/Alpine/Fedora/Arch/Kali

# 颜色定义（和原版一致）
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
echo -e "${PURPLE}            基础工具安装 - 科技lion            ${NC}"
echo -e "${BLUE}=============================================${NC}"
echo -e ""

# 定义需要安装的基础工具列表
TOOLS=(
    "wget"       # 网络下载工具
    "curl"       # 网络请求工具
    "vim"        # 文本编辑器
    "git"        # 版本控制工具
    "unzip"      # 解压工具
    "zip"        # 压缩工具
    "tar"        # 归档工具
    "gzip"       # 压缩工具
    "bzip2"      # 压缩工具
    "net-tools"  # 网络工具（ifconfig等）
    "iproute2"   # 网络配置工具
    "ping"       # 网络测试工具
    "traceroute" # 路由追踪工具
    "telnet"     # 远程登录工具
    "nano"       # 简易文本编辑器
    "tree"       # 目录树展示工具
    "bc"         # 计算器工具
    "jq"         # JSON解析工具
    "htop"       # 系统监控工具
    "iotop"      # IO监控工具
    "iftop"      # 网络流量监控工具
)

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

echo -e "${GREEN}🔍 检测到系统：${OS}${NC}"
echo -e "---------------------------------------------"

# 定义各系统的包管理器命令
case $OS in
    ubuntu|debian|kali|raspbian)
        PM_UPDATE="apt update -y"
        PM_INSTALL="apt install -y"
        ;;
    centos|rhel|almalinux|rocky)
        PM_UPDATE="yum update -y"
        PM_INSTALL="yum install -y"
        ;;
    fedora)
        PM_UPDATE="dnf update -y"
        PM_INSTALL="dnf install -y"
        ;;
    arch|manjaro)
        PM_UPDATE="pacman -Syu --noconfirm"
        PM_INSTALL="pacman -S --noconfirm"
        ;;
    alpine)
        PM_UPDATE="apk update"
        PM_INSTALL="apk add"
        ;;
    *)
        echo -e "${RED}❌ 不支持当前系统：${OS}${NC}"
        echo -e "\n${CYAN}按任意键返回主菜单...${NC}"
        read -n 1 -s
        exit 1
        ;;
esac

# 第一步：更新包管理器缓存
echo -e "\n${YELLOW}1. 更新包管理器缓存...${NC}"
eval $PM_UPDATE >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ 包缓存更新完成${NC}"
else
    echo -e "${YELLOW}⚠️  包缓存更新失败（不影响工具安装）${NC}"
fi

# 第二步：安装基础工具
echo -e "\n${YELLOW}2. 开始安装基础工具（共${#TOOLS[@]}个）...${NC}"
INSTALLED_COUNT=0
FAILED_TOOLS=()

for tool in "${TOOLS[@]}"; do
    # 检查工具是否已安装
    if command -v $tool >/dev/null 2>&1; then
        echo -e "${GREEN}✅ ${tool} 已安装${NC}"
        ((INSTALLED_COUNT++))
        continue
    fi

    # 安装工具
    echo -e "${CYAN}🔧 正在安装 ${tool}...${NC}"
    eval $PM_INSTALL $tool >/dev/null 2>&1

    # 验证安装结果
    if command -v $tool >/dev/null 2>&1; then
        echo -e "${GREEN}✅ ${tool} 安装成功${NC}"
        ((INSTALLED_COUNT++))
    else
        echo -e "${RED}❌ ${tool} 安装失败${NC}"
        FAILED_TOOLS+=($tool)
    fi
done

# 第三步：输出安装结果
echo -e "\n${BLUE}=============================================${NC}"
echo -e "${GREEN}🎉 基础工具安装完成！${NC}"
echo -e "${YELLOW}📊 安装统计：${NC}"
echo -e "   总计工具数：${#TOOLS[@]}"
echo -e "   成功安装：${INSTALLED_COUNT}"
echo -e "   安装失败：${#FAILED_TOOLS[@]}"

if [ ${#FAILED_TOOLS[@]} -gt 0 ]; then
    echo -e "${RED}❌ 失败列表：${FAILED_TOOLS[*]}${NC}"
fi

echo -e "${BLUE}=============================================${NC}"
echo -e "\n${CYAN}按任意键退出...${NC}"

read -n 1 -s
echo -e "\n"