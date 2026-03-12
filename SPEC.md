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

```text
AI-TASK/                          # 协作中心 (iCloud 同步)
├── SPEC.md                       # 本规范文档
├── README.md                     # 快速入门
├── init-project.sh               # 项目初始化脚本（交互式多 IDE）
├── relink.sh                     # 软链接重建脚本
├── projects/                     # 项目空间
│   └── {PROJECT}/                # 子项目 (按代号命名)
│       ├── project.yaml          # 项目元数据
│       ├── index.md              # 项目入口
│       ├── tasks/                # 任务目录
│       ├── docs/                 # 文档目录
│       └── archive/              # 归档目录 (可选)
├── rules/                        # 规则库
│   └── {PROJECT}.md              # 项目规则
├── skills/                       # 规范参考（纯规范层）
│   └── {skill-name}/SKILL.md     # 规范定义
├── templates/                    # 核心模板库
│   ├── AGENT.md                  # 通用 AI 协作入口模板
│   ├── project.yaml              # 项目元数据模板
│   ├── project-index.md          # 项目入口模板
│   ├── task-template.md          # 任务模板
│   └── review-actions.yaml       # 评审行动项 schema
├── tools/                        # 工具脚本
├── temp/                         # 临时文件
└── archive/                      # 全局归档
```

---

## 📂 项目结构规范

### 子项目目录

每个子项目在 `projects/{PROJECT}/` 下包含：

```text
{PROJECT}/
├── project.yaml          # 必需：项目元数据 (v2)
├── index.md              # 必需：项目入口文档
├── tasks/                # 必需：任务文件目录
│   ├── {DATE}-{SEQ}_[TAG]NAME.md          # 单文件任务
│   └── {DATE}-{SEQ}_[TAG]NAME/            # 文件夹任务（预期产出 ≥2 文档）
│       ├── task_plan.md                   # 入口（必须，统一命名）
│       ├── task_1_{主题}.md               # 子文件，平铺根部
│       ├── task_2_{主题}.md
│       └── artifacts/ notes/ templog/    # 可选扩展子目录
├── docs/                 # 可选：项目文档
└── archive/              # 可选：已完成任务归档
    └── YYYY-MM/
```

### 文件夹任务约束

| 约束项 | 规则 |
|--------|------|
| `task_plan.md` 行数 | **≤ 300 行**，仅做"问题定义 + 分工 + 结论汇总" |
| 详细分析 | 拆到子文件 `task_{N}_{主题}.md` |
| 子文件数量 | ≤ 10 个 |
| 触发拆分 | 当 task_plan.md 超过 300 行时，必须拆分子文件 |

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

## 📄 任务文档 Frontmatter 规范

所有任务文档**必须**包含 YAML frontmatter，格式如下：

```yaml
---
date: 2026-03-04             # 创建日期 (YYYY-MM-DD)
status: done                 # 状态: todo | in-progress | done
type: 排查                    # 标签类型（与文件名标签一致，不含方括号）
tags:                        # 主题标签（可选，用于聚合检索）
  - MixVFP
  - 起播链路
related:                     # 关联任务编号（可选，支持跨项目引用）
  - "20260302-001"           # 同项目任务引用
  - "TVKMM/20260303-005"    # 跨项目任务引用
---
```

| 字段 | 必需 | 说明 |
|------|------|------|
| `date` | ✅ | 创建日期 |
| `status` | ✅ | `todo` / `in-progress` / `done` |
| `type` | ✅ | 对应文件名中的标签类型 |
| `tags` | ⚪ | 主题标签，用于 Dataview 聚合检索 |
| `related` | ⚪ | 关联任务编号，形成 task chain |

### `related` 字段语义

`related` 用于标记任务间的**松散关联**（因果、主题、依赖），不强制顺序：

```yaml
related:
  - "20260302-001"                    # 同项目任务引用（纯编号）
  - "TVKMM/20260303-005"             # 跨项目任务引用（项目代号/编号）
```

