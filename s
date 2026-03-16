#!/usr/bin/env bash
# ============================================
# SSH Server Manager (s) - 快捷SSH登录管理工具
# Version: 1.0.0
# ============================================

set -euo pipefail

# --- 配置路径 ---
CONFIG_DIR="$HOME/.ssh-manager"
CONFIG_FILE="$CONFIG_DIR/servers.conf"
HISTORY_FILE="$CONFIG_DIR/.history"
VERSION="1.0.0"

# --- 颜色定义 ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# --- 初始化 ---
init() {
    mkdir -p "$CONFIG_DIR"
    if [[ ! -f "$CONFIG_FILE" ]]; then
        cat > "$CONFIG_FILE" << 'CONF'
# ============================================
# SSH Server Manager - 服务器配置文件
# ============================================
# 格式: 名称 | IP地址 | 端口 | 用户名 | 密码(可选) | 备注说明
# 分组: 以 [分组名] 开头的行表示分组
# 注释: 以 # 开头的行为注释
# 密码留空则使用SSH Key登录
# ============================================

[默认分组]
# example | 192.168.1.1 | 22 | root | yourpass | 示例服务器
CONF
        echo -e "${YELLOW}首次运行，已创建配置文件: ${CONFIG_FILE}${NC}"
        echo -e "${YELLOW}请先添加服务器: s add${NC}"
    fi
    touch "$HISTORY_FILE"
}

# --- 显示帮助 ---
show_help() {
    echo -e "${BOLD}${CYAN}SSH Server Manager v${VERSION}${NC}"
    echo ""
    echo -e "${BOLD}用法:${NC}"
    echo -e "  ${GREEN}s${NC}              交互式选择服务器并登录"
    echo -e "  ${GREEN}s add${NC}           添加新服务器"
    echo -e "  ${GREEN}s rm${NC}            删除服务器"
    echo -e "  ${GREEN}s list${NC}          列出所有服务器"
    echo -e "  ${GREEN}s edit${NC}          编辑配置文件"
    echo -e "  ${GREEN}s key${NC}           配置SSH免密登录"
    echo -e "  ${GREEN}s ping${NC}          检测所有服务器连通性"
    echo -e "  ${GREEN}s <关键词>${NC}      模糊搜索并登录"
    echo -e "  ${GREEN}s help${NC}          显示此帮助信息"
    echo ""
    echo -e "${BOLD}配置文件:${NC} ${CONFIG_FILE}"
}

# --- 解析配置文件，返回服务器列表 ---
parse_servers() {
    local group="未分组"
    while IFS= read -r line; do
        # 跳过空行和注释
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
        # 解析分组
        if [[ "$line" =~ ^\[(.+)\]$ ]]; then
            group="${BASH_REMATCH[1]}"
            continue
        fi
        # 解析服务器行: 名称 | IP | 端口 | 用户名 | 密码 | 备注
        IFS='|' read -r name host port user pass desc <<< "$line"
        name=$(echo "$name" | xargs)
        host=$(echo "$host" | xargs)
        port=$(echo "$port" | xargs)
        user=$(echo "$user" | xargs)
        pass=$(echo "$pass" | xargs 2>/dev/null || echo "")
        desc=$(echo "$desc" | xargs 2>/dev/null || echo "")
        [[ -z "$name" || -z "$host" ]] && continue
        port=${port:-22}
        user=${user:-root}
        echo "${group}|${name}|${host}|${port}|${user}|${pass}|${desc}"
    done < "$CONFIG_FILE"
}

# --- 记录登录历史 ---
record_history() {
    local name="$1"
    local tmp
    tmp=$(mktemp)
    echo "$name" > "$tmp"
    grep -v "^${name}$" "$HISTORY_FILE" >> "$tmp" 2>/dev/null || true
    head -20 "$tmp" > "$HISTORY_FILE"
    rm -f "$tmp"
}

# --- 获取历史排序权重 ---
get_history_rank() {
    local name="$1"
    local rank
    rank=$(grep -n "^${name}$" "$HISTORY_FILE" 2>/dev/null | head -1 | cut -d: -f1)
    echo "${rank:-999}"
}

