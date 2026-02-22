#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# ========== 补充原版依赖函数 ==========
# 1. 采集IP和流量信息（原版ip_address函数核心逻辑）
ip_address() {
    # 获取公网IPv4
    ipv4_address=$(curl -s --max-time 5 ip.sb -4 || curl -s --max-time 5 ifconfig.me -4 || echo "未获取到")
    # 获取公网IPv6
    ipv6_address=$(curl -s --max-time 5 ip.sb -6 || curl -s --max-time 5 ifconfig.me -6 || echo "未获取到/未开启")
    
    # 采集网卡总收发流量（原版rx/tx变量）
    if command -v ip &>/dev/null; then
        # 取第一个非lo的网卡
        main_nic=$(ip link show | grep -E '^[0-9]' | grep -v LOOPBACK | head -n1 | awk '{print $2}' | sed 's/://')
        if [ -n "$main_nic" ]; then
            # 读取流量（字节转MB）
            rx=$(cat /sys/class/net/$main_nic/statistics/rx_bytes | awk '{printf "%.2f MB", $1/1024/1024}')
            tx=$(cat /sys/class/net/$main_nic/statistics/tx_bytes | awk '{printf "%.2f MB", $1/1024/1024}')
        else
            rx="未获取到"
            tx="未获取到"
        fi
    else
        rx="未获取到"
        tx="未获取到"
    fi
}

# 2. 获取当前时区（原版current_timezone函数）
current_timezone() {
    if command -v timedatectl &>/dev/null; then
        timedatectl show -p Timezone --value 2>/dev/null
    else
        date +%Z
    fi
}


