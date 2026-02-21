#!/bin/bash
# 适配：Ubuntu/Debian/CentOS/Fedora/Arch/Alpine/SUSE/OpenWrt

# ========== 1. 你的颜色定义（核心） ==========
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'  # 重置颜色

# ========== 2. 补充缺失的依赖函数（原版未定义） ==========
# 2.1 安装函数（适配所有包管理器）
install() {
    local tools="$@"
    if [ -z "$tools" ]; then
        echo -e "${RED}❌ 未指定要安装的工具！${NC}"
        sleep 1
        return 1
    fi

    echo -e "${GREEN}📦 正在安装：$tools${NC}"
    case $PM in
        apt)
            # Debian/Ubuntu 无交互安装
            apt update -y >/dev/null 2>&1
            DEBIAN_FRONTEND=noninteractive apt install -y $tools
            ;;
        dnf)
            # Fedora/RHEL9+
            dnf install -y $tools
            ;;
        yum)
            # CentOS/RHEL8-
            yum install -y $tools
            ;;
        pacman)
            # Arch/Manjaro
            pacman -S --noconfirm $tools
            ;;
        apk)
            # Alpine
            apk update >/dev/null 2>&1
            apk add $tools
            ;;
        zypper)
            # SUSE
            zypper install -y $tools
            ;;
        opkg)
            # OpenWrt
            opkg update >/dev/null 2>&1
            opkg install $tools
            ;;
        pkg)
            # Termux
            pkg install -y $tools
            ;;
        *)
            echo -e "${RED}❌ 不支持的包管理器！${NC}"
            return 1
            ;;
    esac

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 安装完成！${NC}"
    else
        echo -e "${RED}❌ 部分工具安装失败（可能是包名不一致）${NC}"
    fi
    sleep 1
}

# 2.2 卸载函数（适配所有包管理器）
remove() {
    local tools="$@"
    if [ -z "$tools" ]; then
        echo -e "${RED}❌ 未指定要卸载的工具！${NC}"
        sleep 1
        return 1
    fi

    echo -e "${YELLOW}🗑️  正在卸载：$tools${NC}"
    case $PM in
        apt)
            apt remove -y --purge $tools
            ;;
        dnf)
            dnf remove -y $tools
            ;;
        yum)
            yum remove -y $tools
            ;;
        pacman)
            pacman -Rns --noconfirm $tools
            ;;
        apk)
            apk del $tools
            ;;
        zypper)
            zypper remove -y $tools
            ;;
        opkg)
            opkg remove $tools
            ;;
        pkg)
            pkg remove -y $tools
            ;;
        *)
            echo -e "${RED}❌ 不支持的包管理器！${NC}"
            return 1
            ;;
    esac

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 卸载完成！${NC}"
    else
        echo -e "${RED}❌ 部分工具卸载失败！${NC}"
    fi
    sleep 1
}

# 2.3 操作后暂停函数
break_end() { sleep 1; }

