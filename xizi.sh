#!/bin/bash
VERSION="1.0.4"

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 所有模块地址只在这定义，调用时直接用，杜绝不匹配
URL_SYS_INFO="https://raw.githubusercontent.com/siilao/xizicc/main/modules/sys_info.sh"
URL_SYS_UPDATE="https://raw.githubusercontent.com/siilao/xizicc/main/modules/sys_update.sh"
URL_SYS_CLEAN="https://raw.githubusercontent.com/siilao/xizicc/main/modules/sys_clean.sh"
URL_CHANGELOG="https://raw.githubusercontent.com/siilao/xizicc/main/modules/changelog.txt"
URL_BASE_TOOLS="https://raw.githubusercontent.com/siilao/xizicc/main/modules/base_tools.sh"

# 外面的世界 二级菜单模块地址
URL_WORLD_PROXY="https://raw.githubusercontent.com/siilao/xizicc/main/world/sys_proxy.sh"
URL_WORLD_CDN="https://raw.githubusercontent.com/siilao/xizicc/main/world/sys_bbr.sh"
# 新增：网络连通性检测 三级菜单模块地址
URL_CHECK_PING="https://raw.githubusercontent.com/siilao/xizicc/main/world/check_ping.sh"
URL_CHECK_PORT="https://raw.githubusercontent.com/siilao/xizicc/main/world/check_port.sh"
URL_CHECK_SPEED="https://raw.githubusercontent.com/siilao/xizicc/main/world/check_speed.sh"

# 仅保留脚本地址（无需version.txt）
URL_LATEST_SCRIPT="https://raw.githubusercontent.com/siilao/xizicc/main/xizi.sh"
# ==============================================

# 脚本路径（获取xizi.sh的绝对路径，关键！）
SCRIPT_PATH=$(readlink -f "$0")
# 全局快捷键目标路径
SHORTCUT_PATH="/usr/local/bin/x"

# 优化：直接从远程脚本提取版本号进行对比
check_and_update_version() {
    show_title
    echo -e "${BLUE}🔍 正在检查版本更新...${NC}\n"

    # 抓取远程脚本内容，并提取VERSION变量值
    # grep匹配VERSION定义行 + sed提取引号内的版本号
    remote_version=$(curl -s "$URL_LATEST_SCRIPT" | grep '^VERSION="' | sed -E 's/VERSION="(.*)"/\1/')

    # 检查是否成功获取远程版本
    if [ -z "$remote_version" ] || [ "$remote_version" = "$VERSION" ]; then
        if [ -z "$remote_version" ]; then
            echo -e "${YELLOW}⚠️  无法获取远程版本信息，跳过更新检查${NC}\n"
        else
            echo -e "${GREEN}✅ 当前已是最新版本：v${VERSION}${NC}\n"
        fi
        sleep 1
        return
    fi

    # 版本不一致，执行更新
    echo -e "${GREEN}发现新版本：v${remote_version}（当前版本：v${VERSION}）${NC}"
    echo -e "${YELLOW}正在自动更新脚本...${NC}\n"

    # 下载最新脚本并替换
    if curl -s "$URL_LATEST_SCRIPT" -o "$SCRIPT_PATH.tmp"; then
        # 替换前先备份旧版本（加时间戳，避免覆盖）
        cp "$SCRIPT_PATH" "${SCRIPT_PATH}.old_$(date +%Y%m%d_%H%M%S)"
        # 替换脚本文件
        mv "$SCRIPT_PATH.tmp" "$SCRIPT_PATH"
        # 添加执行权限
        chmod +x "$SCRIPT_PATH"

        echo -e "${GREEN}✅ 脚本更新成功！已自动切换到新版本 v${remote_version}${NC}"
        echo -e "${YELLOW}正在重启脚本...${NC}\n"
        sleep 2

        # 重新执行新版本脚本并退出当前进程
        exec "$SCRIPT_PATH"
        exit 0
    else
        echo -e "${RED}❌ 脚本更新失败，请手动下载最新版本${NC}"
        echo -e "${RED}手动更新命令：curl -s ${URL_LATEST_SCRIPT} -o ${SCRIPT_PATH} && chmod +x ${SCRIPT_PATH}${NC}\n"
        sleep 2
    fi
}

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
    echo -e "${YELLOW}输入${RED}x${YELLOW}可快速启动此脚本${NC}"
    echo -e ""
}

