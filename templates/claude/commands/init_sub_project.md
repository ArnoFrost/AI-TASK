在 AI-TASK 大仓中创建新的子项目。

## 用户输入

$ARGUMENTS

## 参数解析

```
/init_sub_project <CODE> [--name NAME] [--tech TECH] [--path PATH]
```

| 参数 | 必需 | 说明 |
|------|------|------|
| `CODE` | ✅ | 项目代号（大写，如 MYAPP），或外部路径（自动提取最后一段作为 CODE） |
| `--name` | ⚪ | 项目名称，默认同代号 |
| `--tech` | ⚪ | 技术栈，逗号分隔 |
| `--path` | ⚪ | 关联的外部项目路径（可选） |
| `--help` | ⚪ | 显示帮助 |

## 执行流程

### 1. 前置校验

```yaml
checks:
  - name: 在 AI-TASK 大仓内
    action: 检查当前目录是否为 AI-TASK 仓库（存在 projects/ 和 SPEC.md）
    on_fail: "错误: 请在 AI-TASK 仓库根目录执行此命令"
    
  - name: CODE 冲突检测
    action: 检查 projects/{CODE} 是否已存在
    on_fail: "错误: 项目 '{CODE}' 已存在"
```

### 2. 创建项目结构

在 `projects/` 目录下创建：

```
projects/{CODE}/
├── project.yaml          # 项目元数据
├── index.md              # 项目入口（索引 + AI 规则）
├── README.md             # 协作规范（归档/约束）
├── tasks/                # 任务目录
│   └── .gitkeep
└── docs/                 # 文档目录
    └── .gitkeep
```

### 3. 生成 project.yaml

```yaml
# {CODE} 项目元数据

code: {CODE}
name: {NAME}

paths:
  - {PATH}  # 如果提供了 --path

# 任务命名配置
task_naming:
  format: "full"

tech_stack:
  - {TECH_1}
  - {TECH_2}

created: {TODAY}
status: active

tags: []

related: []

metadata:
  description: {NAME}

# 模板同步配置
sync:
  enabled: true
  strategy: "merge"
  locked_fields: []
```

### 4. 生成 index.md（索引 + AI 规则）

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

## 可选技能（取消注释以启用）
# skills:
#   - agent-team-review        # 多角色协作评审
#   - complex-task-workspace   # 复杂任务工作区

规范详见：../../SPEC.md

</ai-task-context>

# {NAME}

> {CODE} 项目

## 📌 项目信息

| 属性 | 值 |
|------|-----|
| **项目代号** | {CODE} |
| **本地路径** | 见 [project.yaml](./project.yaml) |
| **主要技术栈** | {TECH_STACK} |
| **创建时间** | {TODAY} |

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

### 5. 生成 README.md（协作规范）⚠️ 必须生成

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

## 🔗 快捷链接

- [项目入口](./index.md) - 查看近期任务
- [任务目录](./tasks/) - 活跃任务
- [归档目录](./archive/) - 历史任务
- [全局规范](../../README.md) - AI 协作规范

---

## 📜 AI 协作规范

### 1. 任务命名与结构

**统一编号格式**：`YYYYMMDD-NNN_[标签]任务名称`

编号**全局递增**（跨日期），查看 `tasks/` 目录最大编号 +1。

**标签**：根据任务内容自动判断 `[功能/优化/修复/排查/文档/调研/评审/专项]`

#### 1.1 单文件任务（简单任务）

适用于单次排查、单次分析等产出单一文档的任务。

    tasks/
    └── 20260211-003_[排查]某某问题分析.md

#### 1.2 文件夹任务（复杂/专项任务）

适用于多阶段、多角色评审、多文档产出的高内聚任务。
**编号格式与单文件任务完全一致**，只是后缀从 `.md` 变为目录。

    tasks/
    └── 20260226-001_[专项]某某专项/
        ├── task_plan.md          # 总体规划（必须）
        ├── task_1_xxx.md         # 子任务/评审报告（按需）
        ├── task_2_xxx.md
        └── ...

