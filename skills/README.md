# AI Skills 规范参考

> 仓库 `skills/` 保留 SKILL.md 编写规范和开源可用的精简技能。
> 高级可执行技能通过个人技能库（如 `my-claude-skills/`）管理。

## 开源技能

| 技能 | 触发 | 说明 |
|------|------|------|
| task-review | `/task-review` | 单视角评审（结构/可执行性/风险合一） |
| task-init | `/task-init` | 项目初始化 / 规范对齐 |

### 安装到 IDE

使用 `install-skills.sh` 将开源技能注入到各 IDE 全局目录：

```bash
# 交互式选择注入哪些 IDE
./install-skills.sh

# 注入全部已安装的 IDE
./install-skills.sh --all

# 查看已注入状态
./install-skills.sh --list

# 清理已注入的 symlink
./install-skills.sh --remove
```

支持的 IDE：claude、claude-internal、codebuddy、codex、gemini。

## SKILL.md 格式

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

## 推荐个人技能

| 技能 | 触发 | 说明 |
|------|------|------|
| ai-task-review | `/ai-task-review` | 多角色协作评审（总分总结构，增强版） |
| ai-task-init | `/ai-task-init` | 项目初始化（增强版，含 vault 路径探测） |
| ai-task-sync | `/ai-task-sync` | 增量同步已有项目到最新规范 |
| commit | `/commit` | Conventional Commits 提交 |

## 相关链接

- [agentskills.io 规范](https://agentskills.io/specification)
- [全局规范](../SPEC.md)
- [install-skills.sh](../install-skills.sh) — 全局注入脚本
