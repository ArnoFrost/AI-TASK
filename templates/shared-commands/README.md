# 共享命令库

> IDE 无关的命令定义，供 Claude Code / CodeBuddy 等 IDE 引用

## 📂 命令列表

| 命令 | 说明 | 引用技能 |
|------|------|----------|
| [task.md](./task.md) | 任务管理 | skills/task-management |
| [init_sub_project.md](./init_sub_project.md) | 初始化子项目 | skills/project-init |
| [archive.md](./archive.md) | 归档任务 | skills/task-management |
| [status.md](./status.md) | 查看状态 | - |

## 🔧 设计原则

1. **IDE 无关**：命令逻辑与 IDE 适配分离
2. **引用技能**：命令应引用 skills/ 中的能力定义
3. **统一维护**：避免 claude/ 和 codebuddy/ 重复

## 📐 命令模板格式

```markdown
执行 XXX 操作。

## 用户输入
$ARGUMENTS

## 执行规范
详见：[skills/{skill-name}/SKILL.md](../../skills/{skill-name}/SKILL.md)

## 操作流程
1. ...
2. ...
```

## 🔗 IDE 适配层

各 IDE 的 commands/ 目录应引用本目录：

```
templates/
├── shared-commands/          # 命令定义（本目录）
├── claude/
│   ├── CLAUDE.md             # IDE 入口
│   └── commands/             # 可选：IDE 特有命令
└── codebuddy/
    ├── CODEBUDDY.md
    └── commands/             # 可选：IDE 特有命令
```

