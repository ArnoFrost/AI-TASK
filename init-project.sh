#!/bin/bash
# =====================================
# AI-TASK 项目初始化脚本 v1.3.0
# =====================================
# 用法: ./init-project.sh <CODE> "<NAME>" "<PATH>" "<TECH>" [--ide IDE]
# 示例: ./init-project.sh myapp "My App" "/Users/xxx/myapp" "React, TS" --ide both
#
# 功能: 
#   - 多 IDE 支持 (Claude Code / CodeBuddy)
#   - 软链接架构集成
#   - 自动创建项目结构

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 获取脚本所在目录 (AI-TASK 根目录)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECTS_DIR="$SCRIPT_DIR/projects"
RULES_DIR="$SCRIPT_DIR/rules"
TEMPLATES_DIR="$SCRIPT_DIR/templates"

# 默认 IDE 配置
IDE_CONFIG="both"

# 打印帮助
print_help() {
    echo "AI-TASK 项目初始化脚本 v1.2.0"
    echo ""
    echo "用法:"
    echo "  $0 <PROJECT_CODE> [PROJECT_NAME] [PROJECT_PATH] [TECH_STACK] [--ide IDE]"
    echo ""
    echo "参数:"
    echo "  PROJECT_CODE   项目代号 (必需, 如: MYAPP, DEMO)"
    echo "  PROJECT_NAME   项目名称 (可选, 默认同代号)"
    echo "  PROJECT_PATH   项目本地路径 (可选, 支持跨设备多路径)"
    echo "  TECH_STACK     技术栈 (可选)"
    echo "  --ide IDE      IDE 配置 (claude/codebuddy/both, 默认 both)"
    echo ""
    echo "示例:"
    echo "  $0 myapp"
    echo "  $0 myapp \"My Application\""
    echo "  $0 myapp \"My Application\" \"/Users/xxx/Projects/myapp\" \"React, TypeScript\""
    echo "  $0 myapp \"My App\" \"/path/to/app\" \"React\" --ide codebuddy"
    echo ""
    echo "交互模式:"
    echo "  $0              # 无参数时进入交互模式"
}

# 交互式输入
interactive_mode() {
    echo -e "${BLUE}=== AI-TASK 项目初始化 v1.2.0 ===${NC}"
    echo ""
    
    read -p "项目代号 (必需): " PROJECT_CODE
    [[ -z "$PROJECT_CODE" ]] && { echo -e "${RED}错误: 项目代号不能为空${NC}"; exit 1; }
    
    read -p "项目名称 [$PROJECT_CODE]: " PROJECT_NAME
    PROJECT_NAME="${PROJECT_NAME:-$PROJECT_CODE}"
    
    read -p "项目路径 (可选): " PROJECT_PATH
    read -p "技术栈 (可选, 逗号分隔): " TECH_STACK
    read -p "IDE 配置 (claude/codebuddy/both) [both]: " IDE_CONFIG
    IDE_CONFIG="${IDE_CONFIG:-both}"
}

# 参数解析
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    print_help
    exit 0
fi

# 解析 --ide 参数
parse_ide_arg() {
    for arg in "$@"; do
        if [[ "$arg" == "--ide" ]]; then
            shift
            IDE_CONFIG="$1"
            return
        fi
    done
}