**使用建议**：
- 同一技术主题的任务链互相引用（如 MixVFP 系列排查 → 修复 → 评审）
- AI 可通过 Dataview 聚合同 `related` 链的任务，构建主题维度索引
- 不要求双向引用，单向标记即可（后续任务引用前序任务）

**约束规则**：
- AI 生成新任务时**必须**包含 frontmatter，忽略旧文件格式
- `status` 字段必须与 index.md 中的状态保持同步
- `tags` 中的主题标签用于构建模块维度索引

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

**编号规则**：
- 序号（NNN）**全局递增**，跨日期连续编号
- 新任务编号 = `tasks/` 目录下最大 NNN + 1
- 日期前缀 `YYYYMMDD` 记录创建日期，序号保证全局唯一
- 若目录为空则从 `001` 开始

**配置示例**（在 `project.yaml` 中）：

```yaml
task_naming:
  format: "full"           # full | date | simple | custom
  # pattern: "{DATE}-{NNN}_{TAG}{NAME}.md"  # 仅 custom 时使用
  # seq_digits: 3          # 序号位数，默认 3
```

### 标签类型

**核心标签**（必选 1 个，覆盖绝大多数场景）：

| 标签 | 说明 | 标签 | 说明 |
|------|------|------|------|
| `[功能]` | 新功能开发 | `[优化]` | 性能/体验优化 |
| `[修复]` | Bug 修复 | `[排查]` | 问题分析定位 |
| `[文档]` | 文档编写 | `[调研]` | 技术调研 |
| `[技术方案]` | 方案设计 | `[规范]` | 规范制定 |
| `[下线]` | 功能下线 | `[清理]` | 代码清理 |
| `[梳理]` | 逻辑梳理 | `[测试]` | 测试相关 |
| `[评审]` | 代码/方案评审 | `[架构]` | 架构设计/重构 |
| `[集成]` | 模块/系统集成 | `[同步]` | 技术摘要同步 |

**标签约束规则**：
- 每个任务**必须且只能使用 1 个**标签
- AI **不得自行创造**新标签，如遇无法归类的任务，使用最接近的核心标签
- 项目可在 `project.yaml` 中通过 `allowed_tags` 限定可用标签子集
- `[技术方案]` 不得简写为 `[方案]`，`[功能]` 不得替换为 `[任务]`

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

```text
skills/
├── {skill-name}/
│   ├── SKILL.md              # 必需
│   ├── scripts/              # 可选：脚本
│   ├── references/           # 可选：参考文档
│   └── assets/               # 可选：静态资源
```

### 规范参考（仓库内）

仓库 `skills/` 仅保留纯规范参考，不含可执行逻辑：

| 技能 | 说明 |
|------|------|
| ddac-governance | DDAC 自治理协议（纯规范） |
| complex-task-workspace | 文件夹任务目录约定（纯规范） |

### 推荐个人技能（外部）

可执行技能通过个人技能库（如 `my-claude-skills/`）管理，以下为推荐配套技能：

| 技能 | 触发 | 说明 |
|------|------|------|
| ai-task-review | `/ai-task-review` | AI-TASK 工程专属多角色协作评审 |
| ai-task-init | `/ai-task-init` | 项目初始化 / 规范对齐 |
| ai-task-sync | `/ai-task-sync` | 增量同步已有项目到最新规范 |
| commit | `/commit` | Conventional Commits 提交 |

### 项目级 skill 引用

项目可在 `index.md` 的 `<ai-task-context>` 中声明启用规范参考 skill：

```xml
<ai-task-context project="XXX">
...
skills:
  - complex-task-workspace
notes:
  - 评审使用个人技能 /ai-task-review
  - 项目对齐使用 /ai-task-init 或 /ai-task-sync
</ai-task-context>
```

**引用规则**：

| 场景 | 行为 |
|------|------|
| 声明了 `skills` | AI 在该项目上下文中自动激活对应规范参考 |
| `notes` 字段 | 提示用户使用对应个人技能 |
| 对话中触发词匹配 | 用户可通过 `/ai-task-review` 等斜杠命令直接调用 |

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

## 🔄 DDAC 自治理规范