**文件夹任务规则**：

| 规则 | 说明 |
|------|------|
| 入口文件 | `task_plan.md` 必须存在，作为任务总览入口 |
| 子文件命名 | `task_{N}_{角色/主题}.md`，编号从 1 递增 |
| 内聚性 | 文件夹内所有文档围绕同一个任务主题 |
| index.md 引用 | 链接到文件夹目录即可（不需要链接每个子文件） |

#### 1.3 判断标准

| 条件 | 选择 |
|------|------|
| 预期产出 1 个文档 | 单文件任务 |
| 预期产出 ≥ 2 个文档，或涉及多阶段/多角色 | 文件夹任务 |
| 单文件任务演进为多文档 | 升级为文件夹任务（创建同名目录，原文件移入） |

### 2. 自动归档规则

**触发条件**：每次对话开始时，AI 应检查并执行归档

**归档策略**：
- `tasks/` 仅保留**近3天**的任务（文件或文件夹）
- 超过3天的任务自动移至 `archive/` 目录
- 归档按**年月**分组：`archive/YYYY-MM/`
- 文件夹任务整体归档（保持内部结构不变）

### 3. index.md 精简规则

**展示原则**：
- 仅展示**近3天**的任务列表
- 进行中任务始终展示（无论时间）
- 历史任务通过归档目录查看
- 文件夹任务链接到目录路径

### 4. 规范自约束

| 约束项 | 规则 |
|--------|------|
| index.md 行数 | ≤ 80 行 |
| tasks/ 条目数 | ≤ 15 个（文件 + 文件夹各算 1 个） |
| 单任务文件大小 | ≤ 30KB |
| 文件夹任务子文件数 | ≤ 10 个 |
| 归档检查频率 | 每次对话开始 |

---

## 🏷️ 项目信息

- **项目代号**: {CODE}
- **技术栈**: {TECH_STACK}
- **活跃任务**: tasks/ 目录
- **归档任务**: archive/ 目录
```

### 6. 建立软链接（如提供了 --path）

如果用户提供了 `--path` 参数，在外部项目目录创建软链接：

```bash
# 在外部项目创建 ai-task 软链接，指向 AI-TASK 大仓中的项目目录
ln -s /path/to/AI-TASK/projects/{CODE} {PATH}/ai-task
```

**软链接说明**：
- 软链接名称固定为 `ai-task`
- 软链接指向 `projects/{CODE}` 目录
- 外部项目通过 `ai-task/` 访问任务和文档

### 7. 初始化子项目 Git（推荐）

```bash
cd projects/{CODE} && git init && git add . && git commit -m "init: {CODE} project"
```

### 8. 输出结果

```
✅ 项目 {CODE} 创建完成!

创建的文件:
  - projects/{CODE}/project.yaml    # 项目元数据
  - projects/{CODE}/index.md        # 项目入口
  - projects/{CODE}/README.md       # 协作规范
  - projects/{CODE}/tasks/.gitkeep
  - projects/{CODE}/docs/.gitkeep

关联路径:
  - {PATH}  (如果提供了 --path)

下一步:
  1. 编辑 projects/{CODE}/project.yaml 补充技术栈等项目信息
  2. 使用 /task create 创建任务
  3. 如需在外部项目目录建立软链接，运行 ./init-project.sh
```

## 帮助信息

```
/init_sub_project 命令用法:

  /init_sub_project <CODE>                    创建新项目
  /init_sub_project <CODE> --name NAME        指定项目名称
  /init_sub_project <CODE> --tech "A, B"      指定技术栈
  /init_sub_project <CODE> --path /path/to    关联外部路径并建立软链接
  /init_sub_project /path/to/project          从路径提取 CODE 并关联

示例:
  /init_sub_project MYAPP
  /init_sub_project MYAPP --name "我的应用" --tech "React, TypeScript"
  /init_sub_project DEMO --path ~/Projects/demo
  /init_sub_project /Users/xuxin/Desktop/Geek/AI/Animate/DemoGLTF
```
