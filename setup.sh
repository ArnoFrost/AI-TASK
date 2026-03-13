#!/bin/bash
# =====================================================
# AI-TASK 一键安装+初始化脚本 v2.0.0
# =====================================================
# 可通过 curl | bash 远程执行，也可 AI 在本地执行
#
# 用法:
#   curl -fsSL https://raw.githubusercontent.com/ArnoFrost/AI-TASK/main/setup.sh | bash
#   bash setup.sh
#   bash setup.sh --path ~/AI-TASK
#   bash setup.sh --skip-project
#   bash setup.sh --path ~/AI-TASK --skip-project
# =====================================================

set -e

VERSION="2.0.0"
REPO_URL="https://github.com/ArnoFrost/AI-TASK.git"
DEFAULT_PATH="$HOME/AI-TASK"
ICLOUD_BASE="$HOME/Library/Mobile Documents/iCloud~md~obsidian"

# ======================== 颜色定义 ========================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# ======================== 全局变量 ========================
INSTALL_PATH=""
SKIP_PROJECT=false

# ======================== ASCII Art Header ========================
print_header() {
    echo ""
    echo -e "${CYAN}${BOLD}"
    echo "    _    ___     _____  _    ____  _  __"
    echo "   / \  |_ _|   |_   _|/ \  / ___|| |/ /"
    echo "  / _ \  | | _____| | / _ \ \___ \| ' / "
    echo " / ___ \ | ||_____| |/ ___ \ ___) | . \ "
    echo "/_/   \_\___|     |_/_/   \_\____/|_|\_\\"
    echo -e "${NC}"
    echo -e "${DIM}  一键安装脚本 v${VERSION}${NC}"
    echo ""
}

# ======================== 帮助信息 ========================
print_help() {
    echo "AI-TASK 一键安装+初始化脚本 v${VERSION}"
    echo ""
    echo "用法:"
    echo "  curl -fsSL https://raw.githubusercontent.com/ArnoFrost/AI-TASK/main/setup.sh | bash"
    echo "  bash setup.sh [options]"
    echo ""
    echo "选项:"
    echo "  --path PATH       指定安装路径 (默认: ~/AI-TASK)"
    echo "  --skip-project    跳过项目初始化 (仅 clone + 注入技能)"
    echo "  -h, --help        显示帮助"
    echo ""
    echo "交互流程:"
    echo "  1. 检测是否已安装 → 已安装则跳过 clone"
    echo "  2. 选择安装路径 (默认 ~/AI-TASK，检测到 iCloud 时可选同步路径)"
    echo "  3. git clone 到选定路径"
    echo "  4. 初始化第一个项目 (可 --skip-project 跳过)"
    echo "  5. 注入技能到已安装的 IDE"
    echo ""
    echo "示例:"
    echo "  bash setup.sh                          # 交互模式"
    echo "  bash setup.sh --path ~/AI-TASK         # 指定路径，非交互 clone"
    echo "  bash setup.sh --skip-project           # 跳过项目初始化"
}

# ======================== 工具函数 ========================

# 检查命令是否可用
require_cmd() {
    if ! command -v "$1" &>/dev/null; then
        echo -e "${RED}错误: 需要 $1 但未找到，请先安装${NC}"
        exit 1
    fi
}

# 检测已有安装路径
detect_existing_install() {
    local paths=()

    # 检查默认路径
    if [[ -d "$DEFAULT_PATH/.git" ]]; then
        paths+=("$DEFAULT_PATH")
    fi

    # 检查 iCloud 路径（通配匹配 Obsidian vault 下的 AI-TASK）
    if [[ -d "$ICLOUD_BASE" ]]; then
        while IFS= read -r -d '' dir; do
            if [[ -d "$dir/.git" && "$dir" != "$DEFAULT_PATH" ]]; then
                paths+=("$dir")
            fi
        done < <(find "$ICLOUD_BASE" -maxdepth 3 -type d -name "AI-TASK" -print0 2>/dev/null)
    fi

    if [[ ${#paths[@]} -gt 0 ]]; then
        echo "${paths[0]}"
    fi
}

# 检测 iCloud 是否可用
has_icloud() {
    [[ -d "$ICLOUD_BASE" ]]
}

# ======================== 参数解析 ========================
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --path)
                INSTALL_PATH="$2"
                shift 2
                ;;
            --skip-project)
                SKIP_PROJECT=true
                shift
                ;;
            -h|--help)
                print_help
                exit 0
                ;;
            *)
                echo -e "${YELLOW}警告: 未知参数 '$1'，已忽略${NC}"
                shift
                ;;
        esac
    done
}

