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

# 脚本路径
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
# GitHub Raw 基础地址（你的仓库）
GITHUB_RAW_BASE="https://raw.githubusercontent.com/siilao/xizicc/refs/heads/main/modules"
# 各模块远程地址
SYS_INFO_URL="${GITHUB_RAW_BASE}/sys_info.sh"
SYS_UPDATE_URL="${GITHUB_RAW_BASE}/sys_update.sh"
SYS_CLEAN_URL="${GITHUB_RAW_BASE}/sys_clean.sh"
CHANGELOG_URL="${GITHUB_RAW_BASE}/changelog.txt"

# GitHub仓库地址（整包更新用）
GIT_REPO_URL="https://github.com/siilao/xizicc.git"

# 网络检测函数（核心：确保能访问GitHub）
check_network() {
    if ! curl -s --head --request GET "https://github.com" | grep "200 OK" > /dev/null; then
        echo -e "${RED}❌ 网络连接失败！无法访问GitHub，请检查网络后重试。${NC}"
        sleep 3
        main_menu
        return 1
    fi
    return 0
}

show_title() {
    clear
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${PURPLE}戏子一键工具箱  v${VERSION} 只为更简单的Linux的使用！${NC}"
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${YELLOW}适配Ubuntu/Debian/CentOS/Alpine/Kali/Arch/RedHat/Fedora/Alma/Rocky系统${NC}"
    echo -e ""
}

# 查看更新日志（拉取远程日志）
show_changelog() {
    show_title
    echo -e "${GREEN}=========================================${NC}"
    echo -e "${CYAN}               更新日志                  ${NC}"
    echo -e "${GREEN}=========================================${NC}\n"

    # 先检测网络
    if ! check_network; then
        return
    fi

    # 拉取远程日志内容
    changelog_content=$(curl -s "${CHANGELOG_URL}")
    if [ -z "${changelog_content}" ]; then
        echo -e "${RED}❌ 拉取更新日志失败！${NC}"
        echo -e "${YELLOW}远程日志地址：${CHANGELOG_URL}${NC}"
    else
        # 按格式高亮展示
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

# 运行远程模块的通用函数（核心：拉取并执行远程脚本）
run_remote_module() {
    local module_url=$1
    local module_name=$2

    show_title
    echo -e "${GREEN}=========================================${NC}"
    echo -e "${YELLOW}            运行${module_name}模块            ${NC}"
    echo -e "${GREEN}=========================================${NC}\n"

    # 检测网络
    if ! check_network; then
        return
    fi

    # 拉取并运行远程脚本
    echo -e "${BLUE}正在拉取${module_name}模块...${NC}"
    if curl -s "${module_url}" | bash; then
        echo -e "\n${GREEN}✅ ${module_name}模块运行完成！${NC}"
    else
        echo -e "\n${RED}❌ ${module_name}模块拉取/运行失败！${NC}"
        echo -e "${YELLOW}远程模块地址：${module_url}${NC}"
    fi

    sleep 2
    main_menu
}

# 整包更新（Git拉取）
update_full_git() {
    show_title
    echo -e "${GREEN}【脚本更新】正在拉取最新代码...${NC}"

    # 检测网络
    if ! check_network; then
        return
    fi

    # 安装Git（适配所有系统）
    if ! command -v git &> /dev/null; then
        echo -e "${YELLOW}正在安装 git...${NC}"
        if command -v apt &> /dev/null; then
            apt update -y && apt install git -y
        elif command -v yum &> /dev/null; then
            yum install git -y
        elif command -v apk &> /dev/null; then
            apk update && apk add git
        elif command -v pacman &> /dev/null; then
            pacman -Sy --noconfirm git
        elif command -v dnf &> /dev/null; then
            dnf install git -y
        else
            echo -e "${RED}❌ 暂不支持当前系统安装Git，请手动安装！${NC}"
            sleep 3
            main_menu
            return
        fi
    fi

    cd "${SCRIPT_DIR}" || {
        echo -e "${RED}❌ 进入脚本目录失败！${NC}"
        sleep 3
        main_menu
        return
    }

    # 初始化Git仓库（首次）
    if [ ! -d .git ]; then
        echo -e "${YELLOW}初始化 Git 仓库...${NC}"
        git init && git remote add origin "${GIT_REPO_URL}"
    fi

    # 拉取最新代码
    git fetch --all > /dev/null 2>&1
    git reset --hard origin/main > /dev/null 2>&1
    pull_result=$(git pull origin main 2>&1)

    if echo "${pull_result}" | grep -q "Already up to date"; then
        echo -e "${GREEN}✅ 脚本已是最新版本（v${VERSION}），无需更新！${NC}"
    elif [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 脚本更新完成！即将重启脚本...${NC}"
        sleep 2
        exec bash "${SCRIPT_DIR}/$(basename "$0")"
    else
        echo -e "${RED}❌ 更新失败！错误信息：${pull_result}${NC}"
    fi

    echo -e "\n${CYAN}按回车返回菜单...${NC}"
    read -r
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
    echo -e " 9. ${CYAN}🔄 脚本更新（Git 拉取）${NC}"
    echo -e " 0. ${RED}退出${NC}"
    echo -e "${BLUE}=========================================${NC}"
    read -p "请输入选项：" choice

    case $choice in
        1) run_remote_module "${SYS_INFO_URL}" "系统信息查询" ;;
        2) run_remote_module "${SYS_UPDATE_URL}" "系统更新" ;;
        3) run_remote_module "${SYS_CLEAN_URL}" "系统清理" ;;
        8) show_changelog ;;
        9) update_full_git ;;
        0) echo -e "${CYAN}感谢使用戏子一键工具箱，再见！${NC}"; exit 0 ;;
        *)
            echo -e "${RED}❌ 输入错误！请输入 0-3、8 或 9${NC}"
            sleep 1
            main_menu
            ;;
    esac
    main_menu
}

# 脚本入口（直接启动主菜单，无多余逻辑）
main_menu
