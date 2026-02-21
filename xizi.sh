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

# ========== 核心修改：修正Raw地址 + 增加备用地址 ==========
# 主Raw地址（简化格式，去掉refs/heads/）
GITHUB_RAW_MAIN="https://raw.githubusercontent.com/siilao/xizicc/main/modules"
# 备用地址（GitHub镜像，国内可用）
GITHUB_RAW_BACKUP="https://ghproxy.com/https://raw.githubusercontent.com/siilao/xizicc/main/modules"

# 各模块地址（先试主地址，失败自动试备用）
SYS_INFO_URL_MAIN="${GITHUB_RAW_MAIN}/sys_info.sh"
SYS_INFO_URL_BACKUP="${GITHUB_RAW_BACKUP}/sys_info.sh"

SYS_UPDATE_URL_MAIN="${GITHUB_RAW_MAIN}/sys_update.sh"
SYS_UPDATE_URL_BACKUP="${GITHUB_RAW_BACKUP}/sys_update.sh"

SYS_CLEAN_URL_MAIN="${GITHUB_RAW_MAIN}/sys_clean.sh"
SYS_CLEAN_URL_BACKUP="${GITHUB_RAW_BACKUP}/sys_clean.sh"

CHANGELOG_URL_MAIN="${GITHUB_RAW_MAIN}/changelog.txt"
CHANGELOG_URL_BACKUP="${GITHUB_RAW_BACKUP}/changelog.txt"
# ========================================================

# 脚本路径
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
# GitHub仓库地址（整包更新用）
GIT_REPO_URL="https://github.com/siilao/xizicc.git"

# ========== 增强网络检测：显示详细错误 ==========
check_network() {
    echo -e "${BLUE}正在检测网络连接...${NC}"
    # 测试主地址
    if curl -s --connect-timeout 10 --head --request GET "${SYS_INFO_URL_MAIN}" | grep "200 OK" > /dev/null; then
        echo -e "${GREEN}✅ 主地址可访问${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️  主地址访问失败，尝试备用地址...${NC}"
        # 测试备用地址
        if curl -s --connect-timeout 10 --head --request GET "${SYS_INFO_URL_BACKUP}" | grep "200 OK" > /dev/null; then
            echo -e "${GREEN}✅ 备用地址可访问${NC}"
            return 0
        else
            echo -e "${RED}❌ 所有地址都无法访问！${NC}"
            echo -e "${YELLOW}主地址：${SYS_INFO_URL_MAIN}${NC}"
            echo -e "${YELLOW}备用地址：${SYS_INFO_URL_BACKUP}${NC}"
            sleep 5
            main_menu
            return 1
        fi
    fi
}

# ========== 增强拉取函数：自动切换备用地址 ==========
fetch_remote_file() {
    local main_url=$1
    local backup_url=$2
    local file_name=$3

    # 先试主地址
    content=$(curl -s --connect-timeout 10 "${main_url}")
    if [ -n "${content}" ]; then
        echo "${content}"
        return 0
    fi

    # 主地址失败，试备用地址
    echo -e "${YELLOW}⚠️  拉取${file_name}失败，尝试备用地址...${NC}"
    content=$(curl -s --connect-timeout 10 "${backup_url}")
    if [ -n "${content}" ]; then
        echo "${content}"
        return 0
    fi

    # 都失败
    echo -e "${RED}❌ 拉取${file_name}失败！${NC}"
    echo -e "${YELLOW}主地址：${main_url}${NC}"
    echo -e "${YELLOW}备用地址：${backup_url}${NC}"
    return 1
}

show_title() {
    clear
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${PURPLE}戏子一键工具箱  v${VERSION} 只为更简单的Linux的使用！${NC}"
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${YELLOW}适配Ubuntu/Debian/CentOS/Alpine/Kali/Arch/RedHat/Fedora/Alma/Rocky系统${NC}"
    echo -e ""
}

# 查看更新日志（支持备用地址）
show_changelog() {
    show_title
    echo -e "${GREEN}=========================================${NC}"
    echo -e "${CYAN}               更新日志                  ${NC}"
    echo -e "${GREEN}=========================================${NC}\n"

    # 检测网络
    if ! check_network; then
        return
    fi

    # 拉取日志（自动切换备用地址）
    changelog_content=$(fetch_remote_file "${CHANGELOG_URL_MAIN}" "${CHANGELOG_URL_BACKUP}" "更新日志")
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

# 运行远程模块（支持备用地址）
run_remote_module() {
    local main_url=$1
    local backup_url=$2
    local module_name=$3

    show_title
    echo -e "${GREEN}=========================================${NC}"
    echo -e "${YELLOW}            运行${module_name}模块            ${NC}"
    echo -e "${GREEN}=========================================${NC}\n"

    # 检测网络
    if ! check_network; then
        return
    fi

    # 拉取模块内容（自动切换备用地址）
    echo -e "${BLUE}正在拉取${module_name}模块...${NC}"
    module_content=$(fetch_remote_file "${main_url}" "${backup_url}" "${module_name}模块")
    if [ $? -eq 0 ] && [ -n "${module_content}" ]; then
        # 运行模块
        echo "${module_content}" | bash
        echo -e "\n${GREEN}✅ ${module_name}模块运行完成！${NC}"
    else
        echo -e "\n${RED}❌ ${module_name}模块拉取失败，无法运行！${NC}"
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
        # 调用时传入主地址+备用地址
        1) run_remote_module "${SYS_INFO_URL_MAIN}" "${SYS_INFO_URL_BACKUP}" "系统信息查询" ;;
        2) run_remote_module "${SYS_UPDATE_URL_MAIN}" "${SYS_UPDATE_URL_BACKUP}" "系统更新" ;;
        3) run_remote_module "${SYS_CLEAN_URL_MAIN}" "${SYS_CLEAN_URL_BACKUP}" "系统清理" ;;
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

# 脚本入口
main_menu