# ========== 3. 核心：linux_tools 函数（清理后） ==========
linux_tools() {
  while true; do
	  clear
	  echo -e "${CYAN}========== 基础工具管理 ==========${NC}"
	  echo -e "${PURPLE}基础工具${NC}"

	  # 定义工具列表
	  tools=(
		curl wget sudo socat htop iftop unzip tar tmux ffmpeg
		btop ranger ncdu fzf cmatrix sl bastet nsnake ninvaders
		vim nano git
	  )

	  # 检测包管理器
	  if command -v apt >/dev/null 2>&1; then
		PM="apt"
	  elif command -v dnf >/dev/null 2>&1; then
		PM="dnf"
	  elif command -v yum >/dev/null 2>&1; then
		PM="yum"
	  elif command -v pacman >/dev/null 2>&1; then
		PM="pacman"
	  elif command -v apk >/dev/null 2>&1; then
		PM="apk"
	  elif command -v zypper >/dev/null 2>&1; then
		PM="zypper"
	  elif command -v opkg >/dev/null 2>&1; then
		PM="opkg"
	  elif command -v pkg >/dev/null 2>&1; then
		PM="pkg"
	  else
		echo -e "${RED}❌ 未识别的包管理器${NC}"
		sleep 2
		exit 1
	  fi

	  # 输出包管理器信息
	  echo -e "${GREEN}📦 使用包管理器: $PM${NC}"
	  echo -e "${CYAN}------------------------${NC}"

	  # 输出工具安装状态（双色列表）
	  for ((i=0; i<${#tools[@]}; i+=2)); do
		# 左列
		if command -v "${tools[i]}" >/dev/null 2>&1; then
		  left=$(printf "${GREEN}✅ %-12s 已安装${NC}" "${tools[i]}")
		else
		  left=$(printf "${RED}❌ %-12s 未安装${NC}" "${tools[i]}")
		fi

		# 右列（防止数组越界）
		if [[ -n "${tools[i+1]}" ]]; then
		  if command -v "${tools[i+1]}" >/dev/null 2>&1; then
			right=$(printf "${GREEN}✅ %-12s 已安装${NC}" "${tools[i+1]}")
		  else
			right=$(printf "${RED}❌ %-12s 未安装${NC}" "${tools[i+1]}")
		  fi
		  printf "%-42s %s\n" "$left" "$right"
		else
		  printf "%s\n" "$left"
		fi
	  done

	  # 输出菜单（替换为你的颜色）
	  echo -e "${CYAN}------------------------${NC}"
	  echo -e "${CYAN}1.   ${NC}curl 下载工具 ${YELLOW}★${NC}                   ${CYAN}2.   ${NC}wget 下载工具 ${YELLOW}★${NC}"
	  echo -e "${CYAN}3.   ${NC}sudo 超级管理权限工具             ${CYAN}4.   ${NC}socat 通信连接工具"
	  echo -e "${CYAN}5.   ${NC}htop 系统监控工具                 ${CYAN}6.   ${NC}iftop 网络流量监控工具"
	  echo -e "${CYAN}7.   ${NC}unzip ZIP压缩解压工具             ${CYAN}8.   ${NC}tar GZ压缩解压工具"
	  echo -e "${CYAN}9.   ${NC}tmux 多路后台运行工具             ${CYAN}10.  ${NC}ffmpeg 视频编码直播推流工具"
	  echo -e "${CYAN}------------------------${NC}"
	  echo -e "${CYAN}11.  ${NC}btop 现代化监控工具 ${YELLOW}★${NC}             ${CYAN}12.  ${NC}ranger 文件管理工具"
	  echo -e "${CYAN}13.  ${NC}ncdu 磁盘占用查看工具             ${CYAN}14.  ${NC}fzf 全局搜索工具"
	  echo -e "${CYAN}15.  ${NC}vim 文本编辑器                    ${CYAN}16.  ${NC}nano 文本编辑器 ${YELLOW}★${NC}"
	  echo -e "${CYAN}17.  ${NC}git 版本控制系统                  ${CYAN}18.  ${NC}opencode AI编程助手 ${YELLOW}★${NC}"
	  echo -e "${CYAN}------------------------${NC}"
	  echo -e "${CYAN}21.  ${NC}黑客帝国屏保                      ${CYAN}22.  ${NC}跑火车屏保"
	  echo -e "${CYAN}26.  ${NC}俄罗斯方块小游戏                  ${CYAN}27.  ${NC}贪吃蛇小游戏"
	  echo -e "${CYAN}28.  ${NC}太空入侵者小游戏"
	  echo -e "${CYAN}------------------------${NC}"
	  echo -e "${CYAN}31.  ${NC}全部安装                          ${CYAN}32.  ${NC}全部安装（不含屏保和游戏）${YELLOW}★${NC}"
	  echo -e "${CYAN}33.  ${NC}全部卸载"
	  echo -e "${CYAN}------------------------${NC}"
	  echo -e "${CYAN}41.  ${NC}安装指定工具                      ${CYAN}42.  ${NC}卸载指定工具"
	  echo -e "${CYAN}------------------------${NC}"
	  echo -e "${CYAN}0.   ${NC}退出脚本"
	  echo -e "${CYAN}------------------------${NC}"

	  # 读取用户选择
	  read -e -p "$(echo -e ${BLUE}"请输入你的选择: "${NC})" sub_choice

	  # 菜单逻辑（已删除所有send_stats/kejilion调用）
	  case $sub_choice in
		  1)
			  clear
			  install curl
			  clear
			  echo -e "${GREEN}工具已安装，使用方法如下：${NC}"
			  curl --help | head -20
			  ;;
		  2)
			  clear
			  install wget
			  clear
			  echo -e "${GREEN}工具已安装，使用方法如下：${NC}"
			  wget --help | head -20
			  ;;
			3)
			  clear
			  install sudo
			  clear
			  echo -e "${GREEN}工具已安装，使用方法如下：${NC}"
			  sudo --help | head -20
			  ;;
			4)
			  clear
			  install socat
			  clear
			  echo -e "${GREEN}工具已安装，使用方法如下：${NC}"
			  socat -h | head -20
			  ;;
			5)
			  clear
			  install htop
			  clear
			  echo -e "${GREEN}工具已安装，按q退出htop${NC}"
			  sleep 1
			  htop
			  ;;
			6)
			  clear
			  install iftop
			  clear
			  echo -e "${GREEN}工具已安装，按q退出iftop${NC}"
			  sleep 1
			  iftop
			  ;;
			7)
			  clear
			  install unzip
			  clear
			  echo -e "${GREEN}工具已安装，使用方法如下：${NC}"
			  unzip --help | head -20
			  ;;
			8)
			  clear
			  install tar
			  clear
			  echo -e "${GREEN}工具已安装，使用方法如下：${NC}"
			  tar --help | head -20
			  ;;
			9)
			  clear
			  install tmux
			  clear
			  echo -e "${GREEN}工具已安装，使用方法如下：${NC}"
			  tmux --help | head -20
			  ;;
			10)
			  clear
			  install ffmpeg
			  clear
			  echo -e "${GREEN}工具已安装，使用方法如下：${NC}"
			  ffmpeg --help | head -20
			  ;;
			11)
			  clear
			  install btop
			  clear
			  echo -e "${GREEN}工具已安装，按q退出btop${NC}"
			  sleep 1
			  btop
			  ;;
			12)
			  clear
			  install ranger
			  clear
			  echo -e "${GREEN}工具已安装，按q退出ranger${NC}"
			  sleep 1
			  ranger
			  ;;
			13)
			  clear
			  install ncdu
			  clear
			  echo -e "${GREEN}工具已安装，按q退出ncdu${NC}"
			  sleep 1
			  ncdu
			  ;;
			14)
			  clear
			  install fzf
			  clear
			  echo -e "${GREEN}工具已安装，使用方法：fzf${NC}"
			  sleep 1
			  fzf --help | head -20
			  ;;
			15)
			  clear
			  install vim
			  clear
			  echo -e "${GREEN}工具已安装，使用方法：vim -h${NC}"
			  vim -h | head -20
			  ;;
			16)
			  clear
			  install nano
			  clear
			  echo -e "${GREEN}工具已安装，使用方法如下：${NC}"
			  nano -h | head -20
			  ;;
			17)
			  clear
			  install git
			  clear
			  echo -e "${GREEN}工具已安装，使用方法如下：${NC}"
			  git --help | head -20
			  ;;
			18)
			  clear
			  echo -e "${GREEN}正在安装opencode AI编程助手...${NC}"
			  cd ~
			  curl -fsSL https://opencode.ai/install | bash
			  source ~/.bashrc 2>/dev/null
			  source ~/.profile 2>/dev/null
			  echo -e "${GREEN}安装完成，输入 opencode 启动${NC}"
			  opencode --help 2>/dev/null
			  ;;
			21)
			  clear
			  install cmatrix
			  clear
			  echo -e "${GREEN}工具已安装，按Ctrl+C退出${NC}"
			  sleep 1
			  cmatrix
			  ;;
			22)
			  clear
			  install sl
			  clear
			  echo -e "${GREEN}工具已安装，运行：sl${NC}"
			  sl
			  ;;
			26)
			  clear
			  install bastet
			  clear
			  echo -e "${GREEN}工具已安装，按q退出游戏${NC}"
			  sleep 1
			  bastet
			  ;;
			27)
			  clear
			  install nsnake
			  clear
			  echo -e "${GREEN}工具已安装，按q退出游戏${NC}"
			  sleep 1
			  nsnake
			  ;;
			28)
			  clear
			  install ninvaders
			  clear
			  echo -e "${GREEN}工具已安装，按q退出游戏${NC}"
			  sleep 1
			  ninvaders
			  ;;
		  31)
			  clear
			  echo -e "${YELLOW}⚠️  即将安装所有工具（含游戏/屏保）${NC}"
			  sleep 2
			  install curl wget sudo socat htop iftop unzip tar tmux ffmpeg btop ranger ncdu fzf cmatrix sl bastet nsnake ninvaders vim nano git
			  ;;
		  32)
			  clear
			  echo -e "${YELLOW}⚠️  即将安装基础工具（不含游戏/屏保）${NC}"
			  sleep 2
			  install curl wget sudo socat htop iftop unzip tar tmux ffmpeg btop ranger ncdu fzf vim nano git
			  ;;
		  33)
			  clear
			  echo -e "${YELLOW}⚠️  即将卸载所有工具（含opencode）${NC}"
			  sleep 2
			  remove htop iftop tmux ffmpeg btop ranger ncdu fzf cmatrix sl bastet nsnake ninvaders vim nano git
			  # 卸载opencode
			  if command -v opencode >/dev/null 2>&1; then
				  opencode uninstall >/dev/null 2>&1
				  rm -rf ~/.opencode
				  echo -e "${GREEN}opencode 已卸载${NC}"
			  fi
			  ;;
		  41)
			  clear
			  read -e -p "$(echo -e ${BLUE}"请输入安装的工具名（多个用空格分隔）: "${NC})" installname
			  install $installname
			  ;;
		  42)
			  clear
			  read -e -p "$(echo -e ${BLUE}"请输入卸载的工具名（多个用空格分隔）: "${NC})" removename
			  remove $removename
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

# ========== 4. 执行核心函数 ==========
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${YELLOW}⚠️  建议使用root权限运行（部分工具需要）${NC}"
    sleep 2
fi
linux_tools
