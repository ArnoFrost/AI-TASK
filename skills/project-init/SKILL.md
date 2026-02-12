---
name: project-init
description: |
  初始化新项目的 AI 协作配置。创建项目目录结构、生成 project.yaml / index.md / README.md、配置软链接。
  Use when: 新建项目、初始化项目、配置项目、project init
---

# 项目初始化技能

## 🎯 能力范围

- 创建项目目录结构
- 生成项目配置文件（project.yaml）
- 生成项目索引（index.md + AI 规则块）
- 生成协作规范（README.md）
- 配置软链接
- 初始化子项目 Git

## 📐 项目结构

```
AI-TASK/projects/{PROJECT_CODE}/
├── project.yaml      # 项目元数据
├── index.md          # 项目入口（索引 + AI 规则）
├── README.md         # 协作规范（归档/约束）
├── tasks/            # 任务目录
│   └── .gitkeep
├── docs/             # 项目文档
│   └── .gitkeep
├── archive/          # 归档目录（按需创建）
│   └── YYYY-MM/
└── rules/            # 项目级规则（可选）
```

## 🔧 初始化步骤

### 输入信息

```yaml
project_code: XXX           # 项目代号（大写字母）
project_name: xxx           # 项目名称
local_path: /path/to/project  # 本地项目路径
tech_stack: Kotlin, ...     # 技术栈
description: 项目描述        # 简要描述
```

### 执行步骤

1. **创建目录结构**
   ```bash
   mkdir -p projects/{CODE}/tasks
   mkdir -p projects/{CODE}/docs
   touch projects/{CODE}/tasks/.gitkeep
   touch projects/{CODE}/docs/.gitkeep
   ```

2. **生成 project.yaml**
   - 使用项目模板
   - 填充项目信息
   - 配置 task_naming.format: "full"

3. **生成 index.md**（索引 + AI 规则）
   - 包含 AI-AUTO-TASK 规则块
   - 强调**全局递增编号**
   - 任务列表区域

4. **生成 README.md**（协作规范）
   - 归档规则（近3天 + 进行中）
   - 约束条件（行数/文件数/大小）
   - 命名格式说明

5. **配置软链接**（如需关联外部项目）
   ```bash
   ln -s "AI-TASK/projects/{CODE}" "{LOCAL_PATH}/ai-task"
   ```

6. **初始化子项目 Git**（推荐）
   ```bash
   cd projects/{CODE} && git init && git add . && git commit -m "init: {CODE} project"
   ```

## 📋 index.md 模板

```markdown
<ai-task-context project="{CODE}">

## 自动行为（无需用户指令）
1. **阅读任务列表** - 了解当前进度，避免重复工作
2. **自动创建任务** - 用户描述需求时，自动生成任务文档到 tasks/
3. **自动命名编号** - 格式: {DATE}-{SEQ}_[标签]名称.md，用户无需关心
4. **自动更新状态** - 任务完成后更新本文件任务列表

## 任务文档自动生成规则
- 文件名: YYYYMMDD-NNN_[标签]任务名.md (AI自动生成)
- 标签: 根据任务内容自动判断（详见 ../../SPEC.md#标签类型）
- 编号: **全局递增，不按日期重置**，取 tasks/ 目录最大 NNN + 1

## 用户只需要
- 描述要做什么（自然语言）
- AI 自动完成：创建任务 → 执行 → 更新状态 → 提交

规范详见：../../SPEC.md

</ai-task-context>

# {PROJECT_NAME}

> {DESCRIPTION}

## 📌 项目信息

| 属性 | 值 |
|------|-----|
| **项目代号** | {CODE} |
| **本地路径** | 见 [project.yaml](./project.yaml) |
| **主要技术栈** | {TECH_STACK} |
| **创建时间** | {DATE} |

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
- [协作规范](./README.md)
- [全局规范](../../SPEC.md)
```

## 📋 README.md 模板

```markdown
# {CODE} AI 任务入口

> 本目录通过软链接接入 iCloud AI-TASK 管理中心

## 📂 目录说明

| 目录/文件 | 说明 |
|-----------|------|
| `index.md` | 项目入口，仅展示近3天任务 |
| `tasks/` | 活跃任务目录（近3天） |
| `archive/` | 归档任务目录（3天前） |
| `docs/` | 项目文档目录 |

## 📜 AI 协作规范

### 1. 自动归档规则

- `tasks/` 仅保留**近3天**的任务文件
- 超过3天的任务自动移至 `archive/YYYY-MM/`

### 2. 规范自约束

| 约束项 | 规则 |
|--------|------|
| index.md 行数 | ≤ 80 行 |
| tasks/ 文件数 | ≤ 15 个 |
| 单任务文件大小 | ≤ 30KB |

### 3. 任务命名格式

```
{日期}-{序号}_[标签]任务名称.md
```

**编号规则**：全局递增（跨日期），查看 tasks/ 目录最大编号 +1
```

## 🔑 关键规则

| 规则 | 说明 |
|------|------|
| **全局递增编号** | 任务编号跨日期递增，不按天重置 |
| **README vs index** | README 是规范，index 是索引 |
| **子仓独立 Git** | 各子项目独立 Git 管理，主仓只保留 EXAMPLE |
