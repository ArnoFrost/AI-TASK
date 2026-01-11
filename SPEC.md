# AI-TASK 协作规范

> 本文档定义 AI-TASK 的架构设计、扩展规范和使用指南

## 🎯 设计理念

### 核心原则

| 原则 | 说明 |
|------|------|
| **去中心化** | 根目录不维护子项目列表，子项目自治 |
| **模板驱动** | 新项目基于模板初始化，保持一致性 |
| **软链接集成** | 子项目通过软链接接入，不侵入原项目 |
| **渐进式加载** | Skills/Rules 按需加载，减少上下文 |
| **跨设备兼容** | 通过 project.yaml 支持多设备路径映射 |

### 架构概览

```
AI-TASK/                          # 协作中心 (iCloud 同步)
├── SPEC.md                       # 本规范文档
├── README.md                     # 快速入门
├── init-project.sh               # 项目初始化脚本
├── projects/                     # 项目空间
│   ├── AI-TASK/                  # 本项目自治
│   └── {PROJECT}/                # 子项目 (按代号命名)
│       ├── project.yaml          # 项目元数据 (v2 新增)
│       ├── index.md              # 项目入口
│       ├── tasks/                # 任务目录
│       ├── docs/                 # 文档目录
│       └── archive/              # 归档目录 (可选)
├── rules/                        # 规则库
│   └── {PROJECT}.md              # 项目规则
├── skills/                       # 技能库 (对齐 agentskills.io)
│   └── {skill-name}/SKILL.md     # 技能定义
├── templates/                    # 模板库
│   ├── project.yaml              # 项目元数据模板
│   ├── project-index.md          # 项目入口模板
│   └── task-template.md          # 任务模板
├── temp/                         # 临时文件
└── archive/                      # 全局归档
```

---

## 📂 项目结构规范

### 子项目目录

每个子项目在 `projects/{PROJECT}/` 下包含：

```
{PROJECT}/
├── project.yaml          # 必需：项目元数据 (v2)
├── index.md              # 必需：项目入口文档
├── tasks/                # 必需：任务文件目录
│   └── {DATE}-{SEQ}_[TAG]NAME.md
├── docs/                 # 可选：项目文档
└── archive/              # 可选：已完成任务归档
    └── YYYY-MM/
```

### 项目元数据 (project.yaml)

```yaml
# 必需字段
code: EXAMPLE                        # 项目代号
name: Example Project                # 项目名称

# 跨设备路径 (按优先级排序，AI 自动检测)
paths:
  - ~/Projects/example-project
  - /home/user/projects/example-project

# 可选字段
tech_stack: [TypeScript, React]
created: 2026-01-10
status: active                        # active | paused | archived
tags: [web, frontend]
related: []                           # 关联项目

# 任务命名配置 (可选)
task_naming:
  format: "full"                      # full | date | simple | custom
  # pattern: "{DATE}-{NNN}_{TAG}{NAME}.md"
  # seq_digits: 3
```

### 项目入口 (index.md)

```markdown
# 项目名称

> 项目简要描述

## 📌 项目信息

| 属性 | 值 |
|------|-----|
| **项目代号** | {CODE} |
| **本地路径** | 见 [project.yaml](./project.yaml) |
| **主要技术栈** | Tech1, Tech2 |
| **创建时间** | YYYY-MM-DD |

## 🏗️ 项目结构
...

## 📋 任务列表
### 进行中 🔄
### 已完成 ✅
```

---

## 🗄️ Archive 归档规范

### 目录结构

```
{PROJECT}/
├── archive/
│   ├── 2025-12/
│   │   ├── 20251211-001_[优化]XXX.md
│   │   └── 20251212-001_[功能]XXX.md
│   └── 2026-01/
└── tasks/                # 仅保留进行中任务
```

### 归档规则

| 条件 | 动作 |
|------|------|
| 任务状态 = 已完成 | 可归档 |
| 任务创建超过 30 天 | 建议归档 |
| index.md 任务超过 20 条 | 触发归档提醒 |

### 归档操作

```bash
# 手动归档
mkdir -p archive/2025-12
mv tasks/20251211-001_*.md archive/2025-12/

# AI 协作归档
"归档 TVKMM 项目 12 月已完成任务"
```

---

## 🏷️ 命名规范

### 项目代号

| 规则 | 示例 |
|------|------|
| 大写字母 + 数字 | TVKMM, L2D |
| 简短有意义 | dotfiles, Textoon |
| 避免特殊字符 | ❌ `my-project` |

### 任务文件

任务文件命名支持多种格式，通过 `project.yaml` 中的 `task_naming.format` 配置：

| format | 文件名格式 | 示例 |
|--------|-----------|------|
| `full` (默认) | `{DATE}-{SEQ}_[TAG]NAME.md` | `20260110-001_[功能]用户登录.md` |
| `date` | `{DATE}-{SEQ}_NAME.md` | `20260110-001_用户登录.md` |
| `simple` | `{SEQ}-NAME.md` | `001-用户登录.md` |
| `custom` | 自定义 pattern | 按 `task_naming.pattern` 生成 |

**配置示例**（在 `project.yaml` 中）：

```yaml
task_naming:
  format: "full"           # full | date | simple | custom
  # pattern: "{DATE}-{NNN}_{TAG}{NAME}.md"  # 仅 custom 时使用
  # seq_digits: 3          # 序号位数，默认 3
```