# ======================== 步骤 1: 检测已有安装 ========================
step_detect() {
    echo -e "${BLUE}${BOLD}[1/4]${NC} 检测已有安装..."

    local existing
    existing="$(detect_existing_install)"

    if [[ -n "$existing" ]]; then
        echo -e "  ${GREEN}✓${NC} 检测到已有安装: ${CYAN}$existing${NC}"

        if [[ -z "$INSTALL_PATH" ]]; then
            INSTALL_PATH="$existing"
        fi

        # 拉取最新代码
        echo -e "  ${DIM}正在拉取最新代码...${NC}"
        if git -C "$INSTALL_PATH" pull --ff-only 2>/dev/null; then
            echo -e "  ${GREEN}✓${NC} 已更新到最新版本"
        else
            echo -e "  ${YELLOW}⚠${NC} 无法自动更新，跳过（可能有本地修改）"
        fi
        return 0
    fi

    echo -e "  ${DIM}未检测到已有安装${NC}"
    return 1
}

# ======================== 步骤 2: 选择安装路径 ========================
step_choose_path() {
    # 如果已通过参数或检测指定了路径，跳过
    if [[ -n "$INSTALL_PATH" ]]; then
        return 0
    fi

    echo ""
    echo -e "${BLUE}${BOLD}[2/4]${NC} 选择安装路径"

    # 检测 iCloud
    if has_icloud; then
        echo ""
        echo -e "  ${CYAN}检测到 iCloud Obsidian vault${NC}"
        echo -e "  放在 iCloud 可实现跨设备（Mac/iPhone/iPad）自动同步"
        echo ""

        # 检测是否存在标准路径
        if [[ -t 0 ]]; then
            # 交互模式
            read -p "  是否放在 iCloud 网盘用于跨设备同步？(y/N): " use_icloud
            if [[ "$use_icloud" == "y" || "$use_icloud" == "Y" ]]; then
                # 尝试检测 vault 路径
                local vault_path=""
                while IFS= read -r -d '' dir; do
                    vault_path="$dir"
                    break
                done < <(find "$ICLOUD_BASE" -maxdepth 2 -type d -name "Documents" -print0 2>/dev/null)

                if [[ -n "$vault_path" ]]; then
                    INSTALL_PATH="$vault_path/AI-TASK"
                    echo -e "  ${GREEN}✓${NC} 将安装到: ${CYAN}$INSTALL_PATH${NC}"
                else
                    INSTALL_PATH="$ICLOUD_BASE/Documents/AI-TASK"
                    echo -e "  ${GREEN}✓${NC} 将安装到: ${CYAN}$INSTALL_PATH${NC}"
                fi
                return 0
            fi
        fi
    fi

    if [[ -t 0 ]]; then
        # 交互模式：允许自定义
        echo ""
        read -p "  安装路径 [$DEFAULT_PATH]: " custom_path
        INSTALL_PATH="${custom_path:-$DEFAULT_PATH}"
    else
        # 管道模式（curl | bash）：使用默认
        INSTALL_PATH="$DEFAULT_PATH"
    fi

    echo -e "  ${GREEN}✓${NC} 安装路径: ${CYAN}$INSTALL_PATH${NC}"
}

