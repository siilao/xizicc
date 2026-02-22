#!/bin/bash
# 适配 Ubuntu/Debian/CentOS/Alpine/Fedora/Arch
# BBR 管理脚本

# 定义颜色常量
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 统计发送函数（空实现，可根据需要扩展）
send_stats() {
    local action="$1"
    echo -e "${CYAN}[统计] $action${NC}"
}

# 安装通用函数
install_package() {
    local pkg="$1"
    echo -e "${YELLOW}正在安装 $pkg...${NC}"

    if command -v apt &>/dev/null; then
        apt update -y && apt install -y "$pkg"
    elif command -v yum &>/dev/null; then
        yum install -y "$pkg"
    elif command -v dnf &>/dev/null; then
        dnf install -y "$pkg"
    elif command -v apk &>/dev/null; then
        apk add "$pkg"
    elif command -v pacman &>/dev/null; then
        pacman -S --noconfirm "$pkg"
    fi
}

# 开启BBRv3函数
bbr_on() {
    echo -e "${YELLOW}正在开启 BBRv3...${NC}"

    # 临时生效
    sysctl -w net.ipv4.tcp_congestion_control=bbr3 >/dev/null 2>&1
    sysctl -w net.core.default_qdisc=fq >/dev/null 2>&1

    # 永久生效（写入sysctl.conf）
    if [ ! -f "/etc/sysctl.conf" ]; then
        touch /etc/sysctl.conf
    fi

    # 先删除原有配置
    sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
    sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf

    # 添加新配置
    echo "net.ipv4.tcp_congestion_control = bbr3" >> /etc/sysctl.conf
    echo "net.core.default_qdisc = fq" >> /etc/sysctl.conf

    # 加载配置
    sysctl -p >/dev/null 2>&1

    # 验证是否生效
    local new_congestion=$(sysctl -n net.ipv4.tcp_congestion_control 2>/dev/null)
    local new_queue=$(sysctl -n net.core.default_qdisc 2>/dev/null)

    if [ "$new_congestion" = "bbr3" ] && [ "$new_queue" = "fq" ]; then
        echo -e "${GREEN}✅ BBRv3 开启成功！${NC}"
    else
        echo -e "${RED}❌ BBRv3 开启失败，请检查系统是否支持！${NC}"
    fi

    echo -e "\n${CYAN}按任意键返回菜单...${NC}"
    read -n 1 -s
}

# 服务器重启函数
server_reboot() {
    echo -e "${YELLOW}警告：关闭BBR需要重启服务器才能生效！${NC}"
    read -p "是否立即重启？(y/n): " reboot_confirm
    if [ "$reboot_confirm" = "y" ] || [ "$reboot_confirm" = "Y" ]; then
        echo -e "${RED}服务器将在 3 秒后重启...${NC}"
        sleep 3
        reboot
    else
        echo -e "${CYAN}已取消重启，BBR关闭操作未完成！${NC}"
        echo -e "\n${CYAN}按任意键返回菜单...${NC}"
        read -n 1 -s
    fi
}

# 核心BBR管理函数
linux_bbr() {
    clear
    send_stats "bbr管理"

    # Alpine系统专属逻辑
    if [ -f "/etc/alpine-release" ]; then
        while true; do
            clear
            # 获取当前算法
            local congestion_algorithm=$(sysctl -n net.ipv4.tcp_congestion_control 2>/dev/null)
            local queue_algorithm=$(sysctl -n net.core.default_qdisc 2>/dev/null)

            # 处理空值
            [ -z "$congestion_algorithm" ] && congestion_algorithm="未知"
            [ -z "$queue_algorithm" ] && queue_algorithm="未知"

            echo -e "${BLUE}=============================================${NC}"
            echo -e "${PURPLE}              BBR 管理 (Alpine)              ${NC}"
            echo -e "${BLUE}=============================================${NC}"
            echo -e "${GREEN}当前TCP阻塞算法: $congestion_algorithm $queue_algorithm${NC}"
            echo ""
            echo "------------------------"
            echo "1. 开启BBRv3              2. 关闭BBRv3（会重启）"
            echo "------------------------"
            echo "0. 返回上一级选单"
            echo "------------------------"
            read -e -p "$(echo -e ${YELLOW}请输入你的选择: ${NC})" sub_choice

            case $sub_choice in
                1)
                    bbr_on
                    send_stats "alpine开启bbr3"
                    ;;
                2)
                    echo -e "${YELLOW}正在清除BBR配置...${NC}"
                    sed -i '/net.ipv4.tcp_congestion_control=/d' /etc/sysctl.conf
                    sed -i '/net.core.default_qdisc=/d' /etc/sysctl.conf
                    sysctl -p >/dev/null 2>&1
                    server_reboot
                    ;;
                0)
                    echo -e "${CYAN}返回上一级菜单...${NC}"
                    break
                    ;;
                *)
                    echo -e "${RED}❌ 无效的选择，请重新输入！${NC}"
                    sleep 2
                    ;;
            esac
        done
    else
        # 非Alpine系统，使用tcpx.sh脚本
        echo -e "${YELLOW}检测到非Alpine系统，将使用通用BBR管理脚本...${NC}"

        # 安装依赖
        install_package "wget"

        # 定义gh_proxy（默认空，可自行添加代理）
        gh_proxy=""

        # 下载并运行tcpx.sh
        if wget --no-check-certificate -O tcpx.sh "${gh_proxy}raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/tcpx.sh"; then
            chmod +x tcpx.sh
            echo -e "${GREEN}✅ 脚本下载完成，正在运行...${NC}"
            ./tcpx.sh
        else
            echo -e "${RED}❌ 脚本下载失败！${NC}"
            echo -e "${CYAN}按任意键退出...${NC}"
            read -n 1 -s
        fi
    fi
}

# 脚本入口
clear
echo -e "${BLUE}=============================================${NC}"
echo -e "${PURPLE}              BBR 管理工具                   ${NC}"
echo -e "${BLUE}=============================================${NC}"
linux_bbr

echo -e "\n${CYAN}脚本执行完成！${NC}"