<div align="center">

# AI-TASK

**单人 · 多项目 · 跨设备的 AI 协作路书与任务管理系统（文件/模板驱动）**

[English](./README_EN.md) | 简体中文

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.1.0-green.svg)](CHANGELOG.md)

</div>

---

## 🎯 什么是 AI-TASK？

AI-TASK 是一套**面向 AI 协作的文件系统约定**：用统一的目录结构、任务模板、规则（Rules）与技能（Skills），把你在多个项目中的 AI 协作过程（目标、方案、验证、结论）沉淀为可复用的“路书”。

它特别适合：**你一个人同时维护多个项目**，并且会在多台设备之间切换（例如 iCloud/云盘同步），希望 AI 在任何项目里都能“按同一套路”创建任务、更新进度、查看状态。

### 核心特性

- **跨项目的协作空间**：每个项目在 `projects/{CODE}/` 下拥有独立的任务/文档/归档与元数据。
- **跨设备一致性**：`project.yaml` 支持多设备路径映射，你只要同步 `AI-TASK/` 目录即可。
- **无侵入接入现有项目**：通过 `ai-task/` 软链接把协作空间挂到你的项目根目录，AI 总能在固定位置找到上下文。
- **模板化让 AI 更稳定**：统一任务模板与命名规范，让 AI 输出更可控、可检索、可复用。
- **IDE/助手适配**：内置 CodeBuddy/Claude Code 的斜杠命令模板（`/task`、`/status`、`/archive` 等）。

### 适用 / 不适用

- **适用**：单人（或极小团队）、多项目并行、跨设备切换、愿意用 Markdown 记录方案/验证/总结。
- **不适用**：强依赖看板/通知/权限/指派的团队协作；需要在线平台级的统计与工作流编排。

---

## 🧠 核心概念（先理解这 3 个就够用了）

- **`projects/{CODE}/`**：每个项目的“协作空间”（任务、文档、归档、元数据）。你可以把它理解为：从主仓模板派生出来的项目空间，彼此隔离但共享同一套规范。
- **`ai-task/` 软链接**：挂载点。把 `projects/{CODE}/` 软链接到你的真实项目根目录下，AI 在任何项目里都能通过固定路径访问任务与规范。
- **`project.yaml` 跨设备路径**：记录同一项目在不同设备上的真实路径（按优先级排序），用于跨设备迁移与定位。

---

## 🚀 快速开始（3 分钟）

### 1. 克隆仓库

```bash
git clone https://github.com/ArnoFrost/AI-TASK.git ~/AI-TASK
```

### 2. 初始化一个项目协作空间

```bash
cd ~/AI-TASK
./init-project.sh MYAPP "我的应用" "/Users/xxx/Projects/myapp" "React, TypeScript"

# 或使用交互模式
./init-project.sh
```

这会创建：

- `projects/MYAPP/`（含 `project.yaml`、`index.md`、`tasks/`、`docs/`）
- 可选：在你的项目根目录生成 `ai-task/` 软链接
- 可选：生成 IDE 配置（Claude Code / CodeBuddy）

### 3. 在 AI 助手中使用命令

```
/task create [功能] 用户登录模块
/task list
/status
```

---

## 📐 架构设计

```mermaid
graph TB
    subgraph "AI-TASK 仓库"
        AITASK[AI-TASK/]
        PROJECTS[projects/]
        SKILLS[skills/]
        RULES[rules/]
        TEMPLATES[templates/]

        AITASK --> PROJECTS
        AITASK --> SKILLS
        AITASK --> RULES
        AITASK --> TEMPLATES

        subgraph "项目协作空间"
            P1[项目A/]
            P2[项目B/]
            P1 --> P1T[tasks/]
            P1 --> P1D[docs/]
            P2 --> P2T[tasks/]
            P2 --> P2D[docs/]
        end

        PROJECTS --> P1
        PROJECTS --> P2
    end

    subgraph "你的真实项目"
        EXT1[~/Projects/app-a/]
        EXT2[~/Projects/app-b/]

        EXT1 -.->|软链接| P1
        EXT2 -.->|软链接| P2
    end

    style AITASK fill:#e1f5fe
    style PROJECTS fill:#fff3e0
    style SKILLS fill:#f3e5f5
```

---

## 📂 目录结构

```text
AI-TASK/
├── README.md                 # 本文件
├── README_EN.md              # English version
├── SPEC.md                   # 完整规范
├── init-project.sh           # 项目初始化脚本
├── projects/                 # 项目协作空间目录
│   └── {PROJECT}/
│       ├── project.yaml      # 项目元数据（含跨设备路径）
│       ├── index.md          # 项目入口
│       ├── tasks/            # 任务文件
│       ├── docs/             # 文档目录
│       └── archive/          # 归档目录（可选）
├── skills/                   # AI 技能定义
├── rules/                    # 项目规则
├── templates/                # 模板库
│   ├── claude/               # Claude Code 模板
│   └── codebuddy/            # CodeBuddy 模板
└── .codebuddy/commands/      # CodeBuddy 斜杠命令
```

---

## 🔧 可用命令

| 命令 | 说明 |
|------|------|
| `/init_sub_project CODE` | 在仓库中创建新项目 |
| `/task create [标签] 名称` | 创建新任务 |
| `/task list` | 列出所有任务 |
| `/task done 编号` | 标记任务完成 |
| `/archive 编号` | 归档已完成任务 |
| `/status` | 查看项目状态 |

---

## 📋 任务标签

| 标签 | 用途 | 标签 | 用途 |
|------|------|------|------|
| `[功能]` | 新功能 | `[优化]` | 性能优化 |
| `[修复]` | Bug 修复 | `[排查]` | 问题分析 |
| `[文档]` | 文档编写 | `[调研]` | 技术调研 |
| `[技术方案]` | 方案设计 | `[规范]` | 规范制定 |

---

## 🔗 软链接工作原理

```mermaid
flowchart LR
    subgraph "你的项目"
        A[~/Projects/myapp/]
        B[ai-task/]
    end

    subgraph "AI-TASK"
        C[projects/MYAPP/]
        D[tasks/]
        E[docs/]
    end

    A --> B
    B -.->|软链接| C
    C --> D
    C --> E

    style B fill:#ffeb3b
```

初始化后，你的项目会有一个 `ai-task/` 软链接指向 `AI-TASK/projects/{CODE}/`。这样可以：

- AI 助手通过 `ai-task/tasks/` 访问任务文件
- 无侵入式集成（只有一个软链接）
- 在多个项目间复用同一套协作模板与规范

---

## 📖 文档

- [完整规范](./SPEC.md) - 系统完整规范
- [技能指南](./skills/) - 可用的 AI 技能
- [规则指南](./rules/) - 项目规则系统

---

## ⚠️ 已知局限（保持小而美）

- **跨设备同步的一致性**：尽量避免在两台设备上同时编辑同一个任务文件；如果云盘产生冲突副本，以任务编号为准手动合并。
- **软链接的跨平台差异**：macOS/Linux 体验最好；Windows 可能需要额外权限/模式。
- **这不是团队任务平台**：AI-TASK 更偏“个人工作台 + 路书沉淀”，不提供看板/权限/指派等平台能力。

---

## 🤝 贡献

欢迎贡献！请随时提交 Pull Request。

## 📄 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件。

## 📝 更新日志

查看 [CHANGELOG.md](CHANGELOG.md) 了解版本历史与更新内容。

---

<div align="center">

Made with ❤️ for AI-assisted development

</div>
