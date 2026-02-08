#!/usr/bin/env bash
# ============================================
# SSH Server Manager - 安装脚本
# 支持本地安装和远程一键安装
# ============================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

REPO="guyfar/ssh-manager"
BRANCH="main"
RAW_URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
INSTALL_DIR="/usr/local/bin"

echo -e "${BOLD}${CYAN}SSH Server Manager - 安装程序${NC}"
echo ""

# --- 判断是本地安装还是远程安装 ---
SCRIPT_DIR=""
if [[ -f "$(dirname "$0")/s" ]] 2>/dev/null; then
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
fi

# --- Step 1: 安装主脚本 ---
echo -e "${DIM}[1/3] 安装主脚本到 ${INSTALL_DIR}/s ...${NC}"

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

if [[ -n "$SCRIPT_DIR" ]]; then
    cp "${SCRIPT_DIR}/s" "$TMP_DIR/s"
    cp "${SCRIPT_DIR}/servers.conf.example" "$TMP_DIR/servers.conf.example"
else
    echo -e "${DIM}  从 GitHub 下载...${NC}"
    curl -fsSL "${RAW_URL}/s" -o "$TMP_DIR/s"
    curl -fsSL "${RAW_URL}/servers.conf.example" -o "$TMP_DIR/servers.conf.example"
fi

chmod +x "$TMP_DIR/s"
if [[ -w "$INSTALL_DIR" ]]; then
    cp "$TMP_DIR/s" "${INSTALL_DIR}/s"
else
    sudo cp "$TMP_DIR/s" "${INSTALL_DIR}/s"
    sudo chmod +x "${INSTALL_DIR}/s"
fi
echo -e "${GREEN}  ✓ 主脚本已安装${NC}"

# --- Step 2: 检查 fzf ---
echo -e "${DIM}[2/3] 检查 fzf ...${NC}"
if command -v fzf &>/dev/null; then
    echo -e "${GREEN}  ✓ fzf 已安装${NC}"
else
    echo -e "${YELLOW}  fzf 未安装${NC}"
    if command -v brew &>/dev/null; then
        read -rp "  是否自动安装 fzf? [Y/n]: " install_fzf
        if [[ ! "$install_fzf" =~ ^[nN] ]]; then
            brew install fzf
            echo -e "${GREEN}  ✓ fzf 安装完成${NC}"
        fi
    else
        echo -e "${DIM}  请手动安装: brew install fzf${NC}"
        echo -e "${DIM}  (无fzf也可使用，体验稍弱)${NC}"
    fi
fi

# --- Step 3: 初始化配置 ---
echo -e "${DIM}[3/3] 初始化配置 ...${NC}"
mkdir -p "$HOME/.ssh-manager"
if [[ ! -f "$HOME/.ssh-manager/servers.conf" ]]; then
    cp "$TMP_DIR/servers.conf.example" "$HOME/.ssh-manager/servers.conf"
    echo -e "${GREEN}  ✓ 配置文件已创建: ~/.ssh-manager/servers.conf${NC}"
else
    echo -e "${GREEN}  ✓ 配置文件已存在(保留原有配置)${NC}"
fi

echo ""
echo -e "${GREEN}${BOLD}✓ 安装完成!${NC}"
echo ""
echo -e "${BOLD}快速开始:${NC}"
echo -e "  1. 添加服务器:     ${CYAN}s add${NC}"
echo -e "  2. 选择并登录:     ${CYAN}s${NC}"
echo -e "  3. 配置免密登录:   ${CYAN}s key${NC}"
echo -e "  4. 查看帮助:       ${CYAN}s help${NC}"
