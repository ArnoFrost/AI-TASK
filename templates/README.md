# 模板库

> AI-TASK 项目模板文件说明

## 🏗️ 三层架构

```
templates/
├── shared-commands/         # 🆕 共享命令层（IDE 无关）
│   ├── task.md              # 任务管理命令
│   ├── init_sub_project.md  # 初始化子项目
│   ├── archive.md           # 归档命令
│   └── status.md            # 状态查询
├── claude/                  # Claude Code 适配层
│   ├── CLAUDE.md            # IDE 入口文件
│   └── commands/            # IDE 特有命令（可选）
├── codebuddy/               # CodeBuddy 适配层
│   ├── CODEBUDDY.md         # IDE 入口文件
│   └── commands/            # IDE 特有命令（可选）
└── *.md / *.yaml            # 静态模板
```

### 设计原则

| 层级 | 职责 | 维护方式 |
|------|------|----------|
| **shared-commands/** | 命令逻辑（IDE 无关） | 统一维护 |
| **claude/** / **codebuddy/** | IDE 入口适配 | 按需定制 |
| **skills/** | 核心能力（agentskills.io） | 独立扩展 |

---

## 📂 模板列表

| 模板文件 | 用途 | 使用场景 |
|----------|------|----------|
| `project.yaml` | 项目元数据（完整版） | 需要高级配置时使用 |
| `project-minimal.yaml` | 项目元数据（精简版） | ⭐ 快速开始推荐 |
| `project-index.md` | 项目入口文档 | 项目 `index.md` 模板 |
| `task-template.md` | 任务文档 | 创建新任务时使用 |
| `daily-summary.md` | 日报模板 | 生成每日工作总结 |
| `project-config.md` | 配置说明 | 项目配置参考 |
| `project-rules.md` | 规则模板 | 项目规则定义 |
| `ai-prompt-guide.md` | AI 提示词指南 | AI 协作提示词参考 |

---

## 📁 共享命令

| 命令 | 说明 | 引用技能 |
|------|------|----------|
| [task.md](./shared-commands/task.md) | 任务创建/更新/完成 | skills/task-management |
| [init_sub_project.md](./shared-commands/init_sub_project.md) | 初始化子项目 | skills/project-init |
| [archive.md](./shared-commands/archive.md) | 归档任务 | skills/task-management |
| [status.md](./shared-commands/status.md) | 查看状态 | - |

---

## 📁 IDE 配置模板

| 目录 | 用途 | 入口文件 |
|------|------|----------|
| `claude/` | Claude Code 配置 | CLAUDE.md |
| `codebuddy/` | CodeBuddy 配置 | CODEBUDDY.md |

---

## 🚀 使用方式

### 初始化新项目

```bash
# 使用脚本自动初始化
./init-project.sh <PROJECT_CODE> "<PROJECT_NAME>" "<PROJECT_PATH>"

# 或手动复制模板
cp templates/project.yaml projects/{PROJECT}/
cp templates/project-index.md projects/{PROJECT}/index.md
```

### 创建任务

```bash
# 使用斜杠命令
/task create [功能] 用户登录模块

# 或手动复制模板（NNN 为全局递增，取 tasks/ 最大 NNN + 1）
cp templates/task-template.md projects/{PROJECT}/tasks/YYYYMMDD-NNN_[标签]名称.md
```

---

## 🔗 相关链接

- [全局规范](../SPEC.md)
- [技能库](../skills/README.md)
- [示例项目](../projects/EXAMPLE/)