# --- SSH连接服务器 ---
connect_server() {
    local host="$1" port="$2" user="$3" name="$4" pass="${5:-}"
    record_history "$name"
    echo -e "${GREEN}▶ 正在连接: ${BOLD}${name}${NC} ${DIM}(${user}@${host}:${port})${NC}"
    echo ""
    local ssh_opts=(-o ConnectTimeout=10 -o ServerAliveInterval=60 -o ServerAliveCountMax=3 -o StrictHostKeyChecking=accept-new -p "$port")
    if [[ -n "$pass" ]] && command -v sshpass &>/dev/null; then
        sshpass -p "$pass" ssh "${ssh_opts[@]}" "${user}@${host}"
    else
        ssh "${ssh_opts[@]}" "${user}@${host}"
    fi
}

# --- 使用fzf交互选择 ---
select_with_fzf() {
    local filter="${1:-}"
    local servers
    servers=$(parse_servers)
    [[ -z "$servers" ]] && echo -e "${RED}✗ 没有配置任何服务器，请先运行: s add${NC}" && return 1

    local fzf_input="" idx=0
    while IFS='|' read -r group name host port user pass desc; do
        idx=$((idx + 1))
        local auth="key"
        [[ -n "$pass" ]] && auth="pwd"
        printf -v line " %2d  %-16s  %-16s  %-5s  %-6s  %-4s  %s" \
            "$idx" "$name" "$host" "$port" "$user" "$auth" "$desc"
        fzf_input+="${line}"$'\n'
    done <<< "$servers"

    local header
    printf -v header " %-3s  %-16s  %-16s  %-5s  %-6s  %-4s  %s" \
        "#" "名称" "IP地址" "端口" "用户" "认证" "备注"

    local selected
    selected=$(printf '%s' "$fzf_input" | \
        fzf --ansi \
            --header="$header" \
            --prompt=" 搜索: " \
            --height=~50% \
            --border=rounded \
            --border-label=" SSH Server Manager " \
            --border-label-pos=3 \
            --query="$filter" \
            --preview-window=hidden \
            --pointer="▶" \
            --marker="●" \
            --color=header:italic \
        2>/dev/null) || return 1

    [[ -z "$selected" ]] && return 1
    local sel_name
    sel_name=$(echo "$selected" | awk '{print $2}')
    echo "$servers" | while IFS='|' read -r group name host port user pass desc; do
        if [[ "$name" == "$sel_name" ]]; then
            echo "${name}|${host}|${port}|${user}|${pass}"
            return 0
        fi
    done
}

# --- 无fzf时的fallback选择 ---
select_fallback() {
    local filter="${1:-}"
    local servers
    servers=$(parse_servers)
    [[ -z "$servers" ]] && echo -e "${RED}✗ 没有配置任何服务器，请先运行: s add${NC}" && return 1

    echo -e "${BOLD}${CYAN}🖥  SSH Server Manager${NC}"
    echo ""

    local -a names=() hosts=() ports=() users=() passes=()
    local current_group="" idx=0
    while IFS='|' read -r group name host port user pass desc; do
        if [[ "$current_group" != "$group" ]]; then
            current_group="$group"
            echo -e "  ${PURPLE}${BOLD}[$group]${NC}"
        fi
        # 如果有过滤词，跳过不匹配的
        if [[ -n "$filter" ]] && ! echo "$name $host $desc $group" | grep -qi "$filter"; then
            continue
        fi
        idx=$((idx + 1))
        names+=("$name")
        hosts+=("$host")
        ports+=("$port")
        users+=("$user")
        passes+=("$pass")
        local auth_icon="🔑"
        [[ -n "$pass" ]] && auth_icon="🔒"
        printf "  ${GREEN}%3d)${NC} %-18s ${DIM}%-16s %-6s %-8s${NC} %s %s\n" \
            "$idx" "$name" "$host" ":$port" "$user" "$auth_icon" "$desc"
    done <<< "$servers"

    [[ $idx -eq 0 ]] && echo -e "${RED}✗ 没有匹配的服务器${NC}" && return 1
    echo ""
    read -rp "$(echo -e "${BOLD}请选择 [1-${idx}]: ${NC}")" choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= idx )); then
        local i=$((choice - 1))
        echo "${names[$i]}|${hosts[$i]}|${ports[$i]}|${users[$i]}|${passes[$i]}"
    else
        echo -e "${RED}✗ 无效选择${NC}" && return 1
    fi
}

