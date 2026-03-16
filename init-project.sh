#!/bin/bash
# =====================================================
# AI-TASK 项目初始化脚本 v3.0.0
# =====================================================
# 交互式多 IDE 支持的项目初始化工具
#
# 用法:
#   ./init-project.sh [CODE] [options]
#   ./init-project.sh                          # 纯交互模式
#   ./init-project.sh myapp                    # 半交互
#   ./init-project.sh myapp --path /x --name "My App" --tech "React,TS" --ide 1,4
#
# v3.0.0 变更:
#   - 软链接 local 化命名：ai-task → ai-task.local, AGENT.md → AGENT.local.md
#   - 参考 Claude Code CLAUDE.local.md 机制，消除 .gitignore 配置负担
#   - 移除 update_project_gitignore() 逻辑（改用全局 gitignore）
#   - IDE 入口文件内容中的路径引用同步更新为 ai-task.local/
#   - 完成后提示配置全局 gitignore
# =====================================================

set -e

VERSION="3.0.0"

# ======================== 颜色定义 ========================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# ======================== 路径常量 ========================
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECTS_DIR="$SCRIPT_DIR/projects"
RULES_DIR="$SCRIPT_DIR/rules"
TEMPLATES_DIR="$SCRIPT_DIR/templates"

# ======================== 全局变量 ========================
PROJECT_CODE=""
PROJECT_NAME=""
PROJECT_PATH=""
TECH_STACK=""
IDE_SELECTIONS=""   # 逗号分隔: 1,2,3,4 / a / n

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
    echo -e "${DIM}  项目初始化脚本 v${VERSION}${NC}"
    echo ""
}

# ======================== 帮助信息 ========================
print_help() {
    echo "AI-TASK 项目初始化脚本 v${VERSION}"
    echo ""
    echo "用法:"
    echo "  $0 [CODE] [options]"
    echo "  $0                                # 纯交互模式"
    echo "  $0 myapp                          # 半交互 (仅指定代号)"
    echo "  $0 myapp --path /x --name \"My App\" --tech \"React,TS\" --ide 1,4"
    echo ""
    echo "选项:"
    echo "  --name  NAME      项目名称 (默认同代号)"
    echo "  --path  PATH      项目本地路径"
    echo "  --tech  TECH      技术栈 (逗号分隔)"
    echo "  --ide   IDE       IDE 适配器 (多选用逗号, 如 1,4 / a / n)"
    echo "  -h, --help        显示帮助"
    echo ""
    echo "IDE 适配器编号:"
    echo "  1  claude-code    生成 CLAUDE.md + .claude/ 目录"
    echo "  2  codebuddy      生成 CODEBUDDY.md + .codebuddy/ 目录"
    echo "  3  cursor         生成 .cursor/rules/ 目录"
    echo "  4  通用 AGENT.md   仅生成 AGENT.md (推荐, IDE 无关)"
    echo "  a  全部"
    echo "  n  跳过"
    echo ""
    echo "Local 化命名 (v3.0.0):"
    echo "  工作仓库中的软链接使用 .local 后缀："
    echo "    ai-task.local/     → AI-TASK/projects/{CODE}"
    echo "    AGENT.local.md     → AI-TASK/projects/{CODE}/AGENT.md"
    echo "    CLAUDE.local.md    → AI-TASK/projects/{CODE}/CLAUDE.md"
    echo "    CODEBUDDY.local.md → AI-TASK/projects/{CODE}/CODEBUDDY.md"
    echo ""
    echo "  配合全局 gitignore 一次配置所有仓库自动忽略："
    echo "    echo 'ai-task.local' >> ~/.gitignore_global"
    echo "    echo '*.local.md' >> ~/.gitignore_global"
    echo ""
    echo "示例:"
    echo "  $0 myapp --ide 4"
    echo "  $0 myapp --path ~/Projects/myapp --name \"My App\" --tech \"React,TS\" --ide 1,4"
}

# ======================== IDE 适配器函数 ========================

