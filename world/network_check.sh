#!/bin/bash
# 网络连通性检测合集脚本
# 适配：Ubuntu/Debian/CentOS/Alpine/Kali/Arch/RedHat/Fedora/Alma/Rocky

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
NC='\033[0m'

# 全局配置
gh_proxy="https://ghproxy.com/"  # GitHub代理（提升国内访问成功率）
VERSION="1.0.0"

# 显示标题
show_title() {
    clear
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${PURPLE}📡 网络连通性检测合集 v${VERSION}${NC}"
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${YELLOW}适配多Linux发行版，包含IP检测/测速/性能测试${NC}"
    echo -e ""
}

# 辅助函数：任务统计提示
send_stats() {
    echo -e "${BLUE}📊 执行任务：$1 ${NC}"
    sleep 1
}

# 辅助函数：检查并创建swap（性能测试必需）
check_swap() {
    if [ $(free | grep Swap | awk '{print $2}') -eq 0 ]; then
        echo -e "${YELLOW}⚠️  检测到无SWAP，创建临时1G SWAP... ${NC}"
        fallocate -l 1G /swapfile || dd if=/dev/zero of=/swapfile bs=1M count=1024
        chmod 600 /swapfile
        mkswap /swapfile
        swapon /swapfile
        echo -e "${GREEN}✅ SWAP创建完成 ${NC}"
    fi
}

# 辅助函数：执行完等待返回
break_end() {
    echo -e "\n${WHITE}=========================================${NC}"
    echo -e "${CYAN}按任意键返回测试菜单... ${NC}"
    read -n 1 -s
}