# --- 添加服务器 ---
cmd_add() {
    echo -e "${BOLD}${CYAN}添加新服务器${NC}"
    echo ""
    read -rp "$(echo -e "${BOLD}服务器名称: ${NC}")" name
    [[ -z "$name" ]] && echo -e "${RED}✗ 名称不能为空${NC}" && return 1
    read -rp "$(echo -e "${BOLD}IP地址/域名: ${NC}")" host
    [[ -z "$host" ]] && echo -e "${RED}✗ 地址不能为空${NC}" && return 1
    read -rp "$(echo -e "${BOLD}端口 [22]: ${NC}")" port
    port=${port:-22}
    read -rp "$(echo -e "${BOLD}用户名 [root]: ${NC}")" user
    user=${user:-root}
    read -rsp "$(echo -e "${BOLD}密码 (直接回车跳过,用Key登录): ${NC}")" pass
    echo ""
    read -rp "$(echo -e "${BOLD}备注说明: ${NC}")" desc

    # 选择分组
    local groups=()
    while IFS= read -r line; do
        if [[ "$line" =~ ^\[(.+)\]$ ]]; then
            groups+=("${BASH_REMATCH[1]}")
        fi
    done < "$CONFIG_FILE"

    local group=""
    if [[ ${#groups[@]} -gt 0 ]]; then
        echo ""
        echo -e "${BOLD}选择分组:${NC}"
        local i=0
        for g in "${groups[@]}"; do
            i=$((i + 1))
            echo -e "  ${GREEN}${i})${NC} $g"
        done
        echo -e "  ${GREEN}$((i + 1)))${NC} 新建分组"
        read -rp "$(echo -e "${BOLD}选择 [1]: ${NC}")" gchoice
        gchoice=${gchoice:-1}
        if (( gchoice > 0 && gchoice <= ${#groups[@]} )); then
            group="${groups[$((gchoice - 1))]}"
        fi
    fi

    if [[ -z "$group" ]]; then
        read -rp "$(echo -e "${BOLD}新分组名称: ${NC}")" group
        group=${group:-默认分组}
        echo "" >> "$CONFIG_FILE"
        echo "[$group]" >> "$CONFIG_FILE"
    fi

    # 写入配置 - 在对应分组下追加
    local entry
    printf -v entry "%-14s| %-16s| %-5s| %-7s| %s | %s" "$name" "$host" "$port" "$user" "$pass" "$desc"
    # 找到分组行号，在其后追加
    local group_line
    group_line=$(grep -n "^\[${group}\]" "$CONFIG_FILE" | tail -1 | cut -d: -f1)
    if [[ -n "$group_line" ]]; then
        sed -i '' "${group_line}a\\
${entry}
" "$CONFIG_FILE"
    else
        echo "$entry" >> "$CONFIG_FILE"
    fi

    echo ""
    echo -e "${GREEN}✓ 服务器已添加: ${BOLD}${name}${NC} (${user}@${host}:${port}) [${group}]"

    # 询问是否配置免密
    echo ""
    read -rp "$(echo -e "${BOLD}是否配置SSH免密登录? [y/N]: ${NC}")" setup_key
    if [[ "$setup_key" =~ ^[yY] ]]; then
        setup_ssh_key "$host" "$port" "$user" "$pass"
    fi
}

# --- 删除服务器 ---
cmd_rm() {
    local result
    if command -v fzf &>/dev/null; then
        result=$(select_with_fzf "")
    else
        result=$(select_fallback "")
    fi
    [[ -z "$result" ]] && return 1

    local name host port user
    IFS='|' read -r name host port user <<< "$result"

    read -rp "$(echo -e "${RED}确认删除 ${BOLD}${name}${NC}${RED} (${host})? [y/N]: ${NC}")" confirm
    if [[ "$confirm" =~ ^[yY] ]]; then
        local tmp
        tmp=$(mktemp)
        grep -v "^${name}[[:space:]]*|" "$CONFIG_FILE" > "$tmp"
        mv "$tmp" "$CONFIG_FILE"
        echo -e "${GREEN}✓ 已删除: ${name}${NC}"
    fi
}

# --- 列出所有服务器 ---
cmd_list() {
    local servers
    servers=$(parse_servers)
    [[ -z "$servers" ]] && echo -e "${YELLOW}暂无服务器配置${NC}" && return 0

    echo -e "${BOLD}${CYAN}🖥  服务器列表${NC}"
    echo ""
    local current_group="" idx=0
    while IFS='|' read -r group name host port user pass desc; do
        if [[ "$current_group" != "$group" ]]; then
            current_group="$group"
            echo -e "  ${PURPLE}${BOLD}[$group]${NC}"
        fi
        idx=$((idx + 1))
        local auth_icon="🔑"
        [[ -n "$pass" ]] && auth_icon="🔒"
        printf "    ${GREEN}%-18s${NC} ${DIM}%-16s :%-5s %-8s${NC} %s %s\n" \
            "$name" "$host" "$port" "$user" "$auth_icon" "$desc"
    done <<< "$servers"
    echo ""
    echo -e "  ${DIM}共 ${idx} 台服务器${NC}"
}

# --- 编辑配置文件 ---
cmd_edit() {
    local editor="${EDITOR:-vim}"
    echo -e "${DIM}使用 ${editor} 编辑配置文件...${NC}"
    "$editor" "$CONFIG_FILE"
}

# --- 配置SSH免密登录 ---
setup_ssh_key() {
    local host="$1" port="$2" user="$3" pass="${4:-}"
    local key_file="$HOME/.ssh/id_rsa.pub"

    if [[ ! -f "$key_file" ]]; then
        if [[ -f "$HOME/.ssh/id_ed25519.pub" ]]; then
            key_file="$HOME/.ssh/id_ed25519.pub"
        else
            echo -e "${YELLOW}未检测到SSH公钥，正在生成...${NC}"
            ssh-keygen -t ed25519 -f "$HOME/.ssh/id_ed25519" -N "" -C "ssh-manager@$(hostname)"
            key_file="$HOME/.ssh/id_ed25519.pub"
        fi
    fi

    echo -e "${DIM}正在将公钥推送到 ${user}@${host}:${port} ...${NC}"
    if [[ -n "$pass" ]] && command -v sshpass &>/dev/null; then
        sshpass -p "$pass" ssh-copy-id -o StrictHostKeyChecking=accept-new -i "$key_file" -p "$port" "${user}@${host}" 2>/dev/null && \
            echo -e "${GREEN}✓ SSH免密登录配置成功!${NC}" || \
            echo -e "${RED}✗ 配置失败，请检查连接或密码${NC}"
    else
        ssh-copy-id -i "$key_file" -p "$port" "${user}@${host}" 2>/dev/null && \
            echo -e "${GREEN}✓ SSH免密登录配置成功!${NC}" || \
            echo -e "${RED}✗ 配置失败，请检查连接或手动配置${NC}"
    fi
}

# --- 为选中服务器配置免密 ---
cmd_key() {
    echo -e "${BOLD}${CYAN}配置SSH免密登录${NC}"
    echo -e "${DIM}选择要配置免密的服务器:${NC}"
    echo ""
    local result
    if command -v fzf &>/dev/null; then
        result=$(select_with_fzf "")
    else
        result=$(select_fallback "")
    fi
    [[ -z "$result" ]] && return 1

    local name host port user pass
    IFS='|' read -r name host port user pass <<< "$result"
    setup_ssh_key "$host" "$port" "$user" "$pass"
}

# --- 检测服务器连通性 ---
cmd_ping() {
    local servers
    servers=$(parse_servers)
    [[ -z "$servers" ]] && echo -e "${YELLOW}暂无服务器配置${NC}" && return 0

    echo -e "${BOLD}${CYAN}🔍 服务器连通性检测${NC}"
    echo ""

    while IFS='|' read -r group name host port user pass desc; do
        printf "  %-18s %-16s " "$name" "$host"
        if nc -z -w 3 "$host" "$port" 2>/dev/null; then
            echo -e "${GREEN}✓ 在线${NC}"
        else
            echo -e "${RED}✗ 离线${NC}"
        fi
    done <<< "$servers"
}

# --- 主入口 ---
main() {
    init

    case "${1:-}" in
        help|--help|-h)
            show_help
            ;;
        add)
            cmd_add
            ;;
        rm|remove|del|delete)
            cmd_rm
            ;;
        list|ls|l)
            cmd_list
            ;;
        edit)
            cmd_edit
            ;;
        key|keys)
            cmd_key
            ;;
        ping|check)
            cmd_ping
            ;;
        "")
            # 无参数：交互式选择
            local result
            if command -v fzf &>/dev/null; then
                result=$(select_with_fzf "")
            else
                result=$(select_fallback "")
            fi
            [[ -z "$result" ]] && exit 0
            local name host port user pass
            IFS='|' read -r name host port user pass <<< "$result"
            connect_server "$host" "$port" "$user" "$name" "$pass"
            ;;
        *)
            # 有参数：作为关键词搜索
            local result
            if command -v fzf &>/dev/null; then
                result=$(select_with_fzf "$1")
            else
                result=$(select_fallback "$1")
            fi
            [[ -z "$result" ]] && exit 0
            local name host port user pass
            IFS='|' read -r name host port user pass <<< "$result"
            connect_server "$host" "$port" "$user" "$name" "$pass"
            ;;
    esac
}

main "$@"
