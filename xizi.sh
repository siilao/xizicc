#!/bin/bash
# Xizicc 一键工具箱
VERSION="1.0.1"

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 确认可用的Raw地址（你测试过能访问）
# 统一变量名，去掉多余的MAIN/BACKUP（你地址本身能访问，无需备用）
SYS_INFO_URL="https://raw.githubusercontent.com/siilao/xizicc/main/modules/sys_info.sh"
SYS_UPDATE_URL="https://raw.githubusercontent.com/siilao/xizicc/main/modules/sys_update.sh"
SYS_CLEAN_URL="https://raw.githubusercontent.com/siilao/xizicc/main/modules/sys_clean.sh"
CHANGELOG_URL="https://raw.githubusercontent.com/siilao/xizicc/main/modules/changelog.txt"

# 脚本路径
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
# GitHub仓库地址（整包更新用）
GIT_REPO_URL="https://github.com/siilao/xizicc.git"

# ========== 补充缺失的核心函数 ==========
# 1. 网络检测函数（修复未定义问题）
check_network() {
    # 测试GitHub是否能访问
    if ! curl -s --head --request GET "https://github.com" | grep "200 OK" > /dev/null; then
        echo -e "${RED}❌ 网络连接失败！无法访问GitHub，请检查网络后重试。${NC}"
        sleep 3
        main_menu
        return 1
    fi
    return 0
}

# 2. 拉取远程文件函数（修复未定义问题）
fetch_remote_file() {
    local url=$1
    local file_name=$2
    # 拉取文件内容
    content=$(curl -s --connect-timeout 10 "$url")
    if [ -n "$content" ]; then
        echo "$content"
        return 0
    else
        echo -e "${RED}❌ 拉取${file_name}失败！${NC}"
        return 1
    fi
}

# 3. 运行远程模块函数（修复未定义问题）
run_remote_module() {
    local url=$1
    local module_name=$2

    show_title
    echo -e "${GREEN}=========================================${NC}"
    echo -e "${YELLOW}            运行${module_name}模块            ${NC}"
    echo -e "${GREEN}=========================================${NC}\n"

    # 检测网络
    if ! check_network; then
        return
    fi

    # 拉取模块并运行（核心：先保存到临时文件，避免管道问题）
    echo -e "${BLUE}正在拉取${module_name}模块...${NC}"
    temp_file=$(mktemp)
    curl -s "$url" -o "$temp_file"

    if [ -s "$temp_file" ]; then
        bash "$temp_file"  # 执行模块
        echo -e "\n${GREEN}✅ ${module_name}模块运行完成！${NC}"
    else
        echo -e "\n${RED}❌ ${module_name}模块拉取失败！${NC}"
    fi

    # 删除临时文件
    rm -f "$temp_file"
    sleep 2
    main_menu
}
# ========== 补充结束 ==========

show_title() {
    clear
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${PURPLE}戏子一键工具箱  v${VERSION} 只为更简单的Linux的使用！${NC}"
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${YELLOW}适配Ubuntu/Debian/CentOS/Alpine/Kali/Arch/RedHat/Fedora/Alma/Rocky系统${NC}"
    echo -e ""
}

# 查看更新日志（修复变量和函数调用）
show_changelog() {
    show_title
    echo -e "${GREEN}=========================================${NC}"
    echo -e "${CYAN}               更新日志                  ${NC}"
    echo -e "${GREEN}=========================================${NC}\n"

    # 检测网络
    if ! check_network; then
        return
    fi

    # 修复：调用fetch_remote_file时只传实际定义的URL，去掉多余的BACKUP
    changelog_content=$(fetch_remote_file "${CHANGELOG_URL}" "更新日志")
    if [ $? -eq 0 ] && [ -n "${changelog_content}" ]; then
        # 高亮展示
        echo "${changelog_content}" | while IFS= read -r line; do
            if [[ "$line" =~ ^脚本更新日志 ]]; then
                echo -e "${BLUE}${line}${NC}"
            elif [[ "$line" =~ ^2026- ]]; then
                echo -e "${PURPLE}${line}${NC}"
            elif [[ "$line" =~ ^------------------------ ]]; then
                echo -e "${GREEN}${line}${NC}"
            else
                echo -e "${YELLOW}${line}${NC}"
            fi
        done
    fi

    echo -e "\n${GREEN}=========================================${NC}"
    echo -e "\n${CYAN}按任意键返回主菜单...${NC}"
    read -n 1 -s
    main_menu
}

main_menu() {
    show_title

    echo -e "${GREEN}【主菜单】${NC}"
    echo -e " 1. ${YELLOW}系统信息查询${NC}"
    echo -e " 2. ${YELLOW}系统更新${NC}"
    echo -e " 3. ${YELLOW}系统清理${NC}"
    echo -e ""
    echo -e " 8. ${CYAN}📝 查看更新日志${NC}"
    echo -e " 0. ${RED}退出${NC}"
    echo -e "${BLUE}=========================================${NC}"
    read -p "请输入选项：" choice

    case $choice in
        # 修复：调用run_remote_module时只传实际定义的URL，去掉多余的BACKUP
        1) run_remote_module "${SYS_INFO_URL}" "系统信息查询" ;;
        2) run_remote_module "${SYS_UPDATE_URL}" "系统更新" ;;
        3) run_remote_module "${SYS_CLEAN_URL}" "系统清理" ;;
        8) show_changelog ;;
        0) echo -e "${CYAN}感谢使用戏子一键工具箱，再见！${NC}"; exit 0 ;;
        *)
            # 修复：错误提示去掉9（菜单里没有9选项）
            echo -e "${RED}❌ 输入错误！请输入 0-3 或 8${NC}"
            sleep 1
            main_menu
            ;;
    esac
    main_menu
}

# 脚本入口
main_menu