# ========== 核心：复刻原版linux_info函数 ==========
linux_info() {
    clear
    echo -e "${YELLOW}正在查询系统信息……${NC}"
    send_stats "系统信息查询"

    # 采集IP和流量信息
    ip_address

    # CPU型号
    local cpu_info=$(lscpu | awk -F': +' '/Model name:/ {print $2; exit}')
    
    # 实时CPU使用率（原版核心计算逻辑）
    local cpu_usage_percent=$(awk '{u=$2+$4; t=$2+$4+$5; if (NR==1){u1=u; t1=t;} else printf "%.0f\n", (($2+$4-u1) * 100 / (t-t1))}' \
        <(grep 'cpu ' /proc/stat) <(sleep 1; grep 'cpu ' /proc/stat))
    
    # CPU核心数
    local cpu_cores=$(nproc)
    
    # CPU频率（转GHz）
    local cpu_freq=$(cat /proc/cpuinfo | grep "MHz" | head -n 1 | awk '{printf "%.1f GHz\n", $4/1000}')
    
    # 内存信息（MB，带百分比）
    local mem_info=$(free -b | awk 'NR==2{printf "%.2f/%.2fM (%.2f%%)", $3/1024/1024, $2/1024/1024, $3*100/$2}')
    
    # 磁盘信息（根目录）
    local disk_info=$(df -h | awk '$NF=="/"{printf "%s/%s (%s)", $3, $2, $5}')
    
    # IP地理信息（ipinfo.io）
    local ipinfo=$(curl -s --max-time 5 ipinfo.io)
    local country=$(echo "$ipinfo" | grep 'country' | awk -F': ' '{print $2}' | tr -d '",')
    local city=$(echo "$ipinfo" | grep 'city' | awk -F': ' '{print $2}' | tr -d '",')
    local isp_info=$(echo "$ipinfo" | grep 'org' | awk -F': ' '{print $2}' | tr -d '",')
    
    # 系统负载
    local load=$(uptime | awk '{print $(NF-2), $(NF-1), $NF}')
    
    # DNS地址
    local dns_addresses=$(awk '/^nameserver/{printf "%s ", $2} END {print ""}' /etc/resolv.conf)
    
    # CPU架构
    local cpu_arch=$(uname -m)
    
    # 主机名
    local hostname=$(uname -n)
    
    # 内核版本
    local kernel_version=$(uname -r)
    
    # 网络算法（拥塞控制+队列算法）
    local congestion_algorithm=$(sysctl -n net.ipv4.tcp_congestion_control 2>/dev/null)
    local queue_algorithm=$(sysctl -n net.core.default_qdisc 2>/dev/null)
    
    # 系统版本
    local os_info=$(grep PRETTY_NAME /etc/os-release | cut -d '=' -f2 | tr -d '"')
    
    output_status
    
    # 当前时间
    local current_time=$(date "+%Y-%m-%d %I:%M %p")
    
    # 交换分区信息
    local swap_info=$(free -m | awk 'NR==3{used=$3; total=$2; if (total == 0) {percentage=0} else {percentage=used*100/total}; printf "%dM/%dM (%d%%)", used, total, percentage}')
    
    # 系统运行时长
    local runtime=$(cat /proc/uptime | awk -F. '{run_days=int($1 / 86400);run_hours=int(($1 % 86400) / 3600);run_minutes=int(($1 % 3600) / 60); if (run_days > 0) printf("%d天 ", run_days); if (run_hours > 0) printf("%d时 ", run_hours); printf("%d分\n", run_minutes)}')
    
    # 时区
    local timezone=$(current_timezone)
    
    # TCP/UDP连接数
    local tcp_count=$(ss -t | wc -l 2>/dev/null || echo "0")
    local udp_count=$(ss -u | wc -l 2>/dev/null || echo "0")

    # 输出最终信息（原版格式）
    clear
    echo -e "系统信息查询"
    echo -e "${YELLOW}-------------"
    echo -e "${YELLOW}主机名:         ${NC}$hostname"
    echo -e "${YELLOW}系统版本:       ${NC}$os_info"
    echo -e "${YELLOW}Linux版本:      ${NC}$kernel_version"
    echo -e "${YELLOW}-------------"
    echo -e "${YELLOW}CPU架构:        ${NC}$cpu_arch"
    echo -e "${YELLOW}CPU型号:        ${NC}$cpu_info"
    echo -e "${YELLOW}CPU核心数:      ${NC}$cpu_cores"
    echo -e "${YELLOW}CPU频率:        ${NC}$cpu_freq"
    echo -e "${YELLOW}-------------"
    echo -e "${YELLOW}CPU占用:        ${NC}$cpu_usage_percent%"
    echo -e "${YELLOW}系统负载:       ${NC}$load"
    echo -e "${YELLOW}TCP|UDP连接数:  ${NC}$tcp_count|$udp_count"
    echo -e "${YELLOW}物理内存:       ${NC}$mem_info"
    echo -e "${YELLOW}虚拟内存:       ${NC}$swap_info"
    echo -e "${YELLOW}硬盘占用:       ${NC}$disk_info"
    echo -e "${YELLOW}-------------"
    echo -e "${YELLOW}总接收:         ${NC}$rx"
    echo -e "${YELLOW}总发送:         ${NC}$tx"
    echo -e "${YELLOW}-------------"
    echo -e "${YELLOW}网络算法:       ${NC}$congestion_algorithm $queue_algorithm"
    echo -e "${YELLOW}-------------"
    echo -e "${YELLOW}运营商:         ${NC}$isp_info"
    if [ -n "$ipv4_address" ] && [ "$ipv4_address" != "未获取到" ]; then
        echo -e "${YELLOW}IPv4地址:       ${NC}$ipv4_address"
    fi

    if [ -n "$ipv6_address" ] && [ "$ipv6_address" != "未获取到/未开启" ]; then
        echo -e "${YELLOW}IPv6地址:       ${NC}$ipv6_address"
    fi
    echo -e "${YELLOW}DNS地址:        ${NC}$dns_addresses"
    echo -e "${YELLOW}地理位置:       ${NC}$country $city"
    echo -e "${YELLOW}系统时间:       ${NC}$timezone $current_time"
    echo -e "${YELLOW}-------------"
    echo -e "${YELLOW}运行时长:       ${NC}$runtime"
    echo
}

# ========== 执行脚本 + 交互逻辑 ==========
# 调用核心函数
linux_info

# 按任意键退出（你的风格）
echo -e "${CYAN}按任意键退出...${NC}"
read -n 1 -s
echo -e "\n"