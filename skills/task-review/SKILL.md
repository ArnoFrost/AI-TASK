---
name: task-review
description: |
  AI-TASK 单视角评审 — 对方案/规范/代码进行结构化评审，输出 Obsidian 格式报告。
  Use when: 评审方案、评审规范、评审代码、启动评审、review、task-review
user_invocable: true
license: MIT
metadata:
  author: ArnoFrost
  version: 1.0.0
---

# 单视角评审 (AI-TASK Review)

> 对评审对象进行结构/可执行性/风险合一的单视角评审，输出统一行动计划

## 触发条件

| 条件 | 示例 |
|------|------|
| 评审方案/规范/代码 | "评审这个技术方案"、"Review 这份规范" |
| 用户明确要求 | "启动评审"、`/task-review` |

## 执行流程

```
1. 读取评审对象（文件/代码/方案）
2. 项目探测（可选）
3. 单视角评审（结构 + 可执行性 + 风险合一）
4. 输出评审报告
5. 落盘后校验（如脚本存在）
```

### 项目探测

检查当前目录是否存在 `ai-task/` 目录（软链接或真实目录）：
- 若存在 → 读取 `ai-task/project.yaml`、`ai-task/index.md`、`ai-task/README.md` 作为评审背景
- 若不存在 → 跳过，按通用模式执行

## 评审维度

单次评审覆盖以下三个维度，不拆分角色：

| 维度 | 关注点 |
|------|--------|
| **结构与一致性** | 目录结构、命名规范、入口文件完整性、引用一致性 |
| **可执行性** | 行动项可落地性、验收标准明确性、依赖识别、优先级合理性 |
| **风险与边界** | 安全风险、范围漂移、过度工程化、向后兼容、依赖风险 |

## 输出契约

所有评审输出**必须**包含以下字段：

| 字段 | 说明 | 必需 |
|------|------|------|
| **TL;DR** | 结论摘要，<= 3 句 | 是 |
| **Findings** | 客观发现，每项带证据/引用。按 P0/P1/P2 分级 | 是 |
| **Actions** | 行动项（Owner/优先级/验收标准） | 是 |
| **Open Questions** | 未决问题（阻塞项、需补材料） | 按需 |

### Findings 分级标准

| 级别 | 含义 | 判断标准 |
|------|------|---------|
| **P0** | 阻塞级 | 安全问题、核心逻辑错误、阻塞后续工作 |
| **P1** | 重要 | 功能缺陷、设计不一致、用户体验显著影响 |
| **P2** | 改善 | 规范对齐、体验优化、可延后处理 |

## 产物格式

输出为单个 Markdown 文件，使用 Obsidian Flavored Markdown。

### 落盘后校验

写入产物文件后，若校验脚本存在则执行：

```bash
python3 {AI_TASK_PATH}/tools/validate_obsidian.py {output_file}
```

- 输出含 `[FAIL]` → 修复后重新写入
- 输出全为 `[PASS]` → 继续
- 脚本不存在 → 跳过，注明 `[校验跳过：validate_obsidian.py 未安装]`

## Obsidian 格式规范

### Frontmatter

```yaml
---
date: YYYY-MM-DD
status: done
type: 评审
tags:
  - review
---
```

### Callout 映射

| 语义 | Callout |
|------|---------|
| TL;DR | `> [!abstract] TL;DR` |
| P0 阻塞 | `> [!danger] P0-{编号}: {标题}` |
| P1 重要 | `> [!warning] P1-{编号}: {标题}` |
| P2 改善 | `> [!note]- P2-{编号}: {标题}`（折叠） |
| 行动计划 | `> [!tip] Actions` |
| 最终结论 | `> [!success] 结论` |

### 格式原则

- 每个章节最多 1-2 个 callout，不过度装饰
- 高亮 `==文本==` 每段最多 1-2 处
- 表格优于嵌套列表
- 中英文之间加空格
