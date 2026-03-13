#!/bin/bash
# =====================================================
# AI-TASK 项目初始化脚本 v2.0.0
# =====================================================
# 交互式多 IDE 支持的项目初始化工具
#
# 用法:
#   ./init-project.sh [CODE] [options]
#   ./init-project.sh                          # 纯交互模式
#   ./init-project.sh myapp                    # 半交互
#   ./init-project.sh myapp --path /x --name "My App" --tech "React,TS" --ide 1,4
# =====================================================

set -e

VERSION="2.0.0"

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
    echo "示例:"
    echo "  $0 myapp --ide 4"
    echo "  $0 myapp --path ~/Projects/myapp --name \"My App\" --tech \"React,TS\" --ide 1,4"
}

# ======================== IDE 适配器函数 ========================

# --- Claude Code 适配器 ---
setup_ide_claude_code() {
    local project_path="$1"
    local project_code="$2"
    local project_name="$3"

    # 创建 .claude/ 目录（不创建 commands/ 子目录）
    mkdir -p "$project_path/.claude"

    # 生成 CLAUDE.md
    cat > "$project_path/CLAUDE.md" << EOF
# ${project_name}

> AI 协作入口 · Claude Code · Powered by [AI-TASK](https://github.com/ArnoFrost/AI-TASK)

## 项目信息

详见 \`ai-task/project.yaml\`

## 任务管理

| 操作 | 说明 |
|------|------|
| 创建任务 | 描述需求，AI 自动创建到 ai-task/tasks/ |
| 查看任务 | 查看 ai-task/index.md 任务列表 |
| 完成任务 | AI 自动更新状态并归档 |

## 标签

\`[功能]\` \`[优化]\` \`[修复]\` \`[排查]\` \`[文档]\` \`[调研]\` \`[技术方案]\` \`[规范]\` \`[下线]\` \`[清理]\` \`[梳理]\` \`[测试]\` \`[评审]\` \`[架构]\` \`[集成]\` \`[同步]\`

## 结构

\`\`\`
ai-task/                    # 软链接 → AI-TASK/projects/${project_code}
├── project.yaml            # 项目元数据
├── index.md                # 项目入口
├── tasks/                  # 任务目录
└── docs/                   # 文档目录
\`\`\`

## 规范

详见 ai-task/ 下的 ../../SPEC.md
EOF

    echo -e "  ${GREEN}+${NC} $project_path/CLAUDE.md"
    echo -e "  ${GREEN}+${NC} $project_path/.claude/"
}

# --- CodeBuddy 适配器 ---
setup_ide_codebuddy() {
    local project_path="$1"
    local project_code="$2"
    local project_name="$3"

    # 创建 .codebuddy/ 目录（不创建 commands/ 子目录）
    mkdir -p "$project_path/.codebuddy"

    # 生成 CODEBUDDY.md
    cat > "$project_path/CODEBUDDY.md" << EOF
# ${project_name}

> AI 协作入口 · CodeBuddy · Powered by [AI-TASK](https://github.com/ArnoFrost/AI-TASK)

## 项目信息

详见 \`ai-task/project.yaml\`

## 任务管理

| 操作 | 说明 |
|------|------|
| 创建任务 | 描述需求，AI 自动创建到 ai-task/tasks/ |
| 查看任务 | 查看 ai-task/index.md 任务列表 |
| 完成任务 | AI 自动更新状态并归档 |

## 标签

\`[功能]\` \`[优化]\` \`[修复]\` \`[排查]\` \`[文档]\` \`[调研]\` \`[技术方案]\` \`[规范]\` \`[下线]\` \`[清理]\` \`[梳理]\` \`[测试]\` \`[评审]\` \`[架构]\` \`[集成]\` \`[同步]\`

## 结构

\`\`\`
ai-task/                    # 软链接 → AI-TASK/projects/${project_code}
├── project.yaml            # 项目元数据
├── index.md                # 项目入口
├── tasks/                  # 任务目录
└── docs/                   # 文档目录
\`\`\`

## 规范

详见 ai-task/ 下的 ../../SPEC.md
EOF

    echo -e "  ${GREEN}+${NC} $project_path/CODEBUDDY.md"
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
  - ai-task/**
---

# ${project_name}

> AI 协作规范 · Cursor · Powered by [AI-TASK](https://github.com/ArnoFrost/AI-TASK)

## 项目信息

详见 \`ai-task/project.yaml\`

## 任务管理

- 创建任务: 描述需求，AI 自动创建到 ai-task/tasks/
- 查看任务: 查看 ai-task/index.md 任务列表
- 完成任务: AI 自动更新状态并归档

## 标签

[功能] [优化] [修复] [排查] [文档] [调研] [技术方案] [规范] [下线] [清理] [梳理] [测试] [评审] [架构] [集成] [同步]

## 结构

ai-task/ 是软链接，指向 AI-TASK/projects/${project_code}:
- project.yaml — 项目元数据
- index.md — 项目入口
- tasks/ — 任务目录
- docs/ — 文档目录

## 规范

详见 ai-task/ 下的 ../../SPEC.md
EOF

    echo -e "  ${GREEN}+${NC} $project_path/.cursor/rules/ai-task.mdc"
}

# --- 通用 AGENT.md 适配器 ---
setup_ide_agent() {
    local project_path="$1"
    local project_code="$2"
    local project_name="$3"

    cat > "$project_path/AGENT.md" << EOF
# ${project_name}

> AI 协作入口 · Powered by [AI-TASK](https://github.com/ArnoFrost/AI-TASK)

## 项目信息

详见 \`ai-task/project.yaml\`

## 任务管理

| 操作 | 说明 |
|------|------|
| 创建任务 | 描述需求，AI 自动创建到 ai-task/tasks/ |
| 查看任务 | 查看 ai-task/index.md 任务列表 |
| 完成任务 | AI 自动更新状态并归档 |

## 标签

\`[功能]\` \`[优化]\` \`[修复]\` \`[排查]\` \`[文档]\` \`[调研]\` \`[技术方案]\` \`[规范]\` \`[下线]\` \`[清理]\` \`[梳理]\` \`[测试]\` \`[评审]\` \`[架构]\` \`[集成]\` \`[同步]\`

## 结构

\`\`\`
ai-task/                    # 软链接 → AI-TASK/projects/${project_code}
├── project.yaml            # 项目元数据
├── index.md                # 项目入口
├── tasks/                  # 任务目录
└── docs/                   # 文档目录
\`\`\`

## 规范

详见 ai-task/ 下的 ../../SPEC.md
EOF

    echo -e "  ${GREEN}+${NC} $project_path/AGENT.md"
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
    echo -e "${GREEN}[1/7]${NC} 创建目录结构..."
    mkdir -p "$project_dir/tasks"
    mkdir -p "$project_dir/docs"
    touch "$project_dir/tasks/.gitkeep"
    touch "$project_dir/docs/.gitkeep"
    echo -e "  ${GREEN}+${NC} $project_dir/tasks/"
    echo -e "  ${GREEN}+${NC} $project_dir/docs/"

    # ------ 2. 生成 project.yaml ------
    echo -e "${GREEN}[2/7]${NC} 生成项目元数据 project.yaml..."

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
    echo -e "${GREEN}[3/7]${NC} 生成项目入口 index.md..."

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
    echo -e "${GREEN}[4/7]${NC} 生成协作规范 README.md..."
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
    echo -e "${GREEN}[5/7]${NC} 生成项目规则 rules/$PROJECT_CODE.md..."
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

    # ------ 6. 创建软链接 ------
    if [[ -n "$PROJECT_PATH" && -d "$PROJECT_PATH" ]]; then
        echo -e "${GREEN}[6/7]${NC} 创建软链接..."
        local link_path="$PROJECT_PATH/ai-task"
        if [[ -L "$link_path" ]]; then
            rm "$link_path"
        fi
        ln -s "$project_dir" "$link_path"
        echo -e "  ${GREEN}+${NC} $link_path -> $project_dir"
    elif [[ -n "$PROJECT_PATH" && ! -d "$PROJECT_PATH" ]]; then
        echo -e "${YELLOW}[6/7]${NC} 跳过软链接 (路径不存在: $PROJECT_PATH)"
    else
        echo -e "${YELLOW}[6/7]${NC} 跳过软链接 (未提供项目路径)"
    fi

    # ------ 6. IDE 适配器 ------
    if [[ -n "$PROJECT_PATH" && -d "$PROJECT_PATH" ]]; then
        echo -e "${GREEN}[7/7]${NC} 生成 IDE 适配器配置..."
        apply_ide_adapters "$PROJECT_PATH" "$PROJECT_CODE" "$PROJECT_NAME"
    elif [[ "$IDE_SELECTIONS" != "n" ]]; then
        echo -e "${YELLOW}[7/7]${NC} 跳过 IDE 适配器 (项目路径无效，无法写入 IDE 文件)"
    else
        echo -e "${DIM}[7/7]${NC} 跳过 IDE 适配器"
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
        echo "  - $PROJECT_PATH/ai-task -> $project_dir"
        # 列出 IDE 生成物
        if [[ "$IDE_SELECTIONS" != "n" ]]; then
            local sels="$IDE_SELECTIONS"
            [[ "$sels" == "a" ]] && sels="1,2,3,4"
            IFS=',' read -ra sel_arr <<< "$sels"
            for s in "${sel_arr[@]}"; do
                s="$(echo "$s" | xargs)"
                case "$s" in
                    1) echo "  - $PROJECT_PATH/CLAUDE.md" ;;
                    2) echo "  - $PROJECT_PATH/CODEBUDDY.md" ;;
                    3) echo "  - $PROJECT_PATH/.cursor/rules/ai-task.mdc" ;;
                    4) echo "  - $PROJECT_PATH/AGENT.md" ;;
                esac
            done
        fi
    fi
    echo ""

    echo -e "${BOLD}下一步:${NC}"
    echo "  1. 编辑 $project_dir/project.yaml 补充项目信息"
    echo "  2. 编辑 $RULES_DIR/$PROJECT_CODE.md 补充项目规则"
    if [[ -z "$PROJECT_PATH" || ! -d "$PROJECT_PATH" ]]; then
        echo "  3. 手动创建软链接:"
        echo "     ln -s \"$project_dir\" \"/path/to/project/ai-task\""
        echo "  4. 重新运行并指定 --path 来生成 IDE 适配器文件"
    fi
    echo ""
}

main "$@"
