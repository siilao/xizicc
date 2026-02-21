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

# 路径
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
MODULE_DIR="${SCRIPT_DIR}/modules"

# 替换成你的GitHub仓库地址
GIT_REPO_URL="https://github.com/siilao/xizicc.git"

show_title() {
    clear
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${PURPLE}戏子一键工具箱  v${VERSION} 只为更简单的Linux的使用！${NC}"
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${YELLOW}适配Ubuntu/Debian/CentOS/Alpine/Kali/Arch/RedHat/Fedora/Alma/Rocky系统${NC}"
    echo -e ""
}

check_dir() {
    if [ ! -d "${MODULE_DIR}" ]; then
        mkdir -p "${MODULE_DIR}"
    fi
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
    echo -e " 9. ${CYAN}🔄 脚本更新（Git 拉取）${NC}"
    echo -e " 0. ${RED}退出${NC}"
    echo -e "${BLUE}=========================================${NC}"
    read -p "请输入选项：" choice

    case $choice in
        1) bash "${MODULE_DIR}/sys_info.sh" ;;
        2) bash "${MODULE_DIR}/sys_update.sh" ;;
        3) bash "${MODULE_DIR}/sys_clean.sh" ;;
        9) update_full_git ;;
        0) echo -e "${CYAN}再见！${NC}"; exit 0 ;;
        *) echo -e "${RED}输入错误${NC}"; sleep 1 ;;
    esac

    echo -e "\n按回车返回菜单"
    read -r
    main_menu
}

check_dir
main_menu