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

# 脚本路径（无需本地modules目录）
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
# GitHub Raw 基础地址（替换成你的仓库路径）
GITHUB_RAW_BASE="https://raw.githubusercontent.com/siilao/xizicc/refs/heads/main/modules"
# 各模块的Raw地址
SYS_INFO_URL="${GITHUB_RAW_BASE}/sys_info.sh"
SYS_UPDATE_URL="${GITHUB_RAW_BASE}/sys_update.sh"
SYS_CLEAN_URL="${GITHUB_RAW_BASE}/sys_clean.sh"
CHANGELOG_URL="${GITHUB_RAW_BASE}/changelog.txt"
# 独立日志文件路径
CHANGELOG_FILE="${MODULE_DIR}/changelog.txt"
# 快捷键目标路径（系统全局可执行目录）
SHORTCUT_PATH="/usr/local/bin/x"

# 替换成你的GitHub仓库地址
GIT_REPO_URL="https://github.com/siilao/xizicc.git"

# 网络检测函数
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

check_dir() {
    # 只创建模块目录，不自动创建日志文件
    if [ ! -d "${MODULE_DIR}" ]; then
        mkdir -p "${MODULE_DIR}"
        echo -e "${GREEN}已创建模块目录：${MODULE_DIR}${NC}"
        sleep 1
    fi
}

# 查看独立日志文件
show_changelog() {
    show_title
    echo -e "${GREEN}=========================================${NC}"
    echo -e "${CYAN}               更新日志                  ${NC}"
    echo -e "${GREEN}=========================================${NC}\n"

    # 检查日志文件是否存在
    if [ ! -f "${CHANGELOG_FILE}" ]; then
        echo -e "${RED}❌ 更新日志文件不存在！${NC}"
        echo -e "${YELLOW}日志文件路径：${CHANGELOG_FILE}${NC}"
        echo -e "${CYAN}请手动创建日志文件后重试。${NC}"
    else
        # 按格式高亮展示日志
        while IFS= read -r line; do
            if [[ "$line" =~ ^脚本更新日志 ]]; then
                echo -e "${BLUE}${line}${NC}"
            elif [[ "$line" =~ ^2026- ]]; then
                echo -e "${PURPLE}${line}${NC}"
            elif [[ "$line" =~ ^------------------------ ]]; then
                echo -e "${GREEN}${line}${NC}"
            else
                echo -e "${YELLOW}${line}${NC}"
            fi
        done < "${CHANGELOG_FILE}"
    fi

    echo -e "\n${GREEN}=========================================${NC}"
    echo -e "\n${CYAN}按任意键返回主菜单...${NC}"
    read -n 1 -s
    main_menu
}

# 整包更新（git pull）
update_full_git() {
    echo -e "${GREEN}【脚本更新】正在拉取最新代码...${NC}"

    # 先检查有没有安装 git
    if ! command -v git &> /dev/null; then
        echo -e "${YELLOW}正在安装 git...${NC}"
        apt update && apt install git -y || yum install git -y
    fi

    cd "${SCRIPT_DIR}"

    # 如果不是 git 仓库，先初始化
    if [ ! -d .git ]; then
        echo -e "${YELLOW}初始化 Git 仓库...${NC}"
        git init
        git remote add origin "${GIT_REPO_URL}"
    fi

    git fetch --all
    git reset --hard origin/main
    git pull origin main

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 脚本更新完成！包含主脚本 + modules 全部文件！${NC}"
    else
        echo -e "${RED}❌ 更新失败${NC}"
    fi

    echo -e "\n按回车返回菜单"
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
            main_menu  # 输入错误后清屏返回菜单
            ;;
    esac
    main_menu
}

check_dir
main_menu