# 主菜单函数
main() {
    while true; do
        show_title

        # IP及解锁状态检测
        echo -e "${BLUE}🔍 IP及解锁状态检测${NC}"
        echo -e "${BLUE} 1. ${WHITE}ChatGPT 解锁状态检测${NC}"
        echo -e "${BLUE} 2. ${WHITE}Region 流媒体解锁测试${NC}"
        echo -e "${BLUE} 3. ${WHITE}yeahwu 流媒体解锁检测${NC}"
        echo -e "${BLUE} 4. ${WHITE}xykt IP质量体检脚本 ${YELLOW}★${NC}"

        # 网络线路测速
        echo -e "\n${BLUE}🚀 网络线路测速${NC}"
        echo -e "${BLUE}11. ${WHITE}besttrace 三网回程延迟路由测试${NC}"
        echo -e "${BLUE}12. ${WHITE}mtr_trace 三网回程线路测试${NC}"
        echo -e "${BLUE}13. ${WHITE}Superspeed 三网测速${NC}"
        echo -e "${BLUE}14. ${WHITE}nxtrace 快速回程测试脚本${NC}"
        echo -e "${BLUE}15. ${WHITE}nxtrace 指定IP回程测试脚本${NC}"
        echo -e "${BLUE}16. ${WHITE}ludashi2020 三网线路测试${NC}"
        echo -e "${BLUE}17. ${WHITE}i-abc 多功能测速脚本${NC}"
        echo -e "${BLUE}18. ${WHITE}NetQuality 网络质量体检脚本 ${YELLOW}★${NC}"

        # 硬件性能测试
        echo -e "\n${BLUE}⚙️  硬件性能测试${NC}"
        echo -e "${BLUE}21. ${WHITE}yabs 性能测试${NC}"
        echo -e "${BLUE}22. ${WHITE}icu/gb5 CPU性能测试脚本${NC}"

        # 综合性测试
        echo -e "\n${BLUE}📈 综合性测试${NC}"
        echo -e "${BLUE}31. ${WHITE}bench 性能测试${NC}"
        echo -e "${BLUE}32. ${WHITE}spiritysdx 融合怪测评 ${YELLOW}★${NC}"
        echo -e "${BLUE}33. ${WHITE}nodequality 融合怪测评 ${YELLOW}★${NC}"

        # 退出选项
        echo -e "\n${BLUE}🔙 操作选项${NC}"
        echo -e "${BLUE} 0. ${WHITE}退出脚本${NC}"
        echo -e "${BLUE}=========================================${NC}"
        read -e -p "$(echo -e ${WHITE}"请输入你的选择: "${NC})" sub_choice

        case $sub_choice in
            1)
                clear
                send_stats "ChatGPT解锁状态检测"
                bash <(curl -Ls https://cdn.jsdelivr.net/gh/missuo/OpenAI-Checker/openai.sh)
                break_end
                ;;
            2)
                clear
                send_stats "Region流媒体解锁测试"
                bash <(curl -L -s check.unlock.media)
                break_end
                ;;
            3)
                clear
                send_stats "yeahwu流媒体解锁检测"
                apt install -y wget || yum install -y wget  # 兼容不同系统
                wget -qO- ${gh_proxy}github.com/yeahwu/check/raw/main/check.sh | bash
                break_end
                ;;
            4)
                clear
                send_stats "xykt_IP质量体检脚本"
                bash <(curl -Ls IP.Check.Place)
                break_end
                ;;
            11)
                clear
                send_stats "besttrace三网回程延迟路由测试"
                apt install -y wget || yum install -y wget
                wget -qO- git.io/besttrace | bash
                break_end
                ;;
            12)
                clear
                send_stats "mtr_trace三网回程线路测试"
                curl ${gh_proxy}raw.githubusercontent.com/zhucaidan/mtr_trace/main/mtr_trace.sh | bash
                break_end
                ;;
            13)
                clear
                send_stats "Superspeed三网测速"
                bash <(curl -Lso- https://git.io/superspeed_uxh)
                break_end
                ;;
            14)
                clear
                send_stats "nxtrace快速回程测试脚本"
                curl nxtrace.org/nt | bash
                nexttrace --fast-trace --tcp
                break_end
                ;;
            15)
                clear
                send_stats "nxtrace指定IP回程测试脚本"
                echo -e "${WHITE}可参考的IP列表${NC}"
                echo -e "${WHITE}------------------------${NC}"
                echo "北京电信: 219.141.136.12"
                echo "北京联通: 202.106.50.1"
                echo "北京移动: 221.179.155.161"
                echo "上海电信: 202.96.209.133"
                echo "上海联通: 210.22.97.1"
                echo "上海移动: 211.136.112.200"
                echo "广州电信: 58.60.188.222"
                echo "广州联通: 210.21.196.6"
                echo "广州移动: 120.196.165.24"
                echo "成都电信: 61.139.2.69"
                echo "成都联通: 119.6.6.6"
                echo "成都移动: 211.137.96.205"
                echo "湖南电信: 36.111.200.100"
                echo "湖南联通: 42.48.16.100"
                echo "湖南移动: 39.134.254.6"
                echo -e "${WHITE}------------------------${NC}"

                read -e -p "$(echo -e ${WHITE}"输入一个指定IP: "${NC})" testip
                curl nxtrace.org/nt | bash
                nexttrace $testip
                break_end
                ;;
            16)
                clear
                send_stats "ludashi2020三网线路测试"
                curl ${gh_proxy}raw.githubusercontent.com/ludashi2020/backtrace/main/install.sh -sSf | sh
                break_end
                ;;
            17)
                clear
                send_stats "i-abc多功能测速脚本"
                bash <(curl -sL ${gh_proxy}raw.githubusercontent.com/i-abc/Speedtest/main/speedtest.sh)
                break_end
                ;;
            18)
                clear
                send_stats "网络质量测试脚本"
                bash <(curl -sL Net.Check.Place)
                break_end
                ;;
            21)
                clear
                send_stats "yabs性能测试"
                check_swap
                curl -sL yabs.sh | bash -s -- -i -5
                break_end
                ;;
            22)
                clear
                send_stats "icu/gb5 CPU性能测试脚本"
                check_swap
                bash <(curl -sL bash.icu/gb5)
                break_end
                ;;
            31)
                clear
                send_stats "bench性能测试"
                curl -Lso- bench.sh | bash
                break_end
                ;;
            32)
                send_stats "spiritysdx融合怪测评"
                clear
                curl -L ${gh_proxy}gitlab.com/spiritysdx/za/-/raw/main/ecs.sh -o ecs.sh && chmod +x ecs.sh && bash ecs.sh
                rm -f ecs.sh  # 清理临时文件
                break_end
                ;;
            33)
                send_stats "nodequality融合怪测评"
                clear
                bash <(curl -sL https://run.NodeQuality.com)
                break_end
                ;;
            0)
                echo -e "${CYAN}👋 感谢使用，再见！${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}❌ 无效的输入！请输入正确的数字${NC}"
                sleep 2
                ;;
        esac
    done
}

# 脚本启动入口
main