# ======================== 步骤 3: Clone 仓库 ========================
step_clone() {
    echo ""
    echo -e "${BLUE}${BOLD}[3/4]${NC} 克隆仓库..."

    if [[ -d "$INSTALL_PATH/.git" ]]; then
        echo -e "  ${GREEN}✓${NC} 仓库已存在，跳过 clone"
        return 0
    fi

    # 确保父目录存在
    local parent_dir
    parent_dir="$(dirname "$INSTALL_PATH")"
    if [[ ! -d "$parent_dir" ]]; then
        mkdir -p "$parent_dir"
    fi

    echo -e "  ${DIM}git clone $REPO_URL $INSTALL_PATH${NC}"
    if git clone "$REPO_URL" "$INSTALL_PATH"; then
        echo -e "  ${GREEN}✓${NC} 克隆成功"
    else
        echo -e "  ${RED}✗ 克隆失败${NC}"
        echo -e "  ${DIM}请检查网络连接和 Git 配置${NC}"
        exit 1
    fi
}

# ======================== 步骤 4: 初始化项目 + 注入技能 ========================
step_init() {
    echo ""
    echo -e "${BLUE}${BOLD}[4/4]${NC} 初始化..."

    # 4a. 项目初始化
    if [[ "$SKIP_PROJECT" == true ]]; then
        echo -e "  ${DIM}跳过项目初始化 (--skip-project)${NC}"
    else
        local init_script="$INSTALL_PATH/init-project.sh"
        if [[ -x "$init_script" || -f "$init_script" ]]; then
            echo ""
            echo -e "  ${CYAN}─── 初始化第一个项目 ───${NC}"
            echo ""
            chmod +x "$init_script"
            (cd "$INSTALL_PATH" && bash "$init_script")
        else
            echo -e "  ${YELLOW}⚠${NC} 未找到 init-project.sh，跳过项目初始化"
        fi
    fi

    # 4b. 技能注入
    local skills_script="$INSTALL_PATH/install-skills.sh"
    if [[ -x "$skills_script" || -f "$skills_script" ]]; then
        echo ""
        echo -e "  ${CYAN}─── 注入技能到已安装的 IDE ───${NC}"
        echo ""
        chmod +x "$skills_script"
        (cd "$INSTALL_PATH" && bash "$skills_script" --all) || true
    else
        echo -e "  ${YELLOW}⚠${NC} 未找到 install-skills.sh，跳过技能注入"
    fi
}

# ======================== 完成摘要 ========================
print_summary() {
    echo ""
    echo -e "${GREEN}${BOLD}════════════════════════════════════════════${NC}"
    echo -e "${GREEN}${BOLD}  AI-TASK 安装完成!${NC}"
    echo -e "${GREEN}${BOLD}════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${BOLD}安装摘要:${NC}"
    echo "──────────────────────────────────────────"
    echo -e "  安装路径  : ${CYAN}${INSTALL_PATH}${NC}"
    echo -e "  版本      : ${CYAN}v${VERSION}${NC}"
    echo "──────────────────────────────────────────"
    echo ""
    echo -e "${BOLD}下一步:${NC}"
    echo ""
    echo -e "  1. 在 AI 助手中引入项目入口开始协作:"
    echo -e "     ${CYAN}@projects/YOUR_PROJECT/index.md${NC}"
    echo ""
    echo -e "  2. 如需初始化更多项目:"
    echo -e "     ${CYAN}cd $INSTALL_PATH && ./init-project.sh${NC}"
    echo ""
    echo -e "  3. 查看完整文档:"
    echo -e "     ${CYAN}$INSTALL_PATH/README.md${NC}"
    echo ""
}

# ======================== 主流程 ========================
main() {
    print_header

    # 前置检查
    require_cmd git

    # 解析参数
    parse_args "$@"

    # 步骤 1: 检测已有安装
    local already_installed=false
    if step_detect; then
        already_installed=true
    fi

    # 步骤 2: 选择路径（未安装时）
    if [[ "$already_installed" == false ]]; then
        step_choose_path
    fi

    # 步骤 3: Clone（幂等）
    step_clone

    # 步骤 4: 初始化
    step_init

    # 完成
    print_summary
}

main "$@"