if [[ $# -eq 0 ]]; then
    interactive_mode
else
    PROJECT_CODE="$1"
    PROJECT_NAME="${2:-$PROJECT_CODE}"
    PROJECT_PATH="${3:-}"
    TECH_STACK="${4:-}"
    # 解析 --ide 参数
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --ide)
                IDE_CONFIG="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done
fi

# 验证项目代号
if [[ -z "$PROJECT_CODE" ]]; then
    echo -e "${RED}错误: 项目代号不能为空${NC}"
    exit 1
fi

# 检查项目是否已存在
PROJECT_DIR="$PROJECTS_DIR/$PROJECT_CODE"
if [[ -d "$PROJECT_DIR" ]]; then
    echo -e "${YELLOW}警告: 项目 $PROJECT_CODE 已存在${NC}"
    read -p "是否覆盖? (y/N): " confirm
    [[ "$confirm" != "y" && "$confirm" != "Y" ]] && exit 0
fi

# 当前日期
TODAY=$(date +%Y-%m-%d)

echo ""
echo -e "${BLUE}初始化项目: $PROJECT_CODE${NC}"
echo "----------------------------------------"

# 1. 创建目录结构
echo -e "${GREEN}[1/6]${NC} 创建目录结构..."
mkdir -p "$PROJECT_DIR/tasks"
mkdir -p "$PROJECT_DIR/docs"

# 2. 创建 project.yaml (v2 新增)
echo -e "${GREEN}[2/6]${NC} 创建项目元数据 project.yaml..."

# 处理技术栈为 YAML 数组格式
TECH_YAML=""
if [[ -n "$TECH_STACK" ]]; then
    IFS=',' read -ra TECHS <<< "$TECH_STACK"
    for tech in "${TECHS[@]}"; do
        tech=$(echo "$tech" | xargs)  # trim whitespace
        TECH_YAML="$TECH_YAML  - $tech"$'\n'
    done
fi

cat > "$PROJECT_DIR/project.yaml" << EOF
# $PROJECT_NAME 项目元数据

code: $PROJECT_CODE
name: $PROJECT_NAME

# 跨设备路径 (按优先级排序，AI 自动检测存在的路径)
paths:
  - ${PROJECT_PATH:-~/Projects/$PROJECT_CODE}

tech_stack:
${TECH_YAML:-  - # 待补充}

created: "$TODAY"
status: active

tags: []

related: []

metadata:
  description: 项目描述
EOF

# 3. 创建 index.md（基于模板生成）
echo -e "${GREEN}[3/6]${NC} 创建项目入口 index.md..."
TEMPLATE_INDEX="$TEMPLATES_DIR/project-index.md"
if [[ -f "$TEMPLATE_INDEX" ]]; then
  sed -e "s/{PROJECT_CODE}/$PROJECT_CODE/g" \
      -e "s/{PROJECT_NAME}/$PROJECT_NAME/g" \
      -e "s/{TECH_STACK:-待补充}/${TECH_STACK:-待补充}/g" \
      -e "s/Tech1, Tech2/${TECH_STACK:-待补充}/g" \
      -e "s/YYYY-MM-DD/$TODAY/g" \
      "$TEMPLATE_INDEX" > "$PROJECT_DIR/index.md"
else
  echo -e "${YELLOW}  警告: 模板文件 $TEMPLATE_INDEX 不存在，使用内置最小模板${NC}"
  cat > "$PROJECT_DIR/index.md" << EOF
<ai-task-context project="$PROJECT_CODE">

## 自动行为（无需用户指令）
1. **阅读任务列表** - 了解当前进度，避免重复工作
2. **自动创建任务** - 用户描述需求时，自动生成任务文档到 tasks/
3. **自动命名编号** - 格式: {DATE}-{SEQ}_[标签]名称.md，用户无需关心
4. **自动更新状态** - 任务完成后更新本文件任务列表

## 任务文档自动生成规则
- 文件名: YYYYMMDD-NNN_[标签]任务名.md (AI自动生成)
- 标签: 根据任务内容自动判断（详见 ../../SPEC.md#标签类型）
- 编号: **全局递增**，跨日期连续编号，取 tasks/ 目录最大 NNN + 1

## 用户只需要
- 描述要做什么（自然语言）
- AI 自动完成：创建任务 → 执行 → 更新状态 → 提交

规范详见：../../SPEC.md

</ai-task-context>

# $PROJECT_NAME

> 项目简要描述

## 📌 项目信息

| 属性 | 值 |
|------|-----|
| **项目代号** | $PROJECT_CODE |
| **本地路径** | 见 [project.yaml](./project.yaml) |
| **主要技术栈** | ${TECH_STACK:-待补充} |
| **创建时间** | $TODAY |

---

## 📋 任务列表

> 按时间倒序排列

### 进行中 🔄

_暂无进行中任务_

### 已完成 ✅

_暂无已完成任务_

---

## 🔗 快捷链接

- [任务目录](./tasks/)
- [文档目录](./docs/)
- [项目元数据](./project.yaml)
- [全局规范](../../SPEC.md)
EOF
fi

# 4. 创建规则文件 (可选)
echo -e "${GREEN}[4/6]${NC} 创建项目规则 rules/$PROJECT_CODE.md..."
cat > "$RULES_DIR/$PROJECT_CODE.md" << EOF
---
name: ${PROJECT_CODE,,}-rules
description: $PROJECT_NAME 项目规则
project: $PROJECT_CODE
---

# $PROJECT_NAME 项目规则

## 🏗️ 架构约定

> 描述项目的模块结构和依赖关系

### 模块结构

\`\`\`
project-root/
├── src/
└── ...
\`\`\`

### 依赖规则

- 待补充

## 📐 代码规范

> 项目特定的编码规范

\`\`\`
// 代码示例
\`\`\`

## 🔥 性能关注点

> 项目特定的性能要求

- 待补充

## 📋 任务标签映射

| 模块 | 推荐标签 |
|------|----------|
| 通用 | \`[功能]\` \`[修复]\` \`[优化]\` |

## 🔗 参考文档

- 待补充
EOF

# 5. 创建软链接 (如果提供了项目路径)
if [[ -n "$PROJECT_PATH" && -d "$PROJECT_PATH" ]]; then
    echo -e "${GREEN}[5/6]${NC} 创建软链接..."
    LINK_PATH="$PROJECT_PATH/ai-task"
    if [[ -L "$LINK_PATH" ]]; then
        rm "$LINK_PATH"
    fi
    ln -s "$PROJECT_DIR" "$LINK_PATH"
    echo "  $LINK_PATH -> $PROJECT_DIR"
else
    echo -e "${YELLOW}[5/6]${NC} 跳过软链接 (未提供有效项目路径)"
fi

# 6. 生成 IDE 配置 (v4 支持多 IDE)
if [[ -n "$PROJECT_PATH" && -d "$PROJECT_PATH" ]]; then
    echo -e "${GREEN}[6/6]${NC} 生成 IDE 配置 (${IDE_CONFIG})..."
    
    # Claude Code 配置
    if [[ "$IDE_CONFIG" == "claude" || "$IDE_CONFIG" == "both" ]]; then
        # 创建 CLAUDE.md
        cat > "$PROJECT_PATH/CLAUDE.md" << EOF
# $PROJECT_NAME

> AI 协作入口文档

## 📌 项目信息

详见 \`ai-task/project.yaml\`

## 🔧 快捷命令

| 命令 | 说明 |
|------|------|
| \`/task create [标签] 名称\` | 创建任务 |
| \`/task list\` | 列出任务 |
| \`/task update 编号 说明\` | 更新进度 |
| \`/task done 编号\` | 标记完成 |
| \`/init_sub_project <path>\` | 初始化子项目 |

## 📂 AI-TASK 结构

\`\`\`
ai-task/                    # 软链接 → AI-TASK/projects/$PROJECT_CODE
├── project.yaml            # 项目元数据
├── index.md                # 项目入口
├── tasks/                  # 任务目录
└── docs/                   # 文档目录
\`\`\`

## 📋 任务标签

\`[功能]\` \`[优化]\` \`[修复]\` \`[排查]\` \`[文档]\` \`[调研]\` \`[技术方案]\` \`[规范]\`
EOF
        echo "  $PROJECT_PATH/CLAUDE.md"

        # 创建 .claude/commands/
        mkdir -p "$PROJECT_PATH/.claude/commands"
        cp "$TEMPLATES_DIR/claude/commands/"*.md "$PROJECT_PATH/.claude/commands/"
        echo "  $PROJECT_PATH/.claude/commands/ (全部命令)"
    fi
    
    # CodeBuddy 配置
    if [[ "$IDE_CONFIG" == "codebuddy" || "$IDE_CONFIG" == "both" ]]; then
        # 创建 CODEBUDDY.md
        cat > "$PROJECT_PATH/CODEBUDDY.md" << EOF
# $PROJECT_NAME

> AI 协作入口文档 (CodeBuddy)

## 📌 项目信息

详见 \`ai-task/project.yaml\`

## 🔧 快捷命令

| 命令 | 说明 |
|------|------|
| \`/task create [标签] 名称\` | 创建任务 |
| \`/task list\` | 列出任务 |
| \`/task update 编号 说明\` | 更新进度 |
| \`/task done 编号\` | 标记完成 |
| \`/init_sub_project <path>\` | 初始化子项目 |

## 📂 AI-TASK 结构

\`\`\`
ai-task/                    # 软链接 → AI-TASK/projects/$PROJECT_CODE
├── project.yaml            # 项目元数据
├── index.md                # 项目入口
├── tasks/                  # 任务目录
└── docs/                   # 文档目录
\`\`\`

## 📋 任务标签

\`[功能]\` \`[优化]\` \`[修复]\` \`[排查]\` \`[文档]\` \`[调研]\` \`[技术方案]\` \`[规范]\`
EOF
        echo "  $PROJECT_PATH/CODEBUDDY.md"

        # 创建 .codebuddy/commands/
        mkdir -p "$PROJECT_PATH/.codebuddy/commands"
        cp "$TEMPLATES_DIR/codebuddy/commands/"*.md "$PROJECT_PATH/.codebuddy/commands/"
        echo "  $PROJECT_PATH/.codebuddy/commands/ (全部命令)"
    fi
else
    echo -e "${YELLOW}[6/6]${NC} 跳过 IDE 配置 (未提供有效项目路径)"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✅ 项目 $PROJECT_CODE 初始化完成!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "创建的文件:"
echo "  - $PROJECT_DIR/project.yaml"
echo "  - $PROJECT_DIR/index.md"
echo "  - $PROJECT_DIR/tasks/"
echo "  - $PROJECT_DIR/docs/"
echo "  - $RULES_DIR/$PROJECT_CODE.md"
echo ""

if [[ -n "$PROJECT_PATH" && -d "$PROJECT_PATH" ]]; then
    echo "软链接:"
    echo "  - $PROJECT_PATH/ai-task -> $PROJECT_DIR"
    echo ""
    echo "IDE 配置 (${IDE_CONFIG}):"
    if [[ "$IDE_CONFIG" == "claude" || "$IDE_CONFIG" == "both" ]]; then
        echo "  - $PROJECT_PATH/CLAUDE.md"
        echo "  - $PROJECT_PATH/.claude/commands/ (task, init_sub_project, archive, status)"
    fi
    if [[ "$IDE_CONFIG" == "codebuddy" || "$IDE_CONFIG" == "both" ]]; then
        echo "  - $PROJECT_PATH/CODEBUDDY.md"
        echo "  - $PROJECT_PATH/.codebuddy/commands/ (task, init_sub_project, archive, status)"
    fi
    echo ""
fi

echo "下一步:"
echo "  1. 编辑 $PROJECT_DIR/project.yaml 补充跨设备路径"
echo "  2. 编辑 $PROJECT_DIR/index.md 补充项目信息"
echo "  3. 编辑 $RULES_DIR/$PROJECT_CODE.md 补充项目规则"
if [[ -n "$PROJECT_PATH" && -d "$PROJECT_PATH" ]]; then
    echo "  4. 使用 /task 或 /init_sub_project 命令"
else
    echo "  4. 手动创建软链接:"
    echo "     ln -s \"$PROJECT_DIR\" \"/path/to/project/ai-task\""
    echo "  5. 复制 IDE 配置:"
    echo "     cp \"$TEMPLATES_DIR/claude/CLAUDE.md\" \"/path/to/project/\""
    echo "     cp -r \"$TEMPLATES_DIR/claude/commands\" \"/path/to/project/.claude/\""
    echo "     # 或 CodeBuddy:"
    echo "     cp \"$TEMPLATES_DIR/codebuddy/CODEBUDDY.md\" \"/path/to/project/\""
    echo "     cp -r \"$TEMPLATES_DIR/codebuddy/commands\" \"/path/to/project/.codebuddy/\""
fi
