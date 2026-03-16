---
name: task-init
description: |
  AI-TASK 项目初始化 — 为项目创建 AI-TASK 规范目录结构，生成 project.yaml、index.md、README.md，
  配置软链接。IDE 入口文件 (AGENT.md 等) 存储在 vault 中，工作仓库通过软链接引用。
  Use when: 初始化 ai-task、新建项目、对齐规范、project init、task-init
user_invocable: true
license: MIT
metadata:
  author: ArnoFrost
  version: 1.1.0
---

# AI-TASK 项目初始化

> 为项目初始化或重新对齐 AI-TASK 协作规范

## 触发条件

| 条件 | 示例 |
|------|------|
| 初始化新项目 | "初始化 ai-task"、"新建项目" |
| 对齐规范 | "对齐规范"、"重新初始化" |
| 用户明确要求 | `/task-init` |

## 前置：定位 AI-TASK 仓库

按以下顺序定位 AI-TASK 目录：

1. 检查当前目录是否在 AI-TASK 仓库内
2. 通过 `find` 或环境变量 `$AI_TASK_PATH` 搜索本地 AI-TASK 目录
3. 若均不存在 → 提示用户提供路径

## 执行流程

### 1. 收集项目信息

向用户确认以下必要信息（若未提供）：

```yaml
project_code: XXX           # 项目代号（大写字母）
project_name: xxx           # 项目名称
local_path: /path/to/project  # 本地项目路径
tech_stack: Kotlin, ...     # 技术栈
description: 项目描述        # 简要描述
```

### 2. 读取最新规范

从 AI-TASK 仓库读取（相对路径 `../../templates/`）：

| 文件 | 用途 |
|------|------|
| `SPEC.md` | 编号规则、标签列表、frontmatter schema |
| `templates/project.yaml` | 项目元数据模板 |
| `templates/project-index.md` | 项目入口模板 |
| `templates/task-template.md` | 任务文档模板 |

### 3. 创建项目目录结构

```bash
mkdir -p projects/{CODE}/tasks
mkdir -p projects/{CODE}/docs
touch projects/{CODE}/tasks/.gitkeep
touch projects/{CODE}/docs/.gitkeep
```

### 4. 生成 project.yaml

基于 `templates/project.yaml` 模板，填充项目信息：

```yaml
code: {CODE}
name: {PROJECT_NAME}
paths:
  - {LOCAL_PATH}
tech_stack: [{TECH_STACK}]
created: {TODAY}
status: active
task_naming:
  format: "full"
```

### 5. 生成 index.md

包含 `<ai-task-context>` 规则块：

```markdown
<ai-task-context project="{CODE}">
项目: {CODE} | 规范: ./README.md | 全局规范: ../../SPEC.md
自动行为: 创建任务 → 执行 → 更新 index.md → 归档
约束: 严格遵循 README.md 中的命名/标签/归档规范，不创造新标签
notes:
  - 评审使用 /task-review
  - 项目对齐使用 /task-init
</ai-task-context>
```

### 6. 生成 README.md

协作规范文档，包含：
- 任务命名与结构（单文件/文件夹任务二分法）
- 全局递增编号规则
- 标签类型（引用 SPEC.md）
- 归档规则（近 3 天 + 进行中）
- 规范自约束（行数/条目数/大小限制）

### 7. 生成 IDE 入口文件 (vault 存储 + 软链接)

IDE 入口文件（AGENT.md / CLAUDE.md / CODEBUDDY.md）**存储在 vault** 的 `projects/{CODE}/` 下，
工作仓库根目录通过**软链接**引用。

```bash
# 1. 生成 AGENT.md 到 vault
# → AI-TASK/projects/{CODE}/AGENT.md

# 2. 创建软链接到工作仓库
ln -s "{AI_TASK_PATH}/projects/{CODE}/AGENT.md" "{LOCAL_PATH}/AGENT.md"
```

**优势**：
- 文件受 vault 内部 git 审计，变更可追溯
- 工作仓库只有软链接，`.gitignore` 排除即可，不污染主干
- 在 vault 中定制编辑，跨设备自动同步

### 8. 配置软链接

```bash
# 创建从项目到 AI-TASK 的软链接
ln -s "{AI_TASK_PATH}/projects/{CODE}" "{LOCAL_PATH}/ai-task"
```

若软链接已存在，提示用户确认是否覆盖。

### 9. 更新 .gitignore

确保工作仓库的 `.gitignore` 排除 AI-TASK 相关文件：

```gitignore
# AI-TASK (symlinks to vault, do not commit)
ai-task
AGENT.md
CLAUDE.md
CODEBUDDY.md
```

### 10. 输出 diff 确认

在执行写入前，向用户展示将要创建/更新的文件列表和关键内容差异，获得确认后再执行。

## 关键规则

| 规则 | 说明 |
|------|------|
| 全局递增编号 | 任务编号全局递增，跨日期连续编号 |
| 16 核心标签 | 功能/优化/修复/排查/文档/调研/技术方案/规范/下线/清理/梳理/测试/评审/架构/集成/同步 |
| frontmatter 必需 | date, status, type 三字段必需 |
| IDE 入口文件存 vault | AGENT.md 等文件不直接写入工作仓库，存储在 vault 中通过软链接引用 |

## Obsidian 格式规范

### Frontmatter

生成的文档须包含 YAML frontmatter：

```yaml
---
date: YYYY-MM-DD
status: todo
type: 对应标签类型
tags:
  - 项目代号
---
```

### Callout 映射

| 语义 | Callout |
|------|---------|
| 摘要/元信息 | `> [!info]` |
| 行动计划 | `> [!tip]` |
| 重要提示 | `> [!warning]` |
| 引用/参考 | `> [!quote]-`（折叠） |

### 格式原则

- 每个章节最多 1-2 个 callout，不过度装饰
- 高亮 `==文本==` 每段最多 1-2 处
- 表格优于嵌套列表
- 中英文之间加空格