# --- Claude Code 适配器 ---
# CLAUDE.md 存储在 vault projects/{CODE}/ 下，工作仓库通过软链接引用
# 软链接名为 CLAUDE.local.md（与 Claude Code 原生 .local 机制对齐）
setup_ide_claude_code() {
    local project_path="$1"
    local project_code="$2"
    local project_name="$3"
    local vault_project_dir="$PROJECTS_DIR/$project_code"

    # 创建 .claude/ 目录（直接在工作仓库，IDE 配置目录不走 vault）
    mkdir -p "$project_path/.claude"

    # 生成 CLAUDE.md → vault
    cat > "$vault_project_dir/CLAUDE.md" << EOF
# ${project_name}

> AI 协作入口 · Claude Code · Powered by [AI-TASK](https://github.com/ArnoFrost/AI-TASK)

## 项目信息

详见 \`ai-task.local/project.yaml\`

## 任务管理

| 操作 | 说明 |
|------|------|
| 创建任务 | 描述需求，AI 自动创建到 ai-task.local/tasks/ |
| 查看任务 | 查看 ai-task.local/index.md 任务列表 |
| 完成任务 | AI 自动更新状态并归档 |

## 标签

\`[功能]\` \`[优化]\` \`[修复]\` \`[排查]\` \`[文档]\` \`[调研]\` \`[技术方案]\` \`[规范]\` \`[下线]\` \`[清理]\` \`[梳理]\` \`[测试]\` \`[评审]\` \`[架构]\` \`[集成]\` \`[同步]\`

## 结构

\`\`\`
ai-task.local/              # 软链接 → AI-TASK/projects/${project_code} (local, gitignored)
├── project.yaml            # 项目元数据
├── index.md                # 项目入口
├── tasks/                  # 任务目录
└── docs/                   # 文档目录
\`\`\`

## 规范

详见 ai-task.local/ 下的 ../../SPEC.md

<!-- 可在 vault 中编辑此文件，工作仓库通过 CLAUDE.local.md 软链接自动同步 -->
EOF

    echo -e "  ${GREEN}+${NC} $vault_project_dir/CLAUDE.md ${DIM}(vault)${NC}"

    # 创建 local 化软链接到工作仓库
    create_ide_symlink "$project_path/CLAUDE.local.md" "$vault_project_dir/CLAUDE.md"

    echo -e "  ${GREEN}+${NC} $project_path/.claude/"
}

# --- CodeBuddy 适配器 ---
# CODEBUDDY.md 存储在 vault projects/{CODE}/ 下，工作仓库通过软链接引用
setup_ide_codebuddy() {
    local project_path="$1"
    local project_code="$2"
    local project_name="$3"
    local vault_project_dir="$PROJECTS_DIR/$project_code"

    # 创建 .codebuddy/ 目录（直接在工作仓库，IDE 配置目录不走 vault）
    mkdir -p "$project_path/.codebuddy"

    # 生成 CODEBUDDY.md → vault
    cat > "$vault_project_dir/CODEBUDDY.md" << EOF
# ${project_name}

> AI 协作入口 · CodeBuddy · Powered by [AI-TASK](https://github.com/ArnoFrost/AI-TASK)

## 项目信息

详见 \`ai-task.local/project.yaml\`

## 任务管理

| 操作 | 说明 |
|------|------|
| 创建任务 | 描述需求，AI 自动创建到 ai-task.local/tasks/ |
| 查看任务 | 查看 ai-task.local/index.md 任务列表 |
| 完成任务 | AI 自动更新状态并归档 |

## 标签

\`[功能]\` \`[优化]\` \`[修复]\` \`[排查]\` \`[文档]\` \`[调研]\` \`[技术方案]\` \`[规范]\` \`[下线]\` \`[清理]\` \`[梳理]\` \`[测试]\` \`[评审]\` \`[架构]\` \`[集成]\` \`[同步]\`

## 结构

\`\`\`
ai-task.local/              # 软链接 → AI-TASK/projects/${project_code} (local, gitignored)
├── project.yaml            # 项目元数据
├── index.md                # 项目入口
├── tasks/                  # 任务目录
└── docs/                   # 文档目录
\`\`\`

## 规范

详见 ai-task.local/ 下的 ../../SPEC.md

<!-- 可在 vault 中编辑此文件，工作仓库通过 CODEBUDDY.local.md 软链接自动同步 -->
EOF

    echo -e "  ${GREEN}+${NC} $vault_project_dir/CODEBUDDY.md ${DIM}(vault)${NC}"

    # 创建 local 化软链接到工作仓库
    create_ide_symlink "$project_path/CODEBUDDY.local.md" "$vault_project_dir/CODEBUDDY.md"

    echo -e "  ${GREEN}+${NC} $project_path/.codebuddy/"
}

# --- Cursor 适配器 ---
setup_ide_cursor() {
    local project_path="$1"
    local project_code="$2"
    local project_name="$3"

    mkdir -p "$project_path/.cursor/rules"

    cat > "$project_path/.cursor/rules/ai-task.mdc" << EOF
---
description: AI-TASK 项目管理规范
globs:
  - ai-task.local/**
---

# ${project_name}

> AI 协作规范 · Cursor · Powered by [AI-TASK](https://github.com/ArnoFrost/AI-TASK)

## 项目信息

详见 \`ai-task.local/project.yaml\`

## 任务管理

- 创建任务: 描述需求，AI 自动创建到 ai-task.local/tasks/
- 查看任务: 查看 ai-task.local/index.md 任务列表
- 完成任务: AI 自动更新状态并归档

## 标签

[功能] [优化] [修复] [排查] [文档] [调研] [技术方案] [规范] [下线] [清理] [梳理] [测试] [评审] [架构] [集成] [同步]

## 结构

ai-task.local/ 是软链接，指向 AI-TASK/projects/${project_code}:
- project.yaml — 项目元数据
- index.md — 项目入口
- tasks/ — 任务目录
- docs/ — 文档目录

## 规范

详见 ai-task.local/ 下的 ../../SPEC.md
EOF

    echo -e "  ${GREEN}+${NC} $project_path/.cursor/rules/ai-task.mdc"
}

# --- 通用 AGENT.md 适配器 ---
# AGENT.md 存储在 vault projects/{CODE}/ 下，工作仓库通过软链接引用
setup_ide_agent() {
    local project_path="$1"
    local project_code="$2"
    local project_name="$3"
    local vault_project_dir="$PROJECTS_DIR/$project_code"

    # 生成 AGENT.md → vault
    cat > "$vault_project_dir/AGENT.md" << EOF
# ${project_name}

> AI 协作入口 · Powered by [AI-TASK](https://github.com/ArnoFrost/AI-TASK)

## 项目信息

详见 \`ai-task.local/project.yaml\`

## 任务管理

| 操作 | 说明 |
|------|------|
| 创建任务 | 描述需求，AI 自动创建到 ai-task.local/tasks/ |
| 查看任务 | 查看 ai-task.local/index.md 任务列表 |
| 完成任务 | AI 自动更新状态并归档 |

## 标签

\`[功能]\` \`[优化]\` \`[修复]\` \`[排查]\` \`[文档]\` \`[调研]\` \`[技术方案]\` \`[规范]\` \`[下线]\` \`[清理]\` \`[梳理]\` \`[测试]\` \`[评审]\` \`[架构]\` \`[集成]\` \`[同步]\`

## 结构

\`\`\`
ai-task.local/              # 软链接 → AI-TASK/projects/${project_code} (local, gitignored)
├── project.yaml            # 项目元数据
├── index.md                # 项目入口
├── tasks/                  # 任务目录
└── docs/                   # 文档目录
\`\`\`

## 规范

详见 ai-task.local/ 下的 ../../SPEC.md

<!-- 可在 vault 中编辑此文件，工作仓库通过 AGENT.local.md 软链接自动同步 -->
EOF

    echo -e "  ${GREEN}+${NC} $vault_project_dir/AGENT.md ${DIM}(vault)${NC}"

    # 创建 local 化软链接到工作仓库
    create_ide_symlink "$project_path/AGENT.local.md" "$vault_project_dir/AGENT.md"
}

# ======================== 辅助函数 ========================

# 创建 IDE 入口文件软链接（vault → 工作仓库，local 化命名）
# 参数: $1=工作仓库中的链接路径(*.local.md)  $2=vault 中的实际文件路径
create_ide_symlink() {
    local link_path="$1"
    local target="$2"

    if [ -L "$link_path" ]; then
        rm "$link_path"
    elif [ -f "$link_path" ]; then
        # 已有同名普通文件 → 备份后替换
        mv "$link_path" "${link_path}.bak"
        echo -e "  ${YELLOW}备份${NC} ${link_path} → ${link_path}.bak"
    fi
    ln -s "$target" "$link_path"
    echo -e "  ${GREEN}↗${NC}  $link_path → ${DIM}(vault symlink)${NC}"
}

# 追加项目映射到 relink.local.sh（如果尚未存在）
# 参数: $1=项目代号 $2=工作仓库路径
append_relink_mapping() {
    local project_code="$1"
    local project_path="$2"
    local relink_local="$SCRIPT_DIR/relink.local.sh"

    # 如果 relink.local.sh 不存在，从 example 复制
    if [ ! -f "$relink_local" ]; then
        local example="$SCRIPT_DIR/relink.local.sh.example"
        if [ -f "$example" ]; then
            cp "$example" "$relink_local"
            echo -e "  ${GREEN}+${NC} 创建 relink.local.sh (基于 example)"
        else
            cat > "$relink_local" << 'EORL'
#!/bin/bash
# relink.local.sh — 项目软链接映射配置（自动生成）

declare -a LINK_MAP=(
)
EORL
            echo -e "  ${GREEN}+${NC} 创建 relink.local.sh"
        fi
    fi

    # 检查是否已有此项目的映射
    if grep -q "\"$project_code|" "$relink_local" 2>/dev/null; then
        echo -e "  ${DIM}relink.local.sh 已包含 $project_code 映射${NC}"
        return
    fi

    # 在 LINK_MAP 数组的右括号前插入新条目
    local escaped_path
    escaped_path=$(echo "$project_path" | sed 's|/|\\\/|g')
    # 将绝对路径中的 $HOME 替换为 $HOME 变量引用
    local home_escaped
    home_escaped=$(echo "$HOME" | sed 's|/|\\\/|g')
    local entry_path
    entry_path=$(echo "$project_path" | sed "s|^$HOME|\\\$HOME|")

    sed -i '' "/^)/i\\
  \"$project_code|$entry_path\"" "$relink_local" 2>/dev/null

    if [ $? -eq 0 ]; then
        echo -e "  ${GREEN}+${NC} relink.local.sh: 添加 $project_code 映射"
    fi
}

# 检查全局 gitignore 是否已配置 local 化规则
check_global_gitignore() {
    local global_ignore
    global_ignore="$(git config --global core.excludesFile 2>/dev/null)"

    if [[ -z "$global_ignore" ]]; then
        echo -e "  ${YELLOW}⚠${NC} 全局 gitignore 未配置"
        return 1
    fi

    # 展开 ~ 路径
    global_ignore="${global_ignore/#\~/$HOME}"

    local missing=()
    if ! grep -q "ai-task.local" "$global_ignore" 2>/dev/null; then
        missing+=("ai-task.local")
    fi
    if ! grep -qE '\*\.local\.md' "$global_ignore" 2>/dev/null; then
        missing+=("*.local.md")
    fi

    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "  ${YELLOW}⚠${NC} 全局 gitignore 缺少规则: ${missing[*]}"
        echo -e "  ${DIM}  建议运行: ${NC}"
        for rule in "${missing[@]}"; do
            echo -e "    echo '$rule' >> $global_ignore"
        done
        return 1
    fi

    echo -e "  ${GREEN}✓${NC} 全局 gitignore 已配置 local 化规则"
    return 0
}

# ======================== IDE 选择菜单 ========================
select_ide() {
    echo ""
    echo -e "${BOLD}支持的 AI IDE 适配器:${NC}"
    echo -e "  ${CYAN}[1]${NC} claude-code  — 生成 CLAUDE.md + .claude/ 目录"
    echo -e "  ${CYAN}[2]${NC} codebuddy    — 生成 CODEBUDDY.md + .codebuddy/ 目录"
    echo -e "  ${CYAN}[3]${NC} cursor       — 生成 .cursor/rules/ 目录"
    echo -e "  ${CYAN}[4]${NC} 通用 AGENT.md — 仅生成 AGENT.md（推荐，IDE 无关）"
    echo -e "  ${CYAN}[a]${NC} 全部"
    echo -e "  ${CYAN}[n]${NC} 跳过"
    echo ""
    read -p "请选择 (多选用逗号分隔, 如 1,4) [4]: " ide_input
    IDE_SELECTIONS="${ide_input:-4}"
}

# 应用 IDE 适配器（根据 IDE_SELECTIONS 调用对应函数）
apply_ide_adapters() {
    local project_path="$1"
    local project_code="$2"
    local project_name="$3"

    # 跳过
    if [[ "$IDE_SELECTIONS" == "n" ]]; then
        echo -e "${DIM}  跳过 IDE 适配器配置${NC}"
        return 0
    fi

    # 全选
    if [[ "$IDE_SELECTIONS" == "a" ]]; then
        IDE_SELECTIONS="1,2,3,4"
    fi

    # 逐个执行
    IFS=',' read -ra selections <<< "$IDE_SELECTIONS"
    for sel in "${selections[@]}"; do
        sel="$(echo "$sel" | xargs)"  # 去除空格
        case "$sel" in
            1) setup_ide_claude_code "$project_path" "$project_code" "$project_name" ;;
            2) setup_ide_codebuddy "$project_path" "$project_code" "$project_name" ;;
            3) setup_ide_cursor "$project_path" "$project_code" "$project_name" ;;
            4) setup_ide_agent "$project_path" "$project_code" "$project_name" ;;
            *)
                echo -e "  ${YELLOW}警告: 未知的 IDE 编号 '$sel'，已跳过${NC}"
                ;;
        esac
    done
}

# 获取 IDE 名称列表（用于摘要显示）
get_ide_names() {
    local selections="$1"
    local names=""

    if [[ "$selections" == "n" ]]; then
        echo "无"
        return
    fi
    if [[ "$selections" == "a" ]]; then
        selections="1,2,3,4"
    fi

    IFS=',' read -ra sels <<< "$selections"
    for sel in "${sels[@]}"; do
        sel="$(echo "$sel" | xargs)"
        case "$sel" in
            1) names="${names:+$names, }claude-code" ;;
            2) names="${names:+$names, }codebuddy" ;;
            3) names="${names:+$names, }cursor" ;;
            4) names="${names:+$names, }AGENT.md" ;;
        esac
    done
    echo "${names:-无}"
}

# ======================== 参数解析 ========================
parse_args() {
    # 无参数 → 纯交互模式
    if [[ $# -eq 0 ]]; then
        interactive_input
        return
    fi

    # 帮助
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        print_help
        exit 0
    fi

    # 第一个非 -- 开头参数作为 PROJECT_CODE
    if [[ "$1" != --* ]]; then
        PROJECT_CODE="$1"
        shift
    fi

    # 解析 named options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --name)
                PROJECT_NAME="$2"
                shift 2
                ;;
            --path)
                PROJECT_PATH="$2"
                shift 2
                ;;
            --tech)
                TECH_STACK="$2"
                shift 2
                ;;
            --ide)
                IDE_SELECTIONS="$2"
                shift 2
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

    # 半交互：补全缺失字段
    if [[ -z "$PROJECT_CODE" ]]; then
        read -p "$(echo -e "${BOLD}项目代号 (必需): ${NC}")" PROJECT_CODE
        [[ -z "$PROJECT_CODE" ]] && { echo -e "${RED}错误: 项目代号不能为空${NC}"; exit 1; }
    fi

    if [[ -z "$PROJECT_NAME" ]]; then
        read -p "$(echo -e "${BOLD}项目名称${NC} [$PROJECT_CODE]: ")" PROJECT_NAME
        PROJECT_NAME="${PROJECT_NAME:-$PROJECT_CODE}"
    fi

    if [[ -z "$PROJECT_PATH" ]]; then
        read -p "$(echo -e "${BOLD}项目路径${NC} (可选, 回车跳过): ")" PROJECT_PATH
    fi

    if [[ -z "$TECH_STACK" ]]; then
        read -p "$(echo -e "${BOLD}技术栈${NC} (逗号分隔, 回车跳过): ")" TECH_STACK
    fi

    if [[ -z "$IDE_SELECTIONS" ]]; then
        select_ide
    fi
}

# ======================== 纯交互输入 ========================
interactive_input() {
    echo -e "${BOLD}--- 交互式项目初始化 ---${NC}"
    echo ""

    read -p "$(echo -e "${BOLD}项目代号 (必需): ${NC}")" PROJECT_CODE
    [[ -z "$PROJECT_CODE" ]] && { echo -e "${RED}错误: 项目代号不能为空${NC}"; exit 1; }

    read -p "$(echo -e "${BOLD}项目名称${NC} [$PROJECT_CODE]: ")" PROJECT_NAME
    PROJECT_NAME="${PROJECT_NAME:-$PROJECT_CODE}"

    read -p "$(echo -e "${BOLD}项目路径${NC} (可选, 回车跳过): ")" PROJECT_PATH

    read -p "$(echo -e "${BOLD}技术栈${NC} (逗号分隔, 回车跳过): ")" TECH_STACK

    select_ide
}

# ======================== 主逻辑 ========================
main() {
    print_header
    parse_args "$@"

    # 当前日期
    local today
    today=$(date +%Y-%m-%d)

    local project_dir="$PROJECTS_DIR/$PROJECT_CODE"

    # 检查项目是否已存在
    if [[ -d "$project_dir" ]]; then
        echo ""
        echo -e "${YELLOW}警告: 项目 $PROJECT_CODE 已存在 ($project_dir)${NC}"
        read -p "是否覆盖? (y/N): " confirm
        [[ "$confirm" != "y" && "$confirm" != "Y" ]] && { echo "已取消。"; exit 0; }
    fi

    echo ""
    echo -e "${BLUE}${BOLD}开始初始化项目: $PROJECT_CODE${NC}"
    echo "──────────────────────────────────────────"

    # ------ 1. 创建目录结构 ------
    echo -e "${GREEN}[1/6]${NC} 创建目录结构..."
    mkdir -p "$project_dir/tasks"
    mkdir -p "$project_dir/docs"
    touch "$project_dir/tasks/.gitkeep"
    touch "$project_dir/docs/.gitkeep"
    echo -e "  ${GREEN}+${NC} $project_dir/tasks/"
    echo -e "  ${GREEN}+${NC} $project_dir/docs/"

    # ------ 2. 生成 project.yaml ------
    echo -e "${GREEN}[2/6]${NC} 生成项目元数据 project.yaml..."

    # 技术栈转 YAML 数组
    local tech_yaml=""
    if [[ -n "$TECH_STACK" ]]; then
        IFS=',' read -ra techs <<< "$TECH_STACK"
        for t in "${techs[@]}"; do
            t="$(echo "$t" | xargs)"
            tech_yaml="${tech_yaml}  - ${t}"$'\n'
        done
    fi

    cat > "$project_dir/project.yaml" << EOF
# ${PROJECT_NAME} 项目元数据

code: ${PROJECT_CODE}
name: ${PROJECT_NAME}

# 跨设备路径 (按优先级排序，AI 自动检测存在的路径)
paths:
  - ${PROJECT_PATH:-~/Projects/$PROJECT_CODE}

tech_stack:
${tech_yaml:-  - # 待补充}

created: "${today}"
status: active

tags: []

related: []

metadata:
  description: 项目描述
EOF
    echo -e "  ${GREEN}+${NC} $project_dir/project.yaml"

    # ------ 3. 生成 index.md ------
    echo -e "${GREEN}[3/6]${NC} 生成项目入口 index.md..."

    local template_index="$TEMPLATES_DIR/project-index.md"
    if [[ -f "$template_index" ]]; then
        sed -e "s/{PROJECT_CODE}/$PROJECT_CODE/g" \
            -e "s/{PROJECT_NAME}/$PROJECT_NAME/g" \
            -e "s/{TECH_STACK:-待补充}/${TECH_STACK:-待补充}/g" \
            -e "s/Tech1, Tech2/${TECH_STACK:-待补充}/g" \
            -e "s/YYYY-MM-DD/$today/g" \
            "$template_index" > "$project_dir/index.md"
        echo -e "  ${GREEN}+${NC} $project_dir/index.md ${DIM}(基于模板)${NC}"
    else
        cat > "$project_dir/index.md" << EOF
<ai-task-context project="$PROJECT_CODE">
项目: $PROJECT_CODE | 规范: ./README.md | 全局规范: ../../SPEC.md
自动行为: 创建任务 → 执行 → 更新 index.md → 归档
约束: 严格遵循 README.md 中的命名/标签/归档规范，不创造新标签
skills:
  - task-review
  - task-init
notes:
  - 评审使用 /task-review
  - 项目对齐使用 /task-init
</ai-task-context>

# $PROJECT_NAME

> 项目简要描述

## 📌 项目信息

| 属性 | 值 |
|------|-----|
| **项目代号** | $PROJECT_CODE |
| **本地路径** | 见 [project.yaml](./project.yaml) |
| **主要技术栈** | ${TECH_STACK:-待补充} |
| **创建时间** | $today |

## 🏗️ 项目结构

\`\`\`text
$PROJECT_CODE/
├── project.yaml
├── index.md
├── README.md
├── tasks/
├── docs/
└── archive/
    └── YYYY-MM/
\`\`\`

---

## 📋 任务列表

> 按时间倒序排列

### 进行中 🔄

_暂无进行中任务_

### 已完成 ✅

_暂无已完成任务_

---

## 📂 历史归档

| 月份 | 说明 |
|------|------|
| _暂无归档_ | |

---

## 快捷链接

- [协作规范](./README.md)
- [任务目录](./tasks/)
- [文档目录](./docs/)
- [项目元数据](./project.yaml)
- [全局规范](../../SPEC.md)
EOF
        echo -e "  ${GREEN}+${NC} $project_dir/index.md ${DIM}(内置模板)${NC}"
    fi

    # ------ 4. 生成 README.md ------
    echo -e "${GREEN}[4/6]${NC} 生成协作规范 README.md..."
    cat > "$project_dir/README.md" << EOF
# ${PROJECT_NAME} — 协作规范

> 本文档定义 ${PROJECT_CODE} 项目的 AI 协作约定，AI 引入 \`index.md\` 后自动遵循。

## 命名规范

- **任务格式**：\`{YYYYMMDD}-{NNN}_[标签]任务名称.md\`（full 模式）
- **编号规则**：全局递增，跨日期连续编号
- **标签**：使用 [SPEC.md 核心标签](../../SPEC.md#标签类型)，每个任务必须且只能使用 1 个

## 目录结构

\`\`\`text
${PROJECT_CODE}/
├── project.yaml          # 项目元数据
├── index.md              # 项目入口（任务列表）
├── README.md             # 本文件（协作规范）
├── tasks/                # 进行中的任务
├── docs/                 # 项目文档
└── archive/              # 已完成任务归档
    └── YYYY-MM/
\`\`\`

## 软链接（工作仓库）

工作仓库通过 local 化软链接接入：

\`\`\`text
your-project/
├── ai-task.local/        → AI-TASK/projects/${PROJECT_CODE} (gitignored)
├── AGENT.local.md        → AI-TASK/projects/${PROJECT_CODE}/AGENT.md (gitignored)
└── CLAUDE.local.md       → AI-TASK/projects/${PROJECT_CODE}/CLAUDE.md (gitignored)
\`\`\`

> 配合全局 gitignore (\`ai-task.local\` + \`*.local.md\`) 自动忽略，无需修改项目 .gitignore

## 工作流

1. 引入 \`@projects/${PROJECT_CODE}/index.md\`
2. 描述需求，AI 自动创建任务文档
3. AI 执行任务并更新 \`index.md\` 状态
4. 完成后归档到 \`archive/YYYY-MM/\`

## 归档规则

| 条件 | 动作 |
|------|------|
| 任务状态 = 已完成 | 可归档 |
| 任务创建超过 7 天 | 建议归档 |
| index.md 任务超过 20 条 | 触发归档提醒 |

## 参考

- [全局规范](../../SPEC.md)
- [项目元数据](./project.yaml)
- [任务模板](../../templates/task-template.md)
EOF
    echo -e "  ${GREEN}+${NC} $project_dir/README.md"

    # ------ 5. 生成 rules/{CODE}.md ------
    echo -e "${GREEN}[5/6]${NC} 生成项目规则 rules/$PROJECT_CODE.md..."
    mkdir -p "$RULES_DIR"

    local template_rules="$TEMPLATES_DIR/project-rules.md"
    if [[ -f "$template_rules" ]]; then
        sed -e "s/{PROJECT_CODE}/$PROJECT_CODE/g" \
            -e "s/{PROJECT_NAME}/$PROJECT_NAME/g" \
            -e "s/{project_code}/${PROJECT_CODE,,}/g" \
            "$template_rules" > "$RULES_DIR/$PROJECT_CODE.md"
        echo -e "  ${GREEN}+${NC} $RULES_DIR/$PROJECT_CODE.md ${DIM}(基于模板)${NC}"
    else
        cat > "$RULES_DIR/$PROJECT_CODE.md" << EOF
---
name: ${PROJECT_CODE,,}-rules
description: ${PROJECT_NAME} 项目规则
project: ${PROJECT_CODE}
---

# ${PROJECT_NAME} 项目规则

## 架构约定

> 描述项目的模块结构和依赖关系

### 模块结构

\`\`\`
project-root/
├── src/
└── ...
\`\`\`

### 依赖规则

- 待补充

## 代码规范

> 项目特定的编码规范

\`\`\`
// 代码示例
\`\`\`

## 性能关注点

> 项目特定的性能要求

- 待补充

## 任务标签映射

| 模块 | 推荐标签 |
|------|----------|
| 通用 | \`[功能]\` \`[修复]\` \`[优化]\` |

## 参考文档

- 待补充
EOF
        echo -e "  ${GREEN}+${NC} $RULES_DIR/$PROJECT_CODE.md ${DIM}(内置模板)${NC}"
    fi

    # ------ 6. 创建软链接 + IDE 适配器 ------
    if [[ -n "$PROJECT_PATH" && -d "$PROJECT_PATH" ]]; then
        echo -e "${GREEN}[6/6]${NC} 创建 local 化软链接 + IDE 适配器..."

        # ai-task.local 目录软链接
        local link_path="$PROJECT_PATH/ai-task.local"
        if [[ -L "$link_path" ]]; then
            rm "$link_path"
        fi
        ln -s "$project_dir" "$link_path"
        echo -e "  ${GREEN}+${NC} $link_path -> $project_dir"

        # 追加 relink.local.sh 映射
        append_relink_mapping "$PROJECT_CODE" "$PROJECT_PATH"

        # IDE 适配器
        echo ""
        echo -e "  ${CYAN}── IDE 适配器 (vault + local symlink) ──${NC}"
        apply_ide_adapters "$PROJECT_PATH" "$PROJECT_CODE" "$PROJECT_NAME"
    elif [[ -n "$PROJECT_PATH" && ! -d "$PROJECT_PATH" ]]; then
        echo -e "${YELLOW}[6/6]${NC} 跳过软链接 (路径不存在: $PROJECT_PATH)"
    else
        echo -e "${YELLOW}[6/6]${NC} 跳过软链接 (未提供项目路径)"
        # 即使无路径，如果选了 IDE 适配器也生成到 vault
        if [[ "$IDE_SELECTIONS" != "n" ]]; then
            echo -e "${DIM}  提示: IDE 入口文件仅生成到 vault，后续可通过 relink.sh 补建软链接${NC}"
        fi
    fi

    # ======================== 配置摘要 ========================
    echo ""
    echo -e "${GREEN}${BOLD}════════════════════════════════════════════${NC}"
    echo -e "${GREEN}${BOLD}  项目 ${PROJECT_CODE} 初始化完成!${NC}"
    echo -e "${GREEN}${BOLD}════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${BOLD}配置摘要:${NC}"
    echo "──────────────────────────────────────────"
    echo -e "  项目代号  : ${CYAN}${PROJECT_CODE}${NC}"
    echo -e "  项目名称  : ${CYAN}${PROJECT_NAME}${NC}"
    echo -e "  项目路径  : ${CYAN}${PROJECT_PATH:-未指定}${NC}"
    echo -e "  技术栈    : ${CYAN}${TECH_STACK:-未指定}${NC}"
    echo -e "  IDE 适配器: ${CYAN}$(get_ide_names "$IDE_SELECTIONS")${NC}"
    echo -e "  链接模式  : ${CYAN}local 化 (v3.0.0)${NC}"
    echo "──────────────────────────────────────────"
    echo ""
    echo -e "${BOLD}生成的文件:${NC}"
    echo "  - $project_dir/project.yaml"
    echo "  - $project_dir/index.md"
    echo "  - $project_dir/README.md"
    echo "  - $project_dir/tasks/"
    echo "  - $project_dir/docs/"
    echo "  - $RULES_DIR/$PROJECT_CODE.md"
    if [[ -n "$PROJECT_PATH" && -d "$PROJECT_PATH" ]]; then
        echo "  - $PROJECT_PATH/ai-task.local -> $project_dir"
        # 列出 IDE 生成物
        if [[ "$IDE_SELECTIONS" != "n" ]]; then
            local sels="$IDE_SELECTIONS"
            [[ "$sels" == "a" ]] && sels="1,2,3,4"
            IFS=',' read -ra sel_arr <<< "$sels"
            for s in "${sel_arr[@]}"; do
                s="$(echo "$s" | xargs)"
                case "$s" in
                    1) echo "  - $project_dir/CLAUDE.md (vault) → $PROJECT_PATH/CLAUDE.local.md (symlink)" ;;
                    2) echo "  - $project_dir/CODEBUDDY.md (vault) → $PROJECT_PATH/CODEBUDDY.local.md (symlink)" ;;
                    3) echo "  - $PROJECT_PATH/.cursor/rules/ai-task.mdc" ;;
                    4) echo "  - $project_dir/AGENT.md (vault) → $PROJECT_PATH/AGENT.local.md (symlink)" ;;
                esac
            done
        fi
    fi
    echo ""

    # 全局 gitignore 检查
    echo -e "${BOLD}全局 gitignore 状态:${NC}"
    check_global_gitignore
    echo ""

    echo -e "${BOLD}下一步:${NC}"
    echo "  1. 编辑 $project_dir/project.yaml 补充项目信息"
    echo "  2. 编辑 $RULES_DIR/$PROJECT_CODE.md 补充项目规则"
    if [[ -n "$PROJECT_PATH" && -d "$PROJECT_PATH" ]]; then
        echo "  3. 定制 $project_dir/AGENT.md (或其他 IDE 入口文件)"
        echo "     文件存储在 vault 中，工作仓库通过 *.local.md 软链接引用"
        echo "  4. 跨设备时运行 ./relink.sh 重建所有软链接"
        echo "  5. 确保全局 gitignore 已配置 (ai-task.local + *.local.md)"
    else
        echo "  3. 手动创建软链接:"
        echo "     ln -s \"$project_dir\" \"/path/to/project/ai-task.local\""
        echo "  4. 运行 ./relink.sh 重建 IDE 入口文件软链接"
        echo "  5. 编辑 relink.local.sh 添加项目映射"
        echo "  6. 确保全局 gitignore 已配置 (ai-task.local + *.local.md)"
    fi
    echo ""
}

main "$@"
