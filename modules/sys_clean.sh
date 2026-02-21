#!/bin/bash
# 系统清理模块
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo -e "${GREEN}=========================================${NC}"
echo -e "${YELLOW}              开始系统清理                ${NC}"
echo -e "${GREEN}=========================================${NC}"

# 清理临时文件
echo -e "${BLUE}1. 清理/tmp临时文件...${NC}"
rm -rf /tmp/*

# 清理系统缓存
echo -e "${BLUE}2. 清理系统缓存...${NC}"
sync && echo 3 > /proc/sys/vm/drop_caches

# 按系统类型清理包缓存
if command -v apt &> /dev/null; then
    echo -e "${BLUE}3. 清理Debian/Ubuntu包缓存...${NC}"
    apt clean -y
    apt autoclean -y
elif command -v yum &> /dev/null; then
    echo -e "${BLUE}3. 清理CentOS/RHEL包缓存...${NC}"
    yum clean all -y
fi

# 清理日志文件（可选，保留最近7天）
echo -e "${BLUE}4. 清理旧日志文件...${NC}"
find /var/log -name "*.log" -mtime +7 -delete

echo -e "\n${GREEN}✅ 系统清理完成！${NC}"
echo -e "\n${CYAN}按任意键返回主菜单...${NC}"
read -n 1 -s