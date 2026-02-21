#!/bin/bash
# 系统更新模块
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo -e "${GREEN}=========================================${NC}"
echo -e "${YELLOW}              开始系统更新                ${NC}"
echo -e "${GREEN}=========================================${NC}"

# 判断系统类型（Debian/Ubuntu 或 CentOS/RHEL）
if command -v apt &> /dev/null; then
    echo -e "${BLUE}检测到Debian/Ubuntu系统，开始更新...${NC}"
    apt update -y
    apt upgrade -y
    apt autoremove -y
elif command -v yum &> /dev/null; then
    echo -e "${BLUE}检测到CentOS/RHEL系统，开始更新...${NC}"
    yum update -y
else
    echo -e "${RED}不支持的系统类型！${NC}"
    exit 1
fi

echo -e "\n${GREEN}✅ 系统更新完成！${NC}"
echo -e "\n${CYAN}按任意键返回主菜单...${NC}"
read -n 1 -s