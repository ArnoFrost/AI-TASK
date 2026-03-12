# AI Skills 规范参考

> 仓库 `skills/` 仅保留纯规范参考文档，不含可执行逻辑。
> 可执行技能已迁移至个人技能库（如 `my-claude-skills/`）管理。

## 精简策略

AI-TASK 仓库定位为**模板/规范层**，可执行技能由个人技能库提供：

| 层级 | 职责 | 示例 |
|------|------|------|
| 仓库 `skills/` | 纯规范参考 | ddac-governance, complex-task-workspace |
| 个人技能库 | 可执行技能 | ai-task-review, ai-task-init, ai-task-sync, commit |

## 📂 规范参考列表

| 技能 | 说明 |
|------|------|
| [ddac-governance](./ddac-governance/SKILL.md) | DDAC 自治理协议 |
| [complex-task-workspace](./complex-task-workspace/SKILL.md) | 文件夹任务目录约定 |

## 推荐个人技能

| 技能 | 触发 | 说明 |
|------|------|------|
| ai-task-review | `/ai-task-review` | AI-TASK 工程专属多角色协作评审 |
| ai-task-init | `/ai-task-init` | 项目初始化 / 规范对齐 |
| ai-task-sync | `/ai-task-sync` | 增量同步已有项目到最新规范 |
| commit | `/commit` | Conventional Commits 提交 |

## 📐 SKILL.md 格式

对齐 [agentskills.io/specification](https://agentskills.io/specification)：

```yaml
---
name: skill-name                      # 必需：小写+连字符，与目录名一致
description: |                        # 必需：功能描述 + 触发场景
  技能功能描述。
  Use when: 触发词1、触发词2、触发词3
license: Apache-2.0                   # 可选
metadata:                             # 可选
  author: ""
  version: ""
---
```

## 🔗 相关链接

- [agentskills.io 规范](https://agentskills.io/specification)
- [全局规范](../SPEC.md)
