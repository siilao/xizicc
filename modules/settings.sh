#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'


# 通用等待函数
wait_key() {
    echo -e "\n${CYAN}按任意键返回系统工具菜单...${NC}"
    read -n 1 -s
    settings_submenu
}

# ========== 系统工具二级菜单（整合科技lion核心功能） ==========
settings_submenu() {
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${PURPLE}             系统工具         ${NC}"
    echo -e "${BLUE}=========================================${NC}"
    echo -e " 1. ${YELLOW}修改登录密码${NC}"
    echo -e " 2. ${YELLOW}用户密码登录模式 ${NC}"
    echo -e " 3. ${YELLOW}开放所有端口${NC}"
    echo -e " 4. ${YELLOW}修改SSH连接端口${NC}"
    echo -e " 5. ${YELLOW}优化DNS地址${NC}"
    echo -e " 6. ${YELLOW}一键重装系统${NC}"
    echo -e " 7. ${YELLOW}查看端口占用状态${NC}"
    echo -e " 8. ${YELLOW}切换优先ipv4/ipv6${NC}"
    echo -e " 9. ${YELLOW}修改虚拟内存大小${NC}"
    echo -e " 10. ${YELLOW}系统时区调整${NC}"
    echo -e " 11. ${YELLOW}修改主机名${NC}"
    echo -e " 12. ${YELLOW}切换系统语言${NC}"
    echo -e "${BLUE}=========================================${NC}"
    echo -e " 0. ${CYAN}退出脚本${NC}"
    echo -e "${BLUE}=========================================${NC}"
    read -p "请输入子菜单选项：" sub_choice

    case $sub_choice in
        # 1. 修改登录密码（科技lion核心逻辑）
        1)
            show_title
            echo -e "${GREEN}🔑 开始修改登录密码${NC}\n"
            read -p "请输入要修改密码的用户名（默认root）：" username
            username=${username:-root}

            # 检查用户是否存在
            if id "$username" &>/dev/null; then
                passwd "$username"
                echo -e "\n${GREEN}✅ $username 密码修改完成！${NC}"
            else
                echo -e "\n${RED}❌ 用户 $username 不存在！${NC}"
            fi
            wait_key
            ;;

        # 2. 用户密码登录模式（开启/关闭密码登录）
        2)
            show_title
            echo -e "${GREEN}🔐 配置SSH密码登录模式${NC}\n"
            echo -e "1. 开启密码登录"
            echo -e "2. 关闭密码登录"
            read -p "请选择（1/2）：" ssh_choice

            if [ "$ssh_choice" = "1" ]; then
                # 开启密码登录
                sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
                sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config
                systemctl restart sshd &>/dev/null || service ssh restart &>/dev/null
                echo -e "\n${GREEN}✅ 已开启SSH密码登录！${NC}"
            elif [ "$ssh_choice" = "2" ]; then
                # 关闭密码登录
                sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
                sed -i 's/^#PasswordAuthentication no/PasswordAuthentication no/g' /etc/ssh/sshd_config
                systemctl restart sshd &>/dev/null || service ssh restart &>/dev/null
                echo -e "\n${GREEN}✅ 已关闭SSH密码登录！${NC}"
            else
                echo -e "\n${RED}❌ 输入错误！${NC}"
            fi
            wait_key
            ;;

        # 3. 开放所有端口（关闭防火墙+清空规则）
        3)
            show_title
            echo -e "${GREEN}🚪 开始开放所有端口（关闭防火墙）${NC}\n"

            # 兼容不同系统防火墙
            if command -v ufw &>/dev/null; then
                ufw disable &>/dev/null
                echo -e "✅ UFW防火墙已关闭"
            elif command -v firewalld &>/dev/null; then
                systemctl stop firewalld &>/dev/null
                systemctl disable firewalld &>/dev/null
                echo -e "✅ firewalld防火墙已关闭"
            fi

            # 清空iptables规则
            iptables -F &>/dev/null
            iptables -X &>/dev/null
            echo -e "✅ iptables规则已清空"
            echo -e "\n${GREEN}✅ 所有端口已开放！${NC}"
            wait_key
            ;;

        # 4. 修改SSH连接端口
        4)
            show_title
            echo -e "${GREEN}🔌 开始修改SSH端口${NC}\n"
            read -p "请输入新的SSH端口（建议10000-65535）：" new_port

            # 验证端口合法性
            if ! [[ "$new_port" =~ ^[0-9]+$ ]] || [ "$new_port" -lt 1 ] || [ "$new_port" -gt 65535 ]; then
                echo -e "\n${RED}❌ 端口号必须是1-65535之间的数字！${NC}"
                wait_key
                break
            fi

            # 修改SSH配置
            sed -i "s/^Port .*/Port $new_port/g" /etc/ssh/sshd_config
            sed -i "s/^#Port 22/Port $new_port/g" /etc/ssh/sshd_config

            # 重启SSH服务
            systemctl restart sshd &>/dev/null || service ssh restart &>/dev/null

            echo -e "\n${GREEN}✅ SSH端口已修改为 $new_port！${NC}"
            echo -e "${YELLOW}⚠️  请确保新端口已开放，否则可能无法连接！${NC}"
            wait_key
            ;;

        # 5. 优化DNS地址（阿里云+谷歌DNS）
        5)
            show_title
            echo -e "${GREEN}🌐 开始优化DNS地址${NC}\n"

            # 备份原有DNS配置
            cp /etc/resolv.conf /etc/resolv.conf.bak &>/dev/null

            # 写入优化DNS
            echo "nameserver 223.5.5.5" > /etc/resolv.conf
            echo "nameserver 223.6.6.6" >> /etc/resolv.conf
            echo "nameserver 8.8.8.8" >> /etc/resolv.conf
            echo "nameserver 8.8.4.4" >> /etc/resolv.conf

            echo -e "${GREEN}✅ DNS已优化为阿里云+谷歌DNS！${NC}"
            echo -e "${YELLOW}当前DNS配置：${NC}"
            cat /etc/resolv.conf
            wait_key
            ;;

        # 6. 一键重装系统（调用科技lion重装脚本）
        6)
            show_title
            echo -e "${YELLOW}⚠️  警告：重装系统会清空所有数据！${NC}\n"
            read -p "确认要重装系统吗？(y/n)：" reinstall_confirm
            if [ "$reinstall_confirm" = "y" ] || [ "$reinstall_confirm" = "Y" ]; then
                echo -e "\n${GREEN}🚀 开始执行一键重装脚本...${NC}"
                # 调用科技lion重装脚本（兼容主流架构）
                bash <(curl -sSL https://git.io/reinstall.sh)
            else
                echo -e "\n${GREEN}✅ 已取消重装系统！${NC}"
            fi
            wait_key
            ;;

        # 7. 查看端口占用状态
        7)
            show_title
            echo -e "${GREEN}📋 查看端口占用状态${NC}\n"
            read -p "请输入要查询的端口（留空查看所有）：" check_port

            if [ -n "$check_port" ]; then
                # 查询指定端口
                lsof -i :"$check_port" || netstat -tulpn | grep "$check_port"
                if [ $? -ne 0 ]; then
                    echo -e "\n${YELLOW}⚠️  端口 $check_port 未被占用！${NC}"
                fi
            else
                # 查看所有端口
                netstat -tulpn
            fi
            wait_key
            ;;

        # 8. 切换优先ipv4/ipv6
        8)
            show_title
            echo -e "${GREEN}🌍 切换IP协议优先级${NC}\n"
            echo -e "1. 优先使用IPv4"
            echo -e "2. 优先使用IPv6"
            read -p "请选择（1/2）：" ip_choice

            # 修改gai.conf配置
            gai_conf="/etc/gai.conf"
            if [ "$ip_choice" = "1" ]; then
                sed -i 's/^#precedence ::ffff:0:0\/96  100/precedence ::ffff:0:0\/96  100/g' "$gai_conf"
                echo -e "\n${GREEN}✅ 已设置优先使用IPv4！${NC}"
            elif [ "$ip_choice" = "2" ]; then
                sed -i 's/^precedence ::ffff:0:0\/96  100/#precedence ::ffff:0:0\/96  100/g' "$gai_conf"
                echo -e "\n${GREEN}✅ 已设置优先使用IPv6！${NC}"
            else
                echo -e "\n${RED}❌ 输入错误！${NC}"
            fi
            wait_key
            ;;

        # 9. 修改虚拟内存大小
        9)
            show_title
            echo -e "${GREEN}💾 开始修改虚拟内存（SWAP）${NC}\n"
            read -p "请输入SWAP大小（单位G，如1/2/4）：" swap_size

            # 验证输入
            if ! [[ "$swap_size" =~ ^[0-9]+$ ]]; then
                echo -e "\n${RED}❌ 请输入有效的数字！${NC}"
                wait_key
                break
            fi

            # 关闭原有SWAP
            swapoff /swapfile &>/dev/null
            rm -f /swapfile &>/dev/null

            # 创建新SWAP
            fallocate -l "${swap_size}G" /swapfile || dd if=/dev/zero of=/swapfile bs=1M count=$((swap_size*1024))
            chmod 600 /swapfile
            mkswap /swapfile
            swapon /swapfile

            # 设置开机自启
            echo "/swapfile swap swap defaults 0 0" >> /etc/fstab

            echo -e "\n${GREEN}✅ SWAP已设置为 ${swap_size}G！${NC}"
            echo -e "${YELLOW}当前SWAP状态：${NC}"
            swapon --show
            wait_key
            ;;

        # 10. 系统时区调整
        10)
            show_title
            echo -e "${GREEN}🕒 开始调整系统时区${NC}\n"
            read -p "请输入时区（默认Asia/Shanghai）：" timezone
            timezone=${timezone:-Asia/Shanghai}

            # 设置时区
            ln -sf /usr/share/zoneinfo/"$timezone" /etc/localtime
            echo "$timezone" > /etc/timezone

            echo -e "\n${GREEN}✅ 时区已设置为 $timezone！${NC}"
            echo -e "${YELLOW}当前系统时间：${NC}"
            date
            wait_key
            ;;

        # 11. 修改主机名
        11)
            show_title
            echo -e "${GREEN}🏷️  开始修改主机名${NC}\n"
            read -p "请输入新的主机名：" new_hostname

            if [ -z "$new_hostname" ]; then
                echo -e "\n${RED}❌ 主机名不能为空！${NC}"
                wait_key
                break
            fi

            # 修改主机名
            hostnamectl set-hostname "$new_hostname"
            sed -i "s/^$(hostname).*/$new_hostname/g" /etc/hosts &>/dev/null

            echo -e "\n${GREEN}✅ 主机名已修改为 $new_hostname！${NC}"
            echo -e "${YELLOW}⚠️  重新登录后生效${NC}"
            wait_key
            ;;

        # 12. 切换系统语言
        12)
            show_title
            echo -e "${GREEN}🗣️  切换系统语言${NC}\n"
            echo -e "1. 切换为中文（zh_CN.UTF-8）"
            echo -e "2. 切换为英文（en_US.UTF-8）"
            read -p "请选择（1/2）：" lang_choice

            if [ "$lang_choice" = "1" ]; then
                # 切换为中文
                apt install -y locales &>/dev/null || yum install -y glibc-langpack-zh &>/dev/null
                locale-gen zh_CN.UTF-8 &>/dev/null
                update-locale LANG=zh_CN.UTF-8
                echo -e "\n${GREEN}✅ 系统语言已切换为中文！${NC}"
                echo -e "${YELLOW}⚠️  重新登录后生效${NC}"
            elif [ "$lang_choice" = "1" ]; then
                # 切换为英文
                update-locale LANG=en_US.UTF-8
                echo -e "\n${GREEN}✅ 系统语言已切换为英文！${NC}"
                echo -e "${YELLOW}⚠️  重新登录后生效${NC}"
            else
                echo -e "\n${RED}❌ 输入错误！${NC}"
            fi
            wait_key
            ;;

        0)
			  # 0选项改为直接退出脚本
			  clear
			  echo -e "\n${BLUE}=============================================${NC}"
			  echo -e "${GREEN}✅ 已退出工具管理脚本！${NC}"
			  echo -e "${BLUE}=============================================${NC}"
			  echo -e "\n${CYAN}按任意键退出...${NC}"
			  read -n 1 -s
			  exit 0
			  ;;
		    *)
			  echo -e "${RED}❌ 无效的输入！请输入菜单中的数字${NC}"
			  sleep 1
			  ;;
	  esac
	  break_end
  done
}

# ========== 执行脚本 + 交互逻辑 ==========
# 调用核心函数
settings_submenu

# 按任意键退出（你的风格）
echo -e "${CYAN}按任意键退出...${NC}"
read -n 1 -s
echo -e "\n"