> 基于 [DDAC 方法论](https://github.com/ArnoFrost/DDAC)，实现文档驱动的 AI 协作

### 核心理念

> "不是教 AI 做事，而是让 AI 学会自己理解规范"

| 能力 | 说明 |
|------|------|
| **自我理解** | AI 读取规范文档，理解工作标准和上下文 |
| **自主执行** | 根据规范自动推导执行步骤，无需反复指导 |
| **持续协作** | 跨会话保持上下文，任务接续无缝衔接 |
| **自我优化** | 通过反馈闭环，持续完善规范体系 |

### 自治理原则

| 规则 | 说明 |
|------|------|
| `projects/{PROJECT}/` | 项目自治空间，管理自身任务 |
| 项目代号 = 目录名 | 如 `projects/AI-TASK/` 管理 AI-TASK 自身 |
| 任务必须沉淀 | 讨论产生的计划 → `tasks/` 任务文档 |
| 状态必须更新 | 任务完成 → 更新 `index.md` 任务列表 |

### 自动化行为

**当用户引入 `projects/{PROJECT}/index.md` 后，AI 自动执行：**

| 行为 | 说明 |
|------|------|
| **自动创建任务** | 用户描述需求 → AI 自动生成任务文档 |
| **自动命名编号** | `{DATE}-{SEQ}_[标签]名称.md`，用户无需关心 |
| **自动判断标签** | 根据任务内容智能选择（详见[标签类型](#标签类型)） |
| **自动更新状态** | 任务完成 → 更新 `index.md` 任务列表 |

### 用户零摩擦体验

```
用户: "帮我实现用户登录功能"
  ↓ AI 自动
1. 创建 tasks/20260112-001_[功能]用户登录.md
2. 执行开发任务
3. 更新 index.md 任务状态
4. 提交代码（如需）
```

**用户只需要描述要做什么，其他全部自动化。**

### 任务沉淀触发条件

**以下情况 AI 自动创建任务文档（无需用户指令）：**

1. 用户引入 `projects/{PROJECT}/index.md` 上下文
2. 用户描述任何需要执行的工作
3. 讨论内容涉及代码修改
4. 用户说"帮我"、"实现"、"修复"、"优化"等动作词

### 路书四大法则

| 法则 | 说明 |
|------|------|
| **倒排原则** | 最新任务在前（时间倒序 + 优先级倒序） |
| **归档原则** | 完成后立即归档，活跃任务 ≤ 3 个 |
| **更新原则** | 进度实时更新，状态及时变更 |
| **格式标准** | 统一模板、唯一 ID、完整链接 |

---

## 🔧 项目初始化

### 方式一：脚本初始化

```bash
# 在 AI-TASK 目录下执行（交互模式，推荐）
./init-project.sh

# 或指定参数
./init-project.sh myapp --name "My App" --path "/path/to/myapp" --tech "React,TS"
```

脚本支持多 IDE 适配器选择（Claude Code / CodeBuddy / Cursor / 通用 AGENT.md）。

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

> 完整更新日志请查看 [CHANGELOG.md](./CHANGELOG.md)

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.5.0 | 2026-03-12 | 架构精简：templates 纯模板层、多 IDE 适配、AGENT.md、隐私修复 |
| v1.4.0 | 2026-03-04 | Frontmatter 规范、编号修正、AI 评审驱动演进 |
| v1.3.1 | 2026-02-12 | XML 标签升级、规范碎片化修复、EXAMPLE 完整生命周期 |
| v1.3.0 | 2026-02-03 | 三层架构、init_sub_project 增强、全局编号 |
| v1.2.0 | 2026-01-12 | README 极客化、.gitignore 通用化、开源规范优化 |
| v1.1.1 | 2026-01-11 | DDAC 关联说明、代码块语法统一 |
| v1.1.0 | 2026-01-11 | 任务命名可配置化、模板同步机制、斜杠命令版本控制 |
| v1.0.0 | 2026-01-10 | 首个开源版本：多 IDE 支持、软链接架构、Skills/Rules 系统 |