### 标签类型

| 标签 | 说明 | 标签 | 说明 |
|------|------|------|------|
| `[功能]` | 新功能 | `[优化]` | 性能优化 |
| `[修复]` | Bug 修复 | `[排查]` | 问题分析 |
| `[文档]` | 文档编写 | `[调研]` | 技术调研 |
| `[技术方案]` | 方案设计 | `[规范]` | 规范制定 |
| `[下线]` | 功能下线 | `[清理]` | 代码清理 |
| `[梳理]` | 逻辑梳理 | `[测试]` | 测试相关 |

---

## 📋 Skills 技能系统

### 规范对齐

Skills 对齐 [agentskills.io](https://agentskills.io/specification) 官方规范。

### SKILL.md 格式

```yaml
---
name: skill-name                      # 必需：小写+连字符，与目录名一致
description: |                        # 必需：功能描述 + 触发场景
  技能功能描述。
  Use when: 触发词1、触发词2、触发词3
license: Apache-2.0                   # 可选
compatibility: 环境要求               # 可选
metadata:                             # 可选
  author: ""
  version: ""
---

# 技能标题

[技能指令内容]
```

### 渐进式加载

| 阶段 | 内容 | Token 预算 |
|------|------|-----------|
| 启动 | name + description | ~100 |
| 激活 | SKILL.md 全文 | <5000 |
| 按需 | scripts/references | 无限制 |

### 目录结构

```
skills/
├── {skill-name}/
│   ├── SKILL.md              # 必需
│   ├── scripts/              # 可选：脚本
│   ├── references/           # 可选：参考文档
│   └── assets/               # 可选：静态资源
```

### 内置技能

| 技能 | 说明 |
|------|------|
| task-management | 任务创建、更新、查询 |
| project-init | 初始化项目配置 |
| git-minimal-commit | 最小化提交整理 |

---

## 📐 Rules 规则系统

### 加载方式

| 方式 | 说明 |
|------|------|
| **自动加载** | AI 检测到项目上下文时自动加载对应规则 |
| **手动查看** | "查看 {PROJECT} 项目规则" |

### 规则内容

- 架构约定：模块结构、依赖关系
- 代码规范：语言特定的编码规范
- 性能关注点：项目特定的性能要求
- 任务标签映射：模块与标签的对应关系

---

## 🔧 项目初始化

### 方式一：脚本初始化

```bash
# 在 AI-TASK 目录下执行
./init-project.sh <PROJECT_CODE> "<PROJECT_NAME>" "<PROJECT_PATH>" "<TECH_STACK>"

# 示例
./init-project.sh myapp "My Application" "/Users/xxx/Projects/myapp" "React, TypeScript"
```

### 方式二：手动初始化

1. **创建项目目录**
   ```bash
   mkdir -p projects/{PROJECT}/tasks projects/{PROJECT}/docs
   ```

2. **创建项目元数据**
   ```bash
   cp templates/project.yaml projects/{PROJECT}/project.yaml
   # 编辑 project.yaml 填写项目信息
   ```

3. **创建入口文档**
   ```bash
   cp templates/project-index.md projects/{PROJECT}/index.md
   # 编辑 index.md 填写项目信息
   ```

4. **创建软链接**
   ```bash
   ln -s "/path/to/AI-TASK/projects/{PROJECT}" "/path/to/project/ai-task"
   ```

### 方式三：AI 协作初始化

```
请帮我初始化一个新的 ai-task 子项目：
- 项目代号: XXX
- 项目名称: XXX
- 本地路径: /path/to/project
- 技术栈: XXX
```

---

## 🔗 软链接配置

### 创建软链接

```bash
# 格式
ln -s "{AI-TASK}/projects/{PROJECT}" "{PROJECT_ROOT}/ai-task"

# 示例
ln -s "~/AI-TASK/projects/EXAMPLE" "~/Projects/example-project/ai-task"
```

### 验证软链接

```bash
ls -la {PROJECT_ROOT}/ai-task
# 应显示指向 AI-TASK/projects/{PROJECT} 的链接
```

### 移除软链接

```bash
rm {PROJECT_ROOT}/ai-task  # 只删除链接，不影响原文件
```

---

## 🚀 AI 协作流程

### 新对话初始化

```
请加载 AI-TASK 协作规范：
- 项目: {PROJECT}
- 规范路径: ai-task/
```

### 创建任务

```
创建任务：
- 项目: {PROJECT}
- 标签: [功能]
- 名称: XXX
- 目标: 1. xxx 2. xxx
```

### 更新任务状态

```
更新任务 20260110-001：
- 状态: ✅ 已完成
- 总结: xxx
```

### 生成日报

```
生成今日日报
```

---

## 📊 目录自动发现

AI-TASK 不在根目录维护项目列表，而是通过以下方式发现项目：

```bash
# 列出所有项目
ls -d projects/*/

# 列出所有规则
ls rules/*.md

# 列出所有技能
ls -d skills/*/
```

子项目的 `project.yaml` 和 `index.md` 是入口，包含该项目的所有元信息。

---

## 🔄 版本历史

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.0.0 | 2026-01-10 | 首个开源版本：多 IDE 支持、软链接架构、Skills/Rules 系统 |