# 优化run_module函数：支持返回指定菜单（适配二级菜单）
run_module() {
    local url=$1
    local name=$2
    local return_menu=${3:-main_menu}  # 默认返回主菜单

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
    $return_menu  # 执行指定的返回菜单
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

# ========== 外面的世界 二级菜单 ==========
world_submenu() {
    show_title
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${PURPLE}             🌍 外面的世界子菜单         ${NC}"
    echo -e "${BLUE}=========================================${NC}"
    echo -e " 1. ${YELLOW}代理配置工具${NC}"
    echo -e " 2. ${YELLOW}BBR加速配置${NC}"
    echo -e " 3. ${YELLOW}网络连通性检测${NC}"  # 改文本提示
    echo -e "${BLUE}=========================================${NC}"
    echo -e " 0. ${CYAN}返回主菜单${NC}"
    echo -e "${BLUE}=========================================${NC}"
    read -p "请输入子菜单选项：" sub_choice

    case $sub_choice in
        1) run_module "$URL_WORLD_PROXY" "代理配置工具" "world_submenu" ;;
        2) run_module "$URL_WORLD_CDN" "BBR加速配置" "world_submenu" ;;
        3) check_submenu ;;  # 改为进入三级菜单，不再直接调用模块
        0) main_menu ;;
        *)
            echo -e "${RED}❌ 输入错误！请输入 0-3${NC}"
            sleep 1
            world_submenu
            ;;
    esac
}

# ========== 三级菜单：网络连通性检测 ==========
check_submenu() {
    show_title
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${PURPLE}            📡 网络连通性检测（三级）${NC}"
    echo -e "${BLUE}=========================================${NC}"
    echo -e " 1. ${YELLOW}PING检测（延迟/丢包）${NC}"
    echo -e " 2. ${YELLOW}端口连通性检测${NC}"
    echo -e " 3. ${YELLOW}网速测试${NC}"
    echo -e "${BLUE}=========================================${NC}"
    echo -e " 0. ${CYAN}返回上一级（外面的世界）${NC}"
    echo -e "${BLUE}=========================================${NC}"
    read -p "请输入三级菜单选项：" sub3_choice

    case $sub3_choice in
        1) run_module "$URL_CHECK_PING" "PING检测" "check_submenu" ;;
        2) run_module "$URL_CHECK_PORT" "端口连通性检测" "check_submenu" ;;
        3) run_module "$URL_CHECK_SPEED" "网速测试" "check_submenu" ;;
        0) world_submenu ;;  # 返回二级菜单（外面的世界）
        *)
            echo -e "${RED}❌ 输入错误！请输入 0-3${NC}"
            sleep 1
            check_submenu
            ;;
    esac
}

main_menu() {
    show_title

    echo -e "${BLUE}=========================================${NC}"
    echo -e " 1. ${YELLOW}系统信息查询${NC}"
    echo -e " 2. ${YELLOW}系统更新${NC}"
    echo -e " 3. ${YELLOW}系统清理${NC}"
    echo -e " 4. ${YELLOW}基础工具${NC}"
    echo -e " 5. ${YELLOW}外面的世界${NC}"
    echo -e "${BLUE}=========================================${NC}"
    echo -e " 8. ${CYAN}查看更新日志${NC}"
    echo -e " 9. ${RED}退出脚本${NC}"
    echo -e "${BLUE}=========================================${NC}"
    read -p "请输入选项：" choice

    case $choice in
        1) run_module "$URL_SYS_INFO" "系统信息查询" ;;
        2) run_module "$URL_SYS_UPDATE" "系统更新" ;;
        3) run_module "$URL_SYS_CLEAN" "系统清理" ;;
        4) run_module "$URL_BASE_TOOLS" "基础工具" ;;
        5) world_submenu ;; # 进入外面的世界二级菜单
        8) show_changelog ;;
        9) echo -e "${CYAN}再见！${NC}"; exit 0 ;;
        *)
            echo -e "${RED}❌ 输入错误！请输入 1-5、8、9${NC}"  # 修正错误提示
            sleep 1
            main_menu
            ;;
    esac
}

# ========== 脚本启动入口 ==========
# 第一步：版本检查与更新
check_and_update_version
# 第二步：自动配置快捷键（首次运行触发，后续跳过）
auto_setup_shortcut
# 第三步：进入主菜单
main_menu