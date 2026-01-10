# AI Skills 技能库

> 对齐 [agentskills.io](https://agentskills.io/specification) 官方规范的渐进式加载技能系统

## 🎯 设计理念

Skills 是包含指令、模板和规则的模块化单元，AI 可以按需加载这些技能来提高特定任务的执行质量。

### 核心特性

- **渐进式加载**：元数据 ~100 tokens，指令 <5000 tokens
- **模块化设计**：每个技能独立自包含，可单独更新
- **官方兼容**：对齐 agentskills.io 规范，兼容 Claude Code 等工具
- **可扩展性**：支持自定义技能扩展

## 📂 技能列表

| 技能 | 说明 |
|------|------|
| [task-management](./task-management/SKILL.md) | 任务创建、更新、查询 |
| [project-init](./project-init/SKILL.md) | 项目初始化 |
| [git-minimal-commit](./git-minimal-commit/SKILL.md) | 代码变动整理 |

## 🔧 使用方式

### 自动激活

当对话中出现技能描述的触发场景时，AI 应自动加载对应技能：

```
用户: 帮我创建一个新任务
AI: [加载 task-management 技能] 好的，请提供以下信息...
```

### 手动激活

```
用户: @skill task-management
AI: [已加载任务管理技能]
```

### 查看可用技能

```
用户: 查看可用技能
AI: [列出 skills/ 目录下所有技能]
```

## 📐 SKILL.md 格式 (v2)

对齐 [agentskills.io/specification](https://agentskills.io/specification)：

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

## 🎯 能力范围
...

## 🔧 操作指令
...

## 📋 模板
...
```

### 字段说明

| 字段 | 必需 | 约束 |
|------|------|------|
| `name` | ✅ | 1-64字符，小写+连字符，与目录名一致 |
| `description` | ✅ | 1-1024字符，含触发场景 |
| `license` | ⚪ | 许可证 |
| `compatibility` | ⚪ | 环境要求 |
| `metadata` | ⚪ | 扩展元数据 |

### 渐进式加载

| 阶段 | 内容 | Token 预算 |
|------|------|-----------|
| 启动 | name + description | ~100 |
| 激活 | SKILL.md 全文 | <5000 |
| 按需 | scripts/references | 无限制 |

## 📁 目录结构

```
skills/
├── {skill-name}/
│   ├── SKILL.md              # 必需
│   ├── scripts/              # 可选：脚本
│   ├── references/           # 可选：参考文档
│   └── assets/               # 可选：静态资源
```

## 🆕 创建新技能

1. 在 `skills/` 下创建技能目录（小写+连字符）
2. 创建 `SKILL.md` 文件
3. 填写 YAML 前置元数据（name, description 必需）
4. 编写技能指令和模板
5. 更新本文件的技能列表

## 🔗 相关链接

- [agentskills.io 规范](https://agentskills.io/specification)
- [anthropics/skills](https://github.com/anthropics/skills)
- [全局规范](../SPEC.md)
