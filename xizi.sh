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

# ========== 唯一地址定义区（只改这里！）==========
# 所有模块地址只在这定义，调用时直接用，杜绝不匹配
URL_SYS_INFO="https://raw.githubusercontent.com/siilao/xizicc/main/modules/sys_info.sh"
URL_SYS_UPDATE="https://raw.githubusercontent.com/siilao/xizicc/main/modules/sys_update.sh"
URL_SYS_CLEAN="https://raw.githubusercontent.com/siilao/xizicc/main/modules/sys_clean.sh"
URL_CHANGELOG="https://raw.githubusercontent.com/siilao/xizicc/main/modules/changelog.txt"
# ==============================================

# 脚本路径（获取xizi.sh的绝对路径，关键！）
SCRIPT_PATH=$(readlink -f "$0")
# 全局快捷键目标路径
SHORTCUT_PATH="/usr/local/bin/x"

# 核心：首次运行自动配置快捷键（无交互）
auto_setup_shortcut() {
    # 检查是否已有快捷键
    if [ -L "${SHORTCUT_PATH}" ]; then
        existing_link=$(readlink "${SHORTCUT_PATH}")
        # 已有正确的快捷键，直接返回
        if [ "${existing_link}" = "${SCRIPT_PATH}" ]; then
            return 0
        fi
        # 已有错误的快捷键，自动覆盖（无需确认）
        echo -e "${YELLOW}⚠️  检测到快捷键 x 指向错误，自动更新...${NC}"
        sudo rm -f "${SHORTCUT_PATH}"
    fi

    # 全新配置/覆盖配置快捷键
    echo -e "${BLUE}📦 正在配置全局快捷键 x...${NC}"
    if sudo ln -s "${SCRIPT_PATH}" "${SHORTCUT_PATH}" && sudo chmod +x "${SHORTCUT_PATH}"; then
        echo -e "${GREEN}✅ 全局快捷键 x 配置成功！${NC}"
        echo -e "${YELLOW}任意目录输入 x 即可运行本脚本${NC}\n"
    else
        echo -e "${RED}❌ 快捷键自动配置失败，请手动执行以下命令：${NC}"
        echo -e "sudo ln -s ${SCRIPT_PATH} ${SHORTCUT_PATH}"
        echo -e "sudo chmod +x ${SHORTCUT_PATH}\n"
    fi
    sleep 2
}

show_title() {
    clear
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${PURPLE}戏子一键工具箱  v${VERSION} 只为更简单的Linux的使用！${NC}"
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${YELLOW}适配Ubuntu/Debian/CentOS/Alpine/Kali/Arch/RedHat/Fedora/Alma/Rocky系统${NC}"
    echo -e ""
}

# 运行远程模块（只用统一的地址变量）
run_module() {
    local url=$1
    local name=$2

    show_title
    echo -e "${GREEN}正在运行【${name}】模块...${NC}\n"

    # 保存到临时文件执行（最稳定）
    temp_file=$(mktemp)
    curl -s "$url" -o "$temp_file"

    if [ -s "$temp_file" ]; then
        bash "$temp_file"
        echo -e "\n${GREEN}✅ ${name} 运行完成！${NC}"
    else
        echo -e "${RED}❌ ${name} 拉取失败（地址：${url}）${NC}"
    fi

    rm -f "$temp_file"
    sleep 2
    main_menu
}

# 查看更新日志（只用统一的地址变量）
show_changelog() {
    show_title
    echo -e "${GREEN}=========================================${NC}"
    echo -e "${CYAN}               更新日志                  ${NC}"
    echo -e "${GREEN}=========================================${NC}\n"

    content=$(curl -s "$URL_CHANGELOG")
    if [ -n "$content" ]; then
        echo -e "${YELLOW}${content}${NC}"
    else
        echo -e "${RED}❌ 日志拉取失败（地址：${URL_CHANGELOG}）${NC}"
    fi

    echo -e "\n${GREEN}=========================================${NC}"
    echo -e "\n${CYAN}按任意键返回...${NC}"
    read -n 1 -s
    main_menu
}

main_menu() {
    show_title

    echo -e "${GREEN}【主菜单】${NC}"
#    echo -e " 0. ${CYAN}🔍 验证所有地址${NC}"
    echo -e " 1. ${YELLOW}系统信息查询${NC}"
    echo -e " 2. ${YELLOW}系统更新${NC}"
    echo -e " 3. ${YELLOW}系统清理${NC}"
    echo -e ""
    echo -e " 8. ${CYAN}📝 查看更新日志${NC}"
    echo -e " 9. ${RED}退出${NC}"
    echo -e "${BLUE}=========================================${NC}"
    read -p "请输入选项：" choice

    case $choice in
#        0) verify_urls; main_menu ;;  # 一键验证地址
        1) run_module "$URL_SYS_INFO" "系统信息查询" ;;
        2) run_module "$URL_SYS_UPDATE" "系统更新" ;;
        3) run_module "$URL_SYS_CLEAN" "系统清理" ;;
        8) show_changelog ;;
        9) echo -e "${CYAN}再见！${NC}"; exit 0 ;;
        *)
            echo -e "${RED}❌ 输入错误！请输入 0-3、8、9${NC}"
            sleep 1
            main_menu
            ;;
    esac
}

# ========== 脚本启动入口 ==========
# 第一步：自动配置快捷键（首次运行触发，后续跳过）
auto_setup_shortcut
# 第二步：进入主菜单
main_menu
