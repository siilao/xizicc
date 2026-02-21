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
SCRIPT_DIR=$(dirname "${SCRIPT_PATH}")
# 全局快捷键目标路径
SHORTCUT_PATH="/usr/local/bin/x"

# 一键验证地址（启动时自动检查，告诉你哪个地址有问题）
#verify_urls() {
#    show_title
#    echo -e "${GREEN}=========================================${NC}"
#    echo -e "${CYAN}               地址验证                  ${NC}"
#    echo -e "${GREEN}=========================================${NC}\n"
#
#    local urls=(
#        "系统信息模块:${URL_SYS_INFO}"
#        "系统更新模块:${URL_SYS_UPDATE}"
#        "系统清理模块:${URL_SYS_CLEAN}"
#        "更新日志文件:${URL_CHANGELOG}"
#    )
#
#    local all_ok=1
#    for url in "${urls[@]}"; do
#        name=${url%%:*}
#        link=${url#*:}
#
#        echo -e "${BLUE}检测 ${name}：${link}${NC}"
#        # 测试地址是否能访问且有内容
#        content=$(curl -s --connect-timeout 5 "$link")
#        if [ -n "$content" ]; then
#            echo -e "${GREEN}✅ ${name} 地址有效${NC}"
#        else
#            echo -e "${RED}❌ ${name} 地址无效/无内容${NC}"
#            all_ok=0
#        fi
#        echo "----------------------------------------"
#    done
#
#    if [ $all_ok -eq 1 ]; then
#        echo -e "${GREEN}✅ 所有地址验证通过！${NC}"
#    else
#        echo -e "${RED}❌ 部分地址无效，请检查URL！${NC}"
#    fi
#    sleep 2
#}

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

# 启动时先验证地址，再进主菜单
#verify_urls
main_menu
