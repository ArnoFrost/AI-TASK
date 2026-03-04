<ai-task-context project="AI-TASK">
项目: AI-TASK | 规范: ./README.md | 全局规范: ../../SPEC.md
自动行为: 创建任务 → 执行 → 更新 index.md → 归档
约束: 严格遵循 README.md 中的命名/标签/归档规范，不创造新标签
skills:
  - agent-team-review
  - complex-task-workspace
</ai-task-context>

# AI-TASK

> 跨平台、跨设备 AI 协作路书系统

## 📌 项目信息

| 属性 | 值 |
|------|-----|
| **项目代号** | AI-TASK |
| **本地路径** | 见 [project.yaml](./project.yaml) |
| **主要技术栈** | Markdown, Shell, Skills/Rules 扩展机制 |
| **创建时间** | 2025-01-04 |
| **当前版本** | v1.3.0 |

---

## 🎯 项目定位

**核心价值**：为多项目 AI 协作提供统一的任务管理、知识沉淀和规范约束框架。

**设计理念**：
- **去中心化** - 子项目自治，根目录不维护项目列表
- **渐进式加载** - Skills/Rules 按需加载，减少上下文消耗
- **软链接集成** - 不侵入原项目，通过软链接接入
- **跨设备同步** - 基于云存储实现多设备协作
- **多 IDE 支持** - 支持 Claude Code 和 CodeBuddy

---

## 🏗️ 项目结构

```
AI-TASK/
├── README.md                    # 快速入门
├── SPEC.md                      # 完整规范文档
├── CODEBUDDY.md                 # CodeBuddy 入口
├── init-project.sh              # 项目初始化脚本
├── projects/                    # 项目空间
│   ├── AI-TASK/                 # 本项目 (自治)
│   └── EXAMPLE/                 # 示例项目
├── skills/                      # 核心能力层（agentskills.io 格式）
├── rules/                       # 规则库
├── templates/
│   ├── shared-commands/         # 共享命令（IDE 无关）
│   ├── claude/                  # Claude Code 适配
│   └── codebuddy/               # CodeBuddy 适配
└── archive/                     # 全局归档
```

---

## 📋 任务列表

> 本项目演进任务在本地管理，不公开到开源仓库

### 进行中 🔄

- [20260227-005_[梳理]Next版本远景与泛化能力模板规划](./tasks/20260227-005_[梳理]Next版本远景与泛化能力模板规划.md)

### 最近完成 ✅

- [20260227-006_[评审]Next版本演进方案双视角评审](./tasks/20260227-006_[评审]Next版本演进方案双视角评审.md)
- [20260212-004_[评审]AI-TASK开源项目专项评估](./tasks/20260212-004_[评审]AI-TASK开源项目专项评估.md)
- [20260203-003_[架构]Skill统一与多IDE适配层演进](./tasks/20260203-003_[架构]Skill统一与多IDE适配层演进.md)

---

## 📂 子项目概览

| 项目 | 状态 | 技术栈 | 说明 |
|------|------|--------|------|
| EXAMPLE | 🟢 活跃 | TypeScript, React | 示例项目（公开） |

---

## 🔗 快捷链接

- [快速入门](../../README.md)
- [完整规范](../../SPEC.md)
- [技能库](../../skills/README.md)
- [规则库](../../rules/README.md)
- [模板库](../../templates/)

---

## 📊 统计信息

| 统计项 | 数量 |
|--------|------|
| 技能数 | 7 |
| 共享命令 | 4 |
| 模板数 | 10+ |

---

## 📝 版本历史

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.3.0 | 2026-02-03 | 三层架构、init_sub_project 增强、全局编号 |
| v1.2.0 | 2026-01-12 | README 极客化、开源规范完善 |
| v1.1.0 | 2026-01-11 | 任务命名可配置化、模板同步机制 |
| v1.0.0 | 2026-01-10 | 首个开源版本 |

---

*最后更新: 2026-02-